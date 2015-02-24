drugsCalls = require("../async-calls/drugs").calls
React = require "react"
reactTypes = require "../react-types"
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

  handleNameChanged: (e) =>
    @props.brandedDrug.name = e.target.value
    @props.onBrandedDrugChange @props.brandedDrug

  handleGenericDrugChanged: (genericDrug) =>
    @props.brandedDrug.genericDrug = genericDrug
    @props.onBrandedDrugChange @props.brandedDrug

  render: ->
    <div>
      <div className="form-group">
        <label>Name</label>
        <input
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
      />
    </div>
