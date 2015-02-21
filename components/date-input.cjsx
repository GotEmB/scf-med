moment = require "moment"
React = require "react"

class module.exports extends React.Component
  @displayName: "DateInput"

  @propTypes:
    value: React.PropTypes.oneOfType [
      React.PropTypes.instanceOf Date
      React.PropTypes.string
    ]
    onChange: React.PropTypes.func

  @defaultProps:
    value: null

  componentWillReceiveProps: (props) ->
    $ @refs.dobInput.getDOMNode()
      .data "DateTimePicker"
        .date props.value

  render: ->
    <div style={position: "relative"}>
      <input
        type="text"
        className="form-control"
        onChange={@handleInputValueChanged}
        ref="dobInput"
      />
    </div>

  componentDidMount: ->
    $ @refs.dobInput.getDOMNode()
      .datetimepicker
        format: "ll"
        icons:
          time: 'fa fa-clock-o'
          date: 'fa fa-calendar'
          up: 'fa fa-chevron-up'
          down: 'fa fa-chevron-down'
          previous: 'fa fa-chevron-left'
          next: 'fa fa-chevron-right'
          today: 'fa fa-crosshairs'
          clear: 'fa fa-trash'
      .on "dp.change", (e) =>
        @props.onChange? e.date?.toDate()
      .data "DateTimePicker"
        .date moment(@props.value).toDate()
