moment = require "moment"
React = require "react"
reactTypes = require "../react-types"

class module.exports extends React.Component
  @displayName: "PrescriptionsTable"

  @propTypes:
    prescriptions: React.PropTypes.arrayOf reactTypes.prescription
    selectedPrescription: reactTypes.prescription
    onPrescriptionClick: React.PropTypes.func

  @defaultProps:
    prescriptions: []

  handleRowClicked: (row) ->
    @props.onPrescriptionClick? row

  renderRow: (row, key) ->
    datetime = moment(row.date).format("lll") if row.date?
    className = "active" if row is @props.selectedPatient
    <tr className={className} onClick={@handleRowClicked.bind @, row} key={key}>
      <td>{datetime}</td>
      <td>{row.patient?.id}</td>
      <td>{row.patient?.name}</td>
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
          {@renderRow row, i for row, i in @props.prescriptions}
        </tbody>
      </table>
    </div>
