clone = require "clone"
DateInput = require "./date-input"
EditMedicinesTable = require "./edit-medicines-table"
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

  @defaultProps:
    prescription:
      patient: undefined
      date: new Date()
      medicines: []

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

  handleMedicinesChanged: (medicines) =>
    @props.prescription.medicines = medicines
    @handlePrescriptionChanged()

  handlePrintClicked: =>
    window.print()

  render: ->
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
      />
      <EditMedicinesTable
        medicines={@props.prescription.medicines}
        onMedicinesChange={@handleMedicinesChanged}
      />
      <div className="text-center">
        <button className="btn btn-primary" onClick={@handlePrintClicked}>
          <i className="fa fa-print" /> Print
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
