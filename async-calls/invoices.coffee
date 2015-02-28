async = require "async"
AsyncCaller = require "../async-caller"
db = require "../db"
moment = require "moment"

calls =

  getInvoices: (query, skip, limit, callback) ->
    if typeof query is "string"
      textQuery = new RegExp query, "i"
    else
      textQuery = new RegExp query.text, "i"
      dateQuery =
        $gte: moment(query.daterange.from).toDate()
        $lte: moment(query.daterange.to).toDate()
    async.auto
      patientIDs: (callback) ->
        db.Patient
          .find $or: [{id: textQuery}, {name: textQuery}]
          .select "_id"
          .exec callback
      invoices: ["patientIDs", (callback, {patientIDs}) ->
        db.Invoice
          .find date: dateQuery, patient: $in: patientIDs
          .sort "-date"
          .skip skip
          .limit limit
          .populate "patient"
          .populate "services"
          .exec callback
      ]
      total: ["patientIDs", (callback, {patientIDs}) ->
        db.Invoice
          .count date: dateQuery, patient: $in: patientIDs
          .exec callback
      ]
      (err, {invoices, total}) ->
        callback err, invoices, total

  commitInvoice: (invoice, callback) ->
    invoice.patient = invoice.patient?._id
    for service, i in invoice.services
      invoice.services[i] = service?._id
    unless invoice._id?
      db.Invoice.create invoice, callback
    else
      db.Invoice.update {_id: invoice._id}, invoice, callback

  removeInvoice: (invoice, callback) ->
    db.Invoice.remove _id: invoice._id , callback

module.exports = new AsyncCaller
  mountPath: "/async-calls/invoices"
  calls: calls
