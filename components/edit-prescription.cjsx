clone = require "clone"
DateInput = require "./date-input"
EditMedicinesTable = require "./edit-medicines-table"
patientsCalls = require("../async-calls/patients").calls
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

  handleDateChanged: (date) =>
    @props.prescription.date = date
    @props.onPrescriptionChange @props.prescription

  handlePatientChanged: (patient) =>
    @props.prescription.patient = patient
    @props.onPrescriptionChange @props.prescription

  handleMedicinesChanged: (medicines) =>
    @props.prescription.medicines = medicines
    @props.onPrescriptionChange @props.prescription

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
    </div>

  componentWillMount: ->
    if Object.keys(@props.prescription).length is 0
      prescription = clone @constructor.defaultProps.prescription
      @props.onPrescriptionChange prescription
