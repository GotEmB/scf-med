asyncCaller = require "../async-caller"

calls =
  salute: (name, callback) ->
    if name is ""
      callback "Hello, world!"
    else
      callback "Hello, #{name}!"

module.exports = asyncCaller
  mountPath: "/async-calls/le-api"
  calls: calls
