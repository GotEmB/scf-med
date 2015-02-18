React = require "react"

module.exports =
  patient: React.PropTypes.shape
    id: React.PropTypes.string
    name: React.PropTypes.string
    dob: React.PropTypes.instanceOf Date
    sex: React.PropTypes.oneOf ["Male", "Female"]
