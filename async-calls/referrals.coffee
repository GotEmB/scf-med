async = require "async"
AsyncCaller = require "../async-caller"
db = require "../db"
moment = require "moment"

calls =

  getReferrals: (query, skip, limit, callback) ->
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
      referrals: ["patientIDs", (callback, {patientIDs}) ->
        db.Referral
          .find date: dateQuery, patient: $in: patientIDs
          .sort "-date"
          .skip skip
          .limit limit
          .populate "patient"
          .exec callback
      ]
      total: ["patientIDs", (callback, {patientIDs}) ->
        db.Referral
          .count date: dateQuery, patient: $in: patientIDs
          .exec callback
      ]
      (err, {referrals, total}) ->
        callback err, referrals, total

  commitReferral: (referral, callback) ->
    async.waterfall [
      (callback) ->
        referral.patient = referral.patient?._id
        unless referral._id?
          async.waterfall [
            (callback) ->
              db.Referral.aggregate()
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
            referral.serial =
              year: moment().year()
              number: (result[0]?.serialNumber ? 0) + 1
            db.Referral.create referral, callback
        else
          db.Referral.findByIdAndUpdate referral._id, referral, callback
      (referral, callback) ->
        db.Patient.populate referral, "patient", callback
    ], callback

  removeReferral: (referral, callback) ->
    db.Referral.remove _id: referral._id , callback

  getConsultSuggestions: (query, skip, limit, callback) ->
    query = new RegExp query, "i"
    db.Referral.aggregate()
      .project consult: 1
      .match consult: query
      .group _id: "$consult"
      .sort _id: 1
      .skip skip
      .limit limit
      .exec (err, results) ->
        callback err, results.map (x) -> x._id

  getComplaintsSuggestions: (query, skip, limit, callback) ->
    query = new RegExp query, "i"
    db.Referral.aggregate()
      .project complaint: 1
      .match complaint: query
      .group _id: "$complaint"
      .sort _id: 1
      .skip skip
      .limit limit
      .exec (err, results) ->
        callback err, results.map (x) -> x._id

  getDiagnosesSuggestions: (query, skip, limit, callback) ->
    query = new RegExp query, "i"
    db.Referral.aggregate()
      .project diagnosis: 1
      .match diagnosis: query
      .group _id: "$diagnosis"
      .sort _id: 1
      .skip skip
      .limit limit
      .exec (err, results) ->
        callback err, results.map (x) -> x._id

  getInstructionsSuggestions: (query, skip, limit, callback) ->
    query = new RegExp query, "i"
    db.Referral.aggregate()
      .project instruction: 1
      .match instruction: query
      .group _id: "$instruction"
      .sort _id: 1
      .skip skip
      .limit limit
      .exec (err, results) ->
        callback err, results.map (x) -> x._id

  getCommentsSuggestions: (query, skip, limit, callback) ->
    query = new RegExp query, "i"
    db.Referral.aggregate()
      .project comments: 1
      .match comments: query
      .group _id: "$comments"
      .sort _id: 1
      .skip skip
      .limit limit
      .exec (err, results) ->
        callback err, results.map (x) -> x._id

module.exports = new AsyncCaller
  mountPath: "/async-calls/referrals"
  calls: calls
