var BG, Render, SVG, SpringDHOAnimator, SpringRK4Animator, animateDot, animateDotHandler, backgrounds, canvas, canvasMargin, color_clearColor, color_deepBlue, color_gray, color_lightBlue, color_lightGray, dot, g, getClosestSpringType, gradients, hideDot, i, isLandscape, is_iPhone, is_iPhoneNotPlus, is_iPhonePlus, j, k, len, len1, move, newSliderGroup, page, panel, parseCurveOptions, ref, ref1, rotate, scale, showDot, sliderPages, snapPageToIndex, spring, tabBottomLine, tabIndicator, tabProps, tabStyle, tabSwitch, tab_dho, tab_rk4, tabbar, tick, triangle, visualizer;

if (Utils.isFramerStudio()) {
  is_iPhone = Framer.Device.deviceType.includes("apple-iphone");
  is_iPhonePlus = Framer.Device.deviceType.includes("plus");
  is_iPhoneNotPlus = is_iPhone && !is_iPhonePlus;
  if (is_iPhonePlus) {
    Framer.Device.content.scale = 3;
  }
  if (is_iPhoneNotPlus) {
    Framer.Device.content.scale = 2;
  }
} else {
  if (Framer.Device == null) {
    Framer.Device = new Framer.DeviceView();
  }
  document.querySelector("head>meta[name=viewport]").setAttribute("content", "width=device-width, height=device-height, initial-scale=1, maximum-scale=1, user-scalable=yes");
  Framer.Device._update();
}

if (Utils.isDesktop() && !Utils.isFramerStudio()) {
  Framer.Device.deviceType = "fullscreen";
}

isLandscape = Screen.width > Screen.height;

document.body.style.cursor = "auto";

document.body.style.fontFamily = "Avenir";

document.body.setAttribute("oncontextmenu", "return false");

Framer.Extras.Hints.disable();

Canvas.backgroundColor = "white";

gradients = ["linear-gradient(0deg,    #7C67D5 0%, #0599FF 100%)", "linear-gradient(0deg,    #00BFD0 0%, #00D29A 100%)", "linear-gradient(-225deg, #3A7BD5 0%, #00D2FF 100%)", "linear-gradient(-180deg, #FF0353 0%, #FFC38B 100%)"];

color_clearColor = "transparent";

color_lightBlue = "#54C7FC";

color_lightGray = "#ECF0F1";

color_gray = "#BDC3C7";

color_deepBlue = "#34495E";

String.prototype.toCapitalize = function() {
  return this.charAt(0).toUpperCase() + this.slice(1);
};

Layer.prototype.makeTriangle = function(direction) {
  this.borderColor = "transparent";
  this.borderWidth = this.width / 2;
  this.style["border-" + direction + "-color"] = this.backgroundColor.toHexString();
  return this.backgroundColor = "transparent";
};

SpringRK4Animator = new Framer.SpringRK4Animator;

SpringDHOAnimator = new Framer.SpringDHOAnimator;

spring = {
  rk4: {
    value: {
      tension: 250,
      friction: 25,
      velocity: 0
    },
    range: {
      tension: [0, 1000],
      friction: [1, 100],
      velocity: [0, 100]
    }
  },
  dho: {
    value: {
      stiffness: 200,
      damping: 10,
      mass: 1,
      velocity: 0
    },
    range: {
      stiffness: [0, 1000],
      damping: [1, 100],
      mass: [1, 20],
      velocity: [0, 100]
    }
  }
};

console.log(spring);

Render = function(springType) {
  var animatorClass, i, index, l, value, values, x, y;
  animatorClass = (function() {
    switch (springType) {
      case "rk4":
        return SpringRK4Animator;
      case "dho":
        return SpringDHOAnimator;
    }
  })();
  animatorClass.setup(_.merge(_.clone(spring[springType].value), {
    tolerance: 1 / 10000
  }));
  values = animatorClass.values(1 / 60, 1000);
  spring[springType].svgPoints = [];
  for (index in values) {
    value = values[index];
    l = values.length;
    i = index;
    x = parseInt(i) * (canvas.width / l);
    y = value * (canvas.height / 2);
    spring[springType].svgPoints.push([x, canvas.height - y]);
  }
  return canvas.html = SVG(spring[springType].svgPoints);
};

