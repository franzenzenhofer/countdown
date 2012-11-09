b2Vec2 = Box2D.Common.Math.b2Vec2
b2AABB = Box2D.Collision.b2AABB
b2BodyDef = Box2D.Dynamics.b2BodyDef
b2Body = Box2D.Dynamics.b2Body
b2FixtureDef = Box2D.Dynamics.b2FixtureDef
b2Fixture = Box2D.Dynamics.b2Fixture
b2World = Box2D.Dynamics.b2World
b2MassData = Box2D.Collision.Shapes.b2MassData
b2PolygonShape = Box2D.Collision.Shapes.b2PolygonShape
b2CircleShape = Box2D.Collision.Shapes.b2CircleShape
b2DebugDraw = Box2D.Dynamics.b2DebugDraw
b2RevoluteJointDef = Box2D.Dynamics.Joints.b2RevoluteJointDef
b2MouseJointDef =  Box2D.Dynamics.Joints.b2MouseJointDef
$ = jQuery

#HW accelorate map
#hw={
#    'position': 'absolute',
#    'left': 0,
#    'top': 0,
#    '-webkit-transform': 'translate3d(0,0,1px)',
#    '-o-transform': 'translate3d(0,0,1px)',
#    '-moz-transform': 'translate3d(0,0,1px)',
#    '-ms-transform': 'translate3d(0,0,1px)',
#    'transform': 'translate3d(0,0,1px)',
#    '-webkit-perspective': 1000, 
#    '-webkit-backface-visibility': 'hidden',
#    '-webkit-transition-property': '-webkit-transform',
#    '-webkit-transition-duration': 0.1,
#    '-o-transition-property': '-o-transform',
#    '-o-transition-duration': 0.1,
#    '-moz-transition-property': '-moz-transform',
#    '-moz-transition-duration': 0.1,
#    'transition-property': '-transform',
#    'transition-duration': 0.1
#  }
hw = {
  '-webkit-transform': 'translateZ(0)'
  '-moz-transform': 'translateZ(0)'
  '-o-transform': 'translateZ(0)'
  'transform': 'translateZ(0)'  
}

S_T_A_R_T_E_D = false
world = {}
x_velocity = 0
y_velocity = 0
SCALE = 30
D2R = Math.PI / 180
R2D = 180 / Math.PI
PI2 = Math.PI*2
interval = {}

mouseX = undefined
mouseY = undefined
mousePVec = undefined
isMouseDown = undefined
selectedBody = undefined
mouseJoint = undefined

#helper
downHandler = (x, y) ->
  isMouseDown = true
  moveHandler x, y
upHandler = (x, y) ->
  isMouseDown = false
  mouseX = `undefined`
  mouseY = `undefined`
moveHandler = (x, y) ->
  #console.log(canvasPosition.x)
  #console.log(canvasPosition.y)
  #mouseX = (x - canvasPosition.x) / 30
  #mouseY = (y - canvasPosition.y) / 30
  mouseX = x / 30
  mouseY = y / 30
getBodyAtMouse = ->
  mousePVec = new b2Vec2(mouseX, mouseY)
  aabb = new b2AABB()
  aabb.lowerBound.Set mouseX - 0.001, mouseY - 0.001
  aabb.upperBound.Set mouseX + 0.001, mouseY + 0.001
  
  # Query the world for overlapping shapes.
  selectedBody = null
  world.QueryAABB getBodyCB, aabb
  selectedBody
getBodyCB = (fixture) ->
  unless fixture.GetBody().GetType() is b2Body.b2_staticBody
    if fixture.GetShape().TestPoint(fixture.GetBody().GetTransform(), mousePVec)
      selectedBody = fixture.GetBody()
      return false
  true
getElementPosition = (element) ->
  elem = element
  tagname = ""
  x = 0
  y = 0
  while (typeof (elem) is "object") and (typeof (elem.tagName) isnt "undefined")
    y += elem.offsetTop
    x += elem.offsetLeft
    tagname = elem.tagName.toUpperCase()
    elem = 0  if tagname is "BODY"
    elem = elem.offsetParent  if typeof (elem.offsetParent) is "object"  if typeof (elem) is "object"
  x: x
  y: y
updateMouseDrag = ->
  if isMouseDown and (not mouseJoint)
    body = getBodyAtMouse()
    if body
      md = new b2MouseJointDef()
      md.bodyA = world.GetGroundBody()
      md.bodyB = body
      md.target.Set mouseX, mouseY
      md.collideConnected = true
      md.maxForce = 300.0 * body.GetMass()
      mouseJoint = world.CreateJoint(md)
      body.SetAwake true
  if mouseJoint
    if isMouseDown
      mouseJoint.SetTarget new b2Vec2(mouseX, mouseY)
    else
      world.DestroyJoint mouseJoint
      mouseJoint = null



	
createDOMObjects = (jquery_selector) ->
  #iterate all div elements and create them in the Box2D system
  #$("#container div").each (a, b) ->
  $(jquery_selector).each (a, b) -> 
    console.log(a)
    console.log(b)
    domObj = $(b)
    domPos = $(b).position()
    width = domObj.width() / 2
    height = domObj.height() / 2
    x = (domPos.left)  + width
    y = (domPos.top) + height
    body = createBox(x, y, width, height)
    body.m_userData = {
      domObj: domObj
      width: width
      height: height
      }

    #Reset DOM object position for use with CSS3 positioning
    #domObj.absolutize()#.css({left: "0px",top: "0px"})
    domObj.css({left: "0px",top: "0px"})

    return true

createBox = (x, y, width, height, static_) ->
  bodyDef = new b2BodyDef
  bodyDef.type = (if static_ then b2Body.b2_staticBody else b2Body.b2_dynamicBody)
  bodyDef.position.x = x / SCALE
  bodyDef.position.y = y / SCALE
  fixDef = new b2FixtureDef
  fixDef.density = 1.5
  fixDef.friction = 0.3
  fixDef.restitution = 0.4
  fixDef.shape = new b2PolygonShape
  fixDef.shape.SetAsBox width / SCALE, height / SCALE
  return world.CreateBody(bodyDef).CreateFixture fixDef

drawDOMObjects = ->
  i = 0
  b = world.m_bodyList

  while b
    f = b.m_fixtureList

    while f
      if f.m_userData
        
        #Retrieve positions and rotations from the Box2d world
        x = Math.floor((f.m_body.m_xf.position.x * SCALE) - f.m_userData.width)
        y = Math.floor((f.m_body.m_xf.position.y * SCALE) - f.m_userData.height)
        
        #CSS3 transform does not like negative values or infitate decimals
        r = Math.round(((f.m_body.m_sweep.a + PI2) % PI2) * R2D * 100) / 100
        css =
          "-webkit-transform": "translate(" + x + "px," + y + "px) rotate(" + r + "deg)"
          "-moz-transform": "translate(" + x + "px," + y + "px) rotate(" + r + "deg)"
          "-ms-transform": "translate(" + x + "px," + y + "px) rotate(" + r + "deg)"
          "-o-transform": "translate(" + x + "px," + y + "px) rotate(" + r + "deg)"
          transform: "translate(" + x + "px," + y + "px) rotate(" + r + "deg)"

        f.m_userData.domObj.css css
      f = f.m_next
    b = b.m_next

update = ->

  updateMouseDrag()
  #frame-rate
  #velocity iterations
  world.Step 1 / 60, 10, 10 #position iterations
  drawDOMObjects()
  world.ClearForces()
  #update()
  requestAnimationFrame(update);


init = (jquery_selector) ->
  S_T_A_R_T_E_D = true
  world = new b2World(
    new b2Vec2(x_velocity,y_velocity),
    true
    )
  createDOMObjects($(jquery_selector).bodysnatch())
  w = $(window).width(); 
  h = $(window).height();
  #top border box
  createBox(0, -1 , $(window).width(), 1, true);
  #right hand side box
  createBox($(window).width()+1, 0 , 1, $(window.document).height(), true);
  #left hand side border
  createBox(-1, 0 , 1, $(window.document).height(), true);
  console.log($(window.document).height())
  console.log($(window).height())
  #bottom box
  createBox(0, $(window.document).height()+1, $(window).width(), 1, true);
  mouse = MouseAndTouch(document, downHandler, upHandler, moveHandler)

  #trigger hardware acclearation
  #$('body').css(hw);
  
  update();
  
#init("#container div, img")
#init("h1")
#canvasPosition = getElementPosition(document.getElementById("canvas"))

$.fn.extend
  physics: (options) ->
    self = $.fn.physics
    opts = $.extend {}, self.default_options, options
    x_velocity = opts['x-velocity']
    y_velocity = opts['y-veloctiy']
    if S_T_A_R_T_E_D is false
      console.log('lets start')
      init(@selector)
    else
      console.log('already started')
      
      createDOMObjects($(@selector).bodysnatch())

    $(this).each (i, el) ->
      self.init el, opts
      self.log el if opts.log

$.extend $.fn.physics,
  default_options:
    'x-velocity': 0
    'y-velocity': 0
    log: true
  
  init: (el, opts) ->
    #this.color el, opts
  
  #color: (el, opts) ->
  #  $(el).css('color', opts.color)
  
  log: (msg) ->
    console.log msg

 
###
	fixDef = new b2FixtureDef()
	fixDef.density = 1.0
	fixDef.friction = 0.5
	fixDef.restitution = 0.2

	bodyDef = new b2BodyDef()
	bodyDef.type = b2Body.b2_staticBody
	fixDef.shape = new b2PolygonShape()
	fixDef.shape.SetAsBox(20, 2) 
	bodyDef.position.Set(10, 400 / 30 + 1.8)
	world.CreateBody(bodyDef).CreateFixture(fixDef)
	bodyDef.position.Set(10, -1.8)
	world.CreateBody(bodyDef).CreateFixture(fixDef)
	fixDef.shape.SetAsBox(2, 14)
	bodyDef.position.Set(-1.8, 13)
	world.CreateBody(bodyDef).CreateFixture(fixDef)
	bodyDef.position.Set(21.8, 13)
	world.CreateBody(bodyDef).CreateFixture(fixDef)

	bodyDef.type = b2Body.b2_dynamicBody;
	for i in [0..10]
		fixDef.shape = new b2PolygonShape;
		fixDef.shape.SetAsBox(Math.random() + 0.1, Math.random() + 0.1)
		bodyDef.position.x = Math.random() * 10
		bodyDef.position.y = Math.random() * 10
		world.CreateBody(bodyDef).CreateFixture(fixDef)

	window.setInterval(update, 1000 / 60)
###
