React = require "react"

class module.exports extends React.Component
  @displayName: "PrescriptionsView"

  constructor: ->
    @state =
      filterQuery: ""
      prescriptions: []
      selectedPrescription: undefined
      loadFrom: 0
      total: 0
      loading: false
      layer: undefined
