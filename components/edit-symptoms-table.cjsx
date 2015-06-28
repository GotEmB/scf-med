clone = require "clone"
EditSymptom = require "./edit-symptom"
visitsCalls = require("../async-calls/visits").calls
md5 = require "MD5"
numeral = require "numeral"
React = require "react"
reactTypes = require "../react-types"
symptomsCalls = require("../async-calls/symptoms").calls
TextInput = require "./text-input"
TypeaheadInput = require "./typeahead-input"
TypeaheadSelect = require "./typeahead-select"

class module.exports extends React.Component
  @displayName: "EditSymptomsTable"

  @propTypes:
    symptoms: React.PropTypes.arrayOf reactTypes.symptom
    onSymptomsChange: React.PropTypes.func

  handleSymptomChanged: (index, symptom) =>
    symptoms = clone @props.symptoms
    symptoms[index] = symptom
    @props.onSymptomsChange symptoms

  handleRemoveSymptomClicked: (symptom) =>
    index = @props.symptoms.indexOf symptom
    symptoms = clone @props.symptoms
    symptoms.splice index, 1
    @props.onSymptomsChange symptoms

  renderRow: (symptom, i) ->
    newSymptomSuggestion =
      component: EditSymptom
      dataProperty: "symptom"
      commitMethod: symptomsCalls.commitSymptom
      removeMethod: symptomsCalls.removeSymptom
    unless symptom?
      key = "new-#{i}"
    else
      key = i
    removeButton =
      if (@props.symptoms ? []).indexOf(symptom) isnt -1
        <button
          className="btn btn-danger"
          onClick={@handleRemoveSymptomClicked.bind @, symptom}>
          <i className="fa fa-times" />
        </button>
      else
        <button className="btn btn-danger" disabled>
          <i className="fa fa-times" />
        </button>
    <tr key={key}>
      <td style={paddingRight: 0}>
        <TypeaheadSelect
          selectedItem={symptom}
          onSelectedItemChange={@handleSymptomChanged.bind @, i}
          suggestionsFetcher={symptomsCalls.getSymptoms}
          textFormatter={(x) -> x.name}
          isInline={true}
          newSuggestion={newSymptomSuggestion}
        />
      </td>
      <td>
        {removeButton}
      </td>
    </tr>

  render: ->
    rows = (@props.symptoms ? []).concat undefined
    <table className="table table-striped">
      <colgroup>
        <col span="1" style={width: "100%"} />
        <col span="1" style={width: "0%"} />
      </colgroup>
      <thead>
        <tr>
          <th>Symptom</th>
          <th />
        </tr>
      </thead>
      <tbody>
        {@renderRow row, i for row, i in rows}
      </tbody>
    </table>
