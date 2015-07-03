async = require "async"
AsyncCaller = require "../async-caller"
db = require "../db"

calls =

  getComplaints: (query, skip, limit, callback) ->
    query = new RegExp query, "i"
    async.parallel [
      (callback) ->
        db.Complaint
          .find $or: [{id: query}, {name: query}]
          .sort "name"
          .skip skip
          .limit limit
          .exec callback
      (callback) ->
        db.Complaint
          .count $or: [{id: query}, {name: query}]
          .exec callback
    ], (err, [complaints, total]) ->
      callback err, complaints, total

  commitComplaint: (complaint, callback) ->
    unless complaint._id?
      db.Complaint.create complaint, callback
    else
      db.Complaint.findByIdAndUpdate complaint._id, complaint, callback

  removeComplaint: (complaint, callback) ->
    db.Complaint.remove _id: complaint._id, callback

module.exports = new AsyncCaller
  mountPath: "/async-calls/complaints"
  calls: calls
