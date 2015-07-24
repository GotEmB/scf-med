CommitCache = require "./commit-cache"
constants = require "../constants"
EditUnfit = require "./edit-unfit"
EditFit = require "./edit-fit"
escapeStringRegexp = require "escape-string-regexp"
unfitCalls = require("../async-calls/unfit").calls
fitCalls = require("../async-calls/fit").calls
Layers = require "./layers"
moment = require "moment"
nextTick = require "next-tick"
Page = require "./page"
React = require "react"

class module.exports extends React.Component
  @displayName: "MemoView"

  handleUnfitClicked: =>
    layer =
      <CommitCache
        component={EditUnfit}
        data={undefined}
        dataProperty="unfit"
        commitMethod={unfitCalls.commitUnfit}
        removeMethod={unfitCalls.removeUnfit}
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, "Unfit To Work"

  handleFitClicked: =>
    layer =
      <CommitCache
        component={EditFit}
        data={undefined}
        dataProperty="fit"
        commitMethod={fitCalls.commitFit}
        removeMethod={fitCalls.removeFit}
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, "Fit To Work"

  handleLayerDismissed: ({status}) =>
    Layers.removeLayer @state.layer
    @setState
      selectedMemo: undefined
      layer: undefined

  renderControls: ->
    <div className="form-inline pull-left">
      <button
        className="btn btn-default"
        onClick={@handleUnfitClicked}>
        <i className="fa fa-pencil" /> Unfit To Work
      </button>
      <span> </span>
      <button
        className="btn btn-default"
        onClick={@handleFitClicked}>
        <i className="fa fa-pencil" /> Fit To Work
      </button>
      <span> </span>
    </div>

  render: ->
    <div>
      {@renderControls()}
    </div>

  componentWillMount: ->
    @canSetState = true

  componentWillUnmount: ->
    Layers.removeLayer @state.layer if @state.layer?
    @canSetState = false
