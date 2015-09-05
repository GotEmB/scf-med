calculateAge = require "../helpers/calculate-age"
changeCase = require "change-case"
constants = require "../constants"
moment = require "moment"
React = require "react"
reactTypes = require "../react-types"

class module.exports extends React.Component
  @displayName: "ReferralPrintView"

  @propTypes:
    referral: reactTypes.referral

  renderHeader: ->
    <div className="text-center">
      <img
        style={width: 50, height: 50, position: "absolute", display: "block"}
        src="/static/logo.jpg"
      />
      <h4>{constants.clinicName}</h4>
      <h5>Medical Referral</h5>
      <div className="clearfix" />
    </div>

  renderDetail: ->
    if @props.referral?.patient?.dob
      dob = @props.referral.patient.dob
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
            {moment(@props.referral?.date).format "ll"}
          </td>
          <td style={tdKeyStyle}>Insurance ID:</td>
          <td style={tdValueStyle}>
            {@props.referral?.patient?.insuranceId}
          </td>
        </tr>
        <tr>
          <td style={tdKeyStyle}>Name:</td>
          <td style={tdValueStyle}>
            {@props.referral?.patient?.name}
          </td>
          <td style={tdKeyStyle}>Age:</td>
          <td style={tdValueStyle}>
            {age}
          </td>
        </tr>
        <tr>
          <td style={tdKeyStyle}>Contact:</td>
          <td style={tdValueStyle}>
            {@props.referral?.patient?.contact}
          </td>
          <td style={tdKeyStyle}>Sex:</td>
          <td style={tdValueStyle}>
            {@props.referral?.patient?.sex}
          </td>
        </tr>
        <tr>
          <td style={tdKeyStyle}>Referral to: </td>
          <td style={tdValueStyle}>
            {@props.referral?.consult}
          </td>
          <td style={tdKeyStyle}>Age:</td>
          <td style={tdValueStyle}>
            {age}
          </td>
        </tr>
      </tbody>
    </table>

  renderBody: ->
    services = (@props.invoice?.services ? [])
      .filter (x) -> x?
    thStyle = height: 50, border: "solid 1px black"
    amountTStyle =
      border: "solid 1px black"
      whiteSpace: "nowrap"
    <table className="table table-condensed" style={borderColor: "black"}>
      <tbody>
        <tr>
          <th style={thStyle}>Doctor's Name & Address: </th>
          <td style={tdValueStyle} colSpan={3}>
            {@props.referral?.referred_to}
        </tr>
        <tr>
          <th style={thStyle}>Major Complaint: </th>
          <td style={tdValueStyle} colSpan={3}>
            {@props.referral?.complaint}
        </tr>
        <tr>
          <th style={thStyle}>Diagnosis: </th>
          <td style={tdValueStyle} colSpan={3}>
            {@props.referral?.diagnosis}
        </tr>
        <tr>
          <th style={thStyle}>Special Instructions: </th>
          <td style={tdValueStyle} colSpan={3}>
            {@props.referral?.instruction}
        </tr>
        <tr>
          <th style={thStyle}>Comments: </th>
          <td style={tdValueStyle} colSpan={3}>
            {@props.referral?.comments}
        </tr>
      </tbody>
    </table>

  renderSignature: ->
    <div>
      <div style={height: 50} />
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
      <div style={height: 30} />
      {@renderBody()}
      <br />
      {@renderSignature()}
      {@renderFooter()}
    </div>
