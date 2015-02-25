moment = require "moment"
React = require "react"
reactTypes = require "../react-types"

class module.exports extends React.Component
  @displayName: "DateRangeInput"

  @propTypes:
    startDate: reactTypes.date
    endDate: reactTypes.date
    onDateRangeChange: React.PropTypes.func.isRequired

  constructor: ->
    @state =
      picker: undefined

  handleDateRangeChanged: =>
    @props.onDateRangeChange
      startDate: @state.picker.startDate.toISOString()
      endDate: @state.picker.endDate.toISOString()

  componentWillReceiveProps: (props) ->
    @state.picker?.setStartDate moment(props.startDate).toDate()
    @state.picker?.setEndDate moment(props.endDate).toDate()

  render: ->
    <input
      type="text"
      className={@props.className}
      style={@props.style}
      ref="dateInput"
    />

  componentDidMount: ->
    picker =
      $ @refs.dateInput.getDOMNode()
        .daterangepicker
          showDropdowns: true
          separator: " – "
        .on "change.daterangepicker", (e) =>
          @handleDateRangeChanged()
          @refs.dateInput.getDOMNode().blur()
        .on "apply.daterangepicker", (e) =>
          @handleDateRangeChanged()
        .data "daterangepicker"
    picker.setStartDate moment(@props.startDate).toDate()
    picker.setEndDate moment(@props.endDate).toDate()
    @setState {picker}
