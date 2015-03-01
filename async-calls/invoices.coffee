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
    async.waterfall [
      (callback) ->
        invoice.patient = invoice.patient?._id
        for service, i in invoice.services
          invoice.services[i] = service?._id
        unless invoice._id?
          async.waterfall [
            (callback) ->
              db.Invoice.aggregate()
                .project
                  serialYear: "$serial.year"
                  serialNumber: "$serial.number"
                .match
                  serialYear: moment().year()
                .project
                  serialNumber: 1
                .sort "-serialNumber"
                .limit 1
                .exec callback
          ], (err, result) ->
            invoice.serial =
              year: moment().year()
              number: (result[0]?.serialNumber ? 0) + 1
            db.Invoice.create invoice, callback
        else
          db.Invoice.findByIdAndUpdate invoice._id, invoice, callback
      (invoice, callback) ->
        db.Patient.populate invoice, "patient", callback
      (invoice, callback) ->
        db.Service.populate invoice, "services", callback
    ], callback

  removeInvoice: (invoice, callback) ->
    db.Invoice.remove _id: invoice._id , callback

module.exports = new AsyncCaller
  mountPath: "/async-calls/invoices"
  calls: calls
