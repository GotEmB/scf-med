DateInput = require "./date-input"
React = require "react"
reactTypes = require "../react-types"

class module.exports extends React.Component
  @displayName: "EditPatient"

  @propTypes:
    patient: reactTypes.patient
    onPatientChange: React.PropTypes.func

  @defaultProps:
    patient:
      id: undefined
      name: undefined
      dob: undefined
      sex: undefined

  handleIDChanged: (e) =>
    @props.patient.id = e.target.value
    @props.onPatientChange @props.patient

  handleNameChanged: (e) =>
    @props.patient.name = e.target.value
    @props.onPatientChange @props.patient

  handleDobChanged: (date) =>
    @props.patient.dob = date
    @props.onPatientChange @props.patient

  handleSexChanged: (sex) =>
    @props.patient.sex = sex
    @props.onPatientChange @props.patient

  render: ->
    maleButtonClassName = "btn btn-default"
    femaleButtonClassName = "btn btn-default"
    switch @props.patient.sex
      when "Male" then maleButtonClassName += " active"
      when "Female" then femaleButtonClassName += " active"
    <div>
      <div className="form-group">
        <label>ID</label>
        <input
          className="form-control"
          type="text"
          value={@props.patient.id}
          onChange={@handleIDChanged}
        />
      </div>
      <div className="form-group">
        <label>Name</label>
        <input
          className="form-control"
          type="text"
          value={@props.patient.name}
          onChange={@handleNameChanged}
        />
      </div>
      <div className="form-group" style={position: "relative"}>
        <label>Date of Birth</label>
        <DateInput value={@props.patient.dob} onChange={@handleDobChanged} />
      </div>
      <div className="form-group">
        <label>Sex</label>
        <div className="btn-group" style={display: "block"}>
          <button
            className={maleButtonClassName}
            onClick={@handleSexChanged.bind @, "Male"}>
            Male
          </button>
          <button
            className={femaleButtonClassName}
            onClick={@handleSexChanged.bind @, "Female"}>
            Female
          </button>
        </div>
        <div className="clearfix" />
      </div>
    </div>
