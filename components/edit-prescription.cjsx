clone = require "clone"
DateInput = require "./date-input"
EditMedicinesTable = require "./edit-medicines-table"
EditPatient = require "./edit-patient"
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
      date: new Date()
      medicines: []
      routine: false

  handlePrescriptionChanged: =>
    @props.onPrescriptionChange @props.prescription
    printView = <PrescriptionPrintView prescription={@props.prescription} />
    Page.setPrintView printView

  handleDateChanged: (date) =>
    @props.prescription.date = date
    @handlePrescriptionChanged()

  handlePatientChanged: (patient) =>
    @props.prescription.patient = patient
    @handlePrescriptionChanged()

  handleRoutineChanged: (e) =>
    @props.prescription.routine = e.target.checked
    @handlePrescriptionChanged()

  handleMedicinesChanged: (medicines) =>
    @props.prescription.medicines = medicines
    @handlePrescriptionChanged()

  handlePrintClicked: =>
    @props.onCommit? false
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
      <div className="checkbox">
        <label>
          <input
            type="checkbox"
            checked={@props.prescription.routine}
            onChange={@handleRoutineChanged}
          /> Routine
        </label>
      </div>
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
      @props.onPrescriptionChange prescription
    printView = <PrescriptionPrintView prescription={@props.prescription} />
    Page.setPrintView printView

  componentWillUnmount: ->
    Page.unsetPrintView()
