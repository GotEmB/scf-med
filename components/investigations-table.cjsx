numeral = require "numeral"
React = require "react"
reactTypes = require "../react-types"

class module.exports extends React.Component
  @displayName: "InvestigationsTable"

  @propTypes:
    investigations: React.PropTypes.arrayOf reactTypes.investigation
    selectedInvestigation: reactTypes.investigation
    onInvestigationClick: React.PropTypes.func

  @defaultProps:
    investigations: []

  handleRowClicked: (row) ->
    @props.onInvestigationClick? row

  renderRow: (row, key) ->
    className = "active" if row is @props.selectedInvestigation
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
            <th>Code</th>
            <th>Name</th>
          </tr>
        </thead>
        <tbody>
          {@renderRow row, i for row, i in @props.investigations}
        </tbody>
      </table>
    </div>
