async = require "async"
AsyncCaller = require "../async-caller"
db = require "../db"

calls =

  getSigns: (query, skip, limit, callback) ->
    query = new RegExp query, "i"
    async.parallel [
      (callback) ->
        db.Sign
          .find $or: [{id: query}, {name: query}]
          .sort "name"
          .skip skip
          .limit limit
          .exec callback
      (callback) ->
        db.Sign
          .count $or: [{id: query}, {name: query}]
          .exec callback
    ], (err, [signs, total]) ->
      callback err, signs, total

  commitSign: (sign, callback) ->
    unless sign._id?
      db.Sign.create sign, callback
    else
      db.Sign.findByIdAndUpdate sign._id, sign, callback

  removeSign: (sign, callback) ->
    db.Sign.remove _id: sign._id, callback

module.exports = new AsyncCaller
  mountPath: "/async-calls/signs"
  calls: calls
