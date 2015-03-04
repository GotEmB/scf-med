changeCase = require "change-case"
Checkbox = require "./checkbox"
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
      smoking: false

  handleIDChanged: (id) =>
    patient = clone @props.patient
    patient.id = id
    @props.onPatientChange patient

  handleNameChanged: (name) =>
    patient = clone @props.patient
    patient.name = name
    @props.onPatientChange patient

  handleDobChanged: (date) =>
    patient = clone @props.patient
    patient.dob = date
    @props.onPatientChange patient

  handleSexChanged: (sex) =>
    patient = clone @props.patient
    patient.sex = sex
    @props.onPatientChange patient

  handleContactChanged: (contact) =>
    patient = clone @props.patient
    patient.contact = contact
    @props.onPatientChange patient

  handleInsuranceIdChanged: (insuranceId) =>
    patient = clone @props.patient
    if typeof insuranceId is "string"
      insuranceId = changeCase.upperCase insuranceId
    patient.insuranceId = insuranceId
    @props.onPatientChange patient

  handleBloodGroupChanged: (bloodGroup) =>
    patient = clone @props.patient
    if typeof bloodGroup is "string"
      bloodGroup = changeCase.upperCase bloodGroup
    patient.bloodGroup = bloodGroup
    @props.onPatientChange patient

  handleAddressChanged: (address) =>
    patient = clone @props.patient
    patient.address = address
    @props.onPatientChange patient

  handleNationalityChanged: (nationality) =>
    patient = clone @props.patient
    patient.nationality = nationality
    @props.onPatientChange patient

  handleJobTitleChanged: (jobTitle) =>
    patient = clone @props.patient
    patient.jobTitle = jobTitle
    @props.onPatientChange patient

  handleDepartmentChanged: (department) =>
    patient = clone @props.patient
    patient.department = department
    @props.onPatientChange patient

  handleSponsorChanged: (sponsor) =>
    patient = clone @props.patient
    patient.sponsor = sponsor
    @props.onPatientChange patient

  handleLanguageChanged: (language) =>
    patient = clone @props.patient
    patient.language = language
    @props.onPatientChange patient

  handleSmokingChanged: (smoking) =>
    patient = clone @props.patient
    patient.smoking = smoking
    @props.onPatientChange patient

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
      <Checkbox
        checked={@props.patient.smoking}
        onCheckedChange={@handleSmokingChanged}
        label="Smoking"
      />
    </div>

  componentWillMount: ->
    if Object.keys(@props.patient).length is 0
      patient = clone @constructor.defaultProps.patient
      patient.dob = moment().startOf("day").toISOString()
      @props.onPatientChange patient
