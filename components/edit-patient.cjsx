changeCase = require "change-case"
clone = require "clone"
DateInput = require "./date-input"
moment = require "moment"
patientsCalls = require("../async-calls/patients").calls
React = require "react"
reactTypes = require "../react-types"
TextInput = require "./text-input"
TypeaheadInput = require "./typeahead-input"

class module.exports extends React.Component
  @displayName: "EditPatient"

  @propTypes:
    patient: reactTypes.patient
    onPatientChange: React.PropTypes.func.isRequired

  @defaultProps:
    patient:
      id: undefined
      name: undefined
      dob: undefined
      sex: undefined
      contact: undefined
      insuranceId: undefined
      bloodGroup: undefined
      address: undefined
      nationality: undefined
      jobTitle: undefined
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

  handleJobTitleChanged: (jobTitle) =>
    @props.patient.jobTitle = jobTitle
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
    yesButtonClassName = "btn btn-default"
    noButtonClassName = "btn btn-default"
    switch @props.patient.sex
      when "Male" then maleButtonClassName += " active"
      when "Female" then femaleButtonClassName += " active"
    switch @props.patient.smoking
      when "Yes" then yesButtonClassName += " active"
      when "No" then noButtonClassName += " active"
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
      <TypeaheadInput
        value={@props.patient.bloodGroup}
        onChange={@handleBloodGroupChanged}
        suggestionsFetcher={patientsCalls.getBloodGroupSuggestions}
        textFormatter={(x) -> x}
        label="Blood Group"
      />
      <div className="form-group">
        <label>Address</label>
        <TextInput
          className="form-control"
          type="text"
          value={@props.patient.address}
          onChange={@handleAddressChanged}
        />
      </div>
      <TypeaheadInput
        value={@props.patient.nationality}
        onChange={@handleNationalityChanged}
        suggestionsFetcher={patientsCalls.getNationalitySuggestions}
        textFormatter={(x) -> x}
        label="Nationality"
      />
      <TypeaheadInput
        value={@props.patient.jobTitle}
        onChange={@handleJobTitleChanged}
        suggestionsFetcher={patientsCalls.getJobTitleSuggestions}
        textFormatter={(x) -> x}
        label="Job Title"
      />
      <TypeaheadInput
        value={@props.patient.department}
        onChange={@handleDepartmentChanged}
        suggestionsFetcher={patientsCalls.getDepartmentSuggestions}
        textFormatter={(x) -> x}
        label="Department"
      />
      <TypeaheadInput
        value={@props.patient.sponsor}
        onChange={@handleSponsorChanged}
        suggestionsFetcher={patientsCalls.getSponsorSuggestions}
        textFormatter={(x) -> x}
        label="Sponsor"
      />
      <TypeaheadInput
        value={@props.patient.language}
        onChange={@handleLanguageChanged}
        suggestionsFetcher={patientsCalls.getLanguageSuggestions}
        textFormatter={(x) -> x}
        label="Language"
      />
      <div className="form-group">
        <label>Smoking</label>
        <div className="btn-group" style={display: "block"}>
          <button
            className={yesButtonClassName}
            onClick={@handleSmokingChanged.bind @, "Yes"}>
            Yes
          </button>
          <button
            className={noButtonClassName}
            onClick={@handleSmokingChanged.bind @, "No"}>
            No
          </button>
        </div>
          <div className="clearfix" />
      </div>
    </div>

  componentWillMount: ->
    if Object.keys(@props.patient).length is 0
      patient = clone @constructor.defaultProps.patient
      patient.dob = moment().startOf("day").toISOString()
      @props.onPatientChange patient
