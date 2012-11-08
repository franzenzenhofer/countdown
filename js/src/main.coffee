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
b2MouseJointDef =  Box2D.Dynamics.Joints.b2MouseJointDef;

world = {}
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
  #mouseX = (x - canvasPosition.x) / 30
  #mouseY = (y - canvasPosition.y) / 30
  mouseX = x / 30
  mouseY = x / 30
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



	
createDOMObjects = () ->
  #iterate all div elements and create them in the Box2D system
  $("#container div").each (a, b) ->
    domObj = $(b)
    domPos = $(b).position()
    width = domObj.width() / 2
    height = domObj.height() / 2
    x = (domPos.left) + width
    y = (domPos.top) + height
    body = createBox(x, y, width, height)
    body.m_userData = {
      domObj: domObj
      width: width
      height: height
      }

    #Reset DOM object position for use with CSS3 positioning
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


init = () ->
	world = new b2World(
		new b2Vec2(0,10),
		true
		)

	createDOMObjects()
	w = $(window).width(); 
	h = $(window).height();
	
	createBox(0, h , w, 5, true);
	createBox(0,0,5,h, true);
	createBox(w,0,5,h, true);

	interval = setInterval(update,1000/60);
	update();

init()
#canvasPosition = getElementPosition(document.getElementById("canvas"))
mouse = MouseAndTouch(document, downHandler, upHandler, moveHandler)
 
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
