numeral = require "numeral"
React = require "react"
reactTypes = require "../react-types"

class module.exports extends React.Component
  @displayName: "ServicesTable"

  @propTypes:
    services: React.PropTypes.arrayOf reactTypes.service
    selectedService: reactTypes.service
    onServiceClick: React.PropTypes.func

  @defaultProps:
    services: []

  handleRowClicked: (row) ->
    @props.onServiceClick? row

  renderRow: (row, key) ->
    if service?.amount?
      amount = numeral row?.amount
        .format "($ 0,0.00)"
        .replace "$", "Dhs"
    className = "active" if row is @props.selectedService
    <tr className={className} onClick={@handleRowClicked.bind @, row} key={key}>
      <td>{row?.code}</td>
      <td>{row?.name}</td>
      <td className="text-right">{amount}</td>
    </tr>

  render: ->
    <div className="table-responsive">
      <table className="table table-hover table-striped">
        <thead>
          <tr>
            <th>Code</th>
            <th>Name</th>
            <th className="text-right">Amount</th>
          </tr>
        </thead>
        <tbody>
          {@renderRow row, i for row, i in @props.services}
        </tbody>
      </table>
    </div>
