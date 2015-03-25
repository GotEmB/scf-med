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
    jobTitle: String
    department: String
    sponsor: String
    language: String
    smoking: Boolean
  ), "patients"

exports.Visit = metaDB.model "Visit",
  new mongoose.Schema(
    patient: type: ObjectId, ref: "Patient"
    date: type: Date, default: Date.now()
    symptoms: [type: ObjectId, ref: "Symptom"]
    sign: String
    provisionalDiagnosis: String
    finalDiagnosis: String
    comments: String
    newVisit: Boolean
  ), "visits"

exports.Symptom = metaDB.model "Symptom",
  new mongoose.Schema(
    name: String
    duration: String
  ), "symptoms"

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
      duration: String
      received: Boolean
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

exports.Investigation = metaDB.model "Investigation",
  new mongoose.Schema(
    patient: type: ObjectId, ref: "Patient"
    date: type: Date, default: Date.now()
    tests: [type: ObjectId, ref: "Test"]
    comments: String
  ), "investigations"

exports.Test = metaDB.model "Test",
  new mongoose.Schema(
    code: String
    name: String
  ), "tests"

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
    copay: Number
  ), "invoices"

exports.eval = metaDB.db.eval.bind metaDB.db
