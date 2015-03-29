CommitCache = require "./commit-cache"
constants = require "../constants"
DateRangeInput = require "./date-range-input"
EditVisit = require "./edit-visit"
escapeStringRegexp = require "escape-string-regexp"
Layers = require "./layers"
moment = require "moment"
nextTick = require "next-tick"
Page = require "./page"
React = require "react"
visitsCalls = require("../async-calls/visits").calls
VisitsTable = require "./visits-table"


class module.exports extends React.Component
  @displayName: "VisitsView"

  constructor: ->
    @state =
      filterQuery: ""
      queryStartDate: moment().subtract(1, "month").toDate()
      queryEndDate: moment().endOf("day").toDate()
      visits: []
      selectedVisit: undefined
      loadFrom: 0
      total: 0
      loading: false
      layer: undefined

  fetchVisits: =>
    @setState loading: true
    query =
      text: @state.filterQuery
      daterange:
        from: @state.queryStartDate
        to: @state.queryEndDate
    visitsCalls.getVisits query, @state.loadFrom,
      constants.paginationLimit, (err, visits, total) =>
        @setState
          visits: visits
          total: total
          loading: false

  handleFilterQueryChanged: (e) =>
    @setState
      filterQuery: e.target.value
      loadFrom: 0
    clearTimeout @filterQueryChangeTimer if @filterQueryChangeTimer?
    @filterQueryChangeTimer = setTimeout @fetchVisits, 200

  handleQueryDateRangeChanged: ({startDate, endDate}) =>
    @setState
      queryStartDate: startDate
      queryEndDate: endDate
    clearTimeout @filterQueryChangeTimer if @filterQueryChangeTimer?
    @filterQueryChangeTimer = setTimeout @fetchVisits, 200

  handleNewVisitClicked: =>
    layer =
      <CommitCache
        component={EditVisit}
        data={undefined}
        dataProperty="visit"
        commitMethod={visitsCalls.commitVisit}
        removeMethod={visitsCalls.removeVisit}
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, "New Visit"

  handlePagerPreviousClicked: =>
    @setState
      loadFrom:
        Math.max 0, @state.loadFrom - constants.paginationLimit
    nextTick @fetchVisits

  handlePagerNextClicked: =>
    @setState
      loadFrom:
        Math.min @state.total - constants.paginationLimit,
          @state.loadFrom + constants.paginationLimit
    nextTick @fetchVisits

  handleVisitClicked: (visit) =>
    layer =
      <CommitCache
        component={EditVisit}
        data={visit}
        dataProperty="visit"
        commitMethod={visitsCalls.commitVisit}
        removeMethod={visitsCalls.removeVisit}
        onDismiss={@handleLayerDismissed}
      />
    @setState
      selectedVisit: visit
      layer: layer
    Layers.addLayer layer, "Edit Visit"

  handleLayerDismissed: ({status}) =>
    Layers.removeLayer @state.layer
    @setState
      selectedVisit: undefined
      layer: undefined
    @fetchVisits() if status in ["saved", "removed"]

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
      <button
        className="btn btn-default"
        onClick={@handleNewVisitClicked}>
        <i className="fa fa-pencil" /> New Visit
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
      if @state.loadFrom + @state.visits.length < @state.total
        <button
          className="btn btn-default"
          onClick={@handlePagerNextClicked}>
          <i className="fa fa-chevron-right" />
        </button>
    text =
      "#{@state.loadFrom + 1}—" +
      "#{@state.loadFrom + @state.visits.length} of " +
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
      <VisitsTable
        visits={@state.visits}
        selectedVisit={@state.selectedVisit}
        onVisitClick={@handleVisitClicked}
      />
    </div>

  componentDidMount: ->
    @fetchVisits()

  componentWillUnmount: ->
    Layers.removeLayer @state.layer if @state.layer?
