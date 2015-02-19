nextTick = require "next-tick"
React = require "react"

class module.exports extends React.Component
  @displayName: "Layer"
  @propTypes:
    index: React.PropTypes.number.isRequired

  constructor: ->
    @state =
      transitionState: "pre"

  renderScreen: ->
    style =
      position: "absolute"
      height: "100%"
      width: "100%"
      zIndex: 3
      backgroundColor: "white"
      transition: "opacity .2s ease-in-out"
      opacity:
        switch @state.transitionState
          when "pre" then 0.01
          when "post" then 0.8
    <div style={style} />

  render: ->
    style =
      position: "absolute"
      height: "100%"
      width: "100%"
    <div style={style}>
      {@renderScreen()}
    </div>

  componentWillEnter: (callback) ->
    nextTick =>
      @setState transitionState: "post"
      setTimeout callback, 200

  componentWillLeave: (callback) ->
    @setState transitionState: "pre"
    setTimeout callback, 200
