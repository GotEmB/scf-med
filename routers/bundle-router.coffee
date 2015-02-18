aliasify = require "aliasify"
browserify = require "browserify"
coffeeReactify = require "coffee-reactify"
constants = require "../constants"
envify = require "envify/custom"
express = require "express"
StreamCache = require "stream-cache"

cache = null

getBundle = ->
  return cache if cache?
  b = browserify
    entries: ["./client"]
    extensions: [".cjsx", ".coffee"]
  b.transform coffeeReactify
  b.transform aliasify.configure
    aliases:
      "../db": "nop"
    configDir: __dirname
    appliesTo:
      includeExtensions: [".cjsx", ".coffee"]
  b.transform envify
    PAGE_TITLE: constants.title
  cache = new StreamCache()
  b.bundle().pipe cache
  return cache

router = express.Router()

router.get "/", (req, res, next) ->
  res.type "js"
  getBundle().pipe res

module.exports = router
