clone = require "clone"
CommitCache = require "./commit-cache"
constants = require "../constants"
escapeStringRegexp = require "escape-string-regexp"
DateRangeInput = require "./date-range-input"
EditMedical = require "./edit-medical"
Layers = require "./layers"
moment = require "moment"
nextTick = require "next-tick"
medicalsCalls = require("../async-calls/medicals").calls
MedicalsTable = require "./medicals-table"
React = require "react"

class module.exports extends React.Component
  @displayName: "MedicalsView"

  constructor: ->
    @state =
      filterQuery: ""
      queryStartDate: moment().subtract(3, "month").toDate()
      queryEndDate: moment().endOf("day").toDate()
      medicals: []
      selectedMedical: undefined
      loadFrom: 0
      total: 0
      loading: false
      layer: undefined

  fetchMedicals: =>
    @setState loading: true
    query =
      text: @state.filterQuery
      daterange:
        from: @state.queryStartDate
        to: @state.queryEndDate
    medicalsCalls.getMedicals query, @state.loadFrom,
      constants.paginationLimit, (err, medicals, total) =>
        @setState
          medicals: medicals
          total: total
          loading: false

  handleFilterQueryChanged: (e) =>
    @setState
      filterQuery: e.target.value
      loadFrom: 0
    clearTimeout @filterQueryChangeTimer if @filterQueryChangeTimer?
    @filterQueryChangeTimer = setTimeout @fetchMedicals, 200

  handleQueryDateRangeChanged: ({startDate, endDate}) =>
    @setState
      queryStartDate: startDate
      queryEndDate: endDate
    clearTimeout @filterQueryChangeTimer if @filterQueryChangeTimer?
    @filterQueryChangeTimer = setTimeout @fetchMedicals, 200

  handleNewMedicalClicked: =>
    layer =
      <CommitCache
        component={EditMedical}
        data={undefined}
        dataProperty="medical"
        commitMethod={medicalsCalls.commitMedical}
        removeMethod={medicalsCalls.removeMedical}
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, "New Medical"

  handlePagerPreviousClicked: =>
    @setState
      loadFrom:
        Math.max 0, @state.loadFrom - constants.paginationLimit
    nextTick @fetchMedicals

  handlePagerNextClicked: =>
    @setState
      loadFrom:
        Math.min @state.total - constants.paginationLimit,
          @state.loadFrom + constants.paginationLimit
    nextTick @fetchMedicals

  handleMedicalClicked: (medical) =>
    layer =
      <CommitCache
        component={EditMedical}
        data={medical}
        dataProperty="medical"
        commitMethod={medicalsCalls.commitMedical}
        removeMethod={medicalsCalls.removeMedical}
        onDismiss={@handleLayerDismissed}
      />
    @setState
      selectedMedical: medical
      layer: layer
    Layers.addLayer layer, "Edit Medical"

  handleLayerDismissed: ({status}) =>
    Layers.removeLayer @state.layer
    @setState
      selectedMedical: undefined
      layer: undefined
    @fetchMedicals() if status in ["saved", "removed"]

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
        onClick={@handleNewMedicalClicked}>
        <i className="fa fa-pencil" /> New Medical
      </button>
      <span> </span>
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
      if @state.loadFrom + @state.medicals.length < @state.total
        <button
          className="btn btn-default"
          onClick={@handlePagerNextClicked}>
          <i className="fa fa-chevron-right" />
        </button>
    text =
      "#{@state.loadFrom + 1}—" +
      "#{@state.loadFrom + @state.medicals.length} of " +
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
      <MedicalsTable
        medicals={@state.medicals}
        selectedMedical={@state.selectedMedical}
        onMedicalClick={@handleMedicalClicked}
      />
    </div>

  componentDidMount: ->
    @fetchMedicals()

  componentWillUnmount: ->
    Layers.removeLayer @state.layer if @state.layer?
