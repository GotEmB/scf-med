clone = require "clone"
CommitCache = require "./commit-cache"
constants = require "../constants"
escapeStringRegexp = require "escape-string-regexp"
DateRangeInput = require "./date-range-input"
EditVital = require "./edit-vital"
Layers = require "./layers"
moment = require "moment"
nextTick = require "next-tick"
vitalsCalls = require("../async-calls/vitals").calls
VitalsTable = require "./vitals-table"
React = require "react"

class module.exports extends React.Component
  @displayName: "VitalsView"

  constructor: ->
    @state =
      filterQuery: ""
      queryStartDate: moment().subtract(3, "month").toDate()
      queryEndDate: moment().endOf("day").toDate()
      vitals: []
      selectedVital: undefined
      loadFrom: 0
      total: 0
      loading: false
      layer: undefined

  fetchVitals: =>
    @setState loading: true
    query =
      text: @state.filterQuery
      daterange:
        from: @state.queryStartDate
        to: @state.queryEndDate
    vitalsCalls.getVitals query, @state.loadFrom,
      constants.paginationLimit, (err, vitals, total) =>
        @setState
          vitals: vitals
          total: total
          loading: false

  handleFilterQueryChanged: (e) =>
    @setState
      filterQuery: e.target.value
      loadFrom: 0
    clearTimeout @filterQueryChangeTimer if @filterQueryChangeTimer?
    @filterQueryChangeTimer = setTimeout @fetchVitals, 200

  handleQueryDateRangeChanged: ({startDate, endDate}) =>
    @setState
      queryStartDate: startDate
      queryEndDate: endDate
    clearTimeout @filterQueryChangeTimer if @filterQueryChangeTimer?
    @filterQueryChangeTimer = setTimeout @fetchVitals, 200

  handleNewVitalClicked: =>
    layer =
      <CommitCache
        component={EditVital}
        data={undefined}
        dataProperty="vital"
        commitMethod={vitalsCalls.commitVital}
        removeMethod={vitalsCalls.removeVital}
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, "New Vital"

  handlePagerPreviousClicked: =>
    @setState
      loadFrom:
        Math.max 0, @state.loadFrom - constants.paginationLimit
    nextTick @fetchVitals

  handlePagerNextClicked: =>
    @setState
      loadFrom:
        Math.min @state.total - constants.paginationLimit,
          @state.loadFrom + constants.paginationLimit
    nextTick @fetchVitals

  handleVitalClicked: (vital) =>
    layer =
      <CommitCache
        component={EditVital}
        data={vital}
        dataProperty="vital"
        commitMethod={vitalsCalls.commitVital}
        removeMethod={vitalsCalls.removeVital}
        onDismiss={@handleLayerDismissed}
      />
    @setState
      selectedVital: vital
      layer: layer
    Layers.addLayer layer, "Edit Vital"

  handleLayerDismissed: ({status}) =>
    Layers.removeLayer @state.layer
    @setState
      selectedVital: undefined
      layer: undefined
    @fetchVitals() if status in ["saved", "removed"]

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
        onClick={@handleNewVitalClicked}>
        <i className="fa fa-pencil" /> New Vital
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
      if @state.loadFrom + @state.vitals.length < @state.total
        <button
          className="btn btn-default"
          onClick={@handlePagerNextClicked}>
          <i className="fa fa-chevron-right" />
        </button>
    text =
      "#{@state.loadFrom + 1}—" +
      "#{@state.loadFrom + @state.vitals.length} of " +
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
      <VitalsTable
        vitals={@state.vitals}
        selectedVital={@state.selectedVital}
        onVitalClick={@handleVitalClicked}
      />
    </div>

  componentDidMount: ->
    @fetchVitals()

  componentWillUnmount: ->
    Layers.removeLayer @state.layer if @state.layer?