SVG = function(p) {
  var polyline, svg;
  svg = document.createElement("svg");
  svg.setAttribute("id", "svg");
  svg.setAttribute("width", canvas.width + "px");
  svg.setAttribute("height", canvas.height + "px");
  svg.setAttribute("overflow", "visible");
  polyline = document.createElement("polyline");
  polyline.setAttribute("id", "polyline");
  polyline.setAttribute("fill", "none");
  polyline.setAttribute("stroke", "white");
  polyline.setAttribute("stroke-width", 4);
  polyline.setAttribute("stroke-linecap", "round");
  polyline.setAttribute("stroke-linejoin", "round");
  polyline.setAttribute("vector-effect", "non-scaling-stroke");
  polyline.setAttribute("points", p);
  svg.appendChild(polyline);
  return svg.outerHTML;
};

newSliderGroup = function(springType) {
  var index, j, key, keyLabel, labelProps, len, ref, ref1, set, slider, sliderGroup, sliderSet, value, valueLabel;
  sliderGroup = new ScrollComponent({
    scrollHorizontal: false,
    directionLock: true,
    size: sliderPages.size,
    backgroundColor: color_clearColor,
    contentInset: {
      bottom: springType === "dho" ? 30 : void 0
    }
  });
  sliderGroup.content.clip = false;
  ref = spring[springType].value;
  for (key in ref) {
    value = ref[key];
    sliderSet = new Layer({
      name: "sliderSet - " + key,
      parent: sliderGroup.content,
      width: 300,
      height: 60,
      midX: sliderGroup.content.width / 2,
      backgroundColor: color_clearColor
    });
    sliderSet.draggable.enabled = false;
    sliderSet.draggable.propagateEvents = false;
    labelProps = {
      parent: sliderSet,
      height: 20,
      width: sliderSet.width / 2 - 1,
      style: {
        lineHeight: "20px",
        fontSize: "16px",
        fontWeight: "250",
        color: color_gray
      },
      backgroundColor: color_clearColor
    };
    keyLabel = new Layer({
      name: "keyLabel",
      html: key.toCapitalize()
    });
    keyLabel.props = labelProps;
    valueLabel = new Layer({
      name: "valueLabel",
      html: 0,
      x: sliderSet.width / 2,
      style: {
        textAlign: "right"
      }
    });
    valueLabel.props = labelProps;
    slider = new SliderComponent({
      custom: {
        keyForSpringOptions: key
      },
      name: "slider - " + key,
      parent: sliderSet,
      midY: labelProps.height + 20,
      width: sliderSet.width,
      height: 10,
      backgroundColor: color_lightGray,
      min: spring[springType].range[key][0],
      max: spring[springType].range[key][1]
    });
    slider.fill.backgroundColor = color_lightBlue;
    slider.knob.props = {
      width: 10,
      height: 20,
      borderRadius: 10,
      scale: 2,
      style: {
        boxShadow: "0px 2px 4px rgba(0,0,0,0.10), 0px 6px 10px rgba(0,0,0,0.05)"
      }
    };
    slider.knob.draggable.propagateEvents = false;
    valueLabel.html = slider.value = value;
    slider.on("change:value", function() {
      var currentKeyName, roundedValue;
      currentKeyName = this.custom.keyForSpringOptions;
      valueLabel = this.parent.subLayersByName("valueLabel")[0];
      roundedValue = Math.round(this.value);
      valueLabel.html = roundedValue;
      spring[springType].value[currentKeyName] = roundedValue;
      return Render(springType);
    });
    slider.knob.onMove(function() {
      if (!this.isAnimating && !this.draggable.isDragging) {
        return requestAnimationFrame(animateDot);
      }
    });
    slider.knob.onClick(function() {
      return this.emit(Events.Move);
    });
  }
  ref1 = sliderGroup.content.subLayers;
  for (index = j = 0, len = ref1.length; j < len; index = ++j) {
    set = ref1[index];
    set.y = 30 + (index * set.height) + (index * 30);
  }
  sliderGroup.updateContent();
  sliderPages.addPage(sliderGroup);
  if (springType === "rk4") {
    return Render(springType);
  }
};

tabSwitch = function(tabIndex) {
  switch (tabIndex) {
    case 0:
      tab_rk4.states["switch"]("active");
      return tab_dho.states["switch"]("default");
    case 1:
      tab_rk4.states["switch"]("default");
      return tab_dho.states["switch"]("active");
  }
};

