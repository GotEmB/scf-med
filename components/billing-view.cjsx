CommitCache = require "./commit-cache"
constants = require "../constants"
DateRangeInput = require "./date-range-input"
EditInvoice = require "./edit-invoice"
escapeStringRegexp = require "escape-string-regexp"
invoicesCalls = require("../async-calls/invoices").calls
InvoicesReportPrintView = require "./invoices-report-print-view"
InvoicesTable = require "./invoices-table"
Layers = require "./layers"
ManageServicesView = require "./manage-services-view"
moment = require "moment"
nextTick = require "next-tick"
Page = require "./page"
React = require "react"

class module.exports extends React.Component
  @displayName: "BillingView"

  constructor: ->
    @state =
      filterQuery: ""
      queryStartDate: moment().subtract(1, "month").toDate()
      queryEndDate: moment().endOf("day").toDate()
      invoices: []
      selectedInvoice: undefined
      loadFrom: 0
      total: 0
      loading: false
      layer: undefined
      printView: undefined

  fetchInvoices: =>
    @setState loading: true
    query =
      text: @state.filterQuery
      daterange:
        from: @state.queryStartDate
        to: @state.queryEndDate
    invoicesCalls.getInvoices query, @state.loadFrom,
      constants.paginationLimit, (err, invoices, total) =>
        @setState
          invoices: invoices
          total: total
          loading: false

  handleFilterQueryChanged: (e) =>
    @setState
      filterQuery: e.target.value
      loadFrom: 0
    clearTimeout @filterQueryChangeTimer if @filterQueryChangeTimer?
    @filterQueryChangeTimer = setTimeout @fetchInvoices, 200

  handleQueryDateRangeChanged: ({startDate, endDate}) =>
    @setState
      queryStartDate: startDate
      queryEndDate: endDate
    clearTimeout @filterQueryChangeTimer if @filterQueryChangeTimer?
    @filterQueryChangeTimer = setTimeout @fetchInvoices, 200

  handleNewInvoiceClicked: =>
    layer =
      <CommitCache
        component={EditInvoice}
        data={undefined}
        dataProperty="invoice"
        commitMethod={invoicesCalls.commitInvoice}
        removeMethod={invoicesCalls.removeInvoice}
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, "New Invoice"

  handleManageServicesClicked: =>
    closeButtonStyle =
      position: "absolute"
      top: -50
      right: 0
      padding: "2.5px 0"
      outline: 0
    layer =
      <div style={position: "relative"}>
        <ManageServicesView />
        <button
          className="close"
          onClick={@handleLayerDismissed}
          style={closeButtonStyle}>
          <span className="lead">✕</span>
        </button>
      </div>
    @setState layer: layer
    Layers.addLayer layer, "Manage Services"

  handleConsolidatedReportClicked: (e) =>
    @setState loading: true
    query =
      daterange:
        from: @state.queryStartDate
        to: @state.queryEndDate
    invoicesCalls.getInvoices query, 0, 99999, (err, invoices, total) =>
      invoices.reverse()
      @setState loading: false
      printView =
        <InvoicesReportPrintView
          invoices={invoices}
          fromDate={@state.queryStartDate}
          toDate={@state.queryEndDate}
        />
      @setState printView: printView
      Page.setPrintView printView
      nextTick =>
        window.print()
        setTimeout ( =>
          if @state.printView is printView
            Page.unsetPrintView()
            @setState printView: undefined if @canSetState
        ), 1000
    e.stopPropagation()

  handlePagerPreviousClicked: =>
    @setState
      loadFrom:
        Math.max 0, @state.loadFrom - constants.paginationLimit
    nextTick @fetchInvoices

  handlePagerNextClicked: =>
    @setState
      loadFrom:
        Math.min @state.total - constants.paginationLimit,
          @state.loadFrom + constants.paginationLimit
    nextTick @fetchInvoices

  handleInvoiceClicked: (invoice) =>
    layer =
      <CommitCache
        component={EditInvoice}
        data={invoice}
        dataProperty="invoice"
        commitMethod={invoicesCalls.commitInvoice}
        removeMethod={invoicesCalls.removeInvoice}
        onDismiss={@handleLayerDismissed}
      />
    @setState
      selectedInvoice: invoice
      layer: layer
    Layers.addLayer layer, "Edit Invoice"

  handleLayerDismissed: ({status}) =>
    Layers.removeLayer @state.layer
    @setState
      selectedInvoice: undefined
      layer: undefined
    @fetchInvoices() if status in ["saved", "removed"]

  renderLeftControls: ->
    <div className="form-inline pull-left">
      <div className="input-group">
        <span className="input-group-addon">
          <i className="fa fa-filter" />
        </span>
        <input
          type="text"
          className="form-control"
          value={@state.filterQuery}
          placeholder="Filter"
          onChange={@handleFilterQueryChanged}
        />
      </div>
      <span> </span>
      <div className="input-group">
        <span className="input-group-addon">
          <i className="fa fa-calendar" />
        </span>
        <DateRangeInput
          className="form-control"
          style={width: 200}
          startDate={@state.queryStartDate}
          endDate={@state.queryEndDate}
          onDateRangeChange={@handleQueryDateRangeChanged}
        />
      </div>
      <span> </span>
      <button
        className="btn btn-default"
        onClick={@handleNewInvoiceClicked}>
        <i className="fa fa-pencil" /> New Invoice
      </button>
      <span> </span>
      <button
        className="btn btn-default"
        onClick={@handleManageServicesClicked}>
        <i className="fa fa-th-list" /> Manage Services
      </button>
      <span> </span>
      <button
        className="btn btn-default"
        onClick={@handleConsolidatedReportClicked}>
        <i className="fa fa-file-text" /> Report
      </button>
    </div>

  renderRightControls: ->
    loader =
      if @state.loading
        <button className="btn btn-link" disabled style={color: "inherit"}>
          <i className="fa fa-circle-o-notch fa-spin fa-fw" />
        </button>
    leftButton =
      if @state.loadFrom > 0
        <button
          className="btn btn-default"
          onClick={@handlePagerPreviousClicked}>
          <i className="fa fa-chevron-left" />
        </button>
    rightButton =
      if @state.loadFrom + @state.invoices.length < @state.total
        <button
          className="btn btn-default"
          onClick={@handlePagerNextClicked}>
          <i className="fa fa-chevron-right" />
        </button>
    text =
      "#{@state.loadFrom + 1}—" +
      "#{@state.loadFrom + @state.invoices.length} of " +
      "#{@state.total}"
    <div className="pull-right">
      <div className="pull-right btn-group">
        {loader}
        {leftButton}
        <button className="btn btn-default" disabled>{text}</button>
        {rightButton}
      </div>
    </div>

  renderControls: ->
    <div>
      {@renderLeftControls()}
      {@renderRightControls()}
      <div className="clearfix" />
    </div>

  render: ->
    <div>
      {@renderControls()}
      <br />
      <InvoicesTable
        invoices={@state.invoices}
        selectedInvoice={@state.selectedInvoice}
        onInvoiceClick={@handleInvoiceClicked}
      />
    </div>

  componentWillMount: ->
    @canSetState = true

  componentDidMount: ->
    @fetchInvoices()

  componentWillUnmount: ->
    Layers.removeLayer @state.layer if @state.layer?
    @canSetState = false
