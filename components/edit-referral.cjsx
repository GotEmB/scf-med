clone = require "clone"
DateInput = require "./date-input"
deepDiff = require "deep-diff"
EditPatient = require "./edit-patient"
moment = require "moment"
nextTick = require "next-tick"
Page = require "./page"
patientsCalls = require("../async-calls/patients").calls
referralsCalls = require("../async-calls/referrals").calls
ReferralPrintView = require "./referral-print-view"
React = require "react"
reactTypes = require "../react-types"
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
