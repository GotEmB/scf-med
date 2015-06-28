React = require "react"
reactTypes = require "../react-types"

class module.exports extends React.Component
  @displayName: "SignsTable"

  @propTypes:
    signs: React.PropTypes.arrayOf reactTypes.sign
    selectedSign: reactTypes.sign
    onSignClick: React.PropTypes.func

  @defaultProps:
    signs: []

  handleRowClicked: (row) ->
    @props.onSignClick? row

  renderRow: (row, key) ->
    className = "active" if row is @props.selectedSign
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
          {@renderRow row, i for row, i in @props.signs}
        </tbody>
      </table>
    </div>
