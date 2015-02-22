changeCase = require "change-case"
clone = require "clone"
Layers = require "./layers"
React = require "react"

class module.exports extends React.Component
  @displayName: "CommitCache"

  @propTypes:
    component: (props) ->
      unless props.component?.prototype instanceof React.Component
        new Error "Expected `component` to be a React Component."
    data: React.PropTypes.object
    dataProperty: React.PropTypes.string.isRequired
    onDismiss: React.PropTypes.func.isRequired

  constructor: ->
    @state =
      data: undefined
      layer: undefined

  handleDataChanged: (data) =>
    @setState data: data

  handleCancelClicked: =>
    @props.onDismiss
      commit: false
      data: @props.data

  handleSaveClicked: =>
    @props.onDismiss
      commit: true
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
      @props.onDismiss
        commit: true
        data: undefined

  renderButtonToolbar: ->
    deleteButton =
      unless @props.data is undefined
        <button className="btn btn-danger" onClick={@handleDeleteClicked}>
          Delete
        </button>
    <div>
      <div className="pull-left btn-toolbar">
        {deleteButton}
      </div>
      <div className="pull-right btn-toolbar">
        <button className="btn btn-default" onClick={@handleCancelClicked}>
          Cancel
        </button>
        <button className="btn btn-primary" onClick={@handleSaveClicked}>
          Save
        </button>
      </div>
      <div className="clearfix" />
    </div>

  render: ->
    props = {}
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
