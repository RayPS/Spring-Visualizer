# Setup
if Utils.isFramerStudio()
	is_iPhone = Framer.Device.deviceType.includes "apple-iphone"
	is_iPhonePlus = Framer.Device.deviceType.includes "plus"
	is_iPhoneNotPlus = is_iPhone and not is_iPhonePlus
	
	if is_iPhonePlus then Framer.Device.content.scale = 3
	if is_iPhoneNotPlus then Framer.Device.content.scale = 2

else
	Framer.Device ?= new Framer.DeviceView()
	
	document.querySelector("head>meta[name=viewport]").setAttribute "content",
	"width=device-width, height=device-height, initial-scale=1, maximum-scale=1, user-scalable=yes"

	Framer.Device._update()

if Utils.isDesktop() and not Utils.isFramerStudio()
	Framer.Device.deviceType = "fullscreen"




isLandscape = Screen.width > Screen.height


# Cursor
document.body.style.cursor = "auto"
# Font
document.body.style.fontFamily = "Avenir"
# Context Menu
document.body.setAttribute "oncontextmenu", "return false"
# Hints
Framer.Extras.Hints.disable()
# Canvas Background
Canvas.backgroundColor = "white"



# Gradients
gradients = [
	"linear-gradient(0deg,    #7C67D5 0%, #0599FF 100%)",
	"linear-gradient(0deg,    #00BFD0 0%, #00D29A 100%)",
	"linear-gradient(-225deg, #3A7BD5 0%, #00D2FF 100%)",
	"linear-gradient(-180deg, #FF0353 0%, #FFC38B 100%)"
	]



# Colors
# Auto Completion: "color_"
color_clearColor = "transparent"
color_lightBlue = "#54C7FC"
color_lightGray = "#ECF0F1"
color_gray = "#BDC3C7"
color_deepBlue = "#34495E"

# Capitalize
String::toCapitalize = ->
	return this.charAt(0).toUpperCase() + this.slice(1)

# CSS Triangle
Layer::makeTriangle = (direction)->
	this.borderColor = "transparent"
	this.borderWidth = this.width / 2
	this.style["border-#{direction}-color"] = this.backgroundColor.toHexString()
	this.backgroundColor = "transparent"

SpringRK4Animator = new Framer.SpringRK4Animator
SpringDHOAnimator = new Framer.SpringDHOAnimator

# spring = ▸{rk4: Object, dho: Object}
spring =
	rk4:
		value:
			tension: 250
			friction: 25
			velocity: 0
		range:
			tension: [0, 1000]
			friction: [1, 100]
			velocity: [0, 100]
	dho:
		value:
			stiffness: 200
			damping: 10
			mass: 1
			velocity: 0
		range:
			stiffness: [0, 1000]
			damping: [1, 100]
			mass: [1, 20]
			velocity: [0, 100]
console.log spring

# Functional
# Render(springType) Generate SVG to canvas

Render = (springType) ->

	animatorClass = switch springType
		when "rk4" then SpringRK4Animator
		when "dho" then SpringDHOAnimator

	animatorClass.setup _.merge (_.clone spring[springType].value), {tolerance: 1/10000}
	values = animatorClass.values(1/60, 1000)

	spring[springType].svgPoints = []

	for index, value of values
		l = values.length
		i = index
		x = parseInt(i) * (canvas.width / (l))
		y = value * (canvas.height / 2)
		
		spring[springType].svgPoints.push [x, canvas.height - y]

	canvas.html = SVG spring[springType].svgPoints

# SVG(p) return SVG code by given points.
SVG = (p) ->
	svg = document.createElement "svg"
	svg.setAttribute("id", "svg")
	svg.setAttribute("width", canvas.width + "px")
	svg.setAttribute("height", canvas.height + "px")
	svg.setAttribute("overflow", "visible")

	polyline = document.createElement "polyline"
	polyline.setAttribute("id", "polyline")
	polyline.setAttribute("fill", "none")
	polyline.setAttribute("stroke", "white")
	polyline.setAttribute("stroke-width", 4)
	polyline.setAttribute("stroke-linecap", "round")
	polyline.setAttribute("stroke-linejoin", "round")
	polyline.setAttribute("vector-effect", "non-scaling-stroke")
	polyline.setAttribute("points", p)

	svg.appendChild polyline

	return svg.outerHTML
# newSliderGroup(springType) Create slider group by givin spring type
newSliderGroup = (springType) ->

	sliderGroup = new ScrollComponent
		scrollHorizontal: false
		directionLock: true
		size: sliderPages.size
		backgroundColor: color_clearColor
		contentInset: bottom: if springType is "dho" then 30
	sliderGroup.content.clip = false

	for key, value of spring[springType].value

		sliderSet = new Layer
			name: "sliderSet - #{key}"
			parent: sliderGroup.content
			width: 300
			height: 60
			midX: sliderGroup.content.width / 2
			backgroundColor: color_clearColor
