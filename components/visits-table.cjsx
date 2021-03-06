moment = require "moment"
nextTick = require "next-tick"
Page = require "./page"
padNumber = require "pad-number"
React = require "react"
reactTypes = require "../react-types"

class module.exports extends React.Component
  @displayName: "VisitsTable"

  @propTypes:
    visits: React.PropTypes.arrayOf reactTypes.visit
    selectedVisit: reactTypes.visit
    onVisitClick: React.PropTypes.func
    onVisitRoutineClick: React.PropTypes.func

  @defaultProps:
    visits: []

  handleRowClicked: (row) =>
    @props.onVisitClick? row

  renderRow: (row, key) ->
    datetime = moment(row.date).format("lll") if row.date?
    className = "active" if row is @props.selectedPatient
    <tr
      className={className}
      style={cursor: "pointer"}
      onClick={@handleRowClicked.bind @, row}
      key={key}>
      <td style={verticalAlign: "middle"}>{datetime}</td>
      <td style={verticalAlign: "middle"}>{row.patient?.id}</td>
      <td style={verticalAlign: "middle"}>{row.patient?.name}</td>
    </tr>

  render: ->
    <div className="table-responsive">
      <table className="table table-hover table-striped">
        <thead>
          <tr>
            <th>Date & Time</th>
            <th>Patient ID</th>
            <th>Patient Name</th>
          </tr>
        </thead>
        <tbody>
          {@renderRow row, i for row, i in @props.visits}
        </tbody>
      </table>
    </div>

  componentWillMount: ->
    @canSetState = true

  componentWillUnmount: ->
    @canSetState = false
