calculateAge = require "../helpers/calculate-age"
changeCase = require "change-case"
constants = require "../constants"
moment = require "moment"
numeral = require "numeral"
padNumber = require "pad-number"
React = require "react"
reactTypes = require "../react-types"

class module.exports extends React.Component
  @displayName: "VisitPrintView"

  @propTypes:
    visit: reactTypes.visit

  renderHeader: ->
    <div className="text-center">
      <img
        style={width: 50, height: 50, position: "absolute", display: "block"}
        src="/static/logo.jpg"
      />
      <h4>{constants.clinicName}</h4>
      <h5>Investigation Referral</h5>
      <div className="clearfix" />
    </div>

  renderDetail: ->
    if @props.visit?.serial?
      serial =
        "#{@props.visit.serial.year}-\
        #{padNumber @props.visit.serial.number, 5}"
    if @props.visit?.patient?.dob
      dob = @props.visit.patient.dob
      age = changeCase.upperCaseFirst calculateAge dob
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
        <tr>
          <td style={tdKeyStyle}>Date:</td>
          <td style={tdValueStyle}>
            {moment(@props.visit?.date).format "ll"}
          </td>
          <td style={tdKeyStyle}>Serial:</td>
          <td style={tdValueStyle}>
            {serial}
          </td>
        </tr>
        <tr>
          <td style={tdKeyStyle}>ID:</td>
          <td style={tdValueStyle}>
            {@props.visit?.patient?.id}
          </td>
          <td style={tdKeyStyle}>Insurance ID:</td>
          <td style={tdValueStyle}>
            {@props.visit?.patient?.insuranceId}
          </td>
        </tr>
        <tr>
          <td style={tdKeyStyle}>Name:</td>
          <td style={tdValueStyle}>
            {@props.visit?.patient?.name}
          </td>
          <td style={tdKeyStyle}>Age:</td>
          <td style={tdValueStyle}>
            {age}
          </td>
        </tr>
        <tr>
          <td style={tdKeyStyle}>Contact:</td>
          <td style={tdValueStyle}>
            {@props.visit?.patient?.contact}
          </td>
          <td style={tdKeyStyle}>Sex:</td>
          <td style={tdValueStyle}>
            {@props.visit?.patient?.sex}
          </td>
        </tr>
        <tr>
          <td style={tdKeyStyle}>Comments:</td>
          <td style={tdValueStyle} colSpan={3}>
            {@props.visit?.comments}
          </td>
        </tr>
      </tbody>
    </table>

  renderInvestigation: (investigation, key) ->
    tdStyle = border: "solid 0px black"
    <tr key={key}>
      <td style={tdStyle}>{investigation?.name}</td>
    </tr>

  renderInvestigations: ->
    investigations = (@props.visit?.investigations ? [])
      .filter (x) -> x?
    thStyle = border: "solid 0px black"
    <table className="table table-condensed" style={borderColor: "black"}>
      <thead>
        <tr>
          <th style={thStyle}><h6><em>Investigations required:</em></h6></th>
        </tr>
      </thead>
      <tbody >
        {@renderInvestigation investigation, i for investigation, i in investigations}
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
      {@renderInvestigations()}
      <br />
      {@renderSignature()}
      {@renderFooter()}
    </div>
