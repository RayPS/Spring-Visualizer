# Framer.Loop.delta = 1/240 # Slow Motion
document.body.style.cursor = "auto"
Framer.Defaults.deviceType = "fullScreen"


BG = new Layer
	size: Screen.size
	backgroundColor: "hsl(0, 0%, 12%)"

monitorMargin = 20

monitor = new Layer
	x: monitorMargin
	y: monitorMargin
	size: Screen.width - monitorMargin * 2
	backgroundColor: "hsl(0, 0%, 10%)"
	borderRadius: 10
	borderWidth: 1
	borderColor: "hsl(0, 0%, 25%)"
	clip: true


gridFactor = 20 # Numbers of lines to draw the grid
gridGap = monitor.width / gridFactor
gridColor = new Color("black").lighten(15)

for gridIndex in [0...gridFactor - 1]
	monitor.addChild new Layer
		width: monitor.width-2, height: 1
		y: gridGap * gridIndex + gridGap - 2
		backgroundColor:
			if gridIndex is gridFactor / 2 - 1
			then gridColor.lighten(10)
			else gridColor

	monitor.addChild new Layer
		width: 1, height: monitor.height-2
		x: gridGap * gridIndex + gridGap
		backgroundColor: gridColor

oval = new Layer
	parent: monitor
	size: monitor.size, scale: 0.25
	x: Align.center
	y: Align.center
	borderRadius: "50%"
	backgroundColor: "rgba(0,104,22,0.14)"

oval.states.add state: scale: 0.5

rect = new Layer
	parent: monitor
	size: monitor.height / 25
	borderRadius: "25%"
	backgroundColor: "rgba(121,0,178,1)"
	x: Align.right(-5), y: Align.bottom(-5)

sliderPanel = new Layer
# 	width: Screen.width - monitorMargin * 2
# 	height: Screen.height - monitor.maxY - monitorMargin * 2
	width: monitor.width
	height: 250
	x: monitorMargin
	y: monitor.maxY + monitorMargin
	borderRadius: 10
	backgroundColor: "hsla(0, 0%, 100%, 0.015)"
	borderWidth: 1
	borderColor:  "hsla(0, 0%, 100%, 0.05)"
	shadowY: 5, shadowBlur: 20
	shadowColor: "hsla(0, 0%, 0%, 0.05)"


sliderPanelPadding = 20
sliderLabelHeight = 20

for name, index in ["Tension", "Friction", "Velocity"]

	labelProps =
		parent: sliderPanel
		html: name
		color: "hsla(0, 0%, 100%, 0.2)"
		backgroundColor: "transparent"
		y: sliderPanelPadding + index * 75
		width: 100, height: sliderLabelHeight
		style:
			fontSize: "16px"
			lineHeight: sliderLabelHeight + "px"
# 		backgroundColor: "#1F1F1F"

	label = new Layer
	label.props = labelProps
	label.name = "#{name}Label"
	label.x = monitorMargin

	value = new Layer
	value.props = labelProps
	value.name = "#{name}Value"
	value.x = Align.right(-monitorMargin)
	value.style.textAlign = "right"

	slider = new SliderComponent
		name: name
		parent: sliderPanel
		x: monitorMargin
		y: label.maxY + 10
		width: sliderPanel.width - monitorMargin * 2
		height: 5
		backgroundColor: "hsla(0, 0%, 0%, 0.2)"
		shadowY: 1
		shadowColor: "hsla(0, 0%, 100%, 0.1)"

	slider.fill.backgroundColor = "#28affa"

	slider.knob.draggable.momentum = false
	newKnob = slider.knob.copy()
	slider.knob.props =
		height: 50
		shadowBlur: 0
		shadowY: 0
		shadowColor: "transparent"
		backgroundColor: "transparent"
		cornerRadius: 0
	slider.knob.addChild newKnob
	newKnob.size = 20
	newKnob.center()



	slider.min = if name is "Velocity" then 0 else 1
	slider.max = if name is "Tension" then 1000 else 100

	value.html = slider.value = switch name
		when "Tension" then 500
		when "Friction" then 25
		when "Velocity" then 0

	slider.on "change:value", (event, layer) ->
		roundedValue = Utils.round this.value
		valueLabel = sliderPanel.subLayersByName("#{layer.name}Value")[0]
		valueLabel.html = roundedValue

	slider.on Events.TouchEnd, (event, layer) ->
		clean()
		drawBySlider()

tension = sliderPanel.subLayersByName("Tension")[0]
friction = sliderPanel.subLayersByName("Friction")[0]
velocity = sliderPanel.subLayersByName("Velocity")[0]


clean = ->
	canvas = monitor.subLayersByName("canvas")[0]
	canvas.destroy()

draw = (tension, friction, velocity) ->

	curveOptions =
		tension: tension
		friction: friction
		velocity: velocity

	canvas = new Layer
		name: "canvas"
		parent: monitor
		backgroundColor: "transparent"
		size: monitor.size

	brush = new Layer
		parent: canvas
		size: rect.size
		borderRadius: "50%"
		backgroundColor: "yellow"
		y: Align.bottom
		scale: 0.75

	oval.states.animationOptions =
		curve: "spring-rk4"
		curveOptions: curveOptions
	oval.states.next()

	rect.y = Align.bottom
	rect.animate
		curve: "spring-rk4"
		curveOptions: curveOptions
		properties: y: Align.center

	drawY = brush.animate
		curve: "spring-rk4"
		curveOptions: curveOptions
		properties:
			y: Align.center(-1)
			backgroundColor: "red"

	drawX = brush.animate
		curve: "linear"
		properties:
			midX: rect.midX

	drawX.onAnimationEnd ->
		drawY.stop()

	brush.on "change:y", ->
		if brush.x <= canvas.width
			clone = @copy()
			clone.animate
				time: 0.5
				properties: scale: 0.2
			canvas.addChild clone

drawBySlider = () ->
	draw(tension.value, friction.value, velocity.value)
drawBySlider()


monitor.onClick ->
	if not rect.isAnimating
		clean()
		drawBySlider()
