constants = require "./constants"
mongoose = require "mongoose"

ObjectId = mongoose.Schema.ObjectId

metaDB = mongoose.createConnection constants.dbConnectionString

exports.Patient = metaDB.model "Patient",
  new mongoose.Schema(
    id: String
    name: String
    dob: Date
    sex: String
    contact: String
    insuranceId: String
    bloodGroup: String
    address: String
    nationality: String
    job: String
  ), "patients"

exports.GenericDrug = metaDB.model "GenericDrug",
  new mongoose.Schema(
    name: String
  ), "genericDrugs"

exports.BrandedDrug = metaDB.model "BrandedDrug",
  new mongoose.Schema(
    name: String
    genericDrug: type: ObjectId, ref: "GenericDrug"
  ), "brandedDrug"

exports.Prescription = metaDB.model "Prescription",
  new mongoose.Schema(
    patient: type: ObjectId, ref: "Patient"
    date: type: Date, default: Date.now()
    medicines: [
      brandedDrug: type: ObjectId, ref: "BrandedDrug"
      dosage: String
      comments: String
    ]
    routine: Boolean
  ), "prescriptions"

exports.Service = metaDB.model "Service",
  new mongoose.Schema(
    code: String
    name: String
    amount: Number
  ), "services"

exports.Invoice = metaDB.model "Invoice",
  new mongoose.Schema(
    serial: {
      year: Number
      number: Number
    }
    patient: type: ObjectId, ref: "Patient"
    date: type: Date, default: Date.now()
    services: [type: ObjectId, ref: "Service"]
    comments: String
  ), "invoices"

exports.eval = metaDB.db.eval.bind metaDB.db
