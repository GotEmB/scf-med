changeCase = require "change-case"
CommitCache = require "./commit-cache"
constants = require "../constants"
escapeStringRegexp = require "escape-string-regexp"
Layers = require "./layers"
nextTick = require "next-tick"
React = require "react"
reactTypes = require "../react-types"

newConstant = {}

class module.exports extends React.Component
  @displayName: "TypeaheadSelect"

  @propTypes:
    selectedItem: React.PropTypes.object
    onSelectedItemChange: React.PropTypes.func.isRequired
    suggestionsFetcher: React.PropTypes.func.isRequired
    textFormatter: React.PropTypes.func.isRequired
    label: React.PropTypes.string
    isInline: React.PropTypes.bool
    newSuggestion: React.PropTypes.shape
      component: reactTypes.reactComponent
      dataProperty: React.PropTypes.string.isRequired
      commitMethod: React.PropTypes.func.isRequired
      removeMethod: React.PropTypes.func.isRequired

  constructor: ->
    @state =
      focused: false
      query: ""
      suggestions: []
      loading: false
      keyboardFocusedIndex: undefined
      layer: undefined

  fetchSuggestions: =>
    @setState loading: true
    @props.suggestionsFetcher escapeStringRegexp(@state.query), 0,
      constants.typeaheadSuggestionsLimit, (err, suggestions, total) =>
        if @props.newSuggestion?
          suggestions.push newConstant
        if @canSetState
          @setState
            suggestions: suggestions
            loading: false
            keyboardFocusedIndex: if suggestions.length > 0 then 0

  handleSelectedItemChanged: (item) =>
    if item is newConstant
      @handleCreateSuggestion()
    else
      @props.onSelectedItemChange item
      @setState
        query: @props.textFormatter item
        keyboardFocusedIndex: @state.suggestions.indexOf item

  handleQueryChanged: (e) =>
    @setState query: e.target.value
    clearTimeout @queryChangeTimer if @queryChangeTimer?
    @queryChangeTimer = setTimeout @fetchSuggestions, 200
    @props.onSelectedItemChange undefined

  handleFocused: =>
    @setState focused: true

  handleBlured: =>
    @setState focused: false

  handleKeyDown: (event) =>
    handled = true
    if event.keyCode is 38 and @state.keyboardFocusedIndex? # up arrow
      @setState keyboardFocusedIndex:
        (@state.keyboardFocusedIndex - 1) %% @state.suggestions.length
    else if event.keyCode is 40 and @state.keyboardFocusedIndex? # down arrow
      @setState keyboardFocusedIndex:
        (@state.keyboardFocusedIndex + 1) %% @state.suggestions.length
    else if event.keyCode is 13 and @state.keyboardFocusedIndex? # enter key
      @refs.input.getDOMNode().blur()
      @handleSelectedItemChanged @state.suggestions[@state.keyboardFocusedIndex]
    else
      handled = false
    event.preventDefault() if handled

  handleCreateSuggestion: =>
    layer =
      <CommitCache
        component={@props.newSuggestion.component}
        data={undefined}
        dataProperty={@props.newSuggestion.dataProperty}
        commitMethod={@props.newSuggestion.commitMethod}
        removeMethod={@props.newSuggestion.removeMethod}
        onDismiss={@handleLayerDismissed}
      />
    title = changeCase.titleCase "new #{@props.newSuggestion.dataProperty}"
    @setState layer: layer
    Layers.addLayer layer, title

  handleLayerDismissed: ({status, data}) =>
    Layers.removeLayer @state.layer
    @setState layer: undefined
    if status is "saved"
      @handleSelectedItemChanged data
      nextTick @fetchSuggestions

  renderInput: =>
    divClassName = "form-group"
    divStyle =
      marginBottom: if @props.isInline then 0
    label =
      if @props.label?
        <label className="control-label">{@props.label}</label>
    feedbackDefaultClass = "form-control-feedback fa"
    if @state.loading and @state.focused
      divClassName += " has-feedback"
      feedback =
        <i
          className="#{feedbackDefaultClass} fa-circle-o-notch fa-spin"
          style={lineHeight: "34px"}
        />
    else if @props.selectedItem? and not @state.focused
      divClassName += " has-feedback has-success"
      feedback =
        <i
          className="#{feedbackDefaultClass} fa-check"
          style={lineHeight: "34px"}
        />
    <div className={divClassName} style={divStyle}>
      {label}
      <input
        ref="input"
        type="text"
        className="form-control"
        value={@state.query}
        onChange={@handleQueryChanged}
        onFocus={@handleFocused}
        onBlur={@handleBlured}
        onKeyDown={@handleKeyDown}
      />
      {feedback}
    </div>

  renderSuggestion: (suggestion, key) =>
    liClassName = if @state.keyboardFocusedIndex is key then "active"
    text =
      if suggestion isnt newConstant
        @props.textFormatter suggestion
      else
        "New ..."
    <li
      key={key}
      className={liClassName}
      onMouseDown={@handleSelectedItemChanged.bind @, suggestion}>
      <a href="#">{text}</a>
    </li>

  renderDropdown: =>
    return unless @state.focused
    return if @state.suggestions.length is 0
    <div className="dropdown-menu" style={left: 0, right: 0, display: "block"}>
      {@renderSuggestion suggestion, i for suggestion, i in @state.suggestions}
    </div>

  render: ->
    <div style={position: "relative"}>
      {@renderInput()}
      {@renderDropdown()}
    </div>

  componentWillMount: ->
    @canSetState = true
    if @props.selectedItem?
      @setState query: @props.textFormatter @props.selectedItem

  componentDidMount: ->
    @fetchSuggestions()

  componentWillUnmount: ->
    @canSetState = false
    Layers.removeLayer @state.layer if @state.layer?