snapPageToIndex = function(tabIndex) {
  return sliderPages.snapToPage(sliderPages.content.subLayers[tabIndex]);
};

getClosestSpringType = function() {
  var ref, ref1;
  return (ref = Object.keys(spring)[(typeof sliderPages !== "undefined" && sliderPages !== null ? (ref1 = sliderPages.closestPage) != null ? ref1.index : void 0 : void 0) - 1]) != null ? ref : "rk4";
};

parseCurveOptions = function() {
  var curveOptions, springType;
  springType = getClosestSpringType();
  curveOptions = _.join(_.values(spring[springType].value));
  return "spring-" + springType + "(" + curveOptions + ")";
};

BG = new Layer({
  width: Screen.width / Framer.Device.content.scale,
  height: Screen.height / Framer.Device.content.scale,
  backgroundColor: "white"
});

visualizer = new PageComponent({
  parent: BG,
  width: BG.width,
  height: BG.height * 0.47,
  scrollVertical: false,
  style: {
    backgroundImage: gradients[0]
  }
});

visualizer.animationOptions = {
  curve: "spring"
};

backgrounds = new Layer({
  parent: visualizer,
  frame: visualizer.frame,
  backgroundColor: color_clearColor
});

backgrounds.placeBehind(visualizer.content);

for (i = j = 0, len = gradients.length; j < len; i = ++j) {
  g = gradients[i];
  new Layer({
    name: "gradient_" + i,
    parent: backgrounds,
    frame: backgrounds,
    style: {
      backgroundImage: g
    },
    opacity: i === 0 ? 1 : 0
  });
  visualizer.addPage(new Layer({
    name: "page_" + (i + 1),
    width: visualizer.width,
    height: visualizer.height,
    backgroundColor: color_clearColor
  }));
}

visualizer.onMove(function() {
  var b, k, len1, ref, results;
  ref = backgrounds.subLayers;
  results = [];
  for (i = k = 0, len1 = ref.length; k < len1; i = ++k) {
    b = ref[i];
    results.push(b.opacity = Utils.modulate(visualizer.scrollX, [visualizer.width * (i - 1), visualizer.width * i], [0, 1], true));
  }
  return results;
});

canvasMargin = 20;

canvas = new Layer({
  parent: visualizer.content.subLayers[0],
  x: Align.center(),
  y: Align.center(),
  width: visualizer.width - canvasMargin * 2,
  height: visualizer.height - canvasMargin * 2,
  backgroundColor: color_clearColor,
  clip: false,
  style: {
    filter: "drop-shadow(0 20px 10px rgba(0,0,0,0.1))"
  }
});

triangle = new Layer({
  parent: canvas,
  size: 20,
  opacity: 0.3,
  backgroundColor: "white",
  x: Align.right(canvasMargin),
  midY: canvas.height / 2
});

triangle.makeTriangle("right");

dot = new Layer({
  parent: canvas,
  size: 20,
  backgroundColor: "white",
  borderRadius: "50%",
  opacity: 0.3,
  midX: canvas.width,
  midY: canvas.height / 2,
  scale: 1
});

hideDot = new Animation({
  layer: dot,
  time: 0.25,
  properties: {
    scale: 0
  }
});

showDot = hideDot.invert();

tick = 0;

animateDotHandler = function() {
  var ref, svgPoints;
  svgPoints = spring[getClosestSpringType()].svgPoints;
  if (tick < svgPoints.length) {
    ref = svgPoints[tick], dot.midX = ref[0], dot.midY = ref[1];
    requestAnimationFrame(animateDotHandler);
    return tick += 1;
  }
};

hideDot.onAnimationEnd(function() {
  dot.midX = 0;
  dot.midY = canvas.height;
  showDot.start();
  return triangle.midY = canvas.height;
});

showDot.onAnimationEnd(function() {
  tick = 0;
  requestAnimationFrame(animateDotHandler);
  return triangle.animate({
    properties: {
      midY: canvas.height / 2
    },
    curve: parseCurveOptions()
  });
});

animateDot = function() {
  return hideDot.start();
};

canvas.onTap(function() {
  return hideDot.start();
});

