clone = require "clone"
drugsCalls = require("../async-calls/drugs").calls
EditGenericDrug = require "./edit-generic-drug"
React = require "react"
reactTypes = require "../react-types"
TextInput = require "./text-input"
TypeaheadSelect = require "./typeahead-select"

class module.exports extends React.Component
  @displayName: "EditBrandedDrug"

  @propTypes:
    brandedDrug: reactTypes.brandedDrug
    onBrandedDrugChange: React.PropTypes.func.isRequired

  @defaultProps:
    brandedDrug:
      name: undefined
      genericDrug: undefined

  handleNameChanged: (name) =>
    brandedDrug = clone @props.brandedDrug
    brandedDrug.name = name
    @props.onBrandedDrugChange brandedDrug

  handleGenericDrugChanged: (genericDrug) =>
    brandedDrug = clone @props.brandedDrug
    brandedDrug.genericDrug = genericDrug
    @props.onBrandedDrugChange brandedDrug

  render: ->
    newGenericDrugSuggestion =
      component: EditGenericDrug
      dataProperty: "genericDrug"
      commitMethod: drugsCalls.commitGenericDrug
      removeMethod: drugsCalls.removeGenericDrug
    <div>
      <div className="form-group">
        <label>Name</label>
        <TextInput
          className="form-control"
          type="text"
          value={@props.brandedDrug.name}
          onChange={@handleNameChanged}
        />
      </div>
      <TypeaheadSelect
        selectedItem={@props.brandedDrug.genericDrug}
        onSelectedItemChange={@handleGenericDrugChanged}
        suggestionsFetcher={drugsCalls.getGenericDrugs}
        textFormatter={(x) -> x.name}
        label="Generic Drug"
        newSuggestion={newGenericDrugSuggestion}
      />
    </div>
