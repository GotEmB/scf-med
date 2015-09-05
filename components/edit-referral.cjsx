clone = require "clone"
DateInput = require "./date-input"
deepDiff = require "deep-diff"
EditDiagnosesTable = require "./edit-diagnoses-table"
EditPatient = require "./edit-patient"
moment = require "moment"
nextTick = require "next-tick"
Page = require "./page"
patientsCalls = require("../async-calls/patients").calls
referralsCalls = require("../async-calls/referrals").calls
diagnosesCalls = require("../async-calls/diagnoses").calls
ReferralPrintView = require "./referral-print-view"
React = require "react"
reactTypes = require "../react-types"
TextInput = require "./text-input"
TypeaheadSelect = require "./typeahead-select"
TypeaheadInput = require "./typeahead-input"

class module.exports extends React.Component
  @displayName: "EditReferral"

  @propTypes:
    referral: reactTypes.referral
    onReferralChange: React.PropTypes.func.isRequired
    onCommit: React.PropTypes.func

  @defaultProps:
    referral:
      patient: undefined
      date: undefined
      consult: undefined
      referred_to: undefined
      complaint: undefined
      diagnosis: undefined
      instruction: undefined
      comments: undefined

  componentWillReceiveProps: (props) ->
    if deepDiff(@props.referral, props.referral)?
      printView = <ReferralPrintView referral={props.referral} />
      Page.setPrintView printView

  handleDateChanged: (date) =>
    referral = clone @props.referral
    referral.date = date
    @props.onReferralChange referral

  handlePatientChanged: (patient) =>
    referral = clone @props.referral
    referral.patient = patient
    @props.onReferralChange referral

  handleConsultChanged: (consult) =>
    referral = clone @props.referral
    referral.consult = consult
    @props.onReferralChange referral

  handleReferred_toChanged: (referred_to) =>
    referral = clone @props.referral
    referral.referred_to = referred_to
    @props.onReferralChange referral

  handleComplaintsChanged: (complaint) =>
    referral = clone @props.referral
    referral.complaint = complaint
    @props.onReferralChange referral

  handleDiagnosesChanged: (diagnosis) =>
    referral = clone @props.referral
    referral.diagnosis = diagnosis
    @props.onReferralChange referral

  handleInstructionsChanged: (instruction) =>
    referral = clone @props.referral
    referral.instruction = instruction
    @props.onReferralChange referral

  handleCommentsChanged: (comments) =>
    referral = clone @props.referral
    referral.comments = comments
    @props.onReferralChange referral

  handlePrintClicked: =>
    @props.onCommit? true, ->
      nextTick ->
        window.print()

  render: ->
    newPatientSuggestion =
      component: EditPatient
      dataProperty: "patient"
      commitMethod: patientsCalls.commitPatient
      removeMethod: patientsCalls.removePatient
    <div>
      <div className="form-group" style={position: "relative"}>
        <label>Date & Time</label>
        <DateInput
          date={@props.referral.date}
          onDateChange={@handleDateChanged}
          hasTime={true}
          className="form-control"
        />
      </div>
      <TypeaheadSelect
        selectedItem={@props.referral.patient}
        onSelectedItemChange={@handlePatientChanged}
        suggestionsFetcher={patientsCalls.getPatients}
        textFormatter={(x) -> "#{x.name} - #{x.id}"}
        label="* Patient (required)"
        newSuggestion={newPatientSuggestion}
      />
      <TypeaheadInput
        value={@props.referral.consult}
        onChange={@handleConsultChanged}
        suggestionsFetcher={referralsCalls.getConsultSuggestions}
        textFormatter={(x) -> x}
        label="Consult"
      />
      <div className="form-group" style={position: "relative"}>
        <label>Referred_to</label>
        <TextInput
          type="text"
          className="form-control"
          value={@props.referral.referred_to}
          onChange={@handleReferred_toChanged}
          multiline={true}
        />
      </div>
      <div className="form-group" style={position: "relative"}>
        <label>Complaint</label>
        <TextInput
          type="text"
          className="form-control"
          value={@props.referral.complaint}
          onChange={@handleComplaintsChanged}
          multiline={true}
        />
      </div>
      <TypeaheadInput
        value={@props.referral.diagnosis}
        onChange={@handleDiagnosesChanged}
        suggestionsFetcher={referralsCalls.getDiagnosesSuggestions}
        textFormatter={(x) -> x}
        label="Diagnosis"
      />
      <div className="form-group" style={position: "relative"}>
        <label>Instrucion</label>
        <TextInput
          type="text"
          className="form-control"
          value={@props.referral.instruction}
          onChange={@handleInstructionsChanged}
          multiline={true}
        />
      </div>
      <div className="form-group" style={position: "relative"}>
        <label>Comments</label>
        <TextInput
          type="text"
          className="form-control"
          value={@props.referral.comments}
          onChange={@handleCommentsChanged}
          multiline={true}
        />
      </div>
      <div className="text-center">
        <button className="btn btn-primary" onClick={@handlePrintClicked}>
          <i className="fa fa-print" /> Save & Print
        </button>
      </div>
    </div>

  componentWillMount: ->
    if Object.keys(@props.referral).length is 0
      referral = clone @constructor.defaultProps.referral
      referral.date = moment().toISOString()
      @props.onReferralChange referral
    printView = <ReferralPrintView referral={@props.referral} />
    Page.setPrintView printView

  componentWillUnmount: ->
    Page.unsetPrintView()
