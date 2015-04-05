async = require "async"
AsyncCaller = require "../async-caller"
db = require "../db"

calls =

  getSymptoms: (query, skip, limit, callback) ->
    query = new RegExp query, "i"
    async.parallel [
      (callback) ->
        db.Symptom
          .find $or: [{id: query}, {name: query}]
          .sort "name"
          .skip skip
          .limit limit
          .exec callback
      (callback) ->
        db.Symptom
          .count $or: [{id: query}, {name: query}]
          .exec callback
    ], (err, [symptoms, total]) ->
      callback err, symptoms, total

  commitSymptom: (symptom, callback) ->
    unless symptom._id?
      db.Symptom.create symptom, callback
    else
      db.Symptom.findByIdAndUpdate symptom._id, symptom, callback

  removeSymptom: (symptom, callback) ->
    db.Symptom.remove _id: symptom._id, callback

module.exports = new AsyncCaller
  mountPath: "/async-calls/symptoms"
  calls: calls
