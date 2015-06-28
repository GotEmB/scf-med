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

brandedDrug = shape
  _id: string
  name: string
  genericDrug: genericDrug

genericDrug = shape
  _id: string
  name: string

investigation = shape
  _id: string
  patient: patient
  date: date
  tests: arrayOf test
  comments: string

invoice = shape
  _id: string
  patient: patient
  date: date
  services: arrayOf service
  comments: string
  copay: number

medicine = shape
  brandedDrug: brandedDrug
  dosage: string
  duration: string
  received: bool
  comments: string

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
  nationality: string
  jobTitle: string
  department: string
  sponsor: string
  language: string
  smoking: bool

prescription = shape
  _id: string
  patient: patient
  date: date
  medicines: arrayOf medicine
  routine: bool
  pharmacy: string

service = shape
  _id: string
  code: string
  name: string
  amount: number

symptom = shape
  _id: string
  code: string
  name: string

sign = shape
  _id: string
  code: string
  name: string

test = shape
  _id: string
  code: string
  name: string

visit = shape
  _id: string
  patient: patient
  date: date
  symptoms: arrayOf symptom
  signs: arrayOf sign
  comments: string

module.exports = {
  brandedDrug
  date
  genericDrug
  invoice
  investigation
  medicine
  patient
  prescription
  reactComponent
  service
  sign
  symptom
  test
  visit
}
