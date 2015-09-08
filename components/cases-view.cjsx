clone = require "clone"
CommitCache = require "./commit-cache"
constants = require "../constants"
escapeStringRegexp = require "escape-string-regexp"
Layers = require "./layers"
moment = require "moment"
nextTick = require "next-tick"
MemosView = require "./memos-view"
VisitsView = require "./visits-view"
VitalsView = require "./vitals-view"
ReferralsView = require "./referrals-view"
FitsView = require "./fits-view"
UnfitsView = require "./unfits-view"
React = require "react"

class module.exports extends React.Component
  @displayName: "CasesView"

  handleVisitClicked: =>
    layer =
      <CommitCache
        component={VisitsView}
        data={undefined}
        dataProperty="visit"
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, "Visits"

  handleVitalClicked: =>
    layer =
    layer =
      <CommitCache
        component={VitalsView}
        data={undefined}
        dataProperty="vital"
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, "Vitals"

  handleReferralClicked: =>
    layer =
      <CommitCache
        component={ReferralsView}
        data={undefined}
        dataProperty="referral"
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, "Referrals"

  handleFitClicked: =>
    layer =
      <CommitCache
        component={FitsView}
        data={undefined}
        dataProperty="fit"
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, "Fitness Certificates"

  handleUnfitClicked: =>
    layer =
      <CommitCache
        component={UnfitsView}
        data={undefined}
        dataProperty="Unfit"
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, "Unfitness Certificates"

  handleLayerDismissed: ({status}) =>
    Layers.removeLayer @state.layer

  handleMemoClicked: =>
    layer =
      <CommitCache
        component={MemosView}
        data={undefined}
        dataProperty="Memo"
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, "Memos"

  handleLayerDismissed: ({status}) =>
    Layers.removeLayer @state.layer

  render: ->
    <div className="form-inline pull-right">
      <button
        className="btn btn-default"
        onClick={@handleVisitClicked}>
        <i className="fa fa-pencil" /> Visits
      </button>
      <span> </span>
      <button
        className="btn btn-default"
        onClick={@handleVitalClicked}>
        <i className="fa fa-pencil" /> Vitals
      </button>
      <span> </span>
      <button
        className="btn btn-default"
        onClick={@handleReferralClicked}>
        <i className="fa fa-pencil" /> Referrals
      </button>
      <button
        className="btn btn-default"
        onClick={@handleReferralClicked}>
        <i className="fa fa-pencil" /> Fit
      </button>
      <button
        className="btn btn-default"
        onClick={@handleUnfitClicked}>
        <i className="fa fa-pencil" /> Unfit
      </button>
      <button
        className="btn btn-default"
        onClick={@handleMemoClicked}>
        <i className="fa fa-pencil" /> Memo
      </button>
    </div>

  componentWillUnmount: ->
    Layers.removeLayer @state.layer if @state.layer?
