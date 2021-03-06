moment = require "moment"
nextTick = require "next-tick"
Page = require "./page"
PrescriptionPrintView = require "./prescription-print-view"
React = require "react"
reactTypes = require "../react-types"

class module.exports extends React.Component
  @displayName: "PrescriptionsTable"

  @propTypes:
    prescriptions: React.PropTypes.arrayOf reactTypes.prescription
    selectedPrescription: reactTypes.prescription
    onPrescriptionClick: React.PropTypes.func
    onPrescriptionRoutineClick: React.PropTypes.func

  @defaultProps:
    prescriptions: []

  constructor: ->
    @state =
      printView: undefined

  handleRowClicked: (row) =>
    @props.onPrescriptionClick? row

  handleRoutineClicked: (row, e) =>
    @props.onPrescriptionRoutineClick row
    e.stopPropagation()

  handlePrintClicked: (row, e) =>
    printView = <PrescriptionPrintView prescription={row} />
    @setState printView: printView
    Page.setPrintView printView
    nextTick =>
      window.print()
      setTimeout ( =>
        if @state.printView is printView
          Page.unsetPrintView()
          @setState printView: undefined if @canSetState
      ), 1000
    e.stopPropagation()

  renderRow: (row, key) ->
    datetime = moment(row.date).format("lll") if row.date?
    if row.routine
      routineButton =
        <button
          className="btn btn-default btn-sm"
          style={marginLeft: 3, marginRight: 3}
          onClick={@handleRoutineClicked.bind @, row}>
          <i className="fa fa-repeat" />
        </button>
    if row.medicines?.reduce(((x, y) -> x and y.received), {}) is true
      receivedAllI =
        <i
          className="fa fa-fw fa-check text-success"
          style={lineHeight: "inherit", margin: "0 10px"}
        />
    className = "active" if row is @props.selectedPatient
    btnTdStyle =
      padding: 3
      whiteSpace: "nowrap"
    <tr
      className={className}
      style={cursor: "pointer"}
      onClick={@handleRowClicked.bind @, row}
      key={key}>
      <td style={verticalAlign: "middle"}>{datetime}</td>
      <td style={verticalAlign: "middle"}>{row.patient?.id}</td>
      <td style={verticalAlign: "middle"}>{row.patient?.name}</td>
      <td className="text-right" style={btnTdStyle}>
        {routineButton}
        {receivedAllI}
        <button
          className="btn btn-primary btn-sm"
          style={marginLeft: 3}
          onClick={@handlePrintClicked.bind @, row}>
          <i className="fa fa-print" />
        </button>
      </td>
    </tr>

  render: ->
    <div className="table-responsive">
      <table className="table table-hover table-striped">
        <thead>
          <tr>
            <th>Date & Time</th>
            <th>Patient ID</th>
            <th>Patient Name</th>
            <th style={width: 1} />
          </tr>
        </thead>
        <tbody>
          {@renderRow row, i for row, i in @props.prescriptions}
        </tbody>
      </table>
    </div>

  componentWillMount: ->
    @canSetState = true

  componentWillUnmount: ->
    @canSetState = false
