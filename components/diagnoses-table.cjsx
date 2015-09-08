React = require "react"
reactTypes = require "../react-types"

class module.exports extends React.Component
  @displayName: "DiagnosesTable"

  @propTypes:
    diagnoses: React.PropTypes.arrayOf reactTypes.diagnosis
    selectedDiagnosis: reactTypes.diagnosis
    onDiagnosisClick: React.PropTypes.func

  @defaultProps:
    diagnoses: []

  handleRowClicked: (row) ->
    @props.onDiagnosisClick? row

  renderRow: (row, key) ->
    className = "active" if row is @props.selectedDiagnosis
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
            <th>ICD-10 Code</th>
            <th>Name</th>
          </tr>
        </thead>
        <tbody>
          {@renderRow row, i for row, i in @props.diagnoses}
        </tbody>
      </table>
    </div>
