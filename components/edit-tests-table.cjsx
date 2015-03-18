clone = require "clone"
EditInvestigation = require "./edit-investigation"
invoicesCalls = require("../async-calls/invoices").calls
md5 = require "MD5"
numeral = require "numeral"
React = require "react"
reactTypes = require "../react-types"
investigationsCalls = require("../async-calls/investigations").calls
TextInput = require "./text-input"
TypeaheadInput = require "./typeahead-input"
TypeaheadSelect = require "./typeahead-select"

class module.exports extends React.Component
  @displayName: "EditInvestigationsTable"

  @propTypes:
    investigations: React.PropTypes.arrayOf reactTypes.investigation
    onInvestigationsChange: React.PropTypes.func

  handleInvestigationChanged: (index, investigation) =>
    investigations = clone @props.investigations
    investigations[index] = investigation
    @props.onInvestigationsChange investigations

  handleRemoveInvestigationClicked: (investigation) =>
    index = @props.investigations.indexOf investigation
    investigations = clone @props.investigations
    investigations.splice index, 1
    @props.onInvestigationsChange investigations

  renderRow: (investigation, i) ->
    newInvestigationSuggestion =
      component: EditInvestigation
      dataProperty: "investigation"
      commitMethod: investigationsCalls.commitInvestigation
      removeMethod: investigationsCalls.removeInvestigation
    unless investigation?
      key = "new-#{i}"
    else
      key = i
    removeButton =
      if (@props.investigations ? []).indexOf(investigation) isnt -1
        <button
          className="btn btn-danger"
          onClick={@handleRemoveInvestigationClicked.bind @, investigation}>
          <i className="fa fa-times" />
        </button>
      else
        <button className="btn btn-danger" disabled>
          <i className="fa fa-times" />
        </button>
    <tr key={key}>
      <td style={paddingRight: 0}>
        <TypeaheadSelect
          selectedItem={investigation}
          onSelectedItemChange={@handleInvestigationChanged.bind @, i}
          suggestionsFetcher={investigationsCalls.getInvestigations}
          textFormatter={(x) -> x.name}
          isInline={true}
          newSuggestion={newInvestigationSuggestion}
        />
      </td>
      <td>
        {removeButton}
      </td>
    </tr>

  render: ->
    rows = (@props.investigations ? []).concat undefined
    <table className="table table-striped">
      <colgroup>
        <col span="1" style={width: "100%"} />
        <col span="1" style={width: "0%"} />
      </colgroup>
      <thead>
        <tr>
          <th>Investigation</th>
          <th />
        </tr>
      </thead>
      <tbody>
        {@renderRow row, i for row, i in rows}
      </tbody>
    </table>
