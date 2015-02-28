async = require "async"
AsyncCaller = require "../async-caller"
db = require "../db"

calls =

  getGenericDrugs: (query, skip, limit, callback) ->
    query = new RegExp query, "i"
    async.parallel [
      (callback) ->
        db.GenericDrug
          .find name: query
          .sort "name"
          .skip skip
          .limit limit
          .exec callback
      (callback) ->
        db.GenericDrug
          .count name: query
          .exec callback
    ], (err, [genericDrugs, total]) ->
      callback err, genericDrugs, total

  commitGenericDrug: (genericDrug, callback) ->
    unless genericDrug._id?
      db.GenericDrug.create genericDrug, callback
    else
      db.GenericDrug.update {_id: genericDrug._id}, genericDrug, callback

  removeGenericDrug: (genericDrug, callback) ->
    async.parallel [
      (callback) ->
        db.GenericDrug.remove _id: genericDrug._id, callback
      (callback) ->
        db.BrandedDrug.remove genericDrug: genericDrug._id, callback
    ], callback

  getBrandedDrugs: (query, skip, limit, callback) ->
    query = new RegExp query, "i"
    async.auto
      genericDrugIDs: (callback) ->
        db.GenericDrug
          .find name: query
          .select "_id"
          .exec callback
      brandedDrugs: ["genericDrugIDs", (callback, {genericDrugIDs}) ->
        db.BrandedDrug
          .find $or: [{genericDrug: $in: genericDrugIDs}, {name: query}]
          .sort "name"
          .skip skip
          .limit limit
          .populate "genericDrug"
          .exec callback
      ]
      total: ["genericDrugIDs", (callback, {genericDrugIDs}) ->
        db.BrandedDrug
          .count $or: [{genericDrug: $in: genericDrugIDs}, {name: query}]
          .exec callback
      ]
      (err, {brandedDrugs, total}) ->
        callback err, brandedDrugs, total

  commitBrandedDrug: (brandedDrug, callback) ->
    async.waterfall [
      (callback) ->
        brandedDrug.genericDrug = brandedDrug.genericDrug?._id
        unless brandedDrug._id?
          db.BrandedDrug.create brandedDrug, callback
        else
          db.BrandedDrug.update {_id: brandedDrug._id}, brandedDrug, callback
      (brandedDrug, callback) ->
        db.GenericDrug.populate brandedDrug, "genericDrug", callback
    ], callback

  removeBrandedDrug: (brandedDrug, callback) ->
    db.BrandedDrug.remove _id: brandedDrug._id, callback

module.exports = new AsyncCaller
  mountPath: "/async-calls/drugs"
  calls: calls