# 				backgroundColor: Utils.randomColor() # Debug
		
		
		sliderSet.draggable.enabled = false
		sliderSet.draggable.propagateEvents = false




		# Create Labels
		labelProps =
			parent: sliderSet
			height: 20
			width: sliderSet.width / 2 - 1
			style:
				lineHeight: "20px"
				fontSize: "16px"
				fontWeight: "250"
				color: color_gray
			backgroundColor: color_clearColor

		keyLabel = new Layer
			name: "keyLabel"
			html: key.toCapitalize()
		keyLabel.props = labelProps

		valueLabel = new Layer
			name: "valueLabel"
			html: 0
			x: sliderSet.width / 2
			style: textAlign: "right"
		valueLabel.props = labelProps





		# Create Sliders
		slider = new SliderComponent
			custom: keyForSpringOptions: key
			name: "slider - #{key}"
			parent:  sliderSet
			midY: labelProps.height + 20
			width: sliderSet.width
			height: 10
			backgroundColor: color_lightGray
			min: spring[springType].range[key][0]
			max: spring[springType].range[key][1]

		slider.fill.backgroundColor = color_lightBlue
		
		slider.knob.props =
			width: 10
			height: 20
			borderRadius: 10
			scale: 2
			style:
				boxShadow: "0px 2px 4px rgba(0,0,0,0.10), 0px 6px 10px rgba(0,0,0,0.05)"

		slider.knob.draggable.propagateEvents = false
# 			slider.knob.draggable.momentum = false

		# Reset Default
		valueLabel.html = slider.value = value
		
		# Reset Default (Animated)
# 			switch springType
# 				when "rk4" then slider.animateToValue value, time: 1.5
# 				when "dho" then valueLabel.html = slider.value = value




		# Events
		slider.on "change:value", ->
			currentKeyName = @custom.keyForSpringOptions
			valueLabel = @parent.subLayersByName("valueLabel")[0]
			roundedValue = Math.round @value
			valueLabel.html = roundedValue
			
			spring[springType].value[currentKeyName] = roundedValue

			Render springType
		
		slider.knob.onMove ->
			if not this.isAnimating and not this.draggable.isDragging
				requestAnimationFrame animateDot

		slider.knob.onClick -> this.emit Events.Move

		# End of for loop
		# ------------------------------------------------------

	# Stack Slider Sets
	for set, index in sliderGroup.content.subLayers
		set.y = 30 + (index * set.height) + (index * 30)

	sliderGroup.updateContent()
	sliderPages.addPage sliderGroup

	if springType is "rk4" then Render springType
# tabSwitch(tabIndex) Switch tab by given index
tabSwitch = (tabIndex) ->
	switch tabIndex
		when 0
			tab_rk4.states.switch "active"
			tab_dho.states.switch "default"
		when 1
			tab_rk4.states.switch "default"
			tab_dho.states.switch "active"

snapPageToIndex = (tabIndex) ->
	sliderPages.snapToPage sliderPages.content.subLayers[tabIndex]

getClosestSpringType = ->
	return Object.keys(spring)[sliderPages?.closestPage?.index - 1] ? "rk4"
parseCurveOptions = ->
	springType = getClosestSpringType()
	curveOptions = _.join _.values spring[springType].value
	return "spring-#{springType}(#{curveOptions})"

# Interface
# BG
BG = new Layer
	width: Screen.width / Framer.Device.content.scale
	height: Screen.height / Framer.Device.content.scale
	backgroundColor: "white"

# Visualizer
visualizer = new PageComponent
	parent: BG
	width: BG.width
	height: BG.height * 0.47
	scrollVertical: false
	style: backgroundImage: gradients[0]

visualizer.animationOptions =
	curve: "spring"
# Visualizer Backgrounds
backgrounds = new Layer
	parent: visualizer
	frame: visualizer.frame
	backgroundColor: color_clearColor
backgrounds.placeBehind visualizer.content


for g,i in gradients
	new Layer
		name: "gradient_#{i}"
		parent: backgrounds
		frame: backgrounds
		style: backgroundImage: g
		opacity: if i is 0 then 1 else 0

	visualizer.addPage new Layer
		name: "page_#{i+1}"
		width: visualizer.width
		height: visualizer.height
		backgroundColor: color_clearColor


visualizer.onMove ->
	for b,i in backgrounds.subLayers
		b.opacity = Utils.modulate visualizer.scrollX,
			[visualizer.width * (i - 1), visualizer.width * i],
			[0, 1],
			true
# Canvas
canvasMargin = 20

canvas = new Layer
	parent: visualizer.content.subLayers[0]
	x: Align.center()
	y: Align.center()
	width: visualizer.width - canvasMargin * 2
	height: visualizer.height - canvasMargin * 2
	backgroundColor: color_clearColor
	clip: false
	style: filter: "drop-shadow(0 20px 10px rgba(0,0,0,0.1))"

triangle = new Layer
	parent: canvas
	size: 20
	opacity: 0.3
	backgroundColor: "white"
	x: Align.right canvasMargin
	midY: canvas.height / 2

