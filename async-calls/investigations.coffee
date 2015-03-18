async = require "async"
AsyncCaller = require "../async-caller"
db = require "../db"

calls =

  getInvestigations: (query, skip, limit, callback) ->
    query = new RegExp query, "i"
    async.parallel [
      (callback) ->
        db.Investigation
          .find $or: [{id: query}, {name: query}]
          .sort "code"
          .skip skip
          .limit limit
          .exec callback
      (callback) ->
        db.Investigation
          .count $or: [{id: query}, {name: query}]
          .exec callback
    ], (err, [investigations, total]) ->
      callback err, investigations, total

  commitInvestigation: (investigation, callback) ->
    unless investigation._id?
      db.Investigation.create investigation, callback
    else
      db.Investigation.findByIdAndUpdate investigation._id, investigation, callback

  removeInvestigation: (investigation, callback) ->
    db.Investigation.remove _id: investigation._id, callback

module.exports = new AsyncCaller
  mountPath: "/async-calls/investigations"
  calls: calls
