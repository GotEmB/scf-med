clone = require "clone"
visitsCalls = require("../async-calls/visits").calls
md5 = require "MD5"
React = require "react"
reactTypes = require "../react-types"
TextInput = require "./text-input"
TypeaheadInput = require "./typeahead-input"

class module.exports extends React.Component
  @displayName: "EditSignsTable"

  @propTypes:
    signs: React.PropTypes.arrayOf reactTypes.sign
    onSignsChange: React.PropTypes.func

  handleSignChanged: (sign, index) =>
    keys = Object.keys(sign).length
    signs = clone @props.signs
    if keys isnt 0 and index is -1
      signs.push sign
    else
      signs[index] = sign
    @props.onSignsChange signs

  handleRemoveSignClicked: (sign) =>
    index = @props.signs.indexOf sign
    signs = clone @props.signs
    signs.splice index, 1
    @props.onSignsChange signs

  handleNameChanged: (sign, name) =>
    index = @props.signs.indexOf sign
    sign = clone sign
    sign.name = name
    @handleSignChanged sign, index

  renderRow: (sign, i) ->
    unless sign._key?
      sign._key =
        if (@props.signs ? []).indexOf(sign) isnt -1
          md5 "#{Date.now()}#{i}"
        else
          md5 "#{i}"
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
    <tr key={sign._key}>
      <td style={paddingRight: 0}>
        <TypeaheadInput
          value={sign.name}
          onChange={@handleNameChanged.bind @, sign}
          suggestionsFetcher={visitsCalls.getSignNameSuggestions}
          textFormatter={(x) -> x}
          isInline={true}
        />
      </td>
      <td>
        {removeButton}
      </td>
    </tr>

  render: ->
    rows = (@props.signs ? []).concat {}
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
