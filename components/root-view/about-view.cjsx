leAPICalls = require("../../async-calls/le-api").calls
React = require "react"

class module.exports extends React.Component
  @displayName: "AboutView"

  constructor: ->
    @state =
      name: ""
      message: ""

  handleNameChanged: (e) =>
    @setState name: e.target.value
    @setSalutation e.target.value

  setSalutation: (name) =>
    leAPICalls.salute (name ? ""), (message) =>
      @setState message: message

  render: =>
    <div className="container">
      <div className="form-group">
        <label>Your Name:</label>
        <input
          className="form-control"
          type="text"
          value={@state.name}
          onChange={@handleNameChanged}
        />
      </div>
      <br />
      <div className="lead">
        {@state.message}
      </div>
    </div>

  componentDidMount: ->
    @setSalutation()
