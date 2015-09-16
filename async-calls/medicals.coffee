async = require "async"
AsyncCaller = require "../async-caller"
db = require "../db"
moment = require "moment"

calls =

  getMedicals: (query, skip, limit, callback) ->
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
      medicals: ["patientIDs", (callback, {patientIDs}) ->
        db.Medical
          .find date: dateQuery, patient: $in: patientIDs
          .sort "-date"
          .skip skip
          .limit limit
          .populate "patient"
          .exec callback
      ]
      total: ["patientIDs", (callback, {patientIDs}) ->
        db.Medical
          .count date: dateQuery, patient: $in: patientIDs
          .exec callback
      ]
      (err, {medicals, total}) ->
        callback err, medicals, total

  commitMedical: (Medical, callback) ->
    async.waterfall [
      (callback) ->
        medical.patient = medical.patient?._id
        unless medical._id?
          async.waterfall [
            (callback) ->
              db.Medical.aggregate()
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
            medical.serial =
              year: moment().year()
              number: (result[0]?.serialNumber ? 0) + 1
            db.Medical.create medical, callback
        else
          db.Medical.findByIdAndUpdate medical._id, medical, callback
      (medical, callback) ->
        db.Patient.populate medical, "patient", callback
    ], callback

  removeMedical: (medical, callback) ->
    db.Medical.remove _id: medical._id , callback

  getDiagnosesSuggestions: (query, skip, limit, callback) ->
    query = new RegExp query, "i"
    db.Medical.aggregate()
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
    db.Medical.aggregate()
      .project comments: 1
      .match comments: query
      .group _id: "$comments"
      .sort _id: 1
      .skip skip
      .limit limit
      .exec (err, results) ->
        callback err, results.map (x) -> x._id

module.exports = new AsyncCaller
  mountPath: "/async-calls/medicals"
  calls: calls
