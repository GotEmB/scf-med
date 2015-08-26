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
      visits: ["patientIDs", (callback, {patientIDs}) ->
        db.Visit
          .find date: dateQuery, patient: $in: patientIDs
          .sort "-date"
          .skip skip
          .limit limit
          .populate "patient"
          .exec callback
      ]
      total: ["patientIDs", (callback, {patientIDs}) ->
        db.Visit
          .count date: dateQuery, patient: $in: patientIDs
          .exec callback
      ]
      (err, {visits, total}) ->
        callback err, visits, total

  commitfit: (fit, callback) ->
    async.waterfall [
      (callback) ->
        fit.patient = fit.patient?._id
        for provisionalDiagnosis, i in fit.provisionalDiagnoses
          fit.provisionalDiagnoses[i] = provisionalDiagnosis?._id
        for Diagnosis, i in fit.finalDiagnoses
          fit.finalDiagnoses[i] = finalDiagnosis?._id
        unless fit._id?
          db.fit.create fit, callback
        else
          db.fit.findByIdAndUpdate fit._id, fit, callback
      (fit, callback) ->
        db.Patient.populate fitfit, "patient", callback
      (fit, callback) ->
        db.Diagnosis.populate fit, "provisionalDiagnoses", callback
      (fit, callback) ->
        db.Diagnosis.populate fit, "finalDiagnoses", callback
    ], callback

  removefit: (fit, callback) ->
    db.fit.remove _id: fit._id , callback

  getSymptomNameSuggestions: (query, skip, limit, callback) ->
    query = new RegExp query, "i"
    db.Visit.aggregate()
      .project symptoms: 1
      .unwind "symptoms"
      .project name: "$symptoms.name"
      .group _id: "$name"
      .match _id: query
      .sort _id: 1
      .skip skip
      .limit limit
      .exec (err, results) ->
        callback err, results.map (x) -> x._id

  getSymptomDurationSuggestions: (query, skip, limit, callback) ->
    query = new RegExp query, "i"
    db.Visit.aggregate()
      .project symptoms: 1
      .unwind "symptoms"
      .project duration: "$symptoms.duration"
      .group _id: "$duration"
      .match _id: query
      .sort _id: 1
      .skip skip
      .limit limit
      .exec (err, results) ->
        callback err, results.map (x) -> x._id

  getSignNameSuggestions: (query, skip, limit, callback) ->
    query = new RegExp query, "i"
    db.Visit.aggregate()
      .project signs: 1
      .unwind "signs"
      .project name: "$signs.name"
      .group _id: "$name"
      .match _id: query
      .sort _id: 1
      .skip skip
      .limit limit
      .exec (err, results) ->
        callback err, results.map (x) -> x._id

module.exports = new AsyncCaller
  mountPath: "/async-calls/visits"
  calls: calls
