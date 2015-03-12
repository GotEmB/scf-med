CommitCache = require "./commit-cache"
constants = require "../constants"
drugsCalls = require("../async-calls/drugs").calls
EditBrandedDrug = require "./edit-branded-drug"
EditGenericDrug = require "./edit-generic-drug"
escapeStringRegexp = require "escape-string-regexp"
BrandedDrugsTable = require "./branded-drugs-table"
GenericDrugsTable = require "./generic-drugs-table"
Layers = require "./layers"
nextTick = require "next-tick"
React = require "react"

class module.exports extends React.Component
  @displayName: "ManageDrugsView"

  constructor: ->
    @state =
      which: "branded"
      filterQuery: ""
      drugs: []
      selectedDrug: undefined
      loadFrom: 0
      total: 0
      loading: false
      layer: undefined

  fetchDrugs: =>
    @setState loading: true
    getDrugs =
      switch @state.which
        when "generic" then drugsCalls.getGenericDrugs
        when "branded" then drugsCalls.getBrandedDrugs
    getDrugs escapeStringRegexp(@state.filterQuery), @state.loadFrom,
      constants.paginationLimit, (err, drugs, total) =>
        @setState
          drugs: drugs
          total: total
          loading: false

  handleWhichButtonClicked: (which) =>
    @setState
      which: which
      drugs: []
      selectedDrug: undefined
    nextTick @fetchDrugs

  handleFilterQueryChanged: (e) =>
    @setState
      filterQuery: e.target.value
      loadFrom: 0
    clearTimeout @filterQueryChangeTimer if @filterQueryChangeTimer?
    @filterQueryChangeTimer = setTimeout @fetchDrugs, 200

  handleNewDrugClicked: =>
    switch @state.which
      when "generic"
        EditComponent = EditGenericDrug
        dataProperty = "genericDrug"
        title = "New Generic Drug"
        commitDrug = drugsCalls.commitGenericDrug
        removeDrug = drugsCalls.removeGenericDrug
      when "branded"
        EditComponent = EditBrandedDrug
        dataProperty = "brandedDrug"
        title = "New Branded Drug"
        commitDrug = drugsCalls.commitBrandedDrug
        removeDrug = drugsCalls.removeBrandedDrug
    layer =
      <CommitCache
        component={EditComponent}
        data={undefined}
        dataProperty={dataProperty}
        commitMethod={commitDrug}
        removeMethod={removeDrug}
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, title

  handlePagerPreviousClicked: =>
    @setState
      loadFrom:
        Math.max 0, @state.loadFrom - constants.paginationLimit
    nextTick @fetchDrugs

  handlePagerNextClicked: =>
    @setState
      loadFrom:
        Math.min @state.total - constants.paginationLimit,
          @state.loadFrom + constants.paginationLimit
    nextTick @fetchDrugs

  handleDrugClicked: (drug) =>
    switch @state.which
      when "generic"
        EditComponent = EditGenericDrug
        dataProperty = "genericDrug"
        title = "Edit Generic Drug"
        commitDrug = drugsCalls.commitGenericDrug
        removeDrug = drugsCalls.removeGenericDrug
      when "branded"
        EditComponent = EditBrandedDrug
        dataProperty = "brandedDrug"
        title = "Edit Branded Drug"
        commitDrug = drugsCalls.commitBrandedDrug
        removeDrug = drugsCalls.removeBrandedDrug
    layer =
      <CommitCache
        component={EditComponent}
        data={drug}
        dataProperty={dataProperty}
        commitMethod={commitDrug}
        removeMethod={removeDrug}
        onDismiss={@handleLayerDismissed}
      />
    @setState
      selectedDrug: drug
      layer: layer
    Layers.addLayer layer, title

  handleLayerDismissed: ({status}) =>
    Layers.removeLayer @state.layer
    @setState
      selectedDrug: undefined
      layer: undefined
    @fetchDrugs() if status in ["saved", "removed"]

  renderWhichSelect: ->
    genericDrugButtonClassName = "btn btn-default col-sm-6"
    brandedDrugButtonClassName = "btn btn-default col-sm-6"
    switch @state.which
      when "generic"
        genericDrugButtonClassName += " active"
      when "branded"
        brandedDrugButtonClassName += " active"
    <div className="row" style={marginBottom: 20}>
      <div className="btn-group col-sm-4 col-sm-offset-4">
        <button
          className={brandedDrugButtonClassName}
          onClick={@handleWhichButtonClicked.bind @, "branded"}>
          Branded Drug
        </button>
        <button
          className={genericDrugButtonClassName}
          onClick={@handleWhichButtonClicked.bind @, "generic"}>
          Generic Drug
        </button>
      </div>
    </div>

  renderLeftControls: ->
    newButtonText =
      switch @state.which
        when "generic" then "New Generic Drug"
        when "branded" then "New Branded Drug"
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
        onClick={@handleNewDrugClicked}>
        <i className="fa fa-pencil" /> {newButtonText}
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
      if @state.loadFrom + @state.drugs.length < @state.total
        <button
          className="btn btn-default"
          onClick={@handlePagerNextClicked}>
          <i className="fa fa-chevron-right" />
        </button>
    text =
      "#{@state.loadFrom + 1}—" +
      "#{@state.loadFrom + @state.drugs.length} of " +
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
      {@renderWhichSelect()}
      {@renderLeftControls()}
      {@renderRightControls()}
      <div className="clearfix" />
    </div>

  renderTable: ->
    switch @state.which
      when "generic"
        <GenericDrugsTable
          genericDrugs={@state.drugs}
          selectedGenericDrug={@state.selectedDrug}
          onGenericDrugClick={@handleDrugClicked}
        />
      when "branded"
        <BrandedDrugsTable
          brandedDrugs={@state.drugs}
          selectedBrandedDrug={@state.selectedDrug}
          onBrandedDrugClick={@handleDrugClicked}
        />

  render: ->
    <div>
      {@renderControls()}
      <br />
      {@renderTable()}
    </div>

  componentDidMount: ->
    @fetchDrugs()

  componentWillUnmount: ->
    Layers.removeLayer @state.layer if @state.layer?
