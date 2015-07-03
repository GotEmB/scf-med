clone = require "clone"
md5 = require "MD5"
visitsCalls = require("../async-calls/visits").calls
React = require "react"
reactTypes = require "../react-types"
TextInput = require "./text-input"
TypeaheadInput = require "./typeahead-input"

class module.exports extends React.Component
  @displayName: "EditSymptomsTable"

  @propTypes:
    symptoms: React.PropTypes.arrayOf reactTypes.symptom
    onSymptomsChange: React.PropTypes.func

  handleSymptomChanged: (symptom, index) =>
    keys = Object.keys(symptom).length
    symptoms = clone @props.symptoms
    if keys isnt 0 and index is -1
      symptoms.push symptom
    else
      symptoms[index] = symptom
    @props.onSymptomsChange symptoms

  handleRemoveSymptomClicked: (symptom) =>
    index = @props.symptoms.indexOf symptom
    symptoms = clone @props.symptoms
    symptoms.splice index, 1
    @props.onSymptomsChange symptoms

  handleNameChanged: (symptom, name) =>
    index = @props.symptoms.indexOf symptom
    symptom = clone symptom
    symptom.name = name
    @handleSymptomChanged symptom, index

  handleDurationChanged: (symptom, duration) =>
    index = @props.symptoms.indexOf symptom
    symptom = clone symptom
    symptom.duration = duration
    @handleSymptomChanged symptom, index

  renderRow: (symptom, i) ->
    unless symptom._key?
      symptom._key =
        if (@props.symptoms ? []).indexOf(symptom) isnt -1
          md5 "#{Date.now()}#{i}"
        else
          md5 "#{i}"
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
    <tr key={symptom._key}>
      <td style={paddingRight: 0}>
        <TypeaheadInput
          value={symptom.name}
          onChange={@handleNameChanged.bind @, symptom}
          suggestionsFetcher={visitsCalls.getSymptomNameSuggestions}
          textFormatter={(x) -> x}
          isInline={true}
        />
      </td>
      <td style={paddingRight: 0}>
        <TypeaheadInput
          value={symptom.duration}
          onChange={@handleDurationChanged.bind @, symptom}
          suggestionsFetcher={visitsCalls.getSymptomDurationSuggestions}
          textFormatter={(x) -> x}
          isInline={true}
        />
      </td>
      <td>
        {removeButton}
      </td>
    </tr>

  render: ->
    rows = (@props.symptoms ? []).concat {}
    <table className="table table-striped">
      <colgroup>
         <col span="1" style={width: "50%"} />
         <col span="1" style={width: "50%"} />
         <col />
      </colgroup>
      <thead>
        <tr>
          <th>Symptom</th>
          <th>Duration</th>
          <th />
        </tr>
      </thead>
      <tbody>
        {@renderRow row, i for row, i in rows}
      </tbody>
    </table>
