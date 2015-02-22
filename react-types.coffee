React = require "react"

patient = React.PropTypes.shape
  _id: React.PropTypes.string
  id: React.PropTypes.string
  name: React.PropTypes.string
  dob: React.PropTypes.oneOfType [
    React.PropTypes.instanceOf Date
    React.PropTypes.string
  ]
  sex: React.PropTypes.oneOf ["Male", "Female"]

genericDrug = React.PropTypes.shape
  _id: React.PropTypes.string
  name: React.PropTypes.string

brandedDrug = React.PropTypes.shape
  _id: React.PropTypes.string
  name: React.PropTypes.string
  genericDrug: genericDrug

module.exports = {patient, genericDrug, brandedDrug}
