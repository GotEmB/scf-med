nextTick = require "next-tick"
React = require "react"

class module.exports extends React.Component
  @displayName: "Layer"
  @propTypes:
    negDepth: React.PropTypes.number.isRequired
    children: React.PropTypes.element.isRequired
    title: React.PropTypes.string

  constructor: ->
    @state =
      transitionState: "pre"

  getTransformOffset: =>
    5 * Math.pow(2, 4 - @props.negDepth) * (-1 + Math.pow(2, @props.negDepth))

  renderTranslucentScreen: ->
    style =
      position: "fixed"
      height: "100%"
      width: "100%"
      zIndex: 3
      backgroundColor:
        switch @state.transitionState
          when "pre" then "rgba(255, 255, 255, 0.01)"
          when "post" then "rgba(255, 255, 255, 0.8)"
      transition: "background-color .2s ease-in-out"
    <div style={style} />

  renderOpaqueScreen: ->
    style =
      position: "fixed"
      top: 120
      bottom: 0
      width: "100%"
      zIndex: 3
      backgroundColor: "white"
      transition: "transform .2s ease-in-out, opacity .2s ease-in-out"
      transform:
        switch @state.transitionState
          when "pre" then "translateY(#{100 - @getTransformOffset()}px)"
          when "post" then "translateY(#{0 - @getTransformOffset()}px)"
      WebkitTransition:
        "-webkit-transform .2s ease-in-out, opacity .2s ease-in-out"
      WebkitTransform:
        switch @state.transitionState
          when "pre" then "translateY(#{100 - @getTransformOffset()}px)"
          when "post" then "translateY(#{0 - @getTransformOffset()}px)"
      opacity:
        switch @state.transitionState
          when "pre" then 0.01
          when "post" then 1
    <div style={style} />

  renderPane: ->
    outerStyle =
      position: "absolute"
      left: 0
      right: 0
      top: 120
      bottom: 0
      zIndex: 3
      backgroundColor: "white"
      borderTop: "solid rgba(0, 0, 0, 0.1) 1px"
      transition: "transform .2s ease-in-out, opacity .2s ease-in-out"
      transform:
        switch @state.transitionState
          when "pre" then "translateY(#{100 - @getTransformOffset()}px)"
          when "post" then "translateY(#{0 - @getTransformOffset()}px)"
      WebkitTransition:
        "-webkit-transform .2s ease-in-out, opacity .2s ease-in-out"
      WebkitTransform:
        switch @state.transitionState
          when "pre" then "translateY(#{100 - @getTransformOffset()}px)"
          when "post" then "translateY(#{0 - @getTransformOffset()}px)"
      boxShadow: "0 -5px 5px -5px rgba(0, 0, 0, 0.1)"
      opacity:
        switch @state.transitionState
          when "pre" then 0.01
          when "post" then 1
    innerStyle =
      backgroundcolor: "white"
      paddingTop: 20
      paddingBottom: 20
      height: "100%"
      overflowY: "scroll"
    titleDiv =
      if @props.title?
        <div className="lead text-center">{@props.title}</div>
    <div style={outerStyle}>
      <div className="container" style={innerStyle}>
        {titleDiv}
        {@props.children}
      </div>
    </div>

  render: ->
    style =
      position: "absolute"
      height: "100%"
      width: "100%"
    <div style={style}>
      {@renderTranslucentScreen()}
      {@renderOpaqueScreen()}
      {@renderPane()}
    </div>

  componentWillEnter: (callback) ->
    nextTick =>
      @setState transitionState: "post"
      setTimeout callback, 200

  componentWillLeave: (callback) ->
    @setState transitionState: "pre"
    setTimeout callback, 200
