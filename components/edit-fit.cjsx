clone = require "clone"
DateInput = require "./date-input"
deepDiff = require "deep-diff"
EditDiagnosesTable = require "./edit-diagnoses-table"
EditPatient = require "./edit-patient"
moment = require "moment"
nextTick = require "next-tick"
Page = require "./page"
patientsCalls = require("../async-calls/patients").calls
fitsCalls = require("../async-calls/fits").calls
diagnosesCalls = require("../async-calls/diagnoses").calls
FitPrintView = require "./fit-print-view"
React = require "react"
reactTypes = require "../react-types"
TextInput = require "./text-input"
TypeaheadSelect = require "./typeahead-select"
TypeaheadInput = require "./typeahead-input"

class module.exports extends React.Component
  @displayName: "EditFit"

  @propTypes:
    fit: reactTypes.fit
    onFitChange: React.PropTypes.func.isRequired
    onCommit: React.PropTypes.func

  @defaultProps:
    fit:
      patient: undefined
      date: undefined
      diagnosis: undefined
      comments: undefined

  componentWillReceiveProps: (props) ->
    if deepDiff(@props.fit, props.fit)?
      printView = <FitPrintView fit={props.fit} />
      Page.setPrintView printView

  handleDateChanged: (date) =>
    fit = clone @props.fit
    fit.date = date
    @props.onFitChange fit

  handlePatientChanged: (patient) =>
    fit = clone @props.fit
    fit.patient = patient
    @props.onFitChange fit

  handleDiagnosesChanged: (diagnosis) =>
    fit = clone @props.fit
    fit.diagnosis = diagnosis
    @props.onFitChange fit

  handleCommentsChanged: (comments) =>
    fit = clone @props.fit
    fit.comments = comments
    @props.onFitChange fit

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
          date={@props.fit.date}
          onDateChange={@handleDateChanged}
          hasTime={true}
          className="form-control"
        />
      </div>
      <TypeaheadSelect
        selectedItem={@props.fit.patient}
        onSelectedItemChange={@handlePatientChanged}
        suggestionsFetcher={patientsCalls.getPatients}
        textFormatter={(x) -> "#{x.name} - #{x.id}"}
        label="* Patient (required)"
        newSuggestion={newPatientSuggestion}
      />
      <TypeaheadInput
        value={@props.fit.diagnosis}
        onChange={@handleDiagnosesChanged}
        suggestionsFetcher={fitsCalls.getDiagnosesSuggestions}
        textFormatter={(x) -> x}
        label="Diagnosis"
      />
      <div className="form-group" style={position: "relative"}>
        <label>Comments</label>
        <TextInput
          type="text"
          className="form-control"
          value={@props.fit.comments}
          onChange={@handleCommentsChanged}
          multiline={true}
        />
      </div>
      <div className="text-center">
        <button className="btn btn-primary" onClick={@handlePrintClicked}>
          <i className="fa fa-print" /> Save & Print
        </button>
      </div>
    </div>

  componentWillMount: ->
    if Object.keys(@props.fit).length is 0
      fit = clone @constructor.defaultProps.fit
      fit.date = moment().toISOString()
      @props.onFitChange fit
    printView = <FitPrintView fit={@props.fit} />
    Page.setPrintView printView

  componentWillUnmount: ->
    Page.unsetPrintView()
