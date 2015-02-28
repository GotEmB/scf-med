React = require "react"
reactTypes = require "../react-types"

class module.exports extends React.Component
  @displayName: "BrandedDrugsTable"

  @propTypes:
    brandedDrugs: React.PropTypes.arrayOf reactTypes.brandedDrug
    selectedBrandedDrug: reactTypes.brandedDrug
    onBrandedDrugClick: React.PropTypes.func

  @defaultProps:
    brandedDrugs: []

  handleRowClicked: (row) ->
    @props.onBrandedDrugClick? row

  renderRow: (row, key) ->
    className = "active" if row is @props.selectedBrandedDrug
    <tr className={className} onClick={@handleRowClicked.bind @, row} key={key}>
      <td>{row.name}</td>
      <td>{row.genericDrug?.name}</td>
    </tr>

  render: ->
    <div className="table-responsive">
      <table className="table table-hover table-striped">
        <thead>
          <tr>
            <th>Name</th>
            <th>Generic Drug</th>
          </tr>
        </thead>
        <tbody>
          {@renderRow row, i for row, i in @props.brandedDrugs}
        </tbody>
      </table>
    </div>
