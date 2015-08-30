CommitCache = require "./commit-cache"
Layers = require "./layers"
referralsCalls = require("../async-calls/referrals").calls
fitsCalls = require("../async-calls/fits").calls
unfitsCalls = require("../async-calls/unfits").calls
ReferralsView = require "./referrals-view"
FitsView = require "./fits-view"
UnfitsView = require "./unfits-view"
React = require "react"

class module.exports extends React.Component
  @displayName: "ReferralsView"

  handleUnfitClicked: =>
    layer =
      <CommitCache
        component={UnfitsView}
        data={undefined}
        dataProperty="unfit"
        commitMethod={unfitsCalls.commitUnfit}
        removeMethod={unfitsCalls.removeUnfit}
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, " Unfit"

  handleFitClicked: =>
    layer =
      <CommitCache
        component={FitsView}
        data={undefined}
        dataProperty="fit"
        commitMethod={fitsCalls.commitFit}
        removeMethod={fitsCalls.removeFit}
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, " Fit"

  handleReferralClicked: =>
    layer =
      <CommitCache
        component={ReferralsView}
        data={undefined}
        dataProperty="referral"
        commitMethod={referralsCalls.commitReferral}
        removeMethod={referralsCalls.removeReferral}
        onDismiss={@handleLayerDismissed}
      />
    @setState layer: layer
    Layers.addLayer layer, " Referral"

  handleLayerDismissed: ({status}) =>
    Layers.removeLayer @state.layer
    @setState
      selectedVital: undefined
      layer: undefined
    @fetchVitals() if status in ["saved", "removed"]

  render: ->
    <div className="form-inline pull-right">
      <button
        className="btn btn-default"
        onClick={@handleUnfitClicked}>
        Unfit
      </button>
      <span> </span>
      <button
        className="btn btn-default"
        onClick={@handleFitClicked}>
        Fit
      </button>
      <span> </span>
      <button
        className="btn btn-default"
        onClick={@handleReferralClicked}>
        Referral
      </button>
      <span> </span>
    </div>

  componentWillUnmount: ->
    Layers.removeLayer @state.layer if @state.layer?
