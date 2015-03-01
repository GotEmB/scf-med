React = require "react"

{
  instanceOf
  string
  number
  oneOf
  oneOfType
  shape
  array
  arrayOf
  bool
} = React.PropTypes

date = oneOfType [
  instanceOf Date
  string
]

reactComponent = (props) ->
  unless props.component?.prototype instanceof React.Component
    new Error "Expected `component` to be a React Component."

patient = shape
  _id: string
  id: string
  name: string
  dob: date
  sex: oneOf ["Male", "Female"]
  contact: string
  insuranceId: string
  bloodGroup: string
  address: string

genericDrug = shape
  _id: string
  name: string

brandedDrug = shape
  _id: string
  name: string
  genericDrug: genericDrug

medicine = shape
  brandedDrug: brandedDrug
  dosage: string
  comments: string

prescription = shape
  _id: string
  patient: patient
  date: date
  medicines: arrayOf medicine
  routine: bool

service = shape
  _id: string
  code: string
  name: string
  amount: number

invoice = shape
  _id: string
  patient: patient
  date: date
  services: arrayOf service
  comments: string

module.exports = {
  date
  reactComponent
  patient
  genericDrug
  brandedDrug
  medicine
  prescription
  service
  invoice
}
