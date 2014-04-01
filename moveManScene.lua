----------------------------------------------------------------------------------
-- scene1.lua
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

----------------------------------------------------------------------------------
-- 
--	NOTE:
--	
--	Code outside of listener functions (below) will only be executed once,
--	unless storyboard.removeScene() is called.
-- 
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local targetItem
local backButton

--event handler for touching the button
--essentially this handler will just record the fact that the touch is in progress as a property on the button object
--when the touch is finished or cancelled this object property will be updated accordingly
-- it will be the responsibility of the timer handler to do something with the fact that the button is being pushed
function buttonTouch(event) 
	print ( event.phase)
	if event.phase == "began" then
		event.target.pressed = true
	elseif	event.phase == "canceled" or event.phase == "ended" or event.moved == "phase" then
		
		event.target.pressed = false
	end
end

-- this function is called periodically. It calculates and sets the velocity on the targetItem based on
-- the old velocity of the item
-- whether one of the move buttons is pressed then acceleration is applied to the velocity based on button direction
-- a dragfactor is applied to velocity so if no button is pressed the object slows down
-- velocity on the object may not exceed maxVelocity
function movementLoop()
	-- get the current linear velocity
	xVelocity, yVelocity = targetItem:getLinearVelocity()

	local xButton;
	local yButton;

	xButton, yButton = 0, 0

	-- check if buttons are pressed 
	if leftArrow.pressed then
		xButton = xButton -1
	end
	if rightArrow.pressed then
		xButton = xButton +1
	end
	if upArrow.pressed then
		yButton = yButton-1
	end
	if downArrow.pressed then
		yButton = yButton +1
	end

	-- apply button changes to linear velocity (taking account of max velocity and acceleration)
	-- apply drag to linear velocity	
	acceleration = 35

	xVelocity = xVelocity + xButton * acceleration
	yVelocity = yVelocity + yButton * acceleration

	-- dragFactor -- applied to each time the movement loop is called this will work to slow the current linear velocity
	dragFactor = 6

	if xVelocity <= dragFactor and xVelocity >= -dragFactor then
		xVelocity = 0
	elseif xVelocity > dragFactor then
		xVelocity = xVelocity - dragFactor
	else -- xVelocity < -dragFactor
		xVelocity = xVelocity + dragFactor
	end
	if yVelocity <= dragFactor and yVelocity >= -dragFactor then
		yVelocity = 0
	elseif yVelocity > dragFactor then
		yVelocity = yVelocity - dragFactor
	else -- xVelocity < -dragFactor
		yVelocity = yVelocity + dragFactor
	end

	-- check that MaxVelocity has not been exceeded
	maxVelocity = 250

	if xVelocity > maxVelocity then
		xVelocity = maxVelocity
	elseif xVelocity < -maxVelocity then
		xVelocity = -maxVelocity
	end
	if yVelocity > maxVelocity then
		yVelocity = maxVelocity
	elseif yVelocity < -maxVelocity then
		yVelocity = -maxVelocity
	end

	-- based on all these calculations set the current linear velocity
	targetItem:setLinearVelocity(xVelocity, yVelocity)
end

function goBack(event)
	if event.phase == "ended" then
		storyboard.gotoScene("scenemenu")
	end
end


