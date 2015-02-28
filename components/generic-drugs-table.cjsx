React = require "react"
reactTypes = require "../react-types"

class module.exports extends React.Component
  @displayName: "GenericDrugsTable"

  @propTypes:
    genericDrugs: React.PropTypes.arrayOf reactTypes.genericDrug
    selectedGenericDrug: reactTypes.genericDrug
    onGenericDrugClick: React.PropTypes.func

  @defaultProps:
    genericDrugs: []

  handleRowClicked: (row) ->
    @props.onGenericDrugClick? row

  renderRow: (row, key) ->
    className = "active" if row is @props.selectedGenericDrug
    <tr className={className} onClick={@handleRowClicked.bind @, row} key={key}>
      <td>{row.name}</td>
    </tr>

  render: ->
    <div className="table-responsive">
      <table className="table table-hover table-striped">
        <thead>
          <tr>
            <th>Name</th>
          </tr>
        </thead>
        <tbody>
          {@renderRow row, i for row, i in @props.genericDrugs}
        </tbody>
      </table>
    </div>
