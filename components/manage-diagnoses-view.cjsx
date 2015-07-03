CommitCache = require "./commit-cache"
constants = require "../constants"
EditDiagnosis = require "./edit-diagnosis"
escapeStringRegexp = require "escape-string-regexp"
Layers = require "./layers"
nextTick = require "next-tick"
React = require "react"
diagnosesCalls = require("../async-calls/diagnoses").calls
DiagnosesTable = require "./diagnoses-table"

class module.exports extends React.Component
  @displayName: "ManageDiagnosesView"

  constructor: ->
    @state =
      filterQuery: ""
      diagnoses: []
      selectedDiagnosis: undefined
      loadFrom: 0
      total: 0
      loading: false
      layer: undefined

  fetchDiagnoses: =>
    @setState loading: true
    diagnosesCalls.getDiagnoses escapeStringRegexp(@state.filterQuery),
      @state.loadFrom, constants.paginationLimit, (err, diagnoses, total) =>
        @setState
          diagnoses: diagnoses
          total: total
          loading: false

  handleFilterQueryChanged: (e) =>
    @setState
      filterQuery: e.target.value
      loadFrom: 0
    clearTimeout @filterQueryChangeTimer if @filterQueryChangeTimer?
    @filterQueryChangeTimer = setTimeout @fetchDiagnoses, 200

  handleNewDiagnosisClicked: =>
    layer =
      <CommitCache
        component={EditDiagnosis}
        data={undefined}
        dataProperty="diagnosis"
        commitMethod={diagnosesCalls.commitDiagnosis}
        removeMethod={diagnosesCalls.removeDiagnosis}
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, "New Diagnosis"

  handlePagerPreviousClicked: =>
    @setState
      loadFrom:
        Math.max 0, @state.loadFrom - constants.paginationLimit
    nextTick @fetchDiagnoses

  handlePagerNextClicked: =>
    @setState
      loadFrom:
        Math.min @state.total - constants.paginationLimit,
          @state.loadFrom + constants.paginationLimit
    nextTick @fetchDiagnoses

  handleDiagnosisClicked: (diagnosis) =>
    layer =
      <CommitCache
        component={EditDiagnosis}
        data={diagnosis}
        dataProperty="diagnosis"
        commitMethod={diagnosesCalls.commitDiagnosis}
        removeMethod={diagnosesCalls.removeDiagnosis}
        onDismiss={@handleLayerDismissed}
      />
    @setState
      selectedDiagnosis: diagnosis
      layer: layer
    Layers.addLayer layer, "Edit Diagnosis"

  handleLayerDismissed: ({status}) =>
    Layers.removeLayer @state.layer
    @setState
      selectedDiagnosis: undefined
      layer: undefined
    @fetchDiagnoses() if status in ["saved", "removed"]

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
        onClick={@handleNewDiagnosisClicked}>
        <i className="fa fa-pencil" /> New Diagnosis
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
      if @state.loadFrom + @state.diagnoses.length < @state.total
        <button
          className="btn btn-default"
          onClick={@handlePagerNextClicked}>
          <i className="fa fa-chevron-right" />
        </button>
    text =
      "#{@state.loadFrom + 1}—" +
      "#{@state.loadFrom + @state.diagnoses.length} of " +
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
    <DiagnosesTable
      diagnoses={@state.diagnoses}
      selectedDiagnosis={@state.selectedDiagnosis}
      onDiagnosisClick={@handleDiagnosisClicked}
    />

  render: ->
    <div>
      {@renderControls()}
      <br />
      {@renderTable()}
    </div>

  componentDidMount: ->
    @fetchDiagnoses()

  componentWillUnmount: ->
    Layers.removeLayer @state.layer if @state.layer?
