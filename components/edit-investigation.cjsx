clone = require "clone"
DateInput = require "./date-input"
deepDiff = require "deep-diff"
EditTestsTable = require "./edit-tests-table"
EditPatient = require "./edit-patient"
InvestigationPrintView = require "./investigation-print-view"
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
  @displayName: "EditInvestigation"

  @propTypes:
    investigation: reactTypes.investigation
    onInvestigationChange: React.PropTypes.func.isRequired
    onCommit: React.PropTypes.func

  @defaultProps:
    investigation:
      patient: undefined
      date: undefined
      tests: []
      comments: undefined

  componentWillReceiveProps: (props) ->
    if deepDiff(@props.investigation, props.investigation)?
      printView = <InvestigationPrintView investigation={props.investigation} />
      Page.setPrintView printView

  handleDateChanged: (date) =>
    investigation = clone @props.investigation
    investigation.date = date
    @props.onInvestigationChange investigation

  handlePatientChanged: (patient) =>
    investigation = clone @props.investigation
    investigation.patient = patient
    @props.onInvestigationChange investigation

  handleCommentsChanged: (comments) =>
    investigation = clone @props.investigation
    investigation.comments = comments
    @props.onInvestigationChange investigation

  handleTestsChanged: (tests) =>
    investigation = clone @props.investigation
    investigation.tests = tests
    @props.onInvestigationChange investigation

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
    <div>
      <div className="form-group" style={position: "relative"}>
        <label>Date & Time</label>
        <DateInput
          date={@props.investigation.date}
          onDateChange={@handleDateChanged}
          hasTime={true}
          className="form-control"
        />
      </div>
      <TypeaheadSelect
        selectedItem={@props.investigation.patient}
        onSelectedItemChange={@handlePatientChanged}
        suggestionsFetcher={patientsCalls.getPatients}
        textFormatter={(x) -> "#{x.name} - #{x.id}"}
        label="* Patient (required)"
        newSuggestion={newPatientSuggestion}
      />
      <div className="form-group" style={position: "relative"}>
        <label>Comments</label>
        <TextInput
          type="text"
          className="form-control"
          value={@props.investigation.comments}
          onChange={@handleCommentsChanged}
        />
      </div>
      <EditTestsTable
        tests={@props.investigation.tests}
        onTestsChange={@handleTestsChanged}
      />
      <div className="text-center">
        <button className="btn btn-primary" onClick={@handlePrintClicked}>
          <i className="fa fa-print" /> Save & Print
        </button>
      </div>
    </div>

  componentWillMount: ->
    if Object.keys(@props.investigation).length is 0
      investigation = clone @constructor.defaultProps.investigation
      investigation.date = moment().toISOString()
      @props.onInvestigationChange investigation
    printView = <InvestigationPrintView investigation={@props.investigation} />
    Page.setPrintView printView

  componentWillUnmount: ->
    Page.unsetPrintView()
