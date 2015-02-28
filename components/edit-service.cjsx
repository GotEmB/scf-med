React = require "react"
reactTypes = require "../react-types"
TextInput = require "./text-input"

class module.exports extends React.Component
  @displayName: "EditService"

  @propTypes:
    service: reactTypes.service
    onServiceChange: React.PropTypes.func.isRequired

  @defaultProps:
    service:
      code: undefined
      name: undefined
      amount: undefined

  handleCodeChanged: (code) =>
    @props.service.code = code
    @props.onServiceChange @props.service

  handleNameChanged: (name) =>
    @props.service.name = name
    @props.onServiceChange @props.service

  handleAmountChanged: (amount) =>
    amountNumber =
      unless amount?
        undefined
      else if isNaN amount
        @props.service.amount
      else
        Number amount
    @props.service.amount = amountNumber
    @props.onServiceChange @props.service

  render: ->
    <div>
      <div className="form-group">
        <label>Code</label>
        <TextInput
          className="form-control"
          type="text"
          value={@props.service.code}
          onChange={@handleCodeChanged}
        />
      </div>
      <div className="form-group">
        <label>Name</label>
        <TextInput
          className="form-control"
          type="text"
          value={@props.service.name}
          onChange={@handleNameChanged}
        />
      </div>
      <div className="form-group">
        <label>Amount</label>
        <div className="input-group">
          <span className="input-group-addon">Dhs</span>
          <TextInput
            className="form-control"
            type="text"
            value={@props.service.amount?.toString()}
            onChange={@handleAmountChanged}
          />
        </div>
      </div>
    </div>
