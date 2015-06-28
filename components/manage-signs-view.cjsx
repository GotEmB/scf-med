CommitCache = require "./commit-cache"
constants = require "../constants"
EditSign = require "./edit-sign"
escapeStringRegexp = require "escape-string-regexp"
Layers = require "./layers"
nextTick = require "next-tick"
React = require "react"
signsCalls = require("../async-calls/signs").calls
SignsTable = require "./signs-table"

class module.exports extends React.Component
  @displayName: "ManageSignsView"

  constructor: ->
    @state =
      filterQuery: ""
      signs: []
      selectedSign: undefined
      loadFrom: 0
      total: 0
      loading: false
      layer: undefined

  fetchSigns: =>
    @setState loading: true
    signsCalls.getSigns escapeStringRegexp(@state.filterQuery),
      @state.loadFrom, constants.paginationLimit, (err, signs, total) =>
        @setState
          signs: signs
          total: total
          loading: false

  handleFilterQueryChanged: (e) =>
    @setState
      filterQuery: e.target.value
      loadFrom: 0
    clearTimeout @filterQueryChangeTimer if @filterQueryChangeTimer?
    @filterQueryChangeTimer = setTimeout @fetchSigns, 200

  handleNewSignClicked: =>
    layer =
      <CommitCache
        component={EditSign}
        data={undefined}
        dataProperty="sign"
        commitMethod={signsCalls.commitSign}
        removeMethod={signsCalls.removeSign}
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, "New Sign"

  handlePagerPreviousClicked: =>
    @setState
      loadFrom:
        Math.max 0, @state.loadFrom - constants.paginationLimit
    nextTick @fetchSigns

  handlePagerNextClicked: =>
    @setState
      loadFrom:
        Math.min @state.total - constants.paginationLimit,
          @state.loadFrom + constants.paginationLimit
    nextTick @fetchSigns

  handleSignClicked: (sign) =>
    layer =
      <CommitCache
        component={EditSign}
        data={sign}
        dataProperty="sign"
        commitMethod={signsCalls.commitSign}
        removeMethod={signsCalls.removeSign}
        onDismiss={@handleLayerDismissed}
      />
    @setState
      selectedSign: sign
      layer: layer
    Layers.addLayer layer, "Edit Sign"

  handleLayerDismissed: ({status}) =>
    Layers.removeLayer @state.layer
    @setState
      selectedSign: undefined
      layer: undefined
    @fetchSigns() if status in ["saved", "removed"]

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
        onClick={@handleNewSignClicked}>
        <i className="fa fa-pencil" /> New Sign
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
      if @state.loadFrom + @state.signs.length < @state.total
        <button
          className="btn btn-default"
          onClick={@handlePagerNextClicked}>
          <i className="fa fa-chevron-right" />
        </button>
    text =
      "#{@state.loadFrom + 1}—" +
      "#{@state.loadFrom + @state.signs.length} of " +
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
    <SignsTable
      signs={@state.signs}
      selectedSign={@state.selectedSign}
      onSignClick={@handleSignClicked}
    />

  render: ->
    <div>
      {@renderControls()}
      <br />
      {@renderTable()}
    </div>

  componentDidMount: ->
    @fetchSigns()

  componentWillUnmount: ->
    Layers.removeLayer @state.layer if @state.layer?
