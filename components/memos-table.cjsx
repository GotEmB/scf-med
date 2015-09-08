moment = require "moment"
nextTick = require "next-tick"
Page = require "./page"
MemoPrintView = require "./memo-print-view"
React = require "react"
reactTypes = require "../react-types"

class module.exports extends React.Component
  @displayName: "MemosTable"

  @propTypes:
    memos: React.PropTypes.arrayOf reactTypes.memo
    selectedMemo: reactTypes.memo
    onMemoClick: React.PropTypes.func

  @defaultProps:
    memos: []

  constructor: ->
    @state =
      printView: undefined

  handleRowClicked: (row) =>
    @props.onMemoClick? row

  handlePrintClicked: (row, e) =>
    printView = <MemoPrintView memo={row} />
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
          {@renderRow row, i for row, i in @props.memos}
        </tbody>
      </table>
    </div>

  componentWillMount: ->
    @canSetState = true

  componentWillUnmount: ->
    @canSetState = false
