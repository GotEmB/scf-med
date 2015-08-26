clone = require "clone"
DateInput = require "./date-input"
deepDiff = require "deep-diff"
EditPatient = require "./edit-patient"
UnfitPrintView = require "./unfit-print-view"
moment = require "moment"
nextTick = require "next-tick"
Page = require "./page"
padNumber = require "pad-number"
patientsCalls = require("../async-calls/patients").calls
React = require "react"
reactTypes = require "../react-types"
TextInput = require "./text-input"
TypeaheadSelect = require "./typeahead-select"

class module.exports extends React.Component
  @displayName: "EditUnfit"

  @propTypes:
    unfit: reactTypes.unfit
    onUnfitChange: React.PropTypes.func.isRequired
    onCommit: React.PropTypes.func

  @defaultProps:
    unfit:
      patient: undefined
      date: undefined

  componentWillReceiveProps: (props) ->
    if deepDiff(@props.unfit, props.unfit)?
      printView = <UnfitPrintView unfit={props.unfit} />
      Page.setPrintView printView

  handleDateChanged: (date) =>
    unfit = clone @props.unfit
    unfit.date = date
    @props.onUnfitChange unfit

  handlePatientChanged: (patient) =>
    unfit = clone @props.unfit
    unfit.patient = patient
    @props.onUnfitChange unfit

  handleCommentsChanged: (comments) =>
    unfit = clone @props.unfit
    unfit.comments = comments
    @props.onUnfitChange unfit

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
    if @props.unfit.serial?
      serial =
        "#{@props.unfit.serial.year}-\
        #{padNumber @props.unfit.serial.number, 5}"
    <div>
      <div className="form-group" style={position: "relative"}>
        <label>Serial</label>
        <input
          type="text"
          value={serial}
          className="form-control"
          disabled
        />
      </div>
      <div className="form-group" style={position: "relative"}>
        <label>Date & Time</label>
        <DateInput
          date={@props.unfit.date}
          onDateChange={@handleDateChanged}
          hasTime={true}
          className="form-control"
        />
      </div>
      <TypeaheadSelect
        selectedItem={@props.unfit.patient}
        onSelectedItemChange={@handlePatientChanged}
        suggestionsFetcher={patientsCalls.getPatients}
        textFormatter={(x) -> "#{x.name} - #{x.id}"}
        label="* Patient (required)"
        newSuggestion={newPatientSuggestion}
      />
      <div className="form-group" style={position: "relative"}>
        <label>Comments</label>
        <TextInput
          type="text"
          className="form-control"
          value={@props.unfit.comments}
          onChange={@handleCommentsChanged}
        />
      </div>
      <div className="text-center">
        <button className="btn btn-primary" onClick={@handlePrintClicked}>
          <i className="fa fa-print" /> Save & Print
        </button>
      </div>
    </div>

  componentWillMount: ->
    if Object.keys(@props.unfit).length is 0
      unfit = clone @constructor.defaultProps.unfit
      unfit.date = moment().toISOString()
      @props.onUnfitChange unfit
    printView = <UnfitPrintView unfit={@props.unfit} />
    Page.setPrintView printView

  componentWillUnmount: ->
    Page.unsetPrintView()
