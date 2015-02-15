require "coffee-react/register"

bodyParser = require "body-parser"
bundleRouter = require "./routers/bundle-router"
compression = require "compression"
express = require "express"
http = require "http"
leAPICalls = require "./async-calls/le-api"
rootViewRouter = require "./routers/root-view-router"
staticRouter = require "./routers/static-router"

router = express()

router.use compression()
router.use rootViewRouter
router.use "/static", staticRouter
router.use "/bundle", bundleRouter
router.use leAPICalls.router express: express, bodyParser: bodyParser

server = http.createServer router

server.listen (port = process.env.PORT ? 5080), ->
  console.log "Listening on port #{port}"
