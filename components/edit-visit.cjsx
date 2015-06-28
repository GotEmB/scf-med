clone = require "clone"
DateInput = require "./date-input"
deepDiff = require "deep-diff"
EditSignsTable = require "./edit-signs-table"
EditSymptomsTable = require "./edit-symptoms-table"
EditPatient = require "./edit-patient"
moment = require "moment"
nextTick = require "next-tick"
Page = require "./page"
padNumber = require "pad-number"
patientsCalls = require("../async-calls/patients").calls
React = require "react"
reactTypes = require "../react-types"
TextInput = require "./text-input"
TypeaheadSelect = require "./typeahead-select"

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

  handleSignsChanged: (signs) =>
    visit = clone @props.visit
    visit.signs = signs
    @props.onVisitChange visit

  handleSymptomsChanged: (symptoms) =>
    visit = clone @props.visit
    visit.symptoms = symptoms
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
      <div className="form-group" style={position: "relative"}>
        <label>Comments</label>
        <TextInput
          type="text"
          className="form-control"
          value={@props.visit.comments}
          onChange={@handleCommentsChanged}
        />
      </div>
      <EditSignsTable
        signs={@props.visit.signs}
        onSignsChange={@handleSignsChanged}
      />
      <EditSymptomsTable
        symptoms={@props.visit.symptoms}
        onSymptomsChange={@handleSymptomsChanged}
      />
    </div>
