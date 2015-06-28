clone = require "clone"
EditSign = require "./edit-sign"
visitsCalls = require("../async-calls/visits").calls
md5 = require "MD5"
numeral = require "numeral"
React = require "react"
reactTypes = require "../react-types"
signsCalls = require("../async-calls/signs").calls
TextInput = require "./text-input"
TypeaheadInput = require "./typeahead-input"
TypeaheadSelect = require "./typeahead-select"

class module.exports extends React.Component
  @displayName: "EditSignsTable"

  @propTypes:
    signs: React.PropTypes.arrayOf reactTypes.sign
    onSignsChange: React.PropTypes.func

  handleSignChanged: (index, sign) =>
    signs = clone @props.signs
    signs[index] = sign
    @props.onSignsChange signs

  handleRemoveSignClicked: (sign) =>
    index = @props.signs.indexOf sign
    signs = clone @props.signs
    signs.splice index, 1
    @props.onSignsChange signs

  renderRow: (sign, i) ->
    newSignSuggestion =
      component: EditSign
      dataProperty: "sign"
      commitMethod: signsCalls.commitSign
      removeMethod: signsCalls.removeSign
    unless sign?
      key = "new-#{i}"
    else
      key = i
    removeButton =
      if (@props.signs ? []).indexOf(sign) isnt -1
        <button
          className="btn btn-danger"
          onClick={@handleRemoveSignClicked.bind @, sign}>
          <i className="fa fa-times" />
        </button>
      else
        <button className="btn btn-danger" disabled>
          <i className="fa fa-times" />
        </button>
    <tr key={key}>
      <td style={paddingRight: 0}>
        <TypeaheadSelect
          selectedItem={sign}
          onSelectedItemChange={@handleSignChanged.bind @, i}
          suggestionsFetcher={signsCalls.getSigns}
          textFormatter={(x) -> x.name}
          isInline={true}
          newSuggestion={newSignSuggestion}
        />
      </td>
      <td>
        {removeButton}
      </td>
    </tr>

  render: ->
    rows = (@props.signs ? []).concat undefined
    <table className="table table-striped">
      <colgroup>
        <col span="1" style={width: "100%"} />
        <col span="1" style={width: "0%"} />
      </colgroup>
      <thead>
        <tr>
          <th>Sign</th>
          <th />
        </tr>
      </thead>
      <tbody>
        {@renderRow row, i for row, i in rows}
      </tbody>
    </table>
