numeral = require "numeral"
React = require "react"
reactTypes = require "../react-types"

class module.exports extends React.Component
  @displayName: "ComplaintsTable"

  @propTypes:
    complaints: React.PropTypes.arrayOf reactTypes.complaint
    selectedComplaint: reactTypes.complaint
    onComplaintClick: React.PropTypes.func

  @defaultProps:
    complaints: []

  handleRowClicked: (row) ->
    @props.onComplaintClick? row

  renderRow: (row, key) ->
    className = "active" if row is @props.selectedComplaint
    <tr
      className={className}
      style={cursor: "pointer"}
      onClick={@handleRowClicked.bind @, row}
      key={key}>
      <td>{row?.name}</td>
    </tr>

  render: ->
    <div className="table-responsive">
      <table className="table table-hover table-striped">
        <thead>
          <tr>
            <th>Name</th>
          </tr>
        </thead>
        <tbody>
          {@renderRow row, i for row, i in @props.complaints}
        </tbody>
      </table>
    </div>
