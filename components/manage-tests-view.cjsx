CommitCache = require "./commit-cache"
constants = require "../constants"
EditTest = require "./edit-test"
escapeStringRegexp = require "escape-string-regexp"
Layers = require "./layers"
nextTick = require "next-tick"
React = require "react"
testsCalls = require("../async-calls/tests").calls
TestsTable = require "./tests-table"

class module.exports extends React.Component
  @displayName: "ManageTestsView"

  constructor: ->
    @state =
      filterQuery: ""
      tests: []
      selectedTest: undefined
      loadFrom: 0
      total: 0
      loading: false
      layer: undefined

  fetchTests: =>
    @setState loading: true
    testsCalls.getTests escapeStringRegexp(@state.filterQuery),
      @state.loadFrom, constants.paginationLimit, (err, tests, total) =>
        @setState
          tests: tests
          total: total
          loading: false

  handleFilterQueryChanged: (e) =>
    @setState
      filterQuery: e.target.value
      loadFrom: 0
    clearTimeout @filterQueryChangeTimer if @filterQueryChangeTimer?
    @filterQueryChangeTimer = setTimeout @fetchTests, 200

  handleNewTestClicked: =>
    layer =
      <CommitCache
        component={EditTest}
        data={undefined}
        dataProperty="test"
        commitMethod={testsCalls.commitTest}
        removeMethod={testsCalls.removeTest}
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, "New Test"

  handlePagerPreviousClicked: =>
    @setState
      loadFrom:
        Math.max 0, @state.loadFrom - constants.paginationLimit
    nextTick @fetchTests

  handlePagerNextClicked: =>
    @setState
      loadFrom:
        Math.min @state.total - constants.paginationLimit,
          @state.loadFrom + constants.paginationLimit
    nextTick @fetchTests

  handleTestClicked: (test) =>
    layer =
      <CommitCache
        component={EditTest}
        data={test}
        dataProperty="test"
        commitMethod={testsCalls.commitTest}
        removeMethod={testsCalls.removeTest}
        onDismiss={@handleLayerDismissed}
      />
    @setState
      selectedTest: test
      layer: layer
    Layers.addLayer layer, "Edit Test"

  handleLayerDismissed: ({status}) =>
    Layers.removeLayer @state.layer
    @setState
      selectedTest: undefined
      layer: undefined
    @fetchTests() if status in ["saved", "removed"]

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
      <button
        className="btn btn-default"
        onClick={@handleNewTestClicked}>
        <i className="fa fa-pencil" /> New Test
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
      if @state.loadFrom + @state.tests.length < @state.total
        <button
          className="btn btn-default"
          onClick={@handlePagerNextClicked}>
          <i className="fa fa-chevron-right" />
        </button>
    text =
      "#{@state.loadFrom + 1}—" +
      "#{@state.loadFrom + @state.tests.length} of " +
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

  renderTable: ->
    <TestsTable
      tests={@state.tests}
      selectedTest={@state.selectedTest}
      onTestClick={@handleTestClicked}
    />

  render: ->
    <div>
      {@renderControls()}
      <br />
      {@renderTable()}
    </div>

  componentDidMount: ->
    @fetchTests()

  componentWillUnmount: ->
    Layers.removeLayer @state.layer if @state.layer?
