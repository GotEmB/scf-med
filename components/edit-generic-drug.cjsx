React = require "react"
reactTypes = require "../react-types"

class module.exports extends React.Component
  @displayName: "EditGenericDrug"

  @propTypes:
    genericDrug: reactTypes.genericDrug
    onGenericDrugChange: React.PropTypes.func.isRequired

  @defaultProps:
    genericDrug:
      name: undefined

  handleNameChanged: (e) =>
    @props.genericDrug.name = e.target.value
    @props.onGenericDrugChange @props.genericDrug

  render: ->
    <div>
      <div className="form-group">
        <label>Name</label>
        <input
          className="form-control"
          type="text"
          value={@props.genericDrug.name}
          onChange={@handleNameChanged}
        />
      </div>
    </div>
