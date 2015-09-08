clone = require "clone"
CommitCache = require "./commit-cache"
constants = require "../constants"
escapeStringRegexp = require "escape-string-regexp"
DateRangeInput = require "./date-range-input"
EditFit = require "./edit-fit"
Layers = require "./layers"
moment = require "moment"
nextTick = require "next-tick"
fitsCalls = require("../async-calls/fits").calls
FitsTable = require "./fits-table"
React = require "react"

class module.exports extends React.Component
  @displayName: "FitsView"

  constructor: ->
    @state =
      filterQuery: ""
      queryStartDate: moment().subtract(3, "month").toDate()
      queryEndDate: moment().endOf("day").toDate()
      fits: []
      selectedFit: undefined
      loadFrom: 0
      total: 0
      loading: false
      layer: undefined

  fetchFits: =>
    @setState loading: true
    query =
      text: @state.filterQuery
      daterange:
        from: @state.queryStartDate
        to: @state.queryEndDate
    fitsCalls.getFits query, @state.loadFrom,
      constants.paginationLimit, (err, fits, total) =>
        @setState
          fits: fits
          total: total
          loading: false

  handleFilterQueryChanged: (e) =>
    @setState
      filterQuery: e.target.value
      loadFrom: 0
    clearTimeout @filterQueryChangeTimer if @filterQueryChangeTimer?
    @filterQueryChangeTimer = setTimeout @fetchFits, 200

  handleQueryDateRangeChanged: ({startDate, endDate}) =>
    @setState
      queryStartDate: startDate
      queryEndDate: endDate
    clearTimeout @filterQueryChangeTimer if @filterQueryChangeTimer?
    @filterQueryChangeTimer = setTimeout @fetchFits, 200

  handleNewFitClicked: =>
    layer =
      <CommitCache
        component={EditFit}
        data={undefined}
        dataProperty="fit"
        commitMethod={fitsCalls.commitFit}
        removeMethod={fitsCalls.removeFit}
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, "New Fit"

  handlePagerPreviousClicked: =>
    @setState
      loadFrom:
        Math.max 0, @state.loadFrom - constants.paginationLimit
    nextTick @fetchFits

  handlePagerNextClicked: =>
    @setState
      loadFrom:
        Math.min @state.total - constants.paginationLimit,
          @state.loadFrom + constants.paginationLimit
    nextTick @fetchFits

  handleFitClicked: (fit) =>
    layer =
      <CommitCache
        component={EditFit}
        data={fit}
        dataProperty="fit"
        commitMethod={fitsCalls.commitFit}
        removeMethod={fitsCalls.removeFit}
        onDismiss={@handleLayerDismissed}
      />
    @setState
      selectedFit: fit
      layer: layer
    Layers.addLayer layer, "Edit Fit"

  handleLayerDismissed: ({status}) =>
    Layers.removeLayer @state.layer
    @setState
      selectedFit: undefined
      layer: undefined
    @fetchFits() if status in ["saved", "removed"]

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
        onClick={@handleNewFitClicked}>
        <i className="fa fa-pencil" /> New Fit
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
      if @state.loadFrom + @state.fits.length < @state.total
        <button
          className="btn btn-default"
          onClick={@handlePagerNextClicked}>
          <i className="fa fa-chevron-right" />
        </button>
    text =
      "#{@state.loadFrom + 1}—" +
      "#{@state.loadFrom + @state.fits.length} of " +
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
      <FitsTable
        fits={@state.fits}
        selectedFit={@state.selectedFit}
        onFitClick={@handleFitClicked}
      />
    </div>

  componentDidMount: ->
    @fetchFits()

  componentWillUnmount: ->
    Layers.removeLayer @state.layer if @state.layer?
