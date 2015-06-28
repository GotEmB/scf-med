CommitCache = require "./commit-cache"
constants = require "../constants"
EditSymptom = require "./edit-symptom"
escapeStringRegexp = require "escape-string-regexp"
Layers = require "./layers"
nextTick = require "next-tick"
React = require "react"
symptomsCalls = require("../async-calls/symptoms").calls
SymptomsTable = require "./symptoms-table"

class module.exports extends React.Component
  @displayName: "ManageSymptomsView"

  constructor: ->
    @state =
      filterQuery: ""
      symptoms: []
      selectedSymptom: undefined
      loadFrom: 0
      total: 0
      loading: false
      layer: undefined

  fetchSymptoms: =>
    @setState loading: true
    symptomsCalls.getSymptoms escapeStringRegexp(@state.filterQuery),
      @state.loadFrom, constants.paginationLimit, (err, symptoms, total) =>
        @setState
          symptoms: symptoms
          total: total
          loading: false

  handleFilterQueryChanged: (e) =>
    @setState
      filterQuery: e.target.value
      loadFrom: 0
    clearTimeout @filterQueryChangeTimer if @filterQueryChangeTimer?
    @filterQueryChangeTimer = setTimeout @fetchSymptoms, 200

  handleNewSymptomClicked: =>
    layer =
      <CommitCache
        component={EditSymptom}
        data={undefined}
        dataProperty="symptom"
        commitMethod={symptomsCalls.commitSymptom}
        removeMethod={symptomsCalls.removeSymptom}
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, "New Symptom"

  handlePagerPreviousClicked: =>
    @setState
      loadFrom:
        Math.max 0, @state.loadFrom - constants.paginationLimit
    nextTick @fetchSymptoms

  handlePagerNextClicked: =>
    @setState
      loadFrom:
        Math.min @state.total - constants.paginationLimit,
          @state.loadFrom + constants.paginationLimit
    nextTick @fetchSymptoms

  handleSymptomClicked: (symptom) =>
    layer =
      <CommitCache
        component={EditSymptom}
        data={symptom}
        dataProperty="symptom"
        commitMethod={symptomsCalls.commitSymptom}
        removeMethod={symptomsCalls.removeSymptom}
        onDismiss={@handleLayerDismissed}
      />
    @setState
      selectedSymptom: symptom
      layer: layer
    Layers.addLayer layer, "Edit Symptom"

  handleLayerDismissed: ({status}) =>
    Layers.removeLayer @state.layer
    @setState
      selectedSymptom: undefined
      layer: undefined
    @fetchSymptoms() if status in ["saved", "removed"]

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
        onClick={@handleNewSymptomClicked}>
        <i className="fa fa-pencil" /> New Symptom
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
      if @state.loadFrom + @state.symptoms.length < @state.total
        <button
          className="btn btn-default"
          onClick={@handlePagerNextClicked}>
          <i className="fa fa-chevron-right" />
        </button>
    text =
      "#{@state.loadFrom + 1}—" +
      "#{@state.loadFrom + @state.symptoms.length} of " +
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
    <SymptomsTable
      symptoms={@state.symptoms}
      selectedSymptom={@state.selectedSymptom}
      onSymptomClick={@handleSymptomClicked}
    />

  render: ->
    <div>
      {@renderControls()}
      <br />
      {@renderTable()}
    </div>

  componentDidMount: ->
    @fetchSymptoms()

  componentWillUnmount: ->
    Layers.removeLayer @state.layer if @state.layer?
