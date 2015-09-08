require "coffee-react/register"

bodyParser = require "body-parser"
bundleRouter = require "./routers/bundle-router"
compression = require "compression"
express = require "express"
http = require "http"
diagnosesCalls = require "./async-calls/diagnoses"
drugsCalls = require "./async-calls/drugs"
fitsCalls = require "./async-calls/fits"
investigationsCalls = require "./async-calls/investigations"
invoicesCalls = require "./async-calls/invoices"
memosCalls = require "./async-calls/memos"
patientsCalls = require "./async-calls/patients"
prescriptionsCalls = require "./async-calls/prescriptions"
referralsCalls = require "./async-calls/referrals"
rootViewRouter = require "./routers/root-view-router"
servicesCalls = require "./async-calls/services"
staticRouter = require "./routers/static-router"
testsCalls = require "./async-calls/tests"
unfitsCalls = require "./async-calls/unfits"
visitsCalls = require "./async-calls/visits"
vitalsCalls = require "./async-calls/vitals"

router = express()

router.use compression()
router.use rootViewRouter
router.use "/static", staticRouter
router.use "/bundle", bundleRouter
router.use "/bundle", bundleRouter
router.use diagnosesCalls.router express: express, bodyParser: bodyParser
router.use drugsCalls.router express: express, bodyParser: bodyParser
router.use fitsCalls.router express: express, bodyParser: bodyParser
router.use investigationsCalls.router express: express, bodyParser: bodyParser
router.use invoicesCalls.router express: express, bodyParser: bodyParser
router.use memosCalls.router express: express, bodyParser: bodyParser
router.use patientsCalls.router express: express, bodyParser: bodyParser
router.use prescriptionsCalls.router express: express, bodyParser: bodyParser
router.use referralsCalls.router express: express, bodyParser: bodyParser
router.use servicesCalls.router express: express, bodyParser: bodyParser
router.use testsCalls.router express: express, bodyParser: bodyParser
router.use unfitsCalls.router express: express, bodyParser: bodyParser
router.use visitsCalls.router express: express, bodyParser: bodyParser
router.use vitalsCalls.router express: express, bodyParser: bodyParser


server = http.createServer router

server.listen (port = process.env.PORT ? 5080), ->
  console.log "Listening on port #{port}"
