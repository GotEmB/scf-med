clone = require "clone"
React = require "react"
reactTypes = require "../react-types"
TextInput = require "./text-input"

class module.exports extends React.Component
  @displayName: "EditGenericDrug"

  @propTypes:
    genericDrug: reactTypes.genericDrug
    onGenericDrugChange: React.PropTypes.func.isRequired

  @defaultProps:
    genericDrug:
      name: undefined

  handleNameChanged: (name) =>
    genericDrug = clone @props.genericDrug
    genericDrug.name = name
    @props.onGenericDrugChange genericDrug

  render: ->
    <div>
      <div className="form-group">
        <label>Name</label>
        <TextInput
          className="form-control"
          type="text"
          value={@props.genericDrug.name}
          onChange={@handleNameChanged}
        />
      </div>
    </div>
