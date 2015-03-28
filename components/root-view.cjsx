BillingView = require "./billing-view"
InvestigationsView = require "./investigations-view"
MainNav = require "./main-nav"
PatientsView = require "./patients-view"
PrescriptionsView = require "./prescriptions-view"
VisitView = require "./visit-view"
React = require "react"

class module.exports extends React.Component
  @displayName: "RootView"

  constructor: ->
    @state =
      activeView: "patients"
      patient: undefined

  handleActiveViewChanged: (str) =>
    @setState activeView: str

  handlePatientChanged: (patient) =>
    @setState patient: patient

  render: ->
    activeView =
      switch @state.activeView
        when "patients"
          <PatientsView />
        when "visits"
          <VisitView />
        when "prescriptions"
          <PrescriptionsView />
        when "investigations"
          <InvestigationsView />
        when "billing"
          <BillingView />
    <div>
      <MainNav
        activeView={@state.activeView}
        onActiveViewChange={@handleActiveViewChanged}
      />
      <div className="container">
        {activeView}
      </div>
    </div>
