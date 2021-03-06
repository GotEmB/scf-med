constants = require "../constants"
escapeStringRegexp = require "escape-string-regexp"
React = require "react"

class module.exports extends React.Component
  @displayName: "TypeaheadInput"
  @propTypes:
    value: React.PropTypes.string
    onChange: React.PropTypes.func.isRequired
    suggestionsFetcher: React.PropTypes.func.isRequired
    textFormatter: React.PropTypes.func.isRequired
    label: React.PropTypes.string
    isInline: React.PropTypes.bool

  constructor: ->
    @state =
      focused: false
      suggestions: []
      loading: false
      keyboardFocusedIndex: undefined

  fetchSuggestions: =>
    @setState loading: true
    @props.suggestionsFetcher escapeStringRegexp(@props.value ? ""), 0,
      constants.typeaheadSuggestionsLimit, (err, suggestions, total) =>
        if @canSetState
          @setState
            suggestions: suggestions
            loading: false
            keyboardFocusedIndex: if suggestions.length > 0 then 0

  getNextSuggestionFragment: =>
    selectedSuggestion =
      @props.textFormatter @state.suggestions[@state.keyboardFocusedIndex]
    leftText = selectedSuggestion[(@props.value ? "").length..]
    fragmentsLeft = leftText
      .split " "
      .filter (x) -> x isnt ""
    fragment = fragmentsLeft[0]
    if leftText[0] is " "
      " " + fragment
    else
      fragment

  handleSuggestionSelected: (suggestion) =>
    @props.onChange @props.textFormatter suggestion
    @setState keyboardFocusedIndex: @state.suggestions.indexOf suggestion

  handleValueChanged: (e) =>
    @setState
      suggestions: []
      keyboardFocusedIndex: undefined
    @props.onChange e.target.value
    clearTimeout @valueChangeTimer if @valueChangeTimer?
    @valueChangeTimer = setTimeout @fetchSuggestions, 200

  handleFocused: =>
    @setState focused: true

  handleBlured: =>
    @setState focused: false

  handleKeyDown: (event) =>
    handled = true
    value = @props.value ? ""
    kfi = @state.keyboardFocusedIndex
    if event.keyCode is 38 and kfi? # up arrow
      @setState keyboardFocusedIndex: (kfi - 1) %% @state.suggestions.length
    else if event.keyCode is 40 and kfi? # down arrow
      @setState keyboardFocusedIndex: (kfi + 1) %% @state.suggestions.length
    else if event.keyCode is 13 and kfi? # enter key
      @refs.input.getDOMNode().blur()
      @handleSuggestionSelected @state.suggestions[kfi]
    else if event.keyCode is 9 and kfi? # tab key
      selectedSuggestion =
        @props.textFormatter @state.suggestions[kfi]
      if selectedSuggestion is value
        @refs.input.getDOMNode().blur()
        @handleSuggestionSelected @state.suggestions[kfi]
      else
        @props.onChange value + @getNextSuggestionFragment()
    else
      handled = false
    event.preventDefault() if handled

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
    <div className={divClassName} style={divStyle}>
      {label}
      <input
        ref="input"
        type="text"
        className="form-control"
        value={@props.value}
        onChange={@handleValueChanged}
        onFocus={@handleFocused}
        onBlur={@handleBlured}
        onKeyDown={@handleKeyDown}
      />
      {feedback}
    </div>

  renderSuggestion: (suggestion, key) =>
    liClassName = if @state.keyboardFocusedIndex is key then "active"
    text = @props.textFormatter suggestion
    if @state.keyboardFocusedIndex is key
      valueLength = (@props.value ? "").length
      nextFragmentLength = (@getNextSuggestionFragment() ? "").length
      text =
        <span>
          <span>{text[0...valueLength]}</span>
          <u>{text[valueLength..][...nextFragmentLength]}</u>
          <span>{text[(valueLength + nextFragmentLength)..]}</span>
        </span>
    <li
      key={key}
      className={liClassName}
      onMouseDown={@handleSuggestionSelected.bind @, suggestion}>
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
