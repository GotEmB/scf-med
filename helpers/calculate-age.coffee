moment = require "moment"

module.exports = (dob) ->
  if moment().isBefore moment(dob).add(1, "year")
    moment(dob).fromNow(true)
  else
    dobMoment = moment(dob)
    if moment(dob).year(moment().year()).isBefore(moment())
      moment().year(moment(dob).year()).fromNow(true)
    else
      moment().year(moment(dob).year() + 1).fromNow(true)
