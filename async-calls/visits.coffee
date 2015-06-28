async = require "async"
AsyncCaller = require "../async-caller"
db = require "../db"
moment = require "moment"

calls =

  getVisits: (query, skip, limit, callback) ->
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
      visits: ["patientIDs", (callback, {patientIDs}) ->
        db.Visit
          .find date: dateQuery, patient: $in: patientIDs
          .sort "-date"
          .skip skip
          .limit limit
          .populate "patient"
          .populate "tests"
          .exec callback
      ]
      total: ["patientIDs", (callback, {patientIDs}) ->
        db.Visit
          .count date: dateQuery, patient: $in: patientIDs
          .exec callback
      ]
      (err, {visits, total}) ->
        callback err, visits, total

  commitVisit: (visit, callback) ->
    async.waterfall [
      (callback) ->
        visit.patient = visit.patient?._id
        for test, i in visit.tests
          visit.tests[i] = test?._id
        unless visit._id?
          async.waterfall [
            (callback) ->
              db.Visit.aggregate()
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
            visit.serial =
              year: moment().year()
              number: (result[0]?.serialNumber ? 0) + 1
            db.Visit.create visit, callback
        else
          db.Visit.findByIdAndUpdate visit._id, visit, callback
      (visit, callback) ->
        db.Patient.populate visit, "patient", callback
      (visit, callback) ->
        db.Test.populate visit, "tests", callback
    ], callback

  removeVisit: (visit, callback) ->
    db.Visit.remove _id: visit._id , callback

module.exports = new AsyncCaller
  mountPath: "/async-calls/visits"
  calls: calls
