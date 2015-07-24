clone = require "clone"
DateInput = require "./date-input"
deepDiff = require "deep-diff"
EditPatient = require "./edit-patient"
moment = require "moment"
nextTick = require "next-tick"
numeral = require "numeral"
Page = require "./page"
padNumber = require "pad-number"
patientsCalls = require("../async-calls/patients").calls
React = require "react"
reactTypes = require "../react-types"
TextInput = require "./text-input"
TypeaheadSelect = require "./typeahead-select"

class module.exports extends React.Component
  @displayName: "EditVital"

  @propTypes:
    vital: reactTypes.vital
    onVitalChange: React.PropTypes.func.isRequired
    onCommit: React.PropTypes.func

  @defaultProps:
    vital:
      patient: undefined
      date: undefined
      temperature: undefined
      systole: undefined
      diastole: undefined
      pulse: undefined
      height: undefined
      weight: undefined
      comments: undefined

  handleDateChanged: (date) =>
    vital = clone @props.vital
    vital.date = date
    @props.onVitalChange vital

  handlePatientChanged: (patient) =>
    vital = clone @props.vital
    vital.patient = patient
    @props.onVitalChange vital

  handleTemperatureChanged: (temperature) =>
    vital = clone @props.vital
    temperatureNumber =
      unless temperature?
        undefined
      else if isNaN temperature
        @props.vital.temperature
      else
        Number temperature
    vital.temperature = temperatureNumber
    @props.onVitalChange vital

  handlePulseChanged: (pulse) =>
    vital = clone @props.vital
    pulseNumber =
      unless pulse?
        undefined
      else if isNaN pulse
        @props.vital.pulse
      else
        Number pulse
    vital.pulse = pulseNumber
    @props.onVitalChange vital

  handleSystoleChanged: (systole) =>
    vital = clone @props.vital
    systoleNumber =
      unless systole?
        undefined
      else if isNaN systole
        @props.vital.systole
      else
        Number systole
    vital.systole = systoleNumber
    @props.onVitalChange vital

  handleDiastoleChanged: (diastole) =>
    vital = clone @props.vital
    diastoleNumber =
      unless diastole?
        undefined
      else if isNaN diastole
        @props.vital.diastole
      else
        Number diastole
    vital.diastole = diastoleNumber
    @props.onVitalChange vital

  handleHeightChanged: (height) =>
    vital = clone @props.vital
    heightNumber =
      unless height?
        undefined
      else if isNaN height
        @props.vital.height
      else
        Number height
    vital.height = heightNumber
    @props.onVitalChange vital

  handleWeightChanged: (weight) =>
    vital = clone @props.vital
    weightNumber =
      unless weight?
        undefined
      else if isNaN weight
        @props.vital.weight
      else
        Number weight
    vital.weight = weightNumber
    @props.onVitalChange vital

  handleCommentsChanged: (comments) =>
    vital = clone @props.vital
    vital.comments = comments
    @props.onVitalChange vital

  render: ->
    if @props.vital.weight? and @props.vital.height?
      bmi = (@props.vital.weight ? 0) /
        Math.pow((@props.vital.height ? Infinity) / 100, 2)
      bmi = numeral(bmi).format "0.00"
    bmiDescription =
      unless bmi?
        undefined
      else if 0 <= bmi < 18.5
        "Underweight"
      else if 18.5 <= bmi < 25
        "Normal"
      else if 25 <= bmi < 30
        "Overweight"
      else if 30 <= bmi < Infinity
        "Obese"
    bmiDescriptionSpan =
      if bmi?
        <span className="input-group-addon">{bmiDescription}</span>
    bmiClassName =
      unless bmiDescription?
        undefined
      else if bmiDescription is "Normal"
        "input-group has-success"
      else
        "input-group has-error"
    newPatientSuggestion =
      component: EditPatient
      dataProperty: "patient"
      commitMethod: patientsCalls.commitPatient
      removeMethod: patientsCalls.removePatient
    <div>
      <div className="form-group" style={position: "relative"}>
        <label>Date & Time</label>
        <DateInput
          date={@props.vital.date}
          onDateChange={@handleDateChanged}
          hasTime={true}
          className="form-control"
        />
      </div>
      <TypeaheadSelect
        selectedItem={@props.vital.patient}
        onSelectedItemChange={@handlePatientChanged}
        suggestionsFetcher={patientsCalls.getPatients}
        textFormatter={(x) -> "#{x.name} - #{x.id}"}
        label="* Patient (required)"
        newSuggestion={newPatientSuggestion}
      />
      <div className="form-group" style={position: "relative"}>
        <label>Temperature (℃)</label>
        <TextInput
          type="text"
          className="form-control"
          value={@props.vital.temperature}
          onChange={@handleTemperatureChanged}
        />
      </div>
      <div className="form-group" style={position: "relative"}>
        <label>Pulse (/min)</label>
        <TextInput
          type="text"
          className="form-control"
          value={@props.vital.pulse}
          onChange={@handlePulseChanged}
        />
      </div>
      <div className="form-group" style={position: "relative"}>
        <label>Systole (mm Hg)</label>
        <TextInput
          type="text"
          className="form-control"
          value={@props.vital.systole}
          onChange={@handleSystoleChanged}
        />
      </div>
      <div className="form-group" style={position: "relative"}>
        <label>Diastole (mm Hg)</label>
        <TextInput
          type="text"
          className="form-control"
          value={@props.vital.diastole}
          onChange={@handleDiastoleChanged}
        />
      </div>
      <div className="form-group" style={position: "relative"}>
        <label>Height (cm)</label>
        <TextInput
          type="text"
          className="form-control"
          value={@props.vital.height}
          onChange={@handleHeightChanged}
        />
      </div>
      <div className="form-group" style={position: "relative"}>
        <label>Weight (kg)</label>
        <TextInput
          type="text"
          className="form-control"
          value={@props.vital.weight}
          onChange={@handleWeightChanged}
        />
      </div>
      <div className="form-group" style={position: "relative"}>
        <label>BMI (kg/m²)</label>
        <div className={bmiClassName}>
          <input
            type="text"
            className="form-control"
            value={bmi}
            disabled
          />
          {bmiDescriptionSpan}
        </div>
      </div>
      <div className="form-group" style={position: "relative"}>
        <label>Comments</label>
        <TextInput
          type="text"
          className="form-control"
          value={@props.vital.comments}
          onChange={@handleCommentsChanged}
        />
      </div>
    </div>

  componentWillMount: ->
    if Object.keys(@props.vital).length is 0
      vital = clone @constructor.defaultProps.vital
      vital.date = moment().toISOString()
      @props.onVitalChange vital

  componentWillUnmount: ->
    Page.unsetPrintView()
