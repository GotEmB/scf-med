docReady = require "doc-ready"
Page = require "./components/page"
React = require "react"
RootView = require "./components/root-view"
window.$ = window.jQuery = require "jquery"

require "bootstrap"
require "bootstrap-datetimepicker/build/js/bootstrap-datetimepicker.min"
require "bootstrap-daterangepicker/daterangepicker"

docReady ->
  page =
    <Page title={process.env.PAGE_TITLE}>
      <RootView />
    </Page>
  React.render page, document

window.preloadLogo = new Image
window.preloadLogo.src = "/static/logo.jpg"
