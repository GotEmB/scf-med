async = require "async"
AsyncCaller = require "../async-caller"
db = require "../db"
moment = require "moment"

calls =

  getUnfits: (query, skip, limit, callback) ->
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
      unfits: ["patientIDs", (callback, {patientIDs}) ->
        db.Unfit
          .find date: dateQuery, patient: $in: patientIDs
          .sort "-date"
          .skip skip
          .limit limit
          .populate "patient"
          .exec callback
      ]
      total: ["patientIDs", (callback, {patientIDs}) ->
        db.Unfit
          .count date: dateQuery, patient: $in: patientIDs
          .exec callback
      ]
      (err, {unfits, total}) ->
        callback err, unfits, total

  commitUnfit: (unfit, callback) ->
    async.waterfall [
      (callback) ->
        unfit.patient = unfit.patient?._id
        unless unfit._id?
          async.waterfall [
            (callback) ->
              db.Unfit.aggregate()
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
            unfit.serial =
              year: moment().year()
              number: (result[0]?.serialNumber ? 0) + 1
            db.Unfit.create unfit, callback
        else
          db.Unfit.findByIdAndUpdate unfit._id, unfit, callback
      (unfit, callback) ->
        db.Patient.populate unfit, "patient", callback
    ], callback

  removeUnfit: (unfit, callback) ->
    db.Unfit.remove _id: unfit._id , callback

  getDiagnosesSuggestions: (query, skip, limit, callback) ->
    query = new RegExp query, "i"
    db.Unfit.aggregate()
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
    db.Unfit.aggregate()
      .project comments: 1
      .match comments: query
      .group _id: "$comments"
      .sort _id: 1
      .skip skip
      .limit limit
      .exec (err, results) ->
        callback err, results.map (x) -> x._id

module.exports = new AsyncCaller
  mountPath: "/async-calls/unfits"
  calls: calls
