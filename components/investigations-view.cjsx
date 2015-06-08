clone = require "clone"
CommitCache = require "./commit-cache"
constants = require "../constants"
escapeStringRegexp = require "escape-string-regexp"
DateRangeInput = require "./date-range-input"
EditInvestigation = require "./edit-investigation"
Layers = require "./layers"
ManageTestsView = require "./manage-tests-view"
moment = require "moment"
nextTick = require "next-tick"
investigationsCalls = require("../async-calls/investigations").calls
InvestigationsTable = require "./investigations-table"
React = require "react"

class module.exports extends React.Component
  @displayName: "InvestigationsView"

  constructor: ->
    @state =
      filterQuery: ""
      queryStartDate: moment().subtract(3, "month").toDate()
      queryEndDate: moment().endOf("day").toDate()
      investigations: []
      selectedInvestigation: undefined
      loadFrom: 0
      total: 0
      loading: false
      layer: undefined

  fetchInvestigations: =>
    @setState loading: true
    query =
      text: @state.filterQuery
      daterange:
        from: @state.queryStartDate
        to: @state.queryEndDate
    investigationsCalls.getInvestigations query, @state.loadFrom,
      constants.paginationLimit, (err, investigations, total) =>
        @setState
          investigations: investigations
          total: total
          loading: false

  handleFilterQueryChanged: (e) =>
    @setState
      filterQuery: e.target.value
      loadFrom: 0
    clearTimeout @filterQueryChangeTimer if @filterQueryChangeTimer?
    @filterQueryChangeTimer = setTimeout @fetchInvestigations, 200

  handleQueryDateRangeChanged: ({startDate, endDate}) =>
    @setState
      queryStartDate: startDate
      queryEndDate: endDate
    clearTimeout @filterQueryChangeTimer if @filterQueryChangeTimer?
    @filterQueryChangeTimer = setTimeout @fetchInvestigations, 200

  handleNewInvestigationClicked: =>
    layer =
      <CommitCache
        component={EditInvestigation}
        data={undefined}
        dataProperty="investigation"
        commitMethod={investigationsCalls.commitInvestigation}
        removeMethod={investigationsCalls.removeInvestigation}
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, "New Investigation"

  handleManageTestsClicked: =>
    closeButtonStyle =
      position: "absolute"
      top: -50
      right: 0
      padding: "2.5px 0"
      outline: 0
    layer =
      <div style={position: "relative"}>
        <ManageTestsView />
        <button
          className="close"
          onClick={@handleLayerDismissed}
          style={closeButtonStyle}>
          <span className="lead">✕</span>
        </button>
      </div>
    @setState layer: layer
    Layers.addLayer layer, "Manage Tests"

  handlePagerPreviousClicked: =>
    @setState
      loadFrom:
        Math.max 0, @state.loadFrom - constants.paginationLimit
    nextTick @fetchInvestigations

  handlePagerNextClicked: =>
    @setState
      loadFrom:
        Math.min @state.total - constants.paginationLimit,
          @state.loadFrom + constants.paginationLimit
    nextTick @fetchInvestigations

  handleInvestigationClicked: (investigation) =>
    layer =
      <CommitCache
        component={EditInvestigation}
        data={investigation}
        dataProperty="investigation"
        commitMethod={investigationsCalls.commitInvestigation}
        removeMethod={investigationsCalls.removeInvestigation}
        onDismiss={@handleLayerDismissed}
      />
    @setState
      selectedInvestigation: investigation
      layer: layer
    Layers.addLayer layer, "Edit Investigation"

  handleLayerDismissed: ({status}) =>
    Layers.removeLayer @state.layer
    @setState
      selectedInvestigation: undefined
      layer: undefined
    @fetchInvestigations() if status in ["saved", "removed"]

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
        onClick={@handleNewInvestigationClicked}>
        <i className="fa fa-pencil" /> New Investigation
      </button>
      <span> </span>
      <button
        className="btn btn-default"
        onClick={@handleManageTestsClicked}>
        <i className="fa fa-th-list" /> Manage Tests
      </button>
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
      if @state.loadFrom + @state.investigations.length < @state.total
        <button
          className="btn btn-default"
          onClick={@handlePagerNextClicked}>
          <i className="fa fa-chevron-right" />
        </button>
    text =
      "#{@state.loadFrom + 1}—" +
      "#{@state.loadFrom + @state.investigations.length} of " +
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
      <InvestigationsTable
        investigations={@state.investigations}
        selectedInvestigation={@state.selectedInvestigation}
        onInvestigationClick={@handleInvestigationClicked}
      />
    </div>

  componentDidMount: ->
    @fetchInvestigations()

  componentWillUnmount: ->
    Layers.removeLayer @state.layer if @state.layer?
