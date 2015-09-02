require "coffee-react/register"

bodyParser = require "body-parser"
bundleRouter = require "./routers/bundle-router"
compression = require "compression"
drugsCalls = require "./async-calls/drugs"
express = require "express"
http = require "http"
investigationsCalls = require "./async-calls/investigations"
vitalsCalls = require "./async-calls/vitals"
visitsCalls = require "./async-calls/visits"
invoicesCalls = require "./async-calls/invoices"
patientsCalls = require "./async-calls/patients"
prescriptionsCalls = require "./async-calls/prescriptions"
referralsCalls = require "./async-calls/referrals"
rootViewRouter = require "./routers/root-view-router"
staticRouter = require "./routers/static-router"
servicesCalls = require "./async-calls/services"
testsCalls = require "./async-calls/tests"
diagnosesCalls = require "./async-calls/diagnoses"

router = express()

router.use compression()
router.use rootViewRouter
router.use "/static", staticRouter
router.use "/bundle", bundleRouter
router.use "/bundle", bundleRouter
router.use patientsCalls.router express: express, bodyParser: bodyParser
router.use drugsCalls.router express: express, bodyParser: bodyParser
router.use prescriptionsCalls.router express: express, bodyParser: bodyParser
router.use referralsCalls.router express: express, bodyParser: bodyParser
router.use servicesCalls.router express: express, bodyParser: bodyParser
router.use testsCalls.router express: express, bodyParser: bodyParser
router.use invoicesCalls.router express: express, bodyParser: bodyParser
router.use investigationsCalls.router express: express, bodyParser: bodyParser
router.use vitalsCalls.router express: express, bodyParser: bodyParser
router.use visitsCalls.router express: express, bodyParser: bodyParser
router.use diagnosesCalls.router express: express, bodyParser: bodyParser


server = http.createServer router

server.listen (port = process.env.PORT ? 5080), ->
  console.log "Listening on port #{port}"
