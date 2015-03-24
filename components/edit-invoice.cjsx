clone = require "clone"
DateInput = require "./date-input"
deepDiff = require "deep-diff"
EditPatient = require "./edit-patient"
EditServicesTable = require "./edit-services-table"
InvoicePrintView = require "./invoice-print-view"
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

  componentWillReceiveProps: (props) ->
    if deepDiff(@props.invoice, props.invoice)?
      printView = <InvoicePrintView invoice={props.invoice} />
      Page.setPrintView printView

  handleDateChanged: (date) =>
    invoice = clone @props.invoice
    invoice.date = date
    @props.onInvoiceChange invoice

  handlePatientChanged: (patient) =>
    invoice = clone @props.invoice
    invoice.patient = patient
    @props.onInvoiceChange invoice

  handleServicesChanged: (services) =>
    invoice = clone @props.invoice
    invoice.services = services
    @props.onInvoiceChange invoice

  handleCommentsChanged: (comments) =>
    invoice = clone @props.invoice
    invoice.comments = comments
    @props.onInvoiceChange invoice

  handleCopayChanged: (copay) =>
    invoice = clone @props.invoice
    invoice.copay = copay
    @props.onInvoiceChange invoice

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
    copayNoneButtonClassName = "btn btn-default"
    copaySilverButtonClassName = "btn btn-default"
    copayGoldButtonClassName = "btn btn-default"
    switch @props.invoice.copay
      when 0 then copayNoneButtonClassName += " active"
      when 25 then copaySilverButtonClassName += " active"
      when 50 then copayGoldButtonClassName += " active"
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
      <div className="form-group">
        <label>Copay</label>
        <div className="btn-group" style={display: "block"}>
          <button
            className={copayNoneButtonClassName}
            onClick={@handleCopayChanged.bind @, 0}>
            None
          </button>
          <button
            className={copaySilverButtonClassName}
            onClick={@handleCopayChanged.bind @, 25}>
            Dhs 25.00
          </button>
          <button
            className={copayGoldButtonClassName}
            onClick={@handleCopayChanged.bind @, 50}>
            Dhs 50.00
          </button>
        </div>
        <div className="clearfix" />
      </div>
      <EditServicesTable
        services={@props.invoice.services}
        onServicesChange={@handleServicesChanged}
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
