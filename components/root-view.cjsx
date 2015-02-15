AboutView = require "./root-view/about-view"
MainNav = require "./root-view/main-nav"
React = require "react"

class module.exports extends React.Component
  @displayName: "RootView"

  constructor: ->
    @state =
      activeView: "about"

  handleActiveViewChanged: (str) ->
    @setState activeView: str

  render: ->
    activeView =
      switch @state.activeView
        when "about"
          <AboutView />
    <div> 
      <MainNav
        activeView={@state.activeView}
        onActiveViewChange={@handleActiveViewChanged}
      />
      {activeView}
    </div>
