React = require "react"
reactTypes = require "../react-types"

class module.exports extends React.Component
  @displayName: "SymptomsTable"

  @propTypes:
    symptoms: React.PropTypes.arrayOf reactTypes.symptom
    selectedSymptom: reactTypes.symptom
    onSymptomClick: React.PropTypes.func

  @defaultProps:
    symptoms: []

  handleRowClicked: (row) ->
    @props.onSymptomClick? row

  renderRow: (row, key) ->
    className = "active" if row is @props.selectedSymptom
    <tr
      className={className}
      style={cursor: "pointer"}
      onClick={@handleRowClicked.bind @, row}
      key={key}>
      <td>{row?.name}</td>
      <td>{row?.duration}</td>
    </tr>

  render: ->
    <div className="table-responsive">
      <table className="table table-hover table-striped">
        <thead>
          <tr>
            <th>Name</th>
            <th>Duration</th>
          </tr>
        </thead>
        <tbody>
          {@renderRow row, i for row, i in @props.symptoms}
        </tbody>
      </table>
    </div>
