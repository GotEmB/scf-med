async = require "async"
AsyncCaller = require "../async-caller"
db = require "../db"

calls =

  getDiagnoses: (query, skip, limit, callback) ->
    query = new RegExp query, "i"
    async.parallel [
      (callback) ->
        db.Diagnosis
          .find $or: [{id: query}, {name: query}]
          .sort "name"
          .skip skip
          .limit limit
          .exec callback
      (callback) ->
        db.Diagnosis
          .count $or: [{id: query}, {name: query}]
          .exec callback
    ], (err, [diagnoses, total]) ->
      callback err, diagnoses, total

  commitDiagnosis: (diagnosis, callback) ->
    unless diagnosis._id?
      db.Diagnosis.create diagnosis, callback
    else
      db.Diagnosis.findByIdAndUpdate diagnosis._id, diagnosis, callback

  removeDiagnosis: (diagnosis, callback) ->
    db.Diagnosis.remove _id: diagnosis._id, callback

module.exports = new AsyncCaller
  mountPath: "/async-calls/diagnoses"
  calls: calls
