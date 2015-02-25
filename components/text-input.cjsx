React = require "react"

class module.exports extends React.Component
  @displayName: "TextInput"

  @propTypes:
    value: React.PropTypes.string
    onChange: React.PropTypes.func

  handleValueChanged: (e) =>
    value =
      if e.target.value is ""
        undefined
      else
        e.target.value
    @props.onChange? value

  render: ->
    <input
      type="text"
      className={@props.className}
      style={@props.style}
      value={@props.value}
      onChange={@handleValueChanged}
    />
