async = require "async"
AsyncCaller = require "../async-caller"
db = require "../db"
moment = require "moment"

calls =

  getVitals: (query, skip, limit, callback) ->
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
      vitals: ["patientIDs", (callback, {patientIDs}) ->
        db.Vital
          .find date: dateQuery, patient: $in: patientIDs
          .sort "-date"
          .skip skip
          .limit limit
          .populate "patient"
          .exec callback
      ]
      total: ["patientIDs", (callback, {patientIDs}) ->
        db.Vital
          .count date: dateQuery, patient: $in: patientIDs
          .exec callback
      ]
      (err, {vitals, total}) ->
        callback err, vitals, total

  commitVital: (vital, callback) ->
    async.waterfall [
      (callback) ->
        vital.patient = vital.patient?._id
        unless vital._id?
          async.waterfall [
            (callback) ->
              db.Vital.aggregate()
                .project
                  serialYear: "$serial.year"
                  serialNumber: "$serial.number"
                .match
                  serialYear: moment().year()
                .project
                  serialNumber: 1
                .sort "-serialNumber"
                .limit 1
                .exec callback
          ], (err, result) ->
            vital.serial =
              year: moment().year()
              number: (result[0]?.serialNumber ? 0) + 1
            db.Vital.create vital, callback
        else
          db.Vital.findByIdAndUpdate vital._id, vital, callback
      (vital, callback) ->
        db.Patient.populate vital, "patient", callback
      (vital, callback) ->
        db.Test.populate vital, "tests", callback
    ], callback

  removeVital: (vital, callback) ->
    db.Vital.remove _id: vital._id , callback

module.exports = new AsyncCaller
  mountPath: "/async-calls/vitals"
  calls: calls
