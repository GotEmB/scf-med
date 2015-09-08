async = require "async"
AsyncCaller = require "../async-caller"
db = require "../db"
moment = require "moment"

calls =

  getFits: (query, skip, limit, callback) ->
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
      fits: ["patientIDs", (callback, {patientIDs}) ->
        db.Fit
          .find date: dateQuery, patient: $in: patientIDs
          .sort "-date"
          .skip skip
          .limit limit
          .populate "patient"
          .exec callback
      ]
      total: ["patientIDs", (callback, {patientIDs}) ->
        db.Fit
          .count date: dateQuery, patient: $in: patientIDs
          .exec callback
      ]
      (err, {fits, total}) ->
        callback err, fits, total

  commitFit: (fit, callback) ->
    async.waterfall [
      (callback) ->
        fit.patient = fit.patient?._id
        unless fit._id?
          async.waterfall [
            (callback) ->
              db.Fit.aggregate()
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
            fit.serial =
              year: moment().year()
              number: (result[0]?.serialNumber ? 0) + 1
            db.Fit.create fit, callback
        else
          db.Fit.findByIdAndUpdate fit._id, fit, callback
      (fit, callback) ->
        db.Patient.populate fit, "patient", callback
    ], callback

  removeFit: (fit, callback) ->
    db.Fit.remove _id: fit._id , callback

  getDiagnosesSuggestions: (query, skip, limit, callback) ->
    query = new RegExp query, "i"
    db.Fit.aggregate()
      .project diagnosis: 1
      .match diagnosis: query
      .group _id: "$diagnosis"
      .sort _id: 1
      .skip skip
      .limit limit
      .exec (err, results) ->
        callback err, results.map (x) -> x._id

  getCommentsSuggestions: (query, skip, limit, callback) ->
    query = new RegExp query, "i"
    db.Fit.aggregate()
      .project comments: 1
      .match comments: query
      .group _id: "$comments"
      .sort _id: 1
      .skip skip
      .limit limit
      .exec (err, results) ->
        callback err, results.map (x) -> x._id

module.exports = new AsyncCaller
  mountPath: "/async-calls/fits"
  calls: calls
