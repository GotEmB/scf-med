clone = require "clone"
React = require "react"
reactTypes = require "../react-types"
TextInput = require "./text-input"

class module.exports extends React.Component
  @displayName: "EditInvestigation"

  @propTypes:
    investigation: reactTypes.investigation
    onInvestigationChange: React.PropTypes.func.isRequired

  @defaultProps:
    investigation:
      code: undefined
      name: undefined

  handleCodeChanged: (code) =>
    investigation = clone @props.investigation
    investigation.code = code
    @props.onInvestigationChange investigation

  handleNameChanged: (name) =>
    investigation = clone @props.investigation
    investigation.name = name
    @props.onInvestigationChange investigation

  render: ->
    <div>
      <div className="form-group">
        <label>Code</label>
        <TextInput
          className="form-control"
          type="text"
          value={@props.investigation.code}
          onChange={@handleCodeChanged}
        />
      </div>
      <div className="form-group">
        <label>Name</label>
        <TextInput
          className="form-control"
          type="text"
          value={@props.investigation.name}
          onChange={@handleNameChanged}
        />
      </div>
    </div>
