async = require "async"
AsyncCaller = require "../async-caller"
db = require "../db"

calls =

  getServices: (query, skip, limit, callback) ->
    query = new RegExp query, "i"
    async.parallel [
      (callback) ->
        db.Service
          .find $or: [{id: query}, {name: query}]
          .sort "code"
          .skip skip
          .limit limit
          .exec callback
      (callback) ->
        db.Service
          .count $or: [{id: query}, {name: query}]
          .exec callback
    ], (err, [services, total]) ->
      callback err, services, total

  commitService: (service, callback) ->
    unless service._id?
      db.Service.create service, callback
    else
      db.Service.update {_id: service._id}, service, callback

  removeService: (service, callback) ->
    db.Service.remove _id: service._id, callback

module.exports = new AsyncCaller
  mountPath: "/async-calls/services"
  calls: calls
