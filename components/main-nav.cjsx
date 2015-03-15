changeCase = require "change-case"
constants = require "../constants"
React = require "react"

navItems = [
  "Patients"
  "Prescriptions"
  "Billing"
  "Visit"
]

class module.exports extends React.Component
  @displayName: "MainNav"
  @propTypes:
    activeView:
      React.PropTypes.oneOf(navItems.map changeCase.paramCase).isRequired
    onActiveViewChange: React.PropTypes.func.isRequired

  handleActiveViewChanged: (str) ->
    @props.onActiveViewChange changeCase.paramCase str

  renderNavItem: (str, key) ->
    if changeCase.paramCase(str) is @props.activeView
      <li key={key} className="active">
        <a href="#">{str}</a>
      </li>
    else
      <li key={key} onClick={@handleActiveViewChanged.bind @, str}>
        <a href="#">{str}</a>
      </li>

  render: ->
    <nav className="navbar navbar-default navbar-fixed-top">
      <div className="container">
        <div className="navbar-header">
          <a className="navbar-brand" href="#">{constants.title}</a>
        </div>
        <ul className="nav navbar-nav navbar-right">
          {@renderNavItem x, i for x, i in navItems}
        </ul>
      </div>
    </nav>
