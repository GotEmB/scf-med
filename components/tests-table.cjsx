React = require "react"
reactTypes = require "../react-types"

class module.exports extends React.Component
  @displayName: "TestsTable"

  @propTypes:
    tests: React.PropTypes.arrayOf reactTypes.test
    selectedTest: reactTypes.test
    onTestClick: React.PropTypes.func

  @defaultProps:
    tests: []

  handleRowClicked: (row) ->
    @props.onTestClick? row

  renderRow: (row, key) ->
    className = "active" if row is @props.selectedTest
    <tr
      className={className}
      style={cursor: "pointer"}
      onClick={@handleRowClicked.bind @, row}
      key={key}>
      <td>{row?.code}</td>
      <td>{row?.name}</td>
    </tr>

  render: ->
    <div className="table-responsive">
      <table className="table table-hover table-striped">
        <thead>
          <tr>
            <th>CPT Code</th>
            <th>Name</th>
          </tr>
        </thead>
        <tbody>
          {@renderRow row, i for row, i in @props.tests}
        </tbody>
      </table>
    </div>
