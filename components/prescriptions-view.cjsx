clone = require "clone"
CommitCache = require "./commit-cache"
constants = require "../constants"
escapeStringRegexp = require "escape-string-regexp"
DateRangeInput = require "./date-range-input"
EditPrescription = require "./edit-prescription"
Layers = require "./layers"
ManageDrugsView = require "./manage-drugs-view"
moment = require "moment"
nextTick = require "next-tick"
prescriptionsCalls = require("../async-calls/prescriptions").calls
PrescriptionsTable = require "./prescriptions-table"
React = require "react"

class module.exports extends React.Component
  @displayName: "PrescriptionsView"

  constructor: ->
    @state =
      filterQuery: ""
      queryStartDate: moment().subtract(3, "month").toDate()
      queryEndDate: moment().endOf("day").toDate()
      prescriptions: []
      selectedPrescription: undefined
      loadFrom: 0
      total: 0
      loading: false
      layer: undefined

  fetchPrescriptions: =>
    @setState loading: true
    query =
      text: @state.filterQuery
      daterange:
        from: @state.queryStartDate
        to: @state.queryEndDate
    prescriptionsCalls.getPrescriptions query, @state.loadFrom,
      constants.paginationLimit, (err, prescriptions, total) =>
        @setState
          prescriptions: prescriptions
          total: total
          loading: false

  handleFilterQueryChanged: (e) =>
    @setState
      filterQuery: e.target.value
      loadFrom: 0
    clearTimeout @filterQueryChangeTimer if @filterQueryChangeTimer?
    @filterQueryChangeTimer = setTimeout @fetchPrescriptions, 200

  handleQueryDateRangeChanged: ({startDate, endDate}) =>
    @setState
      queryStartDate: startDate
      queryEndDate: endDate
    clearTimeout @filterQueryChangeTimer if @filterQueryChangeTimer?
    @filterQueryChangeTimer = setTimeout @fetchPrescriptions, 200

  handleNewPrescriptionClicked: =>
    layer =
      <CommitCache
        component={EditPrescription}
        data={undefined}
        dataProperty="prescription"
        commitMethod={prescriptionsCalls.commitPrescription}
        removeMethod={prescriptionsCalls.removePrescription}
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, "New Prescription"

  handleManageDrugsClicked: =>
    closeButtonStyle =
      position: "absolute"
      top: 0
      right: 0
      padding: "2.5px 0"
      outline: 0
    layer =
      <div style={position: "relative"}>
        <ManageDrugsView />
        <button
          className="close"
          onClick={@handleLayerDismissed}
          style={closeButtonStyle}>
          <span className="lead">✕</span>
        </button>
      </div>
    @setState layer: layer
    Layers.addLayer layer

  handlePagerPreviousClicked: =>
    @setState
      loadFrom:
        Math.max 0, @state.loadFrom - constants.paginationLimit
    nextTick @fetchPrescriptions

  handlePagerNextClicked: =>
    @setState
      loadFrom:
        Math.min @state.total - constants.paginationLimit,
          @state.loadFrom + constants.paginationLimit
    nextTick @fetchPrescriptions

  handlePrescriptionClicked: (prescription) =>
    layer =
      <CommitCache
        component={EditPrescription}
        data={prescription}
        dataProperty="prescription"
        commitMethod={prescriptionsCalls.commitPrescription}
        removeMethod={prescriptionsCalls.removePrescription}
        onDismiss={@handleLayerDismissed}
      />
    @setState
      selectedPrescription: prescription
      layer: layer
    Layers.addLayer layer, "Edit Prescription"

  handlePrescriptionRoutineClicked: (prescription) =>
    duplicatePrescription = clone prescription
    delete duplicatePrescription._id
    duplicatePrescription.date = moment().toISOString()
    layer =
      <CommitCache
        component={EditPrescription}
        data={duplicatePrescription}
        dataProperty="prescription"
        commitMethod={prescriptionsCalls.commitPrescription}
        removeMethod={prescriptionsCalls.removePrescription}
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, "Duplicate Prescription"

  handleLayerDismissed: ({status}) =>
    Layers.removeLayer @state.layer
    @setState
      selectedPrescription: undefined
      layer: undefined
    @fetchPrescriptions() if status in ["saved", "removed"]

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
        onClick={@handleNewPrescriptionClicked}>
        <i className="fa fa-pencil" /> New Prescription
      </button>
      <span> </span>
      <button
        className="btn btn-default"
        onClick={@handleManageDrugsClicked}>
        <i className="fa fa-th-list" /> Manage Drugs
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
      if @state.loadFrom + @state.prescriptions.length < @state.total
        <button
          className="btn btn-default"
          onClick={@handlePagerNextClicked}>
          <i className="fa fa-chevron-right" />
        </button>
    text =
      "#{@state.loadFrom + 1}—" +
      "#{@state.loadFrom + @state.prescriptions.length} of " +
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
      <PrescriptionsTable
        prescriptions={@state.prescriptions}
        selectedPrescription={@state.selectedPrescription}
        onPrescriptionClick={@handlePrescriptionClicked}
        onPrescriptionRoutineClick={@handlePrescriptionRoutineClicked}
      />
    </div>

  componentDidMount: ->
    @fetchPrescriptions()

  componentWillUnmount: ->
    Layers.removeLayer @state.layer if @state.layer?
