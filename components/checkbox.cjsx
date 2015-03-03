React = require "react"

class module.exports extends React.Component
  @displayName: "Checkbox"

  @propTypes:
    checked: React.PropTypes.bool
    onCheckedChange: React.PropTypes.func.isRequired
    label: React.PropTypes.string

  @defaultProps:
    checked: false

  handleCheckedChanged: (e) =>
    @props.onCheckedChange e.target.checked

  render: ->
    if @props.label?
      <div className="checkbox">
        <label>
          <input
            type="checkbox"
            checked={@props.checked}
            onChange={@handleCheckedChanged}
          /> {@props.label}
        </label>
      </div>
    else
      <input
        type="checkbox"
        checked={@props.checked}
        onChange={@handleCheckedChanged}
      />
