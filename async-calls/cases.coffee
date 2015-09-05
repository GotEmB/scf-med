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
          .populate "diagnoses"
          .populate "signs"
          .populate "symptoms"
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
    unless diagnosis._id?
      db.Diagnosis.create diagnosis, callback
    else
      db.Diagnosis.findByIdAndUpdate diagnosis._id, diagnosis, callback

  removeVisit: (visit, callback) ->
    db.Visit.remove _id: visit._id , callback

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
