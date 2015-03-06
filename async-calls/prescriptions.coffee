async = require "async"
AsyncCaller = require "../async-caller"
db = require "../db"
moment = require "moment"

calls =

  getPrescriptions: (query, skip, limit, callback) ->
    if typeof query is "string"
      textQuery = new RegExp query, "i"
    else
      textQuery = new RegExp query.text, "i"
      dateQuery =
        $gte: moment(query.daterange.from).toDate()
        $lte: moment(query.daterange.to).toDate()
    async.auto
      patientIDs: (callback) ->
        db.Patient
          .find $or: [{id: textQuery}, {name: textQuery}]
          .select "_id"
          .exec callback
      prescriptions: ["patientIDs", (callback, {patientIDs}) ->
        db.Prescription
          .find date: dateQuery, patient: $in: patientIDs
          .sort "-date"
          .skip skip
          .limit limit
          .populate "patient"
          .exec callback
      ]
      prescriptions1: ["prescriptions", (callback, {prescriptions}) ->
        db.BrandedDrug.populate prescriptions, "medicines.brandedDrug", callback
      ]
      prescriptions2: ["prescriptions1", (callback, {prescriptions1}) ->
        db.GenericDrug.populate prescriptions1,
          "medicines.brandedDrug.genericDrug", callback
      ]
      total: ["patientIDs", (callback, {patientIDs}) ->
        db.Prescription
          .count date: dateQuery, patient: $in: patientIDs
          .exec callback
      ]
      (err, {prescriptions2, total}) ->
        callback err, prescriptions2, total

  commitPrescription: (prescription, callback) ->
    async.waterfall [
      (callback) ->
        prescription.patient = prescription.patient?._id
        for medicine in prescription.medicines
          medicine.brandedDrug = medicine.brandedDrug?._id
        unless prescription._id?
          db.Prescription.create prescription, callback
        else
          db.Prescription.findByIdAndUpdate prescription._id, prescription,
            callback
      (prescription, callback) ->
        db.Patient.populate prescription, "patient", callback
      (prescription, callback) ->
        db.BrandedDrug.populate prescription, "medicines.brandedDrug", callback
    ], callback

  removePrescription: (prescription, callback) ->
    db.Prescription.remove _id: prescription._id , callback

  getDosageSuggestions: (query, skip, limit, callback) ->
    query = new RegExp query, "i"
    db.Prescription.aggregate()
      .project medicines: 1
      .unwind "medicines"
      .project dosage: "$medicines.dosage"
      .group _id: "$dosage"
      .match _id: query
      .sort _id: 1
      .skip skip
      .limit limit
      .exec (err, results) ->
        callback err, results.map (x) -> x._id

module.exports = new AsyncCaller
  mountPath: "/async-calls/prescriptions"
  calls: calls
