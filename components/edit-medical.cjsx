clone = require "clone"
DateInput = require "./date-input"
deepDiff = require "deep-diff"
EditPatient = require "./edit-patient"
moment = require "moment"
nextTick = require "next-tick"
Page = require "./page"
patientsCalls = require("../async-calls/patients").calls
medicalsCalls = require("../async-calls/medicals").calls
MedicalPrintView = require "./medical-print-view"
React = require "react"
reactTypes = require "../react-types"
TextInput = require "./text-input"
TypeaheadSelect = require "./typeahead-select"
TypeaheadInput = require "./typeahead-input"

class module.exports extends React.Component
  @displayName: "EditMedical"

  @propTypes:
    medical: reactTypes.medical
    onMedicalChange: React.PropTypes.func.isRequired
    onCommit: React.PropTypes.func

  @defaultProps:
    medical:
      patient: undefined
      date: undefined
      comments: undefined

  componentWillReceiveProps: (props) ->
    if deepDiff(@props.medical, props.medical)?
      printView = <MedicalPrintView medical={props.medical} />
      Page.setPrintView printView

  handleDateChanged: (date) =>
    medical = clone @props.medical
    medical.date = date
    @props.onMedicalChange medical

  handlePatientChanged: (patient) =>
    medical = clone @props.medical
    medical.patient = patient
    @props.onMedicalChange medical

  handleCommentsChanged: (comments) =>
    medical = clone @props.medical
    medical.comments = comments
    @props.onMedicalChange medical

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
          date={@props.medical.date}
          onDateChange={@handleDateChanged}
          hasTime={true}
          className="form-control"
        />
      </div>
      <TypeaheadSelect
        selectedItem={@props.medical.patient}
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
          value={@props.medical.comments}
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
    if Object.keys(@props.medical).length is 0
      medical = clone @constructor.defaultProps.medical
      medical.date = moment().toISOString()
      @props.onMedicalChange medical
    printView = <MedicalPrintView medical={@props.medical} />
    Page.setPrintView printView

  componentWillUnmount: ->
    Page.unsetPrintView()
