clone = require "clone"
React = require "react"
reactTypes = require "../react-types"
TextInput = require "./text-input"

class module.exports extends React.Component
  @displayName: "EditSymptom"

  @propTypes:
    symptom: reactTypes.symptom
    onSymptomChange: React.PropTypes.func.isRequired

  @defaultProps:
    symptom:
      name: undefined

  handleNameChanged: (name) =>
    symptom = clone @props.symptom
    symptom.name = name
    @props.onSymptomChange symptom

  render: ->
    <div>
      <div className="form-group">
        <label>Name</label>
        <TextInput
          className="form-control"
          type="text"
          value={@props.symptom.name}
          onChange={@handleNameChanged}
        />
      </div>
    </div>
