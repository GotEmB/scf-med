clone = require "clone"
CommitCache = require "./commit-cache"
constants = require "../constants"
escapeStringRegexp = require "escape-string-regexp"
DateRangeInput = require "./date-range-input"
EditMemo = require "./edit-memo"
Layers = require "./layers"
moment = require "moment"
nextTick = require "next-tick"
memosCalls = require("../async-calls/memos").calls
MemosTable = require "./memos-table"
React = require "react"

class module.exports extends React.Component
  @displayName: "MemosView"

  constructor: ->
    @state =
      filterQuery: ""
      queryStartDate: moment().subtract(3, "month").toDate()
      queryEndDate: moment().endOf("day").toDate()
      memos: []
      selectedMemo: undefined
      loadFrom: 0
      total: 0
      loading: false
      layer: undefined

  fetchMemos: =>
    @setState loading: true
    query =
      text: @state.filterQuery
      daterange:
        from: @state.queryStartDate
        to: @state.queryEndDate
    memosCalls.getMemos query, @state.loadFrom,
      constants.paginationLimit, (err, memos, total) =>
        @setState
          memos: memos
          total: total
          loading: false

  handleFilterQueryChanged: (e) =>
    @setState
      filterQuery: e.target.value
      loadFrom: 0
    clearTimeout @filterQueryChangeTimer if @filterQueryChangeTimer?
    @filterQueryChangeTimer = setTimeout @fetchMemos, 200

  handleQueryDateRangeChanged: ({startDate, endDate}) =>
    @setState
      queryStartDate: startDate
      queryEndDate: endDate
    clearTimeout @filterQueryChangeTimer if @filterQueryChangeTimer?
    @filterQueryChangeTimer = setTimeout @fetchMemos, 200

  handleNewMemoClicked: =>
    layer =
      <CommitCache
        component={EditMemo}
        data={undefined}
        dataProperty="memo"
        commitMethod={memosCalls.commitMemo}
        removeMethod={memosCalls.removeMemo}
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, "New Memo"

  handlePagerPreviousClicked: =>
    @setState
      loadFrom:
        Math.max 0, @state.loadFrom - constants.paginationLimit
    nextTick @fetchMemos

  handlePagerNextClicked: =>
    @setState
      loadFrom:
        Math.min @state.total - constants.paginationLimit,
          @state.loadFrom + constants.paginationLimit
    nextTick @fetchMemos

  handleMemoClicked: (memo) =>
    layer =
      <CommitCache
        component={EditMemo}
        data={memo}
        dataProperty="memo"
        commitMethod={memosCalls.commitMemo}
        removeMethod={memosCalls.removeMemo}
        onDismiss={@handleLayerDismissed}
      />
    @setState
      selectedMemo: memo
      layer: layer
    Layers.addLayer layer, "Edit Memo"

  handleLayerDismissed: ({status}) =>
    Layers.removeLayer @state.layer
    @setState
      selectedMemo: undefined
      layer: undefined
    @fetchMemos() if status in ["saved", "removed"]

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
        onClick={@handleNewMemoClicked}>
        <i className="fa fa-pencil" /> New Memo
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
      if @state.loadFrom + @state.memos.length < @state.total
        <button
          className="btn btn-default"
          onClick={@handlePagerNextClicked}>
          <i className="fa fa-chevron-right" />
        </button>
    text =
      "#{@state.loadFrom + 1}—" +
      "#{@state.loadFrom + @state.memos.length} of " +
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
      <MemosTable
        memos={@state.memos}
        selectedMemo={@state.selectedMemo}
        onMemoClick={@handleMemoClicked}
      />
    </div>

  componentDidMount: ->
    @fetchMemos()

  componentWillUnmount: ->
    Layers.removeLayer @state.layer if @state.layer?
