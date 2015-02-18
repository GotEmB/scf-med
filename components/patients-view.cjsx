PatientsTable = require "./patients-table"
React = require "react"

sampleData = [
  {
    id: "101"
    name: "Badhrinathan Nithyanandam"
    dob: new Date("Apr 23, 1963")
    sex: "Male"
  }
  {
    id: "101D"
    name: "Saundarya Badhrinathan"
    dob: new Date("Jan 13, 1996")
    sex: "Female"
  }
  {
    id: "101S"
    name: "Gautham Badhrinathan"
    dob: new Date("Aug 12, 1991")
    sex: "Male"
  }
  {
    id: "101W"
    name: "Lalitha Badhrinathan"
    dob: new Date("Mar 12, 1968")
    sex: "Female"
  }
]

class module.exports extends React.Component
  @displayName: "PatientsView"

  constructor: ->
    @state =
      patients: sampleData
      selectedPatient: undefined
      loadedFrom: 0
      total: sampleData.length
      loading: false

  handleFilterKeyDown: (e) ->

  handleNewPatientClicked: ->

  handlePagerPreviousClicked: ->

  handlePagerNextClicked: ->

  handlePatientClicked: ->

  renderLeftControls: ->
    <div className="form-inline pull-left">
      <div className="input-group">
        <span className="input-group-addon">
          <i className="fa fa-filter" />
        </span>
        <input type="text" className="form-control" />
      </div>
      <span> </span>
      <button className="btn btn-default">
        <i className="fa fa-plus" /> New Patient
      </button>
    </div>

  renderRightControls: ->
    loader =
      if @state.loading
        <button className="btn btn-link" disabled style={color: "inherit"}>
          <i className="fa fa-circle-o-notch fa-spin fa-fw" />
        </button>
    leftButton =
      if @state.loadedFrom > 0
        <button className="btn btn-default">
          <i className="fa fa-chevron-left" />
        </button>
    rightButton =
      if @state.loadedFrom + @state.patients.length < @state.total
        <button className="btn btn-default">
          <i className="fa fa-chevron-right" />
        </button>
    text =
      "#{@state.loadedFrom + 1}—" +
      "#{@state.loadedFrom + @state.patients.length} of " +
      "#{@state.total}"
    <div className="pull-right">
      <div className="pull-right btn-group">
        {loader}
        {leftButton}
        <button className="btn btn-default" disabled>{text}</button>
        {rightButton}
      </div>
    </div>

  renderControls: ->
    <div>
      {@renderLeftControls()}
      {@renderRightControls()}
      <div className="clearfix" />
    </div>

  render: ->
    <div>
      {@renderControls()}
      <br />
      <PatientsTable patients={@state.patients} />
    </div>
