clone = require "clone"
DateInput = require "./date-input"
deepDiff = require "deep-diff"
EditPatient = require "./edit-patient"
EditTestsTable = require "./edit-tests-table"
VisitPrintView = require "./visit-print-view"
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
      symptom: undefined
      sign: undefined
      tests: []

  componentWillReceiveProps: (props) ->
    if deepDiff(@props.visit, props.visit)?
      printView = <VisitPrintView visit={props.visit} />
      Page.setPrintView printView

  handleDateChanged: (date) =>
    visit = clone @props.visit
    visit.date = date
    @props.onVisitChange visit

  handlePatientChanged: (patient) =>
    visit = clone @props.visit
    visit.patient = patient
    @props.onVisitChange visit

  handleTestsChanged: (tests) =>
    visit = clone @props.visit
    visit.tests = tests
    @props.onVisitChange visit

  handleCommentsChanged: (comments) =>
    visit = clone @props.visit
    visit.comments = comments
    @props.onVisitChange visit

  handlePrintClicked: =>
    @props.onCommit? true, ->
      nextTick ->
        window.print()

  render: ->
    newPatientSuggestion =
      component: EditPatient
      dataProperty: "patient"
      commitMethod: patientsCalls.commitPatient
      removeMethod: patientsCalls.removePatient
    if @props.visit.serial?
      serial =
        "#{@props.visit.serial.year}-\
        #{padNumber @props.visit.serial.number, 5}"
    <div>
      <div className="form-group" style={position: "relative"}>
        <label>Serial</label>
        <input
          type="text"
          value={serial}
          className="form-control"
          disabled
        />
      </div>
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
      <TypeaheadInput
        value={@props.visit.symptom}
        onChange={@handleSymptomChanged}
        suggestionsFetcher={visitsCalls.getSymptomSuggestions}
        textFormatter={(x) -> x}
        label="Symptom"
      />
      <div className="form-group">
        <label>Sign</label>
        <TextInput
          className="form-control"
          type="text"
          value={@props.visit.sign}
          onChange={@handleSignChanged}
        />
      </div>
      <EditTestsTable
        tests={@props.visit.tests}
        onTestsChange={@handleTestsChanged}
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
      <div className="text-center">
        <button className="btn btn-primary" onClick={@handlePrintClicked}>
          <i className="fa fa-print" /> Save & Print
        </button>
      </div>
    </div>

  componentWillMount: ->
    if Object.keys(@props.visit).length is 0
      visit = clone @constructor.defaultProps.visit
      visit.date = moment().toISOString()
      @props.onVisitChange visit
    printView = <VisitPrintView visit={@props.visit} />
    Page.setPrintView printView

  componentWillUnmount: ->
    Page.unsetPrintView()
