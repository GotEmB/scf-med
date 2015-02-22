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
} = React.PropTypes

date = oneOfType [
  instanceOf Date
  string
]

patient = shape
  _id: string
  id: string
  name: string
  dob: date
  sex: oneOf ["Male", "Female"]

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
  when: oneOf ["Before Food", "With Food", "After Food"]
  frequency: string
  administration: oneOf ["Oral"]
  duration: string
  comments: string

prescription = shape
  _id: string
  patient: patient
  date: date
  medicines: arrayOf medicine

module.exports = {
  date
  patient
  genericDrug
  brandedDrug
  medicine
  prescription
}
