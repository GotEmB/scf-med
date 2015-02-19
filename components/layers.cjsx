Layer = require "./layer"
React = require "react/addons"

ReactTransitionGroup = React.addons.TransitionGroup

singletonInstance = undefined

class module.exports extends React.Component
  @displayName: "Layers"

  constructor: ->
    singletonInstance = @
    @state =
      layers: []
    setTimeout ( =>
      @setState layers: ["a"]
    ), 3000

  renderLayer: (layer, key) ->
    <Layer index={key} key={key} />

  render: ->
    style =
      position: "absolute"
      top: 0
      bottom: 0
      left: 0
      right: 0
    style.pointerEvents = "none" if @state.layers.length is 0
    <ReactTransitionGroup style={style} component="div">
      {@renderLayer layer, i for layer, i in @state.layers}
    </ReactTransitionGroup>

  @addLayer: (component) ->
    singletonInstance.state.layers.push component
    singletonInstance.setState layers: singletonInstance.state.layers

  @removeLayer: (component) ->
    i = singletonInstance.state.layers.indexOf component
    if i > 0
      singletonInstance.state.layers.splice i, 1
      singletonInstance.setState layers: singletonInstance.state.layers
