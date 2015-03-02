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
      db.Patient.findByIdAndUpdate patient._id, patient, callback

  removePatient: (patient, callback) ->
    db.Patient.remove _id: patient._id, callback

  getBloodGroupSuggestions: (query, skip, limit, callback) ->
    query = new RegExp query, "i"
    db.Patient.aggregate()
      .project "$bloodGroup"
      .match bloodGroup: query
      .group _id: "$bloodGroup"
      .sort _id: 1
      .skip skip
      .limit limit
      .exec (err, results) ->
        callback err, results.map (x) -> x._id

module.exports = new AsyncCaller
  mountPath: "/async-calls/patients"
  calls: calls
