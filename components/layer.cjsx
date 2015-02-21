nextTick = require "next-tick"
React = require "react"

class module.exports extends React.Component
  @displayName: "Layer"
  @propTypes:
    index: React.PropTypes.number.isRequired
    children: React.PropTypes.element.isRequired
    title: React.PropTypes.string

  constructor: ->
    @state =
      transitionState: "pre"

  renderScreen: ->
    style =
      position: "absolute"
      height: "100%"
      width: "100%"
      zIndex: 3
      backgroundColor:
        switch @state.transitionState
          when "pre" then "rgba(255, 255, 255, 0.01)"
          when "post" then "rgba(255, 255, 255, 0.8)"
      transition: "background-color .2s ease-in-out"
    <div style={style} />

  renderPane: ->
    outerStyle =
      position: "absolute"
      left: 0
      right: 0
      top: 120 + @props.index * 70
      bottom: 0
      zIndex: 3
      backgroundColor: "white"
      borderTop: "solid rgba(0, 0, 0, 0.1) 1px"
      transition: "transform .2s ease-in-out, opacity .2s ease-in-out"
      transform:
        switch @state.transitionState
          when "pre" then "translate3d(0, 100px, 0)"
          when "post" then "translate3d(0, 0, 0)"
      boxShadow: "0 -5px 5px -5px rgba(0, 0, 0, 0.1)"
      opacity:
        switch @state.transitionState
          when "pre" then 0.01
          when "post" then 1
    innerStyle =
      backgroundcolor: "white"
      paddingTop: 20
      paddingBottom: 20
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
      {@renderScreen()}
      {@renderPane()}
    </div>

  componentWillEnter: (callback) ->
    nextTick =>
      @setState transitionState: "post"
      setTimeout callback, 200

  componentWillLeave: (callback) ->
    @setState transitionState: "pre"
    setTimeout callback, 200
