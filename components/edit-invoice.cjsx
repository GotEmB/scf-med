clone = require "clone"
DateInput = require "./date-input"
EditPatient = require "./edit-patient"
EditServicesTable = require "./edit-services-table"
InvoicePrintView = require "./invoice-print-view"
Page = require "./page"
patientsCalls = require("../async-calls/patients").calls
React = require "react"
reactTypes = require "../react-types"
TypeaheadSelect = require "./typeahead-select"

class module.exports extends React.Component
  @displayName: "EditInvoice"

  @propTypes:
    invoice: reactTypes.invoice
    onInvoiceChange: React.PropTypes.func.isRequired
    onCommit: React.PropTypes.func

  @defaultProps:
    invoice:
      patient: undefined
      date: new Date()
      services: []
      routine: false

  handleInvoiceChanged: =>
    @props.onInvoiceChange @props.invoice
    printView = <InvoicePrintView invoice={@props.invoice} />
    Page.setPrintView printView

  handleDateChanged: (date) =>
    @props.invoice.date = date
    @handleInvoiceChanged()

  handlePatientChanged: (patient) =>
    @props.invoice.patient = patient
    @handleInvoiceChanged()

  handleRoutineChanged: (e) =>
    @props.invoice.routine = e.target.checked
    @handleInvoiceChanged()

  handleServicesChanged: (services) =>
    @props.invoice.services = services
    @handleInvoiceChanged()

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
          date={@props.invoice.date}
          onDateChange={@handleDateChanged}
          hasTime={true}
          className="form-control"
        />
      </div>
      <TypeaheadSelect
        selectedItem={@props.invoice.patient}
        onSelectedItemChange={@handlePatientChanged}
        suggestionsFetcher={patientsCalls.getPatients}
        textFormatter={(x) -> x.name}
        label="Patient"
        newSuggestion={newPatientSuggestion}
      />
      <EditServicesTable
        services={@props.invoice.services}
        onServicesChange={@handleServicesChanged}
      />
      <div className="text-center">
        <button className="btn btn-primary" onClick={@handlePrintClicked}>
          <i className="fa fa-print" /> Save & Print
        </button>
      </div>
    </div>

  componentWillMount: ->
    if Object.keys(@props.invoice).length is 0
      invoice = clone @constructor.defaultProps.invoice
      @props.onInvoiceChange invoice
    printView = <InvoicePrintView invoice={@props.invoice} />
    Page.setPrintView printView

  componentWillUnmount: ->
    Page.unsetPrintView()
