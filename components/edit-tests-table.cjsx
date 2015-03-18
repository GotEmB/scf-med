clone = require "clone"
EditTest = require "./edit-test"
invoicesCalls = require("../async-calls/invoices").calls
md5 = require "MD5"
numeral = require "numeral"
React = require "react"
reactTypes = require "../react-types"
testsCalls = require("../async-calls/tests").calls
TextInput = require "./text-input"
TypeaheadInput = require "./typeahead-input"
TypeaheadSelect = require "./typeahead-select"

class module.exports extends React.Component
  @displayName: "EditTestsTable"

  @propTypes:
    tests: React.PropTypes.arrayOf reactTypes.test
    onTestsChange: React.PropTypes.func

  handleTestChanged: (index, test) =>
    tests = clone @props.tests
    tests[index] = test
    @props.onTestsChange tests

  handleRemoveTestClicked: (test) =>
    index = @props.tests.indexOf test
    tests = clone @props.tests
    tests.splice index, 1
    @props.onTestsChange tests

  renderRow: (test, i) ->
    newTestSuggestion =
      component: EditTest
      dataProperty: "test"
      commitMethod: testsCalls.commitTest
      removeMethod: testsCalls.removeTest
    unless test?
      key = "new-#{i}"
    else
      key = i
    removeButton =
      if (@props.tests ? []).indexOf(test) isnt -1
        <button
          className="btn btn-danger"
          onClick={@handleRemoveTestClicked.bind @, test}>
          <i className="fa fa-times" />
        </button>
      else
        <button className="btn btn-danger" disabled>
          <i className="fa fa-times" />
        </button>
    <tr key={key}>
      <td style={paddingRight: 0}>
        <TypeaheadSelect
          selectedItem={test}
          onSelectedItemChange={@handleTestChanged.bind @, i}
          suggestionsFetcher={testsCalls.getTests}
          textFormatter={(x) -> x.name}
          isInline={true}
          newSuggestion={newTestSuggestion}
        />
      </td>
      <td>
        {removeButton}
      </td>
    </tr>

  render: ->
    rows = (@props.tests ? []).concat undefined
    <table className="table table-striped">
      <colgroup>
        <col span="1" style={width: "100%"} />
        <col span="1" style={width: "0%"} />
      </colgroup>
      <thead>
        <tr>
          <th>Test</th>
          <th />
        </tr>
      </thead>
      <tbody>
        {@renderRow row, i for row, i in rows}
      </tbody>
    </table>
