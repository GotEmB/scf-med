CommitCache = require "./commit-cache"
constants = require "../constants"
EditService = require "./edit-service"
escapeStringRegexp = require "escape-string-regexp"
Layers = require "./layers"
nextTick = require "next-tick"
React = require "react"
servicesCalls = require("../async-calls/services").calls
ServicesTable = require "./services-table"

class module.exports extends React.Component
  @displayName: "ManageServicesView"

  constructor: ->
    @state =
      filterQuery: ""
      services: []
      selectedService: undefined
      loadFrom: 0
      total: 0
      loading: false
      layer: undefined

  fetchServices: =>
    @setState loading: true
    servicesCalls.getServices escapeStringRegexp(@state.filterQuery),
      @state.loadFrom, constants.paginationLimit, (err, services, total) =>
        @setState
          services: services
          total: total
          loading: false

  handleFilterQueryChanged: (e) =>
    @setState
      filterQuery: e.target.value
      loadFrom: 0
    clearTimeout @filterQueryChangeTimer if @filterQueryChangeTimer?
    @filterQueryChangeTimer = setTimeout @fetchServices, 200

  handleNewServiceClicked: =>
    layer =
      <CommitCache
        component={EditService}
        data={undefined}
        dataProperty="service"
        commitMethod={servicesCalls.commitService}
        removeMethod={servicesCalls.removeService}
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, "New Service"

  handlePagerPreviousClicked: =>
    @setState
      loadFrom:
        Math.max 0, @state.loadFrom - constants.paginationLimit
    nextTick @fetchServices

  handlePagerNextClicked: =>
    @setState
      loadFrom:
        Math.min @state.total - constants.paginationLimit,
          @state.loadFrom + constants.paginationLimit
    nextTick @fetchServices

  handleServiceClicked: (service) =>
    layer =
      <CommitCache
        component={EditService}
        data={service}
        dataProperty="service"
        commitMethod={servicesCalls.commitService}
        removeMethod={servicesCalls.removeService}
        onDismiss={@handleLayerDismissed}
      />
    @setState
      selectedService: service
      layer: layer
    Layers.addLayer layer, "Edit Service"

  handleLayerDismissed: ({status}) =>
    Layers.removeLayer @state.layer
    @setState
      selectedService: undefined
      layer: undefined
    @fetchServices() if status in ["saved", "removed"]

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
      <button
        className="btn btn-default"
        onClick={@handleNewServiceClicked}>
        <i className="fa fa-pencil" /> New Service
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
      if @state.loadFrom + @state.services.length < @state.total
        <button
          className="btn btn-default"
          onClick={@handlePagerNextClicked}>
          <i className="fa fa-chevron-right" />
        </button>
    text =
      "#{@state.loadFrom + 1}—" +
      "#{@state.loadFrom + @state.services.length} of " +
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

  renderTable: ->
    <ServicesTable
      services={@state.services}
      selectedService={@state.selectedService}
      onServiceClick={@handleServiceClicked}
    />

  render: ->
    <div>
      {@renderControls()}
      <br />
      {@renderTable()}
    </div>

  componentDidMount: ->
    @fetchServices()

  componentWillUnmount: ->
    Layers.removeLayer @state.layer if @state.layer?