triangle.makeTriangle "right"

dot = new Layer
	parent: canvas
	size: 20
	backgroundColor: "white"
	borderRadius: "50%"
	opacity: 0.3
	midX: canvas.width
	midY: canvas.height / 2
	scale: 1

hideDot = new Animation
	layer: dot
	time: 0.25
	properties:
		scale: 0

showDot = hideDot.invert()


tick = 0

animateDotHandler = ->
	svgPoints = spring[getClosestSpringType()].svgPoints
	if tick < svgPoints.length
		[dot.midX, dot.midY] = svgPoints[tick]
# 		triangle.midY        = svgPoints[tick][1]
		requestAnimationFrame animateDotHandler
		tick += 1

hideDot.onAnimationEnd ->
	dot.midX = 0
	dot.midY = canvas.height
	showDot.start()
	triangle.midY = canvas.height
showDot.onAnimationEnd ->
	tick = 0
	requestAnimationFrame animateDotHandler
	
	triangle.animate
		properties: midY: canvas.height / 2
		curve: parseCurveOptions()

animateDot = -> hideDot.start()

canvas.onTap -> hideDot.start()
#Shapes
scale = new Layer
	parent: visualizer.content.subLayers[1]
	size: 200
	scale: 0.5
	point: Align.center
	backgroundColor: "white"
	borderRadius: "50%"

scale.states.add A: scale: 1

rotate = new Layer
	parent: visualizer.content.subLayers[2]
	size: 100
	point: Align.center
	backgroundColor: "white"
	borderRadius: 5

rotate.states.add A: rotation: 90

move = new Layer
	parent: visualizer.content.subLayers[3]
	size: 100
	y: Align.center
	x: Align.center -100
	backgroundColor: "white"
	borderRadius: 5

move.states.add A: x: Align.center 100



for page in visualizer.content.children
	if 1 < page.index < 6 then page.onTap ->
		this.children[0].animationOptions = curve: parseCurveOptions()
# 		this.children[0].animateStop()
		this.children[0].states.next()
# Slider Panel
panel = new Layer
	parent: BG
	y: visualizer.maxY
	html: "panel"
	backgroundColor: "white"
	width: BG.width
	height: BG.height - visualizer.height
# Tab Bar
tabbar = new Layer
	parent: panel
	width: panel.width
	height: 60
	backgroundColor: color_clearColor

tabStyle =
	fontFamily: "Avenir"
	fontWeight: "900"
	fontSize: "18px"
	color: color_deepBlue
	textAlign: "center"
	lineHeight: tabbar.height + "px"
	cursor: "pointer"

tabProps =
	parent: tabbar
	width: 140
	height: tabbar.height
	backgroundColor: "white"
	opacity: 0.35
	style: tabStyle

tab_rk4 = new Layer
tab_rk4.html = "SPRING-RK4"
tab_rk4.props = tabProps
tab_rk4.maxX = tabbar.midX - 10

tab_dho = new Layer
tab_dho.html = "SPRING-DHO"
tab_dho.props = tabProps
tab_dho.x = tabbar.midX + 10

tab_rk4.states.add active: opacity: 1
tab_dho.states.add active: opacity: 1
tab_rk4.states.animationOptions = time: 0.1
tab_dho.states.animationOptions = time: 0.1

tabBottomLine = new Layer
	parent: tabbar
	maxY: tabbar.height
	width: tabbar.width
	height: 1
	backgroundColor: color_lightGray

tabIndicator = new Layer
	parent: tabbar
	maxY: tabbar.height
	midX: tab_rk4.midX
	width: 140
	height: 2
	backgroundColor: color_lightBlue



tab_rk4.states.switch "active"

tab_rk4.onClick -> snapPageToIndex 0
tab_dho.onClick -> snapPageToIndex 1
# Slider Pages
sliderPages = new PageComponent
	parent: panel
	x: Align.center
	y: tabbar.maxY
	width: panel.width
	height: panel.height - tabbar.height
	backgroundColor: color_clearColor
	scrollVertical: false
	directionLock: true

sliderPages.animationOptions =
	curve: "spring"





sliderPages.onMove ->
	pageProcess = Utils.modulate sliderPages.scrollX,
		[0, sliderPages.width],
		[0, 1]
		
	tabIndicator.x = Utils.modulate pageProcess,
		[0, 1],
		[tab_rk4.x, tab_dho.x]

	canvas.opacity = Utils.modulate(
		if pageProcess > 0.5 then 1 - pageProcess else pageProcess,
		[0, 0.5],
		[1, 0]
	)


	tabSwitch sliderPages.closestPage.index - 1

	Render getClosestSpringType()


sliderPages.content.onAnimationStart ->
	knobs = sliderPages.descendants.filter (c)-> c.name is "knob"
	knob.animateStop() for knob in knobs

newSliderGroup("rk4")
newSliderGroup("dho")
# EOF