clone = require "clone"
EditDiagnosis = require "./edit-diagnosis"
md5 = require "MD5"
numeral = require "numeral"
React = require "react"
reactTypes = require "../react-types"
diagnosesCalls = require("../async-calls/diagnoses").calls
TextInput = require "./text-input"
TypeaheadInput = require "./typeahead-input"
TypeaheadSelect = require "./typeahead-select"

class module.exports extends React.Component
  @displayName: "EditDiagnosesTable"

  @propTypes:
    title: React.PropTypes.string
    diagnoses: React.PropTypes.arrayOf reactTypes.diagnosis
    onDiagnosesChange: React.PropTypes.func

  handleDiagnosisChanged: (index, diagnosis) =>
    diagnoses = clone @props.diagnoses
    diagnoses[index] = diagnosis
    @props.onDiagnosesChange diagnoses

  handleRemoveDiagnosisClicked: (diagnosis) =>
    index = @props.diagnoses.indexOf diagnosis
    diagnoses = clone @props.diagnoses
    diagnoses.splice index, 1
    @props.onDiagnosesChange diagnoses

  renderRow: (diagnosis, i) ->
    newDiagnosisSuggestion =
      component: EditDiagnosis
      dataProperty: "diagnosis"
      commitMethod: diagnosesCalls.commitDiagnosis
      removeMethod: diagnosesCalls.removeDiagnosis
    unless diagnosis?
      key = "new-#{i}"
    else
      key = i
    removeButton =
      if (@props.diagnoses ? []).indexOf(diagnosis) isnt -1
        <button
          className="btn btn-danger"
          onClick={@handleRemoveDiagnosisClicked.bind @, diagnosis}>
          <i className="fa fa-times" />
        </button>
      else
        <button className="btn btn-danger" disabled>
          <i className="fa fa-times" />
        </button>
    <tr key={key}>
      <td style={paddingRight: 0}>
        <TypeaheadSelect
          selectedItem={diagnosis}
          onSelectedItemChange={@handleDiagnosisChanged.bind @, i}
          suggestionsFetcher={diagnosesCalls.getDiagnoses}
          textFormatter={(x) -> x.name}
          isInline={true}
          newSuggestion={newDiagnosisSuggestion}
        />
      </td>
      <td>
        {removeButton}
      </td>
    </tr>

  render: ->
    rows = (@props.diagnoses ? []).concat undefined
    <table className="table table-striped">
      <colgroup>
        <col span="1" style={width: "100%"} />
        <col span="1" style={width: "0%"} />
      </colgroup>
      <thead>
        <tr>
          <th>{@props.title}</th>
          <th />
        </tr>
      </thead>
      <tbody>
        {@renderRow row, i for row, i in rows}
      </tbody>
    </table>
