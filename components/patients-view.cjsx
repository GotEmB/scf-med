CommitCache = require "./commit-cache"
constants = require "../constants"
EditPatient = require "./edit-patient"
escapeStringRegexp = require "escape-string-regexp"
Layers = require "./layers"
nextTick = require "next-tick"
patientsCalls = require("../async-calls/patients").calls
PatientsTable = require "./patients-table"
React = require "react"

class module.exports extends React.Component
  @displayName: "PatientsView"

  constructor: ->
    @state =
      filterQuery: ""
      patients: []
      selectedPatient: undefined
      loadFrom: 0
      total: 0
      loading: false
      layer: undefined

  fetchPatients: =>
    @setState loading: true
    patientsCalls.getPatients escapeStringRegexp(@state.filterQuery),
      @state.loadFrom, constants.paginationLimit,
      (err, patients, total) =>
        @setState
          patients: patients
          total: total
          loading: false

  handleFilterQueryChanged: (e) =>
    @setState
      filterQuery: e.target.value
      loadFrom: 0
    clearTimeout @filterQueryChangeTimer if @filterQueryChangeTimer?
    @filterQueryChangeTimer = setTimeout @fetchPatients, 200

  handleNewPatientClicked: =>
    layer =
      <CommitCache
        component={EditPatient}
        data={undefined}
        dataProperty="patient"
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, "New Patient"

  handlePagerPreviousClicked: =>
    @setState
      loadFrom:
        Math.max 0, @state.loadFrom - constants.paginationLimit
    nextTick @fetchPatients

  handlePagerNextClicked: =>
    @setState
      loadFrom:
        Math.min @state.total - constants.paginationLimit,
          @state.loadFrom + constants.paginationLimit
    nextTick @fetchPatients

  handlePatientClicked: (patient) =>
    layer =
      <CommitCache
        component={EditPatient}
        data={patient}
        dataProperty="patient"
        onDismiss={@handleLayerDismissed}
      />
    @setState
      selectedPatient: patient
      layer: layer
    Layers.addLayer layer, "Edit Patient"

  handleLayerDismissed: ({commit, data}) =>
    Layers.removeLayer @state.layer
    @setState
      selectedPatient: undefined
      layer: undefined
    if commit
      if data?
        patientsCalls.commitPatient data, (err) =>
          @setState loading: true
          @fetchPatients()
      else if @state.selectedPatient?._id?
        patientsCalls.removePatient @state.selectedPatient, (err) =>
          @setState loading: true
          @fetchPatients()

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
      <button className="btn btn-default" onClick={@handleNewPatientClicked}>
        <i className="fa fa-user-plus" /> New Patient
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
      if @state.loadFrom + @state.patients.length < @state.total
        <button
          className="btn btn-default"
          onClick={@handlePagerNextClicked}>
          <i className="fa fa-chevron-right" />
        </button>
    text =
      "#{@state.loadFrom + 1}—" +
      "#{@state.loadFrom + @state.patients.length} of " +
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
      <PatientsTable
        patients={@state.patients}
        selectedPatient={@state.selectedPatient}
        onPatientClick={@handlePatientClicked}
      />
    </div>

  componentDidMount: ->
    @fetchPatients()

  componentWillUnmount: ->
    Layers.removeLayer @state.layer if @state.layer?
