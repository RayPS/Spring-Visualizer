# Framer.Loop.delta = 1/240 # Slow Motion
document.body.style.cursor = "auto"
Framer.Defaults.deviceType = "fullScreen"
Framer.Device.contentScale = 1

viewport = document.querySelector "meta[name=viewport]"
viewportContent = "width=device-width, initial-scale=1, user-scalable=no"
viewport.setAttribute("content", viewportContent)

# Framer.Device.setContentScale(1, true)
# Framer.Device.setDeviceScale(0.5, true)

BG = new Layer
	size: Screen.size
	backgroundColor: "hsl(0, 0%, 12.5%)"

tension = 500
friction = 25
velocity = 0

# Monitor
# monitorMargin = 10
monitorMargin = Screen.width * 0.025

monitor = new Layer
	x: monitorMargin
	y: monitorMargin
	size: Screen.width - monitorMargin * 2
	backgroundColor: "hsl(0, 0%, 5%)"
	borderRadius: 8
	borderWidth: 3
	borderColor: "hsla(0, 0%, 100%, 0.05)"
	clip: true
	style:
		boxShadow:
			"0 2px 2px hsla(1, 100%, 100%, 0.03)," +
			"0 -2px 2px hsla(1, 100%, 100%, 0.03)," +
			"inset 0 2px 3px hsla(1, 100%, 0%, 0.2)," +
			"inset 0 0px 5px hsla(1, 100%, 0%, 0.5)"

glassMargin = 6

glass = new Layer
	parent: monitor
	backgroundColor: "transparent"
	width: monitor.width - glassMargin * 2
	height: monitor.width - glassMargin * 2
	x: Align.center
	y: Align.center
	borderRadius: monitor.borderRadius - monitor.borderWidth * 2
	style:
		boxShadow:
			"inset 0 0px 30px hsla(1, 100%, 100%, 0.1)," +
			"inset 0 3px 1px hsla(1, 100%, 100%, 0.1)," +
			"inset 0 -3px 5px hsla(1, 100%, 100%, 0.05)," +
			"inset 0 50px 50px hsla(1, 100%, 100%, 0.02)"

# Grid
gridFactor = 20 # Numbers of lines to draw the grid
gridGap = monitor.width / gridFactor

grid = new Layer
	parent: monitor
	clip: true
	size: monitor.size
	backgroundColor: "none"

for gridIndex in [0...gridFactor - 1]
	grid.addChild new Layer
		width: grid.width, height: 1
		y: gridGap * gridIndex + gridGap - monitor.borderWidth
		backgroundColor: "white"
		opacity:
			if gridIndex is gridFactor / 2 - 1
			then 0.1
			else 0.03

	grid.addChild new Layer
		width: 1, height: grid.height
		x: gridGap * gridIndex + gridGap - monitor.borderWidth
		backgroundColor: "white"
		opacity: 0.03

# Oval & Rect
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
	backgroundColor: "rgba(239,155,40,1)"
	x: Align.right(-5), y: Align.bottom(-5)

# Slider Panel
sliderPanel = new Layer
# 	width: Screen.width - monitorMargin * 2
	height: Screen.height - monitor.maxY - monitorMargin * 2
	width: monitor.width
# 	height: 250
	x: monitorMargin
	y: monitor.maxY + monitorMargin
	borderRadius: monitor.borderRadius
	backgroundColor: "hsla(0, 0%, 0%, 0.5)"
	style:
		boxShadow:
			"0 1px 2px hsla(1, 100%, 100%, 0.05)," +
			"inset 0 2px 3px hsla(1, 100%, 0%, 0.2)"

# Sliders
sliderPanelPadding = 20
sliderLabelHeight = 20

sliderBoxMargin = 2
sliderBoxPadding = 20
sliderBoxHeight = (sliderPanel.height - sliderBoxMargin * 4) / 3

for name, index in ["Tension", "Friction", "Velocity"]

	box = new Layer
		name: "#{name}SliderBox"
		parent: sliderPanel
		x: sliderBoxMargin
		y: sliderBoxMargin + (sliderBoxMargin + sliderBoxHeight) * index
		width: sliderPanel.width - sliderBoxMargin*2
		height: sliderBoxHeight
		borderRadius: sliderPanel.borderRadius - sliderBoxMargin
		backgroundColor: "hsla(0, 0%, 100%, 0.1)"
		style:
			boxShadow:
				"inset 0 1px 2px hsla(1, 100%, 100%, 0.05)," +
				"0 1px 2px hsla(1, 100%, 0%, 0.05)"

	labelProps =
		parent: box
		html: name
		color: "hsla(0, 0%, 100%, 0.3)"
		backgroundColor: "transparent"
		y: sliderBoxPadding
		width: 100, height: sliderLabelHeight
		style:
			fontSize: "16px"
			lineHeight: sliderLabelHeight + "px"
			textShadow: "0 1px 2px hsla(1, 100%, 0%, 0.5)"
# 			backgroundColor: "#1a1a1a"

	label = new Layer
	label.props = labelProps
	label.name = "#{name}Label"
	label.x = sliderBoxPadding

	value = new Layer
	value.props = labelProps
	value.name = "#{name}Value"
	value.x = Align.right(-sliderBoxPadding)
	value.style.textAlign = "right"

	slider = new SliderComponent
		name: name
		parent: box
		x: sliderBoxPadding
		y: Align.bottom(-sliderBoxPadding)
		width: box.width - sliderBoxPadding * 2
		height: 10
		backgroundColor: "hsla(0, 0%, 0%, 0.25)"
		style:
			boxShadow:
				"0 1px 0px hsla(1, 100%, 100%, 0.05)," +
				"inset 0 2px 5px hsla(1, 100%, 0%, 0.2)"


	slider.fill.style =
		backgroundColor: "#28affa"
		boxShadow:
			"inset 0 3px 3px hsla(1, 100%, 100%, 0.3)"

	slider.knob.draggable.momentum = false
	newKnob = slider.knob.copy()
	slider.knob.props =
		height: 50
		backgroundColor: "transparent"
		style: boxShadow: "none"
	slider.knob.addChild newKnob
	newKnob.size = 30
	newKnob.width = 20
	newKnob.center()



	slider.min = if name is "Velocity" then 0 else 1
	slider.max = if name is "Tension" then 1000 else 100

	value.html = slider.value = switch name
		when "Tension" then 500
		when "Friction" then 25
		when "Velocity" then 0
		
	slider.on "change:value", (event, layer) ->
		roundedValue = Utils.round this.value
		valueLabel = layer.parent.subLayersByName("#{layer.name}Value")[0]
		valueLabel.html = roundedValue
		
		variable = layer.name.toLowerCase()
		eval "#{variable} = #{roundedValue}"
# 		print tension, friction, velocity # It works!

	slider.on Events.TouchEnd, (event, layer) ->
		clean()
		draw()



# Draw
# draw = (tension, friction, velocity) ->
draw = () ->
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
			y: Align.center(-monitor.borderWidth)
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


# Clean
clean = ->
	canvas = monitor.subLayersByName("canvas")[0]
	canvas.destroy()

draw()

monitor.onClick ->
	if not rect.isAnimating
		clean()
		draw()