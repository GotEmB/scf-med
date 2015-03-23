async = require "async"
AsyncCaller = require "../async-caller"
db = require "../db"
moment = require "moment"

calls =

  getInvestigations: (query, skip, limit, callback) ->
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
      investigations: ["patientIDs", (callback, {patientIDs}) ->
        db.Investigation
          .find date: dateQuery, patient: $in: patientIDs
          .sort "-date"
          .skip skip
          .limit limit
          .populate "patient"
          .populate "tests"
          .exec callback
      ]
      total: ["patientIDs", (callback, {patientIDs}) ->
        db.Investigation
          .count date: dateQuery, patient: $in: patientIDs
          .exec callback
      ]
      (err, {investigations, total}) ->
        callback err, investigations, total

  commitInvestigation: (investigation, callback) ->
    async.waterfall [
      (callback) ->
        investigation.patient = investigation.patient?._id
        for test, i in investigation.tests
          investigation.tests[i] = test?._id
        unless investigation._id?
          async.waterfall [
            (callback) ->
              db.Investigation.aggregate()
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
            investigation.serial =
              year: moment().year()
              number: (result[0]?.serialNumber ? 0) + 1
            db.Investigation.create investigation, callback
        else
          db.Investigation.findByIdAndUpdate investigation._id, investigation, callback
      (investigation, callback) ->
        db.Patient.populate investigation, "patient", callback
      (investigation, callback) ->
        db.Test.populate investigation, "tests", callback
    ], callback

  removeInvestigation: (investigation, callback) ->
    db.Investigation.remove _id: investigation._id , callback

module.exports = new AsyncCaller
  mountPath: "/async-calls/investigations"
  calls: calls
