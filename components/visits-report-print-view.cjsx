changeCase = require "change-case"
constants = require "../constants"
moment = require "moment"
numeral = require "numeral"
padNumber = require "pad-number"
React = require "react"
reactTypes = require "../react-types"

class module.exports extends React.Component
  @displayName: "VisitsReportPrintView"

  @propTypes:
    visits: React.PropTypes.arrayOf(reactTypes.visit).isRequired
    fromDate: reactTypes.date.isRequired
    toDate: reactTypes.date.isRequired

  renderHeader: ->
    <div className="text-center">
      <img
        style={width: 50, height: 50, position: "absolute", display: "block"}
        src="/static/logo.jpg"
      />
      <h4>{constants.clinicName}</h4>
      <h5>Visits Report</h5>
      <div className="clearfix" />
    </div>

  renderDetail: ->
    tdKeyStyle =
      paddingTop: 4
      paddingRight: 8
      whiteSpace: "nowrap"
    tdValueStyle =
      paddingTop: 4
      fontWeight: "bold"
      paddingRight: 12
    <table>
      <colgroup>
        <col span="1" style={width: "1%"} />
        <col span="1" style={width: "50%"} />
        <col span="1" style={width: "1%"} />
        <col span="1" style={width: "50%"} />
      </colgroup>
      <tbody>
        <td style={tdKeyStyle}>Duration:</td>
        <td style={tdValueStyle}>
          {moment(@props.fromDate).format "ll"}
          {" — "}
          {moment(@props.toDate).format "ll"}
        </td>
      </tbody>
    </table>

  renderVisit: (visit, key) ->
    if visit.serial?
      serial =
        "#{visit.serial.year}-#{padNumber visit.serial.number, 5}"
    tdStyle = border: "solid 1px black"
    <tr key={key}>
      <td style={tdStyle}>{serial}</td>
      <td style={tdStyle}>{moment(visit.date).format "ll"}</td>
      <td style={tdStyle}>{visit.patient?.name}</td>
      <td style={tdStyle}>{visit.patient?.insuranceId}</td>
      <td style={tdStyle}>{visit.comments}</td>
    </tr>

  renderVisits: ->
    thStyle = border: "solid 1px black"
    <table className="table table-condensed" style={borderColor: "black"}>
      <thead>
        <tr>
          <th style={thStyle}>Serial</th>
          <th style={thStyle}>Date</th>
          <th style={thStyle}>Patient</th>
          <th style={thStyle}>Insurance ID</th>
          <th style={thStyle}>Comments</th>
        </tr>
      </thead>
      <tbody>
        {@renderVisit visit, i for visit, i in @props.visits}
      </tbody>
    </table>

  renderSignature: ->
    <div>
      <div style={height: 30} />
      <div style={fontWeight: "bold"}>{constants.signature}</div>
    </div>

  renderFooter: ->
    <footer style={position: "absolute", bottom: 0, width: "100%"}>
      <hr style={margin: "8px 0", borderColor: "black"} />
      <div className="text-center">
        <em>
          {constants.printFooter.line1}
          <br />
          {constants.printFooter.line2}
        </em>
      </div>
    </footer>

  render: ->
    <div style={height: "100%", fontSize: "70%"}>
      {@renderHeader()}
      <hr style={margin: "5px 0 15px", borderColor: "black"} />
      {@renderDetail()}
      <br />
      {@renderVisits()}
      <br />
      {@renderSignature()}
      {@renderFooter()}
    </div>
