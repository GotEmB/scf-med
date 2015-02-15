constants = require "./constants"
mongoose = require "mongoose"

metaDB = mongoose.createConnection constants.dbConnectionString

exports.Record = metaDB.model "Record",
  new mongoose.Schema(
  ), "records"

exports.eval = metaDB.db.eval.bind metaDB.db
