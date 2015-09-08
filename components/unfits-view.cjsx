clone = require "clone"
CommitCache = require "./commit-cache"
constants = require "../constants"
escapeStringRegexp = require "escape-string-regexp"
DateRangeInput = require "./date-range-input"
EditUnfit = require "./edit-unfit"
Layers = require "./layers"
moment = require "moment"
nextTick = require "next-tick"
unfitsCalls = require("../async-calls/unfits").calls
UnfitsTable = require "./unfits-table"
React = require "react"

class module.exports extends React.Component
  @displayName: "UnfitsView"

  constructor: ->
    @state =
      filterQuery: ""
      queryStartDate: moment().subtract(3, "month").toDate()
      queryEndDate: moment().endOf("day").toDate()
      unfits: []
      selectedUnfit: undefined
      loadFrom: 0
      total: 0
      loading: false
      layer: undefined

  fetchUnfits: =>
    @setState loading: true
    query =
      text: @state.filterQuery
      daterange:
        from: @state.queryStartDate
        to: @state.queryEndDate
    unfitsCalls.getUnfits query, @state.loadFrom,
      constants.paginationLimit, (err, unfits, total) =>
        @setState
          unfits: unfits
          total: total
          loading: false

  handleFilterQueryChanged: (e) =>
    @setState
      filterQuery: e.target.value
      loadFrom: 0
    clearTimeout @filterQueryChangeTimer if @filterQueryChangeTimer?
    @filterQueryChangeTimer = setTimeout @fetchUnfits, 200

  handleQueryDateRangeChanged: ({startDate, endDate}) =>
    @setState
      queryStartDate: startDate
      queryEndDate: endDate
    clearTimeout @filterQueryChangeTimer if @filterQueryChangeTimer?
    @filterQueryChangeTimer = setTimeout @fetchUnfits, 200

  handleNewUnfitClicked: =>
    layer =
      <CommitCache
        component={EditUnfit}
        data={undefined}
        dataProperty="unfit"
        commitMethod={unfitsCalls.commitUnfit}
        removeMethod={unfitsCalls.removeUnfit}
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, "New Unfit"

  handlePagerPreviousClicked: =>
    @setState
      loadFrom:
        Math.max 0, @state.loadFrom - constants.paginationLimit
    nextTick @fetchUnfits

  handlePagerNextClicked: =>
    @setState
      loadFrom:
        Math.min @state.total - constants.paginationLimit,
          @state.loadFrom + constants.paginationLimit
    nextTick @fetchUnfits

  handleUnfitClicked: (unfit) =>
    layer =
      <CommitCache
        component={EditUnfit}
        data={unfit}
        dataProperty="unfit"
        commitMethod={unfitsCalls.commitUnfit}
        removeMethod={unfitsCalls.removeUnfit}
        onDismiss={@handleLayerDismissed}
      />
    @setState
      selectedunfit: unfit
      layer: layer
    Layers.addLayer layer, "Edit Unfit"

  handleLayerDismissed: ({status}) =>
    Layers.removeLayer @state.layer
    @setState
      selectedUnfit: undefined
      layer: undefined
    @fetchUnfits() if status in ["saved", "removed"]

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
        onClick={@handleNewUnfitClicked}>
        <i className="fa fa-pencil" /> New Unfit
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
      if @state.loadFrom + @state.unfits.length < @state.total
        <button
          className="btn btn-default"
          onClick={@handlePagerNextClicked}>
          <i className="fa fa-chevron-right" />
        </button>
    text =
      "#{@state.loadFrom + 1}—" +
      "#{@state.loadFrom + @state.unfits.length} of " +
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
      <UnfitsTable
        unfits={@state.unfits}
        selectedUnfit={@state.selectedUnfit}
        onUnfitClick={@handleUnfitClicked}
      />
    </div>

  componentDidMount: ->
    @fetchUnfits()

  componentWillUnmount: ->
    Layers.removeLayer @state.layer if @state.layer?
