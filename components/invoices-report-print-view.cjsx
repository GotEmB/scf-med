changeCase = require "change-case"
constants = require "../constants"
moment = require "moment"
numeral = require "numeral"
padNumber = require "pad-number"
React = require "react"
reactTypes = require "../react-types"

class module.exports extends React.Component
  @displayName: "InvoicesReportPrintView"

  @propTypes:
    invoices: React.PropTypes.arrayOf(reactTypes.invoice).isRequired
    fromDate: reactTypes.date.isRequired
    toDate: reactTypes.date.isRequired

  renderHeader: ->
    <div className="text-center">
      <img
        style={width: 50, height: 50, position: "absolute", display: "block"}
        src="/static/logo.jpg"
      />
      <h4>{constants.clinicName}</h4>
      <h5>Invoices Report</h5>
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

  renderInvoice: (invoice, key) ->
    if invoice.serial?
      serial =
        "#{invoice.serial.year}-#{padNumber invoice.serial.number, 5}"
    amount = (invoice.services ? [])
      .map (x) -> x?.amount ? 0
      .reduce ((carry, x) -> carry + x), 0
    amount = amount * 0.8
    amount = numeral amount
      .format "($ 0,0.00)"
      .replace "$", "Dhs"
    tdStyle = border: "solid 1px black"
    amountTStyle =
      border: "solid 1px black"
      whiteSpace: "nowrap"
    <tr key={key}>
      <td style={tdStyle}>{serial}</td>
      <td style={tdStyle}>{moment(invoice.date).format "ll"}</td>
      <td style={tdStyle}>{invoice.patient?.name}</td>
      <td style={tdStyle}>{invoice.patient?.insuranceId}</td>
      <td style={amountTStyle} className="text-right">{amount}</td>
      <td style={tdStyle}>{invoice.comments}</td>
    </tr>

  renderInvoices: ->
    thStyle = border: "solid 1px black"
    totalAmount = @props.invoices
      .map (x) ->
        grossAmount = (x.services ? [])
          .map (x) -> x?.amount ? 0
          .reduce ((carry, x) -> carry + x), 0
        grossAmount
      .reduce ((carry, x) -> carry + x), 0
    totalAmount = totalAmount * 0.8
    totalAmount = numeral totalAmount
      .format "($ 0,0.00)"
      .replace "$", "Dhs"
    <table className="table table-condensed" style={borderColor: "black"}>
      <thead>
        <tr>
          <th style={thStyle}>Serial</th>
          <th style={thStyle}>Date</th>
          <th style={thStyle}>Patient</th>
          <th style={thStyle}>Insurance ID</th>
          <th style={thStyle} className="text-right">Amount</th>
          <th style={thStyle}>Comments</th>
        </tr>
      </thead>
      <tbody>
        {@renderInvoice invoice, i for invoice, i in @props.invoices}
      </tbody>
      <tfoot>
        <th style={thStyle} colSpan={4}>Total Amount</th>
        <th style={thStyle} className="text-right">{totalAmount}</th>
        <th style={border: "solid 1px black"} />
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
      {@renderInvoices()}
      <br />
      {@renderSignature()}
      {@renderFooter()}
    </div>
