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
          .populate "provisionalDiagnoses"
          .populate "finalDiagnoses"
          .populate "signs"
          .exec callback
      ]
      total: ["patientIDs", (callback, {patientIDs}) ->
        db.Visit
          .count date: dateQuery, patient: $in: patientIDs
          .exec callback
      ]
      (err, {visits, total}) ->
        callback err, visits, total

  commitUnfit: (unfit, callback) ->
    async.waterfall [
      (callback) ->
        unfit.patient = unfit.patient?._id
        for provisionalDiagnosis, i in unfit.provisionalDiagnoses
          unfit.provisionalDiagnoses[i] = provisionalDiagnosis?._id
        for Diagnosis, i in unfit.finalDiagnoses
          unfit.finalDiagnoses[i] = finalDiagnosis?._id
        unless unfit._id?
          db.Unfit.create unfit, callback
        else
          db.Unfit.findByIdAndUpdate unfit._id, unfit, callback
      (unfit, callback) ->
        db.Patient.populate unfit, "patient", callback
      (unfit, callback) ->
        db.Diagnosis.populate unfit, "provisionalDiagnoses", callback
      (unfit, callback) ->
        db.Diagnosis.populate unfit, "finalDiagnoses", callback
    ], callback

  removeUnfit: (unfit, callback) ->
    db.Unfit.remove _id: unfit._id , callback

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
