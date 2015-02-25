moment = require "moment"
React = require "react"
reactTypes = require "../react-types"

class module.exports extends React.Component
  @displayName: "DateInput"

  @propTypes:
    date: reactTypes.date
    onDateChange: React.PropTypes.func.isRequired
    hasTime: React.PropTypes.bool

  @defaultProps:
    hasTime: false

  constructor: ->
    @state =
      picker: undefined

  handleDateChanged: =>
    @props.onDateChange @state.picker.startDate.toISOString()

  componentWillReceiveProps: (props) ->
    @state.picker?.setStartDate moment(props.date).toDate()
    @state.picker?.setEndDate moment(props.date).toDate()

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
          singleDatePicker: true
          timePicker: @props.hasTime
          timePickerIncrement: 1
          format: if @props.hasTime then "lll" else "ll"
        .on "change.daterangepicker", (e) =>
          @handleDateChanged()
          @refs.dateInput.getDOMNode().blur()
        .on "apply.daterangepicker", (e) =>
          @handleDateChanged()
        .data "daterangepicker"
    picker.setStartDate moment(@props.date).toDate()
    picker.setEndDate moment(@props.date).toDate()
    @setState {picker}
