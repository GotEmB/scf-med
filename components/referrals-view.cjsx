clone = require "clone"
CommitCache = require "./commit-cache"
constants = require "../constants"
escapeStringRegexp = require "escape-string-regexp"
DateRangeInput = require "./date-range-input"
EditReferral = require "./edit-referral"
Layers = require "./layers"
moment = require "moment"
nextTick = require "next-tick"
referralsCalls = require("../async-calls/referrals").calls
ReferralsTable = require "./referrals-table"
React = require "react"

class module.exports extends React.Component
  @displayName: "ReferralsView"

  constructor: ->
    @state =
      filterQuery: ""
      queryStartDate: moment().subtract(3, "month").toDate()
      queryEndDate: moment().endOf("day").toDate()
      referrals: []
      selectedReferral: undefined
      loadFrom: 0
      total: 0
      loading: false
      layer: undefined

  fetchReferrals: =>
    @setState loading: true
    query =
      text: @state.filterQuery
      daterange:
        from: @state.queryStartDate
        to: @state.queryEndDate
    referralsCalls.getReferrals query, @state.loadFrom,
      constants.paginationLimit, (err, referrals, total) =>
        @setState
          referrals: referrals
          total: total
          loading: false

  handleFilterQueryChanged: (e) =>
    @setState
      filterQuery: e.target.value
      loadFrom: 0
    clearTimeout @filterQueryChangeTimer if @filterQueryChangeTimer?
    @filterQueryChangeTimer = setTimeout @fetchReferrals, 200

  handleQueryDateRangeChanged: ({startDate, endDate}) =>
    @setState
      queryStartDate: startDate
      queryEndDate: endDate
    clearTimeout @filterQueryChangeTimer if @filterQueryChangeTimer?
    @filterQueryChangeTimer = setTimeout @fetchReferrals, 200

  handleNewReferralClicked: =>
    layer =
      <CommitCache
        component={EditReferral}
        data={undefined}
        dataProperty="referral"
        commitMethod={referralsCalls.commitReferral}
        removeMethod={referralsCalls.removeReferral}
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, "New Referral"

  handlePagerPreviousClicked: =>
    @setState
      loadFrom:
        Math.max 0, @state.loadFrom - constants.paginationLimit
    nextTick @fetchReferrals

  handlePagerNextClicked: =>
    @setState
      loadFrom:
        Math.min @state.total - constants.paginationLimit,
          @state.loadFrom + constants.paginationLimit
    nextTick @fetchReferrals

  handleReferralClicked: (referral) =>
    layer =
      <CommitCache
        component={EditReferral}
        data={referral}
        dataProperty="referral"
        commitMethod={referralsCalls.commitReferral}
        removeMethod={referralsCalls.removeReferral}
        onDismiss={@handleLayerDismissed}
      />
    @setState
      selectedReferral: referral
      layer: layer
    Layers.addLayer layer, "Edit Referral"

  handleReferralRoutineClicked: (referral) =>
    duplicateReferral = clone referral
    delete duplicateReferral._id
    duplicateReferral.date = moment().toISOString()
    layer =
      <CommitCache
        component={EditReferral}
        data={duplicateReferral}
        dataProperty="referral"
        commitMethod={referralsCalls.commitReferral}
        removeMethod={referralsCalls.removeReferral}
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, "Duplicate Referral"

  handleLayerDismissed: ({status}) =>
    Layers.removeLayer @state.layer
    @setState
      selectedReferral: undefined
      layer: undefined
    @fetchReferrals() if status in ["saved", "removed"]

  renderLeftControls: ->
    <div className="form-inline pull-left">
      <div className="input-group">
        <span className="input-group-addon">
          <i className="fa fa-filter" />
        </span>
        <input
          type="text"
          className="form-control"
          value={@state.filterQuery}
          placeholder="Filter"
          onChange={@handleFilterQueryChanged}
        />
      </div>
      <span> </span>
      <div className="input-group">
        <span className="input-group-addon">
          <i className="fa fa-calendar" />
        </span>
        <DateRangeInput
          className="form-control"
          style={width: 200}
          startDate={@state.queryStartDate}
          endDate={@state.queryEndDate}
          onDateRangeChange={@handleQueryDateRangeChanged}
        />
      </div>
      <span> </span>
      <button
        className="btn btn-default"
        onClick={@handleNewReferralClicked}>
        <i className="fa fa-pencil" /> New Referral
      </button>
      <span> </span>
    </div>

  renderRightControls: ->
    loader =
      if @state.loading
        <button className="btn btn-link" disabled style={color: "inherit"}>
          <i className="fa fa-circle-o-notch fa-spin fa-fw" />
        </button>
    leftButton =
      if @state.loadFrom > 0
        <button
          className="btn btn-default"
          onClick={@handlePagerPreviousClicked}>
          <i className="fa fa-chevron-left" />
        </button>
    rightButton =
      if @state.loadFrom + @state.referrals.length < @state.total
        <button
          className="btn btn-default"
          onClick={@handlePagerNextClicked}>
          <i className="fa fa-chevron-right" />
        </button>
    text =
      "#{@state.loadFrom + 1}—" +
      "#{@state.loadFrom + @state.referrals.length} of " +
      "#{@state.total}"
    <div className="pull-right">
      <div className="pull-right btn-group">
        {loader}
        {leftButton}
        <button className="btn btn-default" disabled>{text}</button>
        {rightButton}
      </div>
    </div>

  renderControls: ->
    <div>
      {@renderLeftControls()}
      {@renderRightControls()}
      <div className="clearfix" />
    </div>

  render: ->
    <div>
      {@renderControls()}
      <br />
      <ReferralsTable
        referrals={@state.referrals}
        selectedReferral={@state.selectedReferral}
        onReferralClick={@handleReferralClicked}
        onReferralRoutineClick={@handleReferralRoutineClicked}
      />
    </div>

  componentDidMount: ->
    @fetchReferrals()

  componentWillUnmount: ->
    Layers.removeLayer @state.layer if @state.layer?
