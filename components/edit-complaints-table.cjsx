clone = require "clone"
EditComplaint = require "./edit-complaint"
visitsCalls = require("../async-calls/visits").calls
md5 = require "MD5"
numeral = require "numeral"
React = require "react"
reactTypes = require "../react-types"
complaintsCalls = require("../async-calls/complaints").calls
TextInput = require "./text-input"
TypeaheadInput = require "./typeahead-input"
TypeaheadSelect = require "./typeahead-select"

class module.exports extends React.Component
  @displayName: "EditComplaintsTable"

  @propTypes:
    complaints: React.PropTypes.arrayOf reactTypes.complaint
    onComplaintsChange: React.PropTypes.func

  handleComplaintChanged: (index, complaint) =>
    complaints = clone @props.complaints
    complaints[index] = complaint
    @props.onComplaintsChange complaints

  handleRemoveComplaintClicked: (complaint) =>
    index = @props.complaints.indexOf complaint
    complaints = clone @props.complaints
    complaints.splice index, 1
    @props.onComplaintsChange complaints

  renderRow: (complaint, i) ->
    newComplaintSuggestion =
      component: EditComplaint
      dataProperty: "complaint"
      commitMethod: complaintsCalls.commitComplaint
      removeMethod: complaintsCalls.removeComplaint
    unless complaint?
      key = "new-#{i}"
    else
      key = i
    removeButton =
      if (@props.complaints ? []).indexOf(complaint) isnt -1
        <button
          className="btn btn-danger"
          onClick={@handleRemoveComplaintClicked.bind @, complaint}>
          <i className="fa fa-times" />
        </button>
      else
        <button className="btn btn-danger" disabled>
          <i className="fa fa-times" />
        </button>
    <tr key={key}>
      <td style={paddingRight: 0}>
        <TypeaheadSelect
          selectedItem={complaint}
          onSelectedItemChange={@handleComplaintChanged.bind @, i}
          suggestionsFetcher={complaintsCalls.getComplaints}
          textFormatter={(x) -> x.name}
          isInline={true}
          newSuggestion={newComplaintSuggestion}
        />
      </td>
      <td>
        {removeButton}
      </td>
    </tr>

  render: ->
    rows = (@props.complaints ? []).concat undefined
    <table className="table table-striped">
      <colgroup>
        <col span="1" style={width: "100%"} />
        <col span="1" style={width: "0%"} />
      </colgroup>
      <thead>
        <tr>
          <th>Complaint</th>
          <th />
        </tr>
      </thead>
      <tbody>
        {@renderRow row, i for row, i in rows}
      </tbody>
    </table>
