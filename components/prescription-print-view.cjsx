calculateAge = require "../helpers/calculate-age"
changeCase = require "change-case"
constants = require "../constants"
moment = require "moment"
React = require "react"
reactTypes = require "../react-types"

class module.exports extends React.Component
  @displayName: "PrescriptionPrintView"

  @propTypes:
    prescription: reactTypes.prescription

  renderHeader: ->
    <div className="text-center">
      <img
        style={width: 50, height: 50, position: "absolute", display: "block"}
        src="/static/logo.jpg"
      />
      <h4>{constants.clinicName}</h4>
      <h5>Medical Prescription</h5>
      <div className="clearfix" />
    </div>

  renderDetail: ->
    if @props.prescription?.patient?.dob
      dob = @props.prescription.patient.dob
      age = changeCase.upperCaseFirst calculateAge dob
    tdKeyStyle =
      paddingTop: 4
      paddingRight: 8
      whiteSpace: "nowrap"
    tdValueStyle =
      paddingTop: 4
      fontWeight: "bold"
      paddingRight: 12
    <table>
      <colgroup>
        <col span="1" style={width: "1%"} />
        <col span="1" style={width: "50%"} />
        <col span="1" style={width: "1%"} />
        <col span="1" style={width: "50%"} />
      </colgroup>
      <tbody>
        <tr>
          <td style={tdKeyStyle}>Date:</td>
          <td style={tdValueStyle}>
            {moment(@props.prescription?.date).format "ll"}
          </td>
        </tr>
        <tr>
          <td style={tdKeyStyle}>ID:</td>
          <td style={tdValueStyle}>
            {@props.prescription?.patient?.id}
          </td>
          <td style={tdKeyStyle}>Insurance ID:</td>
          <td style={tdValueStyle}>
            {@props.prescription?.patient?.insuranceId}
          </td>
        </tr>
        <tr>
          <td style={tdKeyStyle}>Name:</td>
          <td style={tdValueStyle}>
            {@props.prescription?.patient?.name}
          </td>
          <td style={tdKeyStyle}>Age:</td>
          <td style={tdValueStyle}>
            {age}
          </td>
        </tr>
        <tr>
          <td style={tdKeyStyle}>Contact:</td>
          <td style={tdValueStyle}>
            {@props.prescription?.patient?.contact}
          </td>
          <td style={tdKeyStyle}>Sex:</td>
          <td style={tdValueStyle}>
            {@props.prescription?.patient?.sex}
          </td>
        </tr>
      </tbody>
    </table>

  renderMedicine: (medicine, key) ->
    <tr key={key}>
      <td style={border: "solid 1px black"}>
        <div style={fontWeight: "bold"}>{medicine.brandedDrug?.name}</div>
        {medicine.brandedDrug?.genericDrug?.name}
      </td>
      <td style={border: "solid 1px black"}>
        <div>{medicine.dosage}</div>
      </td>
      <td style={border: "solid 1px black"}>
        <div>{medicine.comments}</div>
      </td>
    </tr>

  renderMedicines: ->
    medicines = @props.prescription?.medicines ? []
    <div style={marginBottom: 20}>
      <table
        className="table table-bordered table-condensed"
        style={border: 0, marginBottom: 5}>
        <thead>
          <th
            style={border: "solid 1px black"}>
            Drug
          </th>
          <th
            style={border: "solid 1px black"}>
            Dosage
          </th>
          <th
            style={border: "solid 1px black", minWidth: 100}>
            Comments
          </th>
        </thead>
        <tbody>
          {@renderMedicine medicine, i for medicine, i in medicines}
        </tbody>
      </table>
      <div className="text-center">
        <em>(No Substitutions)</em>
      </div>
    </div>

  renderSignature: ->
    <div>
      <div style={height: 30} />
      <div style={fontWeight: "bold"}>{constants.signature}</div>
    </div>

  renderFooter: ->
    <footer style={position: "absolute", bottom: 0, width: "100%"}>
      <hr style={margin: "8px 0", borderColor: "black"} />
      <div className="text-center">
        <em>
          {constants.printFooter.line1}
          <br />
          {constants.printFooter.line2}
        </em>
      </div>
    </footer>

  render: ->
    <div style={height: "100%", fontSize: "70%"}>
      {@renderHeader()}
      <hr style={margin: "5px 0 15px", borderColor: "black"} />
      {@renderDetail()}
      <br />
      {@renderMedicines()}
      <br />
      {@renderSignature()}
      {@renderFooter()}
    </div>
