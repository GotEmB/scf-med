BillingView = require "./billing-view"
MainNav = require "./main-nav"
PatientsView = require "./patients-view"
VisitsView = require "./visits-view"
PrescriptionsView = require "./prescriptions-view"
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
          <VisitsView />
        when "prescriptions"
          <PrescriptionsView />
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
