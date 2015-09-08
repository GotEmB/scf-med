async = require "async"
AsyncCaller = require "../async-caller"
db = require "../db"
moment = require "moment"

calls =

  getMemos: (query, skip, limit, callback) ->
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
      memos: ["patientIDs", (callback, {patientIDs}) ->
        db.Memo
          .find date: dateQuery, patient: $in: patientIDs
          .sort "-date"
          .skip skip
          .limit limit
          .populate "patient"
          .exec callback
      ]
      total: ["patientIDs", (callback, {patientIDs}) ->
        db.Memo
          .count date: dateQuery, patient: $in: patientIDs
          .exec callback
      ]
      (err, {memos, total}) ->
        callback err, memos, total

  commitMemo: (Memo, callback) ->
    async.waterfall [
      (callback) ->
        memo.patient = memo.patient?._id
        unless memo._id?
          async.waterfall [
            (callback) ->
              db.Memo.aggregate()
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
            memo.serial =
              year: moment().year()
              number: (result[0]?.serialNumber ? 0) + 1
            db.Memo.create memo, callback
        else
          db.Memo.findByIdAndUpdate memo._id, memo, callback
      (memo, callback) ->
        db.Patient.populate memo, "patient", callback
    ], callback

  removeMemo: (memo, callback) ->
    db.Memo.remove _id: memo._id , callback

  getDiagnosesSuggestions: (query, skip, limit, callback) ->
    query = new RegExp query, "i"
    db.Memo.aggregate()
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
    db.Memo.aggregate()
      .project comments: 1
      .match comments: query
      .group _id: "$comments"
      .sort _id: 1
      .skip skip
      .limit limit
      .exec (err, results) ->
        callback err, results.map (x) -> x._id

module.exports = new AsyncCaller
  mountPath: "/async-calls/memos"
  calls: calls
