drugsCalls = require("../async-calls/drugs").calls
md5 = require "MD5"
prescriptionsCalls = require("../async-calls/prescriptions").calls
React = require "react"
reactTypes = require "../react-types"
TypeaheadInput = require "./typeahead-input"
TypeaheadSelect = require "./typeahead-select"

class module.exports extends React.Component
  @displayName: "EditPrescription"

  @propTypes:
    medicines: React.PropTypes.arrayOf reactTypes.medicine
    onMedicinesChange: React.PropTypes.func

  handleMedicineChanged: (medicine) =>
    index = @props.medicines.indexOf medicine
    keys = Object.keys(medicine).length
    if keys isnt 0 and index is -1
      @props.medicines.push medicine
    @props.onMedicinesChange @props.medicines

  handleRemoveMedicineClicked: (medicine) =>
    index = @props.medicines.indexOf medicine
    @props.medicines.splice index, 1
    @props.onMedicinesChange @props.medicines

  handleBrandedDrugChanged: (medicine, brandedDrug) =>
    medicine.brandedDrug = brandedDrug
    @handleMedicineChanged medicine

  handleDosageChanged: (medicine, dosage) =>
    medicine.dosage = dosage
    @handleMedicineChanged medicine

  handleCommentsChanged: (medicine, e) =>
    medicine.comments = e.target.value
    @handleMedicineChanged medicine

  renderRow: (medicine, i) ->
    unless medicine._key?
      medicine._key = md5 "#{Date.now()}#{i}"
    removeButton =
      if (@props.medicines ? []).indexOf(medicine) isnt -1
        <button
          className="btn btn-danger"
          onClick={@handleRemoveMedicineClicked.bind @, medicine}>
          <i className="fa fa-times" />
        </button>
      else
        <button className="btn btn-danger" disabled>
          <i className="fa fa-times" />
        </button>
    <tr key={medicine._key}>
      <td style={paddingRight: 0}>
        <TypeaheadSelect
          selectedItem={medicine.brandedDrug}
          onSelectedItemChange={@handleBrandedDrugChanged.bind @, medicine}
          suggestionsFetcher={drugsCalls.getBrandedDrugs}
          textFormatter={(x) -> x.name}
          isInline={true}
        />
      </td>
      <td style={paddingRight: 0}>
        <TypeaheadInput
          value={medicine.dosage}
          onChange={@handleDosageChanged.bind @, medicine}
          suggestionsFetcher={prescriptionsCalls.getDosageSuggestions}
          textFormatter={(x) -> x}
          isInline={true}
        />
      </td>
      <td style={paddingRight: 0}>
        <input
          type="text"
          className="form-control"
          value={medicine.comments}
          onChange={@handleCommentsChanged.bind @, medicine}
        />
      </td>
      <td>
        {removeButton}
      </td>
    </tr>

  render: ->
    rows = (@props.medicines ? []).concat {}
    <table className="table table-striped">
      <colgroup>
         <col span="1" style={width: "33%"} />
         <col span="1" style={width: "33%"} />
         <col span="1" style={width: "33%"} />
         <col />
      </colgroup>
      <thead>
        <tr>
          <th>Drug</th>
          <th>Dosage</th>
          <th>Comments</th>
          <th />
        </tr>
      </thead>
      <tbody>
        {@renderRow row, i for row, i in rows}
      </tbody>
    </table>