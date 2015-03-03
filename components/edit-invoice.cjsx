clone = require "clone"
DateInput = require "./date-input"
EditPatient = require "./edit-patient"
EditServicesTable = require "./edit-services-table"
InvoicePrintView = require "./invoice-print-view"
moment = require "moment"
Page = require "./page"
padNumber = require "pad-number"
patientsCalls = require("../async-calls/patients").calls
React = require "react"
reactTypes = require "../react-types"
TextInput = require "./text-input"
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
      date: undefined
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

  handleCommentsChanged: (comments) =>
    @props.invoice.comments = comments
    @handleInvoiceChanged()

  handlePrintClicked: =>
    @props.onCommit? true, ->
      window.print()

  render: ->
    newPatientSuggestion =
      component: EditPatient
      dataProperty: "patient"
      commitMethod: patientsCalls.commitPatient
      removeMethod: patientsCalls.removePatient
    if @props.invoice.serial?
      serial =
        "#{@props.invoice.serial.year}-\
        #{padNumber @props.invoice.serial.number, 5}"
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
      <div className="form-group" style={position: "relative"}>
        <label>Comments</label>
        <TextInput
          type="text"
          className="form-control"
          value={@props.invoice.comments}
          onChange={@handleCommentsChanged}
        />
      </div>
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
      invoice.date = moment().toISOString()
      @props.onInvoiceChange invoice
    printView = <InvoicePrintView invoice={@props.invoice} />
    Page.setPrintView printView

  componentWillUnmount: ->
    Page.unsetPrintView()
