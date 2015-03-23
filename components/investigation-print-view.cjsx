calculateAge = require "../helpers/calculate-age"
changeCase = require "change-case"
constants = require "../constants"
moment = require "moment"
numeral = require "numeral"
padNumber = require "pad-number"
React = require "react"
reactTypes = require "../react-types"

class module.exports extends React.Component
  @displayName: "InvestigationPrintView"

  @propTypes:
    investigation: reactTypes.investigation

  renderHeader: ->
    <div className="text-center">
      <img
        style={width: 50, height: 50, position: "absolute", display: "block"}
        src="/static/logo.jpg"
      />
      <h4>{constants.clinicName}</h4>
      <h5>Investigation</h5>
      <div className="clearfix" />
    </div>

  renderDetail: ->
    if @props.investigation?.patient?.dob
      dob = @props.investigation.patient.dob
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
            {moment(@props.investigation?.date).format "ll"}
          </td>
          <td style={tdKeyStyle}>Insurance ID:</td>
          <td style={tdValueStyle}>
            {@props.investigation?.patient?.insuranceId}
          </td>
        </tr>
        <tr>
          <td style={tdKeyStyle}>Name:</td>
          <td style={tdValueStyle}>
            {@props.investigation?.patient?.name}
          </td>
          <td style={tdKeyStyle}>Age:</td>
          <td style={tdValueStyle}>
            {age}
          </td>
        </tr>
        <tr>
          <td style={tdKeyStyle}>Contact:</td>
          <td style={tdValueStyle}>
            {@props.investigation?.patient?.contact}
          </td>
          <td style={tdKeyStyle}>Sex:</td>
          <td style={tdValueStyle}>
            {@props.investigation?.patient?.sex}
          </td>
        </tr>
        <tr>
          <td style={tdKeyStyle}>Comments:</td>
          <td style={tdValueStyle} colSpan={3}>
            {@props.investigation?.comments}
          </td>
        </tr>
      </tbody>
    </table>

  renderTest: (test, key) ->
    tdStyle = border: "solid 1px black"
    <tr key={key}>
      <td style={tdStyle}>{test?.name}</td>
    </tr>

  renderTests: ->
    tests = (@props.investigation?.tests ? [])
      .filter (x) -> x?
    thStyle = border: "solid 1px black"
    <table
      className="table table-condensed"
      style={borderColor: "black"}>
      <thead>
          <th style={thStyle}>Test</th>
      </thead>
      <tbody>
        {@renderTest test, i for test, i in tests}
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
      {@renderTests()}
      <br />
      {@renderSignature()}
      {@renderFooter()}
    </div>
