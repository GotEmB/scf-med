calculateAge = require "../helpers/calculate-age"
changeCase = require "change-case"
moment = require "moment"
React = require "react"
reactTypes = require "../react-types"

class module.exports extends React.Component
  @displayName: "PatientsTable"

  @propTypes:
    patients: React.PropTypes.arrayOf reactTypes.patient
    selectedPatient: reactTypes.patient
    onPatientClick: React.PropTypes.func

  @defaultProps:
    patients: []

  handleRowClicked: (row) ->
    @props.onPatientClick? row

  renderRow: (row, key) ->
    dob = moment(row.dob).format("ll") if row.dob?
    age = changeCase.upperCaseFirst calculateAge row.dob
    className = "active" if row is @props.selectedPatient
    <tr className={className} onClick={@handleRowClicked.bind @, row} key={key}>
      <th>{row.id}</th>
      <td>{row.name}</td>
      <td>{dob}</td>
      <td>{age}</td>
      <td>{row.sex}</td>
    </tr>

  render: ->
    <div className="table-responsive">
      <table className="table table-hover table-striped">
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Date of Birth</th>
            <th>Age</th>
            <th>Sex</th>
          </tr>
        </thead>
        <tbody>
          {@renderRow row, i for row, i in @props.patients}
        </tbody>
      </table>
    </div>
