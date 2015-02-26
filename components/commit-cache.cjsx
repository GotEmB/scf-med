changeCase = require "change-case"
clone = require "clone"
deepDiff = require "deep-diff"
Layers = require "./layers"
React = require "react"
reactTypes = require "../react-types"

class module.exports extends React.Component
  @displayName: "CommitCache"

  @propTypes:
    component: reactTypes.reactComponent
    data: React.PropTypes.object
    dataProperty: React.PropTypes.string.isRequired
    commitMethod: React.PropTypes.func.isRequired
    removeMethod: React.PropTypes.func.isRequired
    onDismiss: React.PropTypes.func.isRequired

  constructor: ->
    @state =
      data: undefined
      layer: undefined
      loading: false

  dataChanged: ->
    return true unless @props.data?._id?
    prefilter = (_, x) -> typeof x is "string" and x.startsWith "_"
    deepDiff(@state.data, @props.data, prefilter)?

  handleDataChanged: (data) =>
    @setState data: data

  handleCancelClicked: =>
    @props.onDismiss _ =
      unless @dataChanged()
        status: "cancelled"
      else
        status: "saved"
        data: @state.data

  handleSaveClicked: =>
    @setState loading: true
    if @state.data?
      @props.commitMethod @state.data, (err, {_id}) =>
        @state.data._id = _id
        @setState
          loading: false
          data: @state.data
        @props.onDismiss
          status: "saved"
          data: @state.data

  handleDeleteClicked: =>
    lcDataProperty = changeCase.sentenceCase @props.dataProperty
    layer =
      <div className="text-center">
        <p>
          Are you sure that you would like to delete this {lcDataProperty}?
        </p>
        <div className="btn-toolbar" style={display: "inline-block"}>
          <button
            className="btn btn-danger"
            onClick={@handleDeleteConfirmationDismissed.bind @, true}>
            Delete
          </button>
          <button
            className="btn btn-default"
            onClick={@handleDeleteConfirmationDismissed.bind @, false}>
            Cancel
          </button>
        </div>
      </div>
    Layers.addLayer layer, "Delete #{changeCase.titleCase @props.dataProperty}"
    @setState layer: layer

  handleDeleteConfirmationDismissed: (confirm) =>
    Layers.removeLayer @state.layer
    @setState layer: undefined
    if confirm
      @setState loading: true
      if @props.data?._id?
        @props.removeMethod @props.data, (err) =>
          @setState loading: true
          @props.onDismiss status: "removed"

  handleDismissed: (status) =>
    switch status
      when "cancelled" then @handleCancelClicked()
      when "saved" then @handleSaveClicked()
      when "removed" then @handleDeleteClicked()

  handleCommitted: (dismiss) =>
    @setState loading: true
    if @state.data?
      @props.commitMethod @state.data, (err, {_id}) =>
        @state.data._id = _id
        @setState
          loading: false
          data: @state.data
        if dismiss
          @props.onDismiss
            status: "saved"
            state: @state.data

  renderButtonToolbar: ->
    saveButton =
      if @dataChanged()
        <button className="btn btn-primary" onClick={@handleSaveClicked}>
          Save
        </button>
      else
        <button className="btn btn-primary" disabled>
          Save
        </button>
    loader =
      if @state.loading
        <button className="btn btn-link" disabled style={color: "inherit"}>
          <i className="fa fa-circle-o-notch fa-spin fa-fw" />
        </button>
    deleteButton =
      if @props.data?._id?
        <button className="btn btn-danger" onClick={@handleDeleteClicked}>
          Delete
        </button>
    <div>
      <div className="pull-left btn-toolbar">
        {deleteButton}
      </div>
      <div className="pull-right btn-toolbar">
        {loader}
        <button className="btn btn-default" onClick={@handleCancelClicked}>
          Cancel
        </button>
        {saveButton}
      </div>
      <div className="clearfix" />
    </div>

  render: ->
    props =
      onDismiss: @handleDismissed
      onCommit: @handleCommitted
    props[@props.dataProperty] = @state.data ? {}
    props["on#{changeCase.pascalCase @props.dataProperty}Change"] =
      @handleDataChanged
    <div>
      {React.createElement @props.component, props, @props.children}
      <hr />
      {@renderButtonToolbar()}
    </div>

  componentWillMount: ->
    @setState data: clone @props.data

  componentWillUnmount: ->
    Layers.removeLayer @state.layer if @state.layer?
