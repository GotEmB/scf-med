InvestigationPrintView = require "./investigation-print-view"
moment = require "moment"
nextTick = require "next-tick"
Page = require "./page"
padNumber = require "pad-number"
React = require "react"
reactTypes = require "../react-types"

class module.exports extends React.Component
  @displayName: "InvestigationsTable"

  @propTypes:
    investigations: React.PropTypes.arrayOf reactTypes.investigation
    selectedInvestigation: reactTypes.investigation
    onInvestigationClick: React.PropTypes.func
    onInvestigationRoutineClick: React.PropTypes.func

  @defaultProps:
    investigations: []

  constructor: ->
    @state =
      printView: undefined

  handleRowClicked: (row) =>
    @props.onInvestigationClick? row

  handlePrintClicked: (row, e) =>
    printView = <InvestigationPrintView investigation={row} />
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
    className = "active" if row is @props.selectedPatient
    <tr
      className={className}
      style={cursor: "pointer"}
      onClick={@handleRowClicked.bind @, row}
      key={key}>
      <td style={verticalAlign: "middle"}>{datetime}</td>
      <td style={verticalAlign: "middle"}>{row.patient?.id}</td>
      <td style={verticalAlign: "middle"}>{row.patient?.name}</td>
      <td style={padding: 3}>
        <button
          className="btn btn-primary btn-sm"
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
            <th style={width: 1} />
          </tr>
        </thead>
        <tbody>
          {@renderRow row, i for row, i in @props.investigations}
        </tbody>
      </table>
    </div>

  componentWillMount: ->
    @canSetState = true

  componentWillUnmount: ->
    @canSetState = false