scale = new Layer({
  parent: visualizer.content.subLayers[1],
  size: 200,
  scale: 0.5,
  point: Align.center,
  backgroundColor: "white",
  borderRadius: "50%"
});

scale.states.add({
  A: {
    scale: 1
  }
});

rotate = new Layer({
  parent: visualizer.content.subLayers[2],
  size: 100,
  point: Align.center,
  backgroundColor: "white",
  borderRadius: 5
});

rotate.states.add({
  A: {
    rotation: 90
  }
});

move = new Layer({
  parent: visualizer.content.subLayers[3],
  size: 100,
  y: Align.center,
  x: Align.center(-100),
  backgroundColor: "white",
  borderRadius: 5
});

move.states.add({
  A: {
    x: Align.center(100)
  }
});

ref = visualizer.content.children;
for (k = 0, len1 = ref.length; k < len1; k++) {
  page = ref[k];
  if ((1 < (ref1 = page.index) && ref1 < 6)) {
    page.onTap(function() {
      this.children[0].animationOptions = {
        curve: parseCurveOptions()
      };
      return this.children[0].states.next();
    });
  }
}

panel = new Layer({
  parent: BG,
  y: visualizer.maxY,
  html: "panel",
  backgroundColor: "white",
  width: BG.width,
  height: BG.height - visualizer.height
});

tabbar = new Layer({
  parent: panel,
  width: panel.width,
  height: 60,
  backgroundColor: color_clearColor
});

tabStyle = {
  fontFamily: "Avenir",
  fontWeight: "900",
  fontSize: "18px",
  color: color_deepBlue,
  textAlign: "center",
  lineHeight: tabbar.height + "px",
  cursor: "pointer"
};

tabProps = {
  parent: tabbar,
  width: 140,
  height: tabbar.height,
  backgroundColor: "white",
  opacity: 0.35,
  style: tabStyle
};

tab_rk4 = new Layer;

tab_rk4.html = "SPRING-RK4";

tab_rk4.props = tabProps;

tab_rk4.maxX = tabbar.midX - 10;

tab_dho = new Layer;

tab_dho.html = "SPRING-DHO";

tab_dho.props = tabProps;

tab_dho.x = tabbar.midX + 10;

tab_rk4.states.add({
  active: {
    opacity: 1
  }
});

tab_dho.states.add({
  active: {
    opacity: 1
  }
});

tab_rk4.states.animationOptions = {
  time: 0.1
};

tab_dho.states.animationOptions = {
  time: 0.1
};

tabBottomLine = new Layer({
  parent: tabbar,
  maxY: tabbar.height,
  width: tabbar.width,
  height: 1,
  backgroundColor: color_lightGray
});

tabIndicator = new Layer({
  parent: tabbar,
  maxY: tabbar.height,
  midX: tab_rk4.midX,
  width: 140,
  height: 2,
  backgroundColor: color_lightBlue
});

tab_rk4.states["switch"]("active");

tab_rk4.onClick(function() {
  return snapPageToIndex(0);
});

tab_dho.onClick(function() {
  return snapPageToIndex(1);
});

sliderPages = new PageComponent({
  parent: panel,
  x: Align.center,
  y: tabbar.maxY,
  width: panel.width,
  height: panel.height - tabbar.height,
  backgroundColor: color_clearColor,
  scrollVertical: false,
  directionLock: true
});

sliderPages.animationOptions = {
  curve: "spring"
};

sliderPages.onMove(function() {
  var pageProcess;
  pageProcess = Utils.modulate(sliderPages.scrollX, [0, sliderPages.width], [0, 1]);
  tabIndicator.x = Utils.modulate(pageProcess, [0, 1], [tab_rk4.x, tab_dho.x]);
  canvas.opacity = Utils.modulate(pageProcess > 0.5 ? 1 - pageProcess : pageProcess, [0, 0.5], [1, 0]);
  tabSwitch(sliderPages.closestPage.index - 1);
  return Render(getClosestSpringType());
});

sliderPages.content.onAnimationStart(function() {
  var knob, knobs, len2, m, results;
  knobs = sliderPages.descendants.filter(function(c) {
    return c.name === "knob";
  });
  results = [];
  for (m = 0, len2 = knobs.length; m < len2; m++) {
    knob = knobs[m];
    results.push(knob.animateStop());
  }
  return results;
});

newSliderGroup("rk4");

newSliderGroup("dho");