-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	-----------------------------------------------------------------------------
	--	CREATE display objects and add them to 'group' here.
	--	Example use-case: Restore 'group' from previously saved state.
	-----------------------------------------------------------------------------

	local physics = require("physics")
	physics.start()
	physics.pause()

	background = display.newImageRect ("sceneBG.png", 768, 1024)
	background.x = display.contentWidth/2
	background.y = display.contentHeight/2
	group:insert(background)

	-- Add the control arrows
	heightOffset = display.contentHeight * 0.75
	arrowTileLength= 50
 	
 	leftArrow = display.newImageRect ("leftControlArrow.png",40, 40)
 	leftArrow.x = display.contentWidth * 0.2
	leftArrow.y = display.contentHeight * 0.1 + heightOffset + arrowTileLength
	group:insert(leftArrow)
	
 	rightArrow = display.newImageRect ("rightControlArrow.png",40, 40)
 	rightArrow.x = display.contentWidth * 0.2 + arrowTileLength
	rightArrow.y = display.contentHeight * 0.1 + heightOffset + arrowTileLength
	group:insert(rightArrow)

 	upArrow = display.newImageRect ("upControlArrow.png",40, 40)
 	upArrow.x = display.contentWidth * 0.2 + arrowTileLength/2
	upArrow.y = display.contentHeight * 0.1 + heightOffset 
	group:insert(upArrow)

 	downArrow = display.newImageRect ("downControlArrow.png",40, 40)
 	downArrow.x = display.contentWidth * 0.2 + arrowTileLength/2
	downArrow.y = display.contentHeight * 0.1 + heightOffset + 2 * arrowTileLength
	group:insert(downArrow)

--	add the invisible wall
	iwallThickness = 6
	iwallLength = display.contentWidth
	iWallDepth = display.contentHeight * 0.8
	noBounceMaterial = { bounce = 0 }

	upWall = display.newRect(0,0,iwallLength,iwallThickness)
	downWall = display.newRect(0,iWallDepth,iwallLength,iwallThickness)
	leftWall = display.newRect(0,0,iwallThickness,iWallDepth)
	rightWall = display.newRect(iwallLength - iwallThickness,0,iwallThickness ,iWallDepth)
	physics.addBody(leftWall,"static",noBounceMaterial)
	physics.addBody(rightWall,"static",noBounceMaterial)
	physics.addBody(upWall,"static",noBounceMaterial)
	physics.addBody(downWall,"static",noBounceMaterial)
	leftWall.isVisible = false
	rightWall.isVisible = false
	upWall.isVisible = false
	downWall.isVisible = false

	-- Add the man (who will be moved by the arrows)
	targetMaterial = {density = 1.0, bounce =0.4}
	targetItem = display.newImage("ear-corn-target.png", display.contentWidth/2, display.contentHeight/2)
	physics. addBody(targetItem,"dynamic", targetMaterial)
	targetItem.name = "target"
	group:insert(targetItem)

	-- Add in the invisible barrier

	-- Add the back button (to go back to the menu screen)
	backButton = display.newImage("arrowLeft.png", 120, 120)
	backButton.x = display.contentWidth * 0.8
	backButton.y = display.contentHeight * 0.9
	group:insert(backButton)
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	storyboard.removeAll()
	
	-----------------------------------------------------------------------------
	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	-----------------------------------------------------------------------------
	backButton:addEventListener("touch",goBack)

	-- turn off gravity for this
	physics.setGravity(0,0)

	leftArrow.pressed = false
	rightArrow.pressed = false
	upArrow.pressed = false
	downArrow.pressed = false
	leftArrow:addEventListener("touch", buttonTouch)
	rightArrow:addEventListener("touch", buttonTouch)
	upArrow:addEventListener("touch", buttonTouch)
	downArrow:addEventListener("touch", buttonTouch)

	mytimer = timer.performWithDelay(100, movementLoop,0) -- invoke an function every tenth of a second
	physics.start()

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
	--	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)
	-----------------------------------------------------------------------------		
	leftArrow:removeEventListener("touch", buttonTouch)
	rightArrow:removeEventListener("touch", buttonTouch)
	upArrow:removeEventListener("touch", buttonTouch)
	downArrow:removeEventListener("touch", buttonTouch)

	-- turn gravity back on
	physics.setGravity(0,9.8)

	timer.cancel(mytimer)
	-- set object momentum to 0
	targetItem:setLinearVelocity(0,0)
	physics.pause()
	backButton:removeEventListener("touch", goBack)	
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
	
	--	INSERT code here (e.g. remove listeners, widgets, save state, etc.)
	
	-----------------------------------------------------------------------------
	
end


---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

---------------------------------------------------------------------------------

return scene