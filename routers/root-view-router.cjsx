constants = require "../constants"
express = require "express"
Page = require "../components/page"
React = require "react"
RootView = require "../components/root-view"

router = express.Router()

router.get "/", (req, res, next) ->
  html = "<!DOCTYPE html>"
  html += React.renderToString(
    <Page title={constants.title}>
      <RootView />
    </Page>
  )
  res.send html

module.exports = router
