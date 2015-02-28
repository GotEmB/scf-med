calculateAge = require "../helpers/calculate-age"
changeCase = require "change-case"
constants = require "../constants"
moment = require "moment"
numeral = require "numeral"
React = require "react"
reactTypes = require "../react-types"

class module.exports extends React.Component
  @displayName: "InvoicePrintView"

  @propTypes:
    invoice: reactTypes.invoice

  renderHeader: ->
    <div className="text-center">
      <img
        style={width: 50, height: 50, position: "absolute", display: "block"}
        src="/static/logo.jpg"
      />
      <h4>{constants.clinicName}</h4>
      <h5>Invoice</h5>
      <div className="clearfix" />
    </div>

  renderDetail: ->
    if @props.invoice?.patient?.dob
      dob = @props.invoice.patient.dob
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
            {moment(@props.invoice?.date).format "ll"}
          </td>
        </tr>
        <tr>
          <td style={tdKeyStyle}>ID:</td>
          <td style={tdValueStyle}>
            {@props.invoice?.patient?.id}
          </td>
          <td style={tdKeyStyle}>Insurance ID:</td>
          <td style={tdValueStyle}>
            {@props.invoice?.patient?.insuranceId}
          </td>
        </tr>
        <tr>
          <td style={tdKeyStyle}>Name:</td>
          <td style={tdValueStyle}>
            {@props.invoice?.patient?.name}
          </td>
          <td style={tdKeyStyle}>Age:</td>
          <td style={tdValueStyle}>
            {age}
          </td>
        </tr>
        <tr>
          <td style={tdKeyStyle}>Contact:</td>
          <td style={tdValueStyle}>
            {@props.invoice?.patient?.contact}
          </td>
          <td style={tdKeyStyle}>Sex:</td>
          <td style={tdValueStyle}>
            {@props.invoice?.patient?.sex}
          </td>
        </tr>
      </tbody>
    </table>

  renderService: (service, key) ->
    if service?.amount?
      amount = numeral service?.amount
        .format "($ 0,0.00)"
        .replace "$", "Dhs"
    <tr key={key}>
      <td style={border: "solid 1px black"}>
        <div>{service?.code}</div>
      </td>
      <td style={border: "solid 1px black"}>
        <div>{service?.name}</div>
      </td>
      <td style={border: "solid 1px black", whiteSpace: "nowrap"}>
        <div className="text-right">{amount}</div>
      </td>
    </tr>

  renderServices: ->
    services = @props.invoice?.services ? []
    totalAmount = services
      .map (x) -> x?.amount ? 0
      .reduce ((carry, x) -> carry + x), 0
    totalAmount = numeral totalAmount
      .format "($ 0,0.00)"
      .replace "$", "Dhs"
    <table className="table table-bordered table-condensed" style={border: 0}>
      <thead>
        <th>Code</th>
        <th>Service</th>
        <th className="text-right" style={width: 1}>Amount</th>
      </thead>
      <tbody>
        {@renderService service, i for service, i in services}
      </tbody>
      <tfoot>
        <tr>
          <th />
          <th>Total</th>
          <th className="text-right" style={whiteSpace: "nowrap"}>
            {totalAmount}
          </th>
        </tr>
      </tfoot>
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
      {@renderServices()}
      <br />
      {@renderSignature()}
      {@renderFooter()}
    </div>
