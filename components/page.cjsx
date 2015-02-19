Layers = require "./layers"
React = require "react"

class module.exports extends React.Component
  @displayName: "Page"
  @propTypes:
    title: React.PropTypes.string
    bundle: React.PropTypes.string

  render: ->
    <html style={height: "100%"}>
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
      </head>
      <body style={height: "100%", paddingTop: 70}>
        {@props.children}
        <Layers />
      </body>
    </html>
