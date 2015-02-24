Layers = require "./layers"
React = require "react"

singletonInstance = undefined

class module.exports extends React.Component
  @displayName: "Page"
  @propTypes:
    title: React.PropTypes.string
    bundle: React.PropTypes.string

  constructor: ->
    singletonInstance = @
    @state =
      printView: undefined

  renderHead: ->
    <head>
      <meta
        name="viewport"
        content="width=device-width, initial-scale=1, maximum-scale=1"
      />
      <title>{@props.title}</title>
      <script src="/bundle" />
      <link
        rel="stylesheet"
        type="text/css"
        href="/static/bootstrap.min.css"
      />
      <link
        rel="stylesheet"
        type="text/css"
        href="/static/font-awesome/css/font-awesome.min.css"
      />
      <link
        rel="stylesheet"
        type="text/css"
        href="/static/bootstrap-datetimepicker.min.css"
      />
      <link
        rel="stylesheet"
        type="text/css"
        href="/static/bootstrap-daterangepicker.css"
      />
    </head>

  renderBody: ->
    divClassName = "hidden-print" if @state.printView?
    printViewContainer =
      if @state.printView?
        <div className="visible-print-block" style={height: "100%"}>
          {@state.printView}
        </div>
    <body style={height: "100%"}>
      <div className={divClassName} style={height: "100%", paddingTop: 70}>
        {@props.children}
        <Layers />
      </div>
      {printViewContainer}
    </body>

  render: ->
    <html style={minHeight: "100%"}>
      {@renderHead()}
      {@renderBody()}
    </html>

  @setPrintView: (printView) ->
    singletonInstance.setState printView: printView

  @unsetPrintView: ->
    singletonInstance.setState printView: undefined
