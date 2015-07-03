clone = require "clone"
React = require "react"
reactTypes = require "../react-types"
TextInput = require "./text-input"

class module.exports extends React.Component
  @displayName: "EditComplaint"

  @propTypes:
    complaint: reactTypes.complaint
    onComplaintChange: React.PropTypes.func.isRequired

  @defaultProps:
    complaint:
      name: undefined

  handleNameChanged: (name) =>
    complaint = clone @props.complaint
    complaint.name = name
    @props.onComplaintChange complaint

  render: ->
    <div className="form-group">
      <label>Name</label>
      <TextInput
        className="form-control"
        type="text"
        value={@props.complaint.name}
        onChange={@handleNameChanged}
      />
    </div>
