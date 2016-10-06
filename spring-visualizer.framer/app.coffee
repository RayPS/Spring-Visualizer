# Framer.Loop.delta = 1/240 # Slow Motion
# Setup
Framer.Device.contentScale = 1
Framer.Device.deviceType = "fullscreen"

if Utils.isDesktop()
	Framer.Device.contentScale = 0.5
	
if Utils.isFramerStudio()
	Framer.Device.deviceType = "apple-iphone-6s-space-gray"
	Framer.Device.contentScale = 1
	Framer.Device.deviceScale = 0.75
	Canvas.backgroundColor = "black"

# Cursor
document.body.style.cursor = "auto"

# Context Menu
document.body.setAttribute "oncontextmenu", "return false"

# Hints
Framer.Extras.Hints.disable()

# FramerStudio Canvas Background Color
# Screen.backgroundColor = 

isLandscape = Screen.width > Screen.height


# viewport = document.querySelector "meta[name=viewport]"
# viewportContent = "width=device-width, initial-scale=1, user-scalable=no"
# viewport.setAttribute("content", viewportContent)

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
	borderRadius: 20
	borderWidth: 6
	borderColor: "hsla(0, 0%, 100%, 0.05)"
	clip: true
	style:
		boxShadow:
			"0 4px 4px hsla(1, 100%, 100%, 0.03)," +
			"0 -4px 4px hsla(1, 100%, 100%, 0.03)," +
			"inset 0 4px 6px hsla(1, 100%, 0%, 0.2)," +
			"inset 0 0px 10px hsla(1, 100%, 0%, 0.5)"

glassMargin = 6

glass = new Layer
	parent: monitor
	backgroundColor: "transparent"
	width: monitor.width - glassMargin * 4
	height: monitor.width - glassMargin * 4
	x: Align.center
	y: Align.center
	borderRadius: monitor.borderRadius - monitor.borderWidth * 2
	style:
		boxShadow:
			"inset 0 0px 60px hsla(1, 100%, 100%, 0.1)," +
			"inset 0 3px 2px hsla(1, 100%, 100%, 0.1)," +
			"inset 0 -6px 10px hsla(1, 100%, 100%, 0.05)," +
			"inset 0 100px 60px hsla(1, 100%, 100%, 0.02)"

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
			else 0.05

	grid.addChild new Layer
		width: 1, height: grid.height
		x: gridGap * gridIndex + gridGap - monitor.borderWidth
		backgroundColor: "white"
		opacity: 0.05

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
	midX: monitor.width - monitor.borderWidth - gridGap
	y: Align.bottom(-monitorMargin+4)

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
			"0 2px 4px hsla(1, 100%, 100%, 0.1)," +
			"inset 0 2px 6px hsla(1, 100%, 0%, 0.5)"
			
			
			


# Sliders
sliderPanelPadding = 20
sliderLabelHeight = 40

sliderBoxMargin = 4
sliderBoxPadding = 40
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
		backgroundColor: "hsla(0, 0%, 100%, 0.075)"
		style:
			boxShadow:
				"inset 0 2px 2px hsla(1, 100%, 100%, 0.075)," +
				"0 2px 6px hsla(1, 100%, 0%, 0.5)"

	labelProps =
		parent: box
		html: name
		color: "hsla(0, 0%, 100%, 0.3)"
		backgroundColor: "transparent"
		y: sliderBoxPadding
		width: 120, height: sliderLabelHeight
		style:
			fontSize: sliderLabelHeight - 10 + "px"
			lineHeight: sliderLabelHeight + "px"
			textShadow: "0 2px 4px hsla(1, 100%, 0%, 0.5)"
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
		height: if Utils.isPhone() or Utils.isFramerStudio()
		then 20 else 10
		backgroundColor: "hsla(0, 0%, 0%, 0.25)"
		style:
			boxShadow:
				"0 2px 0px hsla(1, 100%, 100%, 0.05)," +
				"inset 0 4px 10px hsla(1, 100%, 0%, 0.2)"


	slider.fill.style =
		backgroundColor: "#28affa"
		boxShadow:
			"inset 0 3px 3px hsla(1, 100%, 100%, 0.3)"

	slider.knob.draggable.momentum = false
	slider.knob.height = if Utils.isPhone() or Utils.isFramerStudio()
	then 60 else 30
# 	newKnob = slider.knob.copy()
# 	slider.knob.props =
# 		height: 60
# 		backgroundColor: "transparent"
# 		style:
# 			boxShadow: "none"
# 			border: "1px solid red"
# 	slider.knob.addChild newKnob
# 	newKnob.size = 30
# 	newKnob.width = 30
# 	newKnob.center()



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
		width: monitor.width - gridGap*2
		height: monitor.height - gridGap*2
		x: Align.center
		y: Align.center
		
	brush = new Layer
		parent: canvas
		size: rect.size
		borderRadius: "50%"
		backgroundColor: "yellow"
# 		x: Align.left, y: Align.bottom
		midX: 0, midY: canvas.height
		scale: 0.75

	oval.states.animationOptions =
		curve: "spring-rk4"
		curveOptions: curveOptions
	oval.states.next()

	rect.midY = canvas.height
	rect.animate
		curve: "spring-rk4"
		curveOptions: curveOptions
		properties: midY: canvas.midY

	drawY = brush.animate
		curve: "spring-rk4"
		curveOptions: curveOptions
		properties:
			y: Align.center
			backgroundColor: "red"
			
	drawX = brush.animate
		curve: "linear"
		properties:
			midX: canvas.width

	drawX.onAnimationEnd ->
		drawY.stop()

	brush.on "change:y", ->
		if brush.x <= canvas.width
			clone = @copy()
			clone.name = "dot"
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