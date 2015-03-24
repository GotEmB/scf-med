clone = require "clone"
React = require "react"
reactTypes = require "../react-types"
TextInput = require "./text-input"

class module.exports extends React.Component
  @displayName: "EditTest"

  @propTypes:
    test: reactTypes.test
    onTestChange: React.PropTypes.func.isRequired

  @defaultProps:
    test:
      code: undefined
      name: undefined

  handleCodeChanged: (code) =>
    test = clone @props.test
    test.code = code
    @props.onTestChange test

  handleNameChanged: (name) =>
    test = clone @props.test
    test.name = name
    @props.onTestChange test

  render: ->
    <div>
      <div className="form-group">
        <label>CPT Code</label>
        <TextInput
          className="form-control"
          type="text"
          value={@props.test.code}
          onChange={@handleCodeChanged}
        />
      </div>
      <div className="form-group">
        <label>Name</label>
        <TextInput
          className="form-control"
          type="text"
          value={@props.test.name}
          onChange={@handleNameChanged}
        />
      </div>
    </div>
