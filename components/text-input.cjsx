React = require "react"

class module.exports extends React.Component
  @displayName: "TextInput"

  @propTypes:
    value: React.PropTypes.string
    onChange: React.PropTypes.func
    multiline: React.PropTypes.bool

  @defaultProps:
    multiline: false

  handleValueChanged: (e) =>
    value =
      if e.target.value is ""
        undefined
      else
        e.target.value
    @props.onChange? value

  render: ->
    if @props.multiline
      style = @props.style ? {}
      style.resize = "vertical"
      <textarea
        type="text"
        className={@props.className}
        style={style}
        value={@props.value ? ""}
        onChange={@handleValueChanged}
      />
    else
      <input
        type="text"
        className={@props.className}
        style={@props.style}
        value={@props.value ? ""}
        onChange={@handleValueChanged}
      />
