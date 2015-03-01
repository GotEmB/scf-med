changeCase = require "change-case"
clone = require "clone"
DateInput = require "./date-input"
React = require "react"
reactTypes = require "../react-types"
TextInput = require "./text-input"

class module.exports extends React.Component
  @displayName: "EditPatient"

  @propTypes:
    patient: reactTypes.patient
    onPatientChange: React.PropTypes.func.isRequired

  @defaultProps:
    patient:
      id: undefined
      name: undefined
      dob: new Date()
      sex: undefined
      contact: undefined
      insuranceId: undefined
      bloodGroup: undefined
      address: undefined
      nationality: undefined
      job: undefined
      department: undefined
      sponsor: undefined
      language: undefined
      smoking: undefined


  handleIDChanged: (id) =>
    @props.patient.id = id
    @props.onPatientChange @props.patient

  handleNameChanged: (name) =>
    @props.patient.name = name
    @props.onPatientChange @props.patient

  handleDobChanged: (date) =>
    @props.patient.dob = date
    @props.onPatientChange @props.patient

  handleSexChanged: (sex) =>
    @props.patient.sex = sex
    @props.onPatientChange @props.patient

  handleContactChanged: (contact) =>
    @props.patient.contact = contact
    @props.onPatientChange @props.patient

  handleInsuranceIdChanged: (insuranceId) =>
    if typeof insuranceId is "string"
      insuranceId = changeCase.upperCase insuranceId
    @props.patient.insuranceId = insuranceId
    @props.onPatientChange @props.patient

  handleBloodGroupChanged: (bloodGroup) =>
    if typeof bloodGroup is "string"
      bloodGroup = changeCase.upperCase bloodGroup
    @props.patient.bloodGroup = bloodGroup
    @props.onPatientChange @props.patient

  handleAddressChanged: (address) =>
    @props.patient.address = address
    @props.onPatientChange @props.patient

  handleNationalityChanged: (nationality) =>
    @props.patient.nationality = nationality
    @props.onPatientChange @props.patient

  handleJobChanged: (job) =>
    @props.patient.job = job
    @props.onPatientChange @props.patient

  handleDepartmentChanged: (department) =>
    @props.patient.department = department
    @props.onPatientChange @props.patient

  handleSponsorChanged: (sponsor) =>
    @props.patient.sponsor = sponsor
    @props.onPatientChange @props.patient

  handleLanguageChanged: (language) =>
    @props.patient.language = language
    @props.onPatientChange @props.patient

  handleSmokingChanged: (smoking) =>
    @props.patient.smoking = smoking
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
        <TextInput
          className="form-control"
          type="text"
          value={@props.patient.id}
          onChange={@handleIDChanged}
        />
      </div>
      <div className="form-group">
        <label>Name</label>
        <TextInput
          className="form-control"
          type="text"
          value={@props.patient.name}
          onChange={@handleNameChanged}
        />
      </div>
      <div className="form-group" style={position: "relative"}>
        <label>Date of Birth</label>
        <DateInput
          date={@props.patient.dob}
          onDateChange={@handleDobChanged}
          className="form-control"
        />
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
      <div className="form-group">
        <label>Contact</label>
        <TextInput
          className="form-control"
          type="text"
          value={@props.patient.contact}
          onChange={@handleContactChanged}
        />
      </div>
      <div className="form-group">
        <label>Insurance ID</label>
        <TextInput
          className="form-control"
          type="text"
          value={@props.patient.insuranceId}
          onChange={@handleInsuranceIdChanged}
        />
      </div>
      <div className="form-group">
        <label>Blood Group</label>
        <TextInput
          className="form-control"
          type="text"
          value={@props.patient.bloodGroup}
          onChange={@handleBloodGroupChanged}
        />
      </div>
      <div className="form-group">
        <label>Address</label>
        <TextInput
          className="form-control"
          type="text"
          value={@props.patient.address}
          onChange={@handleAddressChanged}
        />
      </div>
      <div className="form-group">
        <label>Nationality</label>
        <TextInput
          className="form-control"
          type="text"
          value={@props.patient.nationality}
          onChange={@handleNationalityChanged}
        />
      </div>
      <div className="form-group">
        <label>Job Title</label>
        <TextInput
          className="form-control"
          type="text"
          value={@props.patient.job}
          onChange={@handleJobChanged}
        />
      </div>
      <div className="form-group">
        <label>Department</label>
        <TextInput
          className="form-control"
          type="text"
          value={@props.patient.department}
          onChange={@handleDepartmentChanged}
        />
      </div>
      <div className="form-group">
        <label>Sponsor</label>
        <TextInput
          className="form-control"
          type="text"
          value={@props.patient.sponsor}
          onChange={@handleSponsorChanged}
        />
      </div>
      <div className="form-group">
        <label>Language</label>
        <TextInput
          className="form-control"
          type="text"
          value={@props.patient.language}
          onChange={@handleLanguageChanged}
        />
      </div>
      <div className="form-group">
        <label>Smoking</label>
        <div className="btn-group" style={display: "block"}>
          <button
            className={yesButtonClassName}
            onClick={@handleSexChanged.bind @, "Yes"}>
            Yes
          </button>
          <button
            className={noButtonClassName}
            onClick={@handleSexChanged.bind @, "No"}>
            No
          </button>
          <div className="clearfix" />
        </div>
      </div>
    </div>

  componentWillMount: ->
    if Object.keys(@props.patient).length is 0
      patient = clone @constructor.defaultProps.patient
      @props.onPatientChange patient
