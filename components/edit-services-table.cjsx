EditService = require "./edit-service"
invoicesCalls = require("../async-calls/invoices").calls
md5 = require "MD5"
numeral = require "numeral"
React = require "react"
reactTypes = require "../react-types"
servicesCalls = require("../async-calls/services").calls
TextInput = require "./text-input"
TypeaheadInput = require "./typeahead-input"
TypeaheadSelect = require "./typeahead-select"

class module.exports extends React.Component
  @displayName: "EditServicesTable"

  @propTypes:
    services: React.PropTypes.arrayOf reactTypes.service
    onServicesChange: React.PropTypes.func

  handleServiceChanged: (index, service) =>
    @props.services[index] = service
    @props.onServicesChange @props.services

  handleRemoveServiceClicked: (service) =>
    index = @props.services.indexOf service
    @props.services.splice index, 1
    @props.onServicesChange @props.services

  renderRow: (service, i) ->
    newServiceSuggestion =
      component: EditService
      dataProperty: "service"
      commitMethod: servicesCalls.commitService
      removeMethod: servicesCalls.removeService
    amountInputStyle =
      textAlign: "right"
    if service?.amount?
      amount = numeral service?.amount
        .format "($ 0,0.00)"
        .replace "$", "Dhs"
    if i is (@props.services ? []).length
      i = "new-#{i}"
    removeButton =
      if (@props.services ? []).indexOf(service) isnt -1
        <button
          className="btn btn-danger"
          onClick={@handleRemoveServiceClicked.bind @, service}>
          <i className="fa fa-times" />
        </button>
      else
        <button className="btn btn-danger" disabled>
          <i className="fa fa-times" />
        </button>
    <tr key={i}>
      <td style={paddingRight: 0}>
        <TypeaheadSelect
          selectedItem={service}
          onSelectedItemChange={@handleServiceChanged.bind @, i}
          suggestionsFetcher={servicesCalls.getServices}
          textFormatter={(x) -> x.name}
          isInline={true}
          newSuggestion={newServiceSuggestion}
        />
      </td>
      <td className="text-right">
        <input
          type="text"
          className="form-control"
          value={amount}
          style={amountInputStyle}
          disabled
        />
      </td>
      <td>
        {removeButton}
      </td>
    </tr>

  render: ->
    rows = (@props.services ? []).concat undefined
    totalAmount = rows
      .map (x) -> x?.amount ? 0
      .reduce ((carry, x) -> carry + x), 0
    totalAmount = numeral totalAmount
      .format "($ 0,0.00)"
      .replace "$", "Dhs"
    <table className="table table-striped">
      <colgroup>
        <col span="1" style={width: "80%"} />
        <col span="1" style={width: "20%"} />
      </colgroup>
      <thead>
        <tr>
          <th>Service</th>
          <th className="text-right">Amount</th>
          <th />
        </tr>
      </thead>
      <tbody>
        {@renderRow row, i for row, i in rows}
      </tbody>
      <tfoot>
        <tr>
          <th>Total</th>
          <th className="text-right">{totalAmount}</th>
          <th />
        </tr>
      </tfoot>
    </table>
