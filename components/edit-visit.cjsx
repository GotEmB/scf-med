clone = require "clone"
DateInput = require "./date-input"
deepDiff = require "deep-diff"
EditDiagnosesTable = require "./edit-diagnoses-table"
EditSignsTable = require "./edit-signs-table"
EditSymptomsTable = require "./edit-symptoms-table"
EditPatient = require "./edit-patient"
moment = require "moment"
nextTick = require "next-tick"
Page = require "./page"
padNumber = require "pad-number"
patientsCalls = require("../async-calls/patients").calls
visitsCalls = require("../async-calls/visits").calls
React = require "react"
reactTypes = require "../react-types"
TextInput = require "./text-input"
TypeaheadSelect = require "./typeahead-select"
TypeaheadInput = require "./typeahead-input"

class module.exports extends React.Component
  @displayName: "EditVisit"

  @propTypes:
    visit: reactTypes.visit
    onVisitChange: React.PropTypes.func.isRequired
    onCommit: React.PropTypes.func

  @defaultProps:
    visit:
      patient: undefined
      date: undefined
      diagnoses: []
      signs: []
      symptoms: []
      comments: undefined

  handleDateChanged: (date) =>
    visit = clone @props.visit
    visit.date = date
    @props.onVisitChange visit

  handlePatientChanged: (patient) =>
    visit = clone @props.visit
    visit.patient = patient
    @props.onVisitChange visit

  handleCommentsChanged: (comments) =>
    visit = clone @props.visit
    visit.comments = comments
    @props.onVisitChange visit

  handleSymptomsChanged: (symptoms) =>
    visit = clone @props.visit
    visit.symptoms = symptoms
    @props.onVisitChange visit

  handleSignsChanged: (signs) =>
    visit = clone @props.visit
    visit.signs = signs
    @props.onVisitChange visit

  handleDiagnosesChanged: (diagnoses) =>
    visit = clone @props.visit
    visit.diagnoses = diagnoses
    @props.onVisitChange visit

  render: ->
    newPatientSuggestion =
      component: EditPatient
      dataProperty: "patient"
      commitMethod: patientsCalls.commitPatient
      removeMethod: patientsCalls.removePatient
    <div>
      <div className="form-group" style={position: "relative"}>
        <label>Date & Time</label>
        <DateInput
          date={@props.visit.date}
          onDateChange={@handleDateChanged}
          hasTime={true}
          className="form-control"
        />
      </div>
      <TypeaheadSelect
        selectedItem={@props.visit.patient}
        onSelectedItemChange={@handlePatientChanged}
        suggestionsFetcher={patientsCalls.getPatients}
        textFormatter={(x) -> x.name}
        label="Patient"
        newSuggestion={newPatientSuggestion}
      />
      <EditSymptomsTable
        symptoms={@props.visit.symptoms}
        onSymptomsChange={@handleSymptomsChanged}
      />
      <EditSignsTable
        signs={@props.visit.signs}
        onSignsChange={@handleSignsChanged}
      />
      <div className="form-group" style={position: "relative"}>
        <label>Comments</label>
        <TextInput
          type="text"
          className="form-control"
          value={@props.visit.comments}
          onChange={@handleCommentsChanged}
        />
      </div>
      <EditDiagnosesTable
        diagnoses={@props.visit.diagnoses}
        onDiagnosesChange={@handleDiagnosesChanged}
      />
    </div>

  componentWillMount: ->
    if Object.keys(@props.visit).length is 0
      visit = clone @constructor.defaultProps.visit
      visit.date = moment().toISOString()
      @props.onVisitChange visit
