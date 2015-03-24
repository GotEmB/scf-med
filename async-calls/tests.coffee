async = require "async"
AsyncCaller = require "../async-caller"
db = require "../db"

calls =

  getTests: (query, skip, limit, callback) ->
    query = new RegExp query, "i"
    async.parallel [
      (callback) ->
        db.Test
          .find $or: [{id: query}, {name: query}]
          .sort "name"
          .skip skip
          .limit limit
          .exec callback
      (callback) ->
        db.Test
          .count $or: [{id: query}, {name: query}]
          .exec callback
    ], (err, [tests, total]) ->
      callback err, tests, total

  commitTest: (test, callback) ->
    unless test._id?
      db.Test.create test, callback
    else
      db.Test.findByIdAndUpdate test._id, test, callback

  removeTest: (test, callback) ->
    db.Test.remove _id: test._id, callback

module.exports = new AsyncCaller
  mountPath: "/async-calls/tests"
  calls: calls
