React = require 'react'
Engine = require '../layout/engine'
Draw = require '../layout/draw'
# Label = require './label'
Region = React.createFactory require './region'
# Label = React.createFactory require './label'
{polarToCartesian} = require '../layout/engine'
{rect, circle, g, text, textPath, path} = React.DOM
ptc = polarToCartesian
Messenger = require './messenger'

class Participant extends React.Component

  constructor: (props) ->
    super(props)

  componentDidMount: ->
    # Whenever there may be a change in the Backbone data, trigger a reconcile.
    @props.model.on 'add change remove', @forceUpdate.bind(this, null), this

  componentWillUnmount: ->
    # Ensure that we clean up any dangling references when the component is
    # destroyed.
    @getBackboneModels().forEach ((model) ->
      model.off null, null, this
      return
    ), this
    return

  focusMe: (bool) =>
    if bool is true
      tt =
        title: "Participant"
        text: [
          @props.model.get("interactor").get("label"),
          "(" + @props.model.get("interactor").get("id") + ")"
        ]

      Messenger.publish "label", tt
    else
      Messenger.publish "label", null
    @props.model.set focus: bool

  render: ->


    Regions = []

    @props.model.get("features").map (f) =>

      # Create a scale from the beginning to the end of the arc angles
      # with a range of the length of the participant
      scale = Engine.scale([@props.view.startAngle, @props.view.endAngle],
        [0, @props.model.get("interactor").get("length")])

      f.get("sequenceData")?.map (s) =>

        # Generate a Region component using the scaled data from the
        # current view

        if s.get("start") != null && s.get("end") != null

          Regions.push Region
            model: s
            key: s.cid
            view:
              radius: @props.view.radius
              startAngle: scale.val s.get("start")
              endAngle: scale.val s.get("end")


    g {key: @props.model.get("key")},
      if @props.view.hasLength is true
        g {},
          path
            onMouseEnter: => @focusMe true
            onMouseLeave: => @focusMe false
            className: "participant" + if @props.model.get("focus") is true then " focused" else ""
            d: Draw.arc @props.view,
          # path
          #   onMouseEnter: => @focusMe true
          #   onMouseLeave: => @focusMe false
          #   className: "participantUnknown" + if @props.model.get("focus") is true then " focused" else ""
          #   d: Draw.arc2 @props.view
      else
        {x: cx, y: cy} = ptc @props.view.radius, @props.view.endAngle
        circle {cx: cx, cy: cy, className: "nolenpart", r: 10 }
      # {x: x1, y: y1} = (ptc @props.view.radius, @props.view.endAngle)
      # console.log "xy", x, y

      # participantCenter = Draw.center(@props.view)
      # console.log "C", participantCenter.x, participantCenter.y
      mid = (@props.view.endAngle + @props.view.startAngle) / 2

      text {
        className: "participantLabel",
        x: Draw.center(@props.view).x,
        y: Draw.center(@props.view).y,
        textAnchor: if mid <= 180 then "start" else "end"
        }, @props.model.get("interactor").get("label")

      text {
        className: "length",
        x: Draw.radial(@props.view.startAngle, 156).x,
        y: Draw.radial(@props.view.startAngle, 156).y,
        textAnchor: "middle",
        alignmentBaseline: "middle"
        }, 1

      text {
        className: "length",
        x: Draw.radial(@props.view.endAngle, 156).x,
        y: Draw.radial(@props.view.endAngle, 156).y,
        textAnchor: "middle",
        alignmentBaseline: "middle"
        }, @props.model.get("interactor").get("length")



      path {className: "tick", d: Draw.line(@props.view.startAngle, 150, 20), pointerEvents: "none"}
      path {className: "tick", d: Draw.line(@props.view.endAngle, 150, 20), pointerEvents: "none"}



      # text {
      #   className: "participantLabel",
      #   textAnchor: "middle",
      #   alignmentBaseline: "middle"},
      #   React.createElement "textPath", {
      #     xlinkHref: "#tp" + @props.model.get("id"),
      #     startOffset: "50%"
      #   }, @props.model.get("interactor").get("label")
      Regions

      if @props.view.hasLength
        for t in Draw.ticks @props.view, 5
          path {className: "tick", d: t, pointerEvents: "none"}




module.exports = Participant
