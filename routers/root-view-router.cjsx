constants = require "../constants"
express = require "express"
Page = require "../components/page"
React = require "react"
RootView = require "../components/root-view"

router = express.Router()

router.get "/", (req, res, next) ->
  res.send React.renderToString(
    <Page title={constants.title}>
      <RootView />
    </Page>
  )

module.exports = router
