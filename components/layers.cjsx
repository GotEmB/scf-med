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
      titles: []

  renderLayer: (layer, title, key) ->
    <Layer index={key} title={title} key={key}>
      {layer}
    </Layer>

  render: ->
    style =
      position: "absolute"
      top: 0
      bottom: 0
      left: 0
      right: 0
    style.pointerEvents = "none" if @state.layers.length is 0
    <ReactTransitionGroup style={style} component="div">
      {@renderLayer layer, @state.titles[i], i for layer, i in @state.layers}
    </ReactTransitionGroup>

  @addLayer: (component, title) ->
    singletonInstance.state.layers.push component
    singletonInstance.state.titles.push title
    singletonInstance.setState
      layers: singletonInstance.state.layers
      titles: singletonInstance.state.titles

  @removeLayer: (component) ->
    i = singletonInstance.state.layers.indexOf component
    if i >= 0
      singletonInstance.state.layers.splice i, 1
      singletonInstance.state.titles.splice i, 1
      singletonInstance.setState
        layers: singletonInstance.state.layers
        titles: singletonInstance.state.titles
