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
  nationality: string
  jobTitle: string
  department: string
  sponsor: string
  language: string
  smoking: bool

visit = shape
  _id: string
  patient: patient
  date: date
  symptom: String
  sign: String
  test: String
  provisionalDiagnosis: String
  finalDiagnosis: String
  comments: String
  newVisit: bool

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

test = shape
  _id: string
  code: string
  name: string

invoice = shape
  _id: string
  patient: patient
  date: date
  services: arrayOf service
  comments: string
  copay: number

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
  visit
  test
}
