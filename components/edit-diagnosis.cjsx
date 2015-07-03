clone = require "clone"
React = require "react"
reactTypes = require "../react-types"
TextInput = require "./text-input"

class module.exports extends React.Component
  @displayName: "EditDiagnosis"

  @propTypes:
    diagnosis: reactTypes.diagnosis
    onDiagnosisChange: React.PropTypes.func.isRequired

  @defaultProps:
    diagnosis:
      code: undefined
      name: undefined

  handleCodeChanged: (code) =>
    diagnosis = clone @props.diagnosis
    diagnosis.code = code
    @props.onDiagnosisChange diagnosis

  handleNameChanged: (name) =>
    diagnosis = clone @props.diagnosis
    diagnosis.name = name
    @props.onDiagnosisChange diagnosis

  render: ->
    <div>
      <div className="form-group">
        <label>ICD-10 Code</label>
        <TextInput
          className="form-control"
          type="text"
          value={@props.diagnosis.code}
          onChange={@handleCodeChanged}
        />
      </div>
      <div className="form-group">
        <label>Name</label>
        <TextInput
          className="form-control"
          type="text"
          value={@props.diagnosis.name}
          onChange={@handleNameChanged}
        />
      </div>
    </div>
