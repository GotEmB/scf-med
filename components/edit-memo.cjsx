clone = require "clone"
DateInput = require "./date-input"
deepDiff = require "deep-diff"
EditDiagnosesTable = require "./edit-diagnoses-table"
EditPatient = require "./edit-patient"
moment = require "moment"
nextTick = require "next-tick"
Page = require "./page"
patientsCalls = require("../async-calls/patients").calls
memosCalls = require("../async-calls/memos").calls
MemoPrintView = require "./memo-print-view"
React = require "react"
reactTypes = require "../react-types"
TextInput = require "./text-input"
TypeaheadSelect = require "./typeahead-select"
TypeaheadInput = require "./typeahead-input"

class module.exports extends React.Component
  @displayName: "EditMemo"

  @propTypes:
    memo: reactTypes.memo
    onMemoChange: React.PropTypes.func.isRequired
    onCommit: React.PropTypes.func

  @defaultProps:
    memo:
      patient: undefined
      date: undefined
      comments: undefined

  componentWillReceiveProps: (props) ->
    if deepDiff(@props.memo, props.memo)?
      printView = <MemoPrintView memo={props.memo} />
      Page.setPrintView printView

  handleDateChanged: (date) =>
    memo = clone @props.memo
    memo.date = date
    @props.onMemoChange memo

  handlePatientChanged: (patient) =>
    memo = clone @props.memo
    memo.patient = patient
    @props.onMemoChange memo

  handleCommentsChanged: (comments) =>
    memo = clone @props.memo
    memo.comments = comments
    @props.onMemoChange memo

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
          date={@props.memo.date}
          onDateChange={@handleDateChanged}
          hasTime={true}
          className="form-control"
        />
      </div>
      <TypeaheadSelect
        selectedItem={@props.memo.patient}
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
          value={@props.memo.comments}
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
    if Object.keys(@props.memo).length is 0
      memo = clone @constructor.defaultProps.memo
      memo.date = moment().toISOString()
      @props.onMemoChange memo
    printView = <MemoPrintView memo={@props.memo} />
    Page.setPrintView printView

  componentWillUnmount: ->
    Page.unsetPrintView()
