clone = require "clone"
React = require "react"
reactTypes = require "../react-types"
TextInput = require "./text-input"

class module.exports extends React.Component
  @displayName: "EditSign"

  @propTypes:
    sign: reactTypes.sign
    onSignChange: React.PropTypes.func.isRequired

  @defaultProps:
    sign:
      code: undefined
      name: undefined

  handleCodeChanged: (code) =>
    sign = clone @props.sign
    sign.code = code
    @props.onSignChange sign

  handleNameChanged: (name) =>
    sign = clone @props.sign
    sign.name = name
    @props.onSignChange sign

  render: ->
    <div>
      <div className="form-group">
        <label>CPT Code</label>
        <TextInput
          className="form-control"
          type="text"
          value={@props.sign.code}
          onChange={@handleCodeChanged}
        />
      </div>
      <div className="form-group">
        <label>Name</label>
        <TextInput
          className="form-control"
          type="text"
          value={@props.sign.name}
          onChange={@handleNameChanged}
        />
      </div>
    </div>
