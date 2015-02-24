async = require "async"
AsyncCaller = require "../async-caller"
db = require "../db"

calls =

  getPatients: (query, skip, limit, callback) ->
    query = new RegExp query, "i"
    async.parallel [
      (callback) ->
        db.Patient
          .find $or: [{id: query}, {name: query}]
          .sort "id"
          .skip skip
          .limit limit
          .exec callback
      (callback) ->
        db.Patient
          .count $or: [{id: query}, {name: query}]
          .exec callback
    ], (err, [patients, total]) ->
      callback err, patients, total

  commitPatient: (patient, callback) ->
    unless patient._id?
      db.Patient.create patient, callback
    else
      db.Patient.update {_id: patient._id}, patient, callback

  removePatient: (patient, callback) ->
    db.Patient.remove _id: patient._id, callback

module.exports = new AsyncCaller
  mountPath: "/async-calls/patients"
  calls: calls
