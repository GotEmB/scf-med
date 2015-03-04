Checkbox = require "./checkbox"
clone = require "clone"
DateInput = require "./date-input"
deepDiff = require "deep-diff"
EditMedicinesTable = require "./edit-medicines-table"
EditPatient = require "./edit-patient"
moment = require "moment"
nextTick = require "next-tick"
Page = require "./page"
patientsCalls = require("../async-calls/patients").calls
PrescriptionPrintView = require "./prescription-print-view"
React = require "react"
reactTypes = require "../react-types"
TypeaheadSelect = require "./typeahead-select"

class module.exports extends React.Component
  @displayName: "EditPrescription"

  @propTypes:
    prescription: reactTypes.prescription
    onPrescriptionChange: React.PropTypes.func.isRequired
    onCommit: React.PropTypes.func

  @defaultProps:
    prescription:
      patient: undefined
      date: undefined
      medicines: []
      routine: false

  componentWillReceiveProps: (props) ->
    if deepDiff(@props.prescription, props.prescription)?
      printView = <PrescriptionPrintView prescription={props.prescription} />
      Page.setPrintView printView

  handleDateChanged: (date) =>
    prescription = clone @props.prescription
    prescription.date = date
    @props.onPrescriptionChange prescription

  handlePatientChanged: (patient) =>
    prescription = clone @props.prescription
    prescription.patient = patient
    @props.onPrescriptionChange prescription

  handleRoutineChanged: (routine) =>
    prescription = clone @props.prescription
    prescription.routine = routine
    @props.onPrescriptionChange prescription

  handleMedicinesChanged: (medicines) =>
    prescription = clone @props.prescription
    prescription.medicines = medicines
    @props.onPrescriptionChange prescription

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
          date={@props.prescription.date}
          onDateChange={@handleDateChanged}
          hasTime={true}
          className="form-control"
        />
      </div>
      <TypeaheadSelect
        selectedItem={@props.prescription.patient}
        onSelectedItemChange={@handlePatientChanged}
        suggestionsFetcher={patientsCalls.getPatients}
        textFormatter={(x) -> x.name}
        label="Patient"
        newSuggestion={newPatientSuggestion}
      />
      <Checkbox
        checked={@props.prescription.routine}
        onCheckedChange={@handleRoutineChanged}
        label="Routine"
      />
      <EditMedicinesTable
        medicines={@props.prescription.medicines}
        onMedicinesChange={@handleMedicinesChanged}
      />
      <div className="text-center">
        <button className="btn btn-primary" onClick={@handlePrintClicked}>
          <i className="fa fa-print" /> Save & Print
        </button>
      </div>
    </div>

  componentWillMount: ->
    if Object.keys(@props.prescription).length is 0
      prescription = clone @constructor.defaultProps.prescription
      prescription.date = moment().toISOString()
      @props.onPrescriptionChange prescription
    printView = <PrescriptionPrintView prescription={@props.prescription} />
    Page.setPrintView printView

  componentWillUnmount: ->
    Page.unsetPrintView()
