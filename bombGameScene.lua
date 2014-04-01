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
local gameWon
local gameLives

-- functions to transition the target back & forth
leftTargetScale = 0.1 
leftTargetBoundary = display.contentWidth * leftTargetScale
rightTargetScale = 0.9
rightTargetBoundary = display.contentWidth * rightTargetScale
oneSecond = 1000
twoSeconds = 2000

function startTargetMoving() 
	tweenRef = transition.to(targetItem, {time = oneSecond , x =  leftTargetBoundary, onComplete = moveTargetToRightBoundary})
end

function moveTargetToLeftBoundary ()
	tweenRef = transition.to(targetItem, {time = twoSeconds, x =  leftTargetBoundary, onComplete = moveTargetToRightBoundary})
end

function moveTargetToRightBoundary ()
	tweenRef = transition.to(targetItem, {time = twoSeconds, x = rightTargetBoundary, onComplete = moveTargetToLeftBoundary})
end

-- function and constants to set up the platforms
platformHeight = display.contentHeight/50
platformWidth = display.contentWidth/10
platform1X = display.contentWidth * 0.2 
platform1Y = display.contentHeight * 0.4
platform2X = display.contentWidth * 0.45 
platform2Y = display.contentHeight * 0.2
platform3X = display.contentWidth * 0.7
platform3Y = display.contentHeight * 0.5

function setupPlatforms()
	local group = scene.view 

	platform1 = display.newRect(platform1X, platform1Y, platformWidth, platformHeight)
	platform2 = display.newRect(platform2X, platform2Y, platformWidth, platformHeight)
	platform3 = display.newRect(platform3X, platform3Y, platformWidth, platformHeight)
	group:insert(platform1)
	group:insert(platform2)
	group:insert(platform3)
	physics.addBody (platform1, "static")
	physics.addBody (platform2, "static")
	physics.addBody (platform3, "static")
	platform1.name, platform2.name, platform3. name = "platform", "platform", "platform"
end

-- function and constants to set up the bombs -- someone set us up the bomb
bombRightAdjust = 10
bombUpAdjust = display.contentHeight * 0.1

function setupBombs()
	local group = scene.view 

	bomb1 = display.newImage("bomb-icon.png", platform1X + bombRightAdjust , platform1Y - bombUpAdjust) 
	bomb2 = display.newImage("bomb-icon.png", platform2X + bombRightAdjust , platform2Y - bombUpAdjust)
	bomb3 = display.newImage("bomb-icon.png", platform3X + bombRightAdjust , platform3Y - bombUpAdjust)

	group:insert(bomb1)
	group:insert(bomb2)
	group:insert(bomb3)
	physics.addBody(bomb1, "dynamic")
	physics.addBody(bomb2, "dynamic")
	physics.addBody(bomb3, "dynamic")
	bomb1.name, bomb2.name, bomb3.name = "bomb", "bomb", "bomb"
end

-- function and constants to set up the ground
groundWidth = display.contentWidth
groundHeight = 20
groundX = 0
bottomBarHeight = 140 -- bottom bar is the bar at the bottom where the back button is kept
groundYAdjust = groundHeight + bottomBarHeight
--groundY = display.contentHeight - groundHeight
groundY = display.contentHeight - groundYAdjust

function setupGround()
	local group = scene.view 
	
	ground = display.newRect(groundX, groundY, groundWidth, groundHeight)
	ground:setFillColor(0, 255 ,0)
	ground.name = "ground"
	group:insert(ground)
	noBounceMaterial = { bounce = 0 }
	physics.addBody( ground, "static", noBounceMaterial)
end

-- function and constants to set up the target
targetInitialX = display.contentWidth/2
targetInitialYOffset = groundYAdjust + 80
targetInitialY = display.contentHeight - targetInitialYOffset

function setupTarget ()
	local group = scene.view 
	targetItem = display.newImage("ear-corn-target.png",targetInitialX, targetInitialY)
	physics. addBody(targetItem,"kinematic")
	targetItem.name = "target"
	group:insert(targetItem)
end

--function and constants to set up the Back Button
backButtonEdgeSize = 120
backButtonX = display.contentWidth * 0.8
backButtonY = display.contentHeight * 0.93

function setupBackButton()
	local group = scene.view 
	backButton = display.newImage("arrowLeft.png", 120, 120)
	backButton.x = display.contentWidth * 0.8
	backButton.y = display.contentHeight * 0.93
	group:insert(backButton)
end

-- event to remove platforms when touched
function removePlatform(event)
--	event.target.isBodyActive = false -- This approach caused problems; sometimes the bomb would not fall and would just hold in the air
--	event.target.isVisible = false
	event.target:removeSelf()

--	Not sure how to nil the object
--	event.target = nil -- this will only nil the event property that refers to the object, not the object itself
end

-- function to change scene in response to the back button being pressed
function goBack(event)
	if event.phase == "ended" then
		storyboard.gotoScene("scenemenu")
	end
end


-- Collision detection to "hit" the target
function onCollision(event)
	local group = scene.view 

	-- need to check if the collision was between bomb and ground 
		-- in which case delete bomb
	local bombToDelete
	if (event.object1.name == "ground" and event.object2.name == "bomb") or ( event.object2.name == "ground" and event.object1.name == "bomb" ) then
		-- MISSED: remove the bomb and lose a life
		gameLives = gameLives - 1

		if event.object1.name == "bomb" then
			bombToDelete = event.object1
		else
			bombToDelete = event.object2
		end
--		bombToDelete.isVisible = false
		bombToDelete:removeSelf()

		if gameLives == 0 and not gameWon then
			-- lost the game
			print ("lost the game!")
			loseMessage = display.newText ("You Lose! Awww!!", display.contentWidth * 0.25, display.contentHeight *0.550, nil, 50)
			loseMessage:setTextColor(255,0,0)
			group:insert(loseMessage)
			transition.cancel(tweenRef)
		end

	-- or collision between bomb and target
		-- in which case win the game
	elseif (event.object1.name == "bomb" and event.object2.name == "target" ) or (event.object1.name == "target" and event.object2.name == "bomb") then
		-- HIT: win the game	
		gameWon = true

		local r = math.random( 0, 255 )
		local g = math.random( 0, 255 )
		local b = math.random( 0, 255 )
		ground:setFillColor( r, g, b )

		local targetObject
		local bombObject

		-- get the location of the target
		if event.object1.name == "target" then
			targetObject = event.object1
			bombObject = event.object2
		else
			targetObject =event.object2
			bombObject = event.object1
		end

		targetX = targetObject.x
		targetY = targetObject.y

		-- remove the target & and also remove the bomb
		targetObject:removeSelf()
		bombObject:removeSelf()
		--cancel the target transition
		transition.cancel(tweenRef)

		-- play the explosion sound
		audio.play(winSound)
		
		-- add in the popcorn
		popcorn = display.newImage("popcorn-2.png", targetX-60, targetY -70)
		local group = scene.view 
		group:insert(popcorn)

		-- display "YOU WIN! POPCORN!" message
		winMessage = display.newText ("You Win! Popcorn!!", display.contentWidth * 0.25, display.contentHeight *0.550, nil, 50)
		winMessage:setTextColor(255,0,0)
		group:insert(winMessage)

	end
end


-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	local physics = require("physics")
	physics.start()
	physics.pause()

	winSound = audio.loadSound("explosion-02.mp3")

	-- Add the background
	background = display.newImageRect ("sceneBG.png", 768, 1024)
	background.x = display.contentWidth/2
	background.y = display.contentHeight/2
	group:insert(background)

	setupGround()
	setupPlatforms()
	setupBombs()
	setupTarget()

	-- set up back button
	setupBackButton()

	gameWon = false
	gameLives = 3
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	storyboard.removeAll()

	-----------------------------------------------------------------------------
	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	-----------------------------------------------------------------------------

	-- event listeners to remove platforms when tapped
	for iterator1 = group.numChildren, 1, -1 do
		local item = group[iterator1]
		if (item.name == "platform") then
			item:addEventListener("tap", removePlatform)
		end
	end

	--start the target moving
	startTargetMoving()

	-- look for collisions 
	Runtime:addEventListener( "collision", onCollision )

	-- listener for the back button
	backButton:addEventListener("touch",goBack)

	physics.start()
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
	--	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)
	-----------------------------------------------------------------------------

	--cancel the target transition
	transition.cancel(tweenRef)
	backButton:removeEventListener("touch" , goBack)

	for iterator1 = group.numChildren, 1, -1 do
		local item = group[iterator1]
		if (item.name == "platform") then
			item:removeEventListener("tap", removePlatform)
		end
	end

	Runtime:removeEventListener( "collision", onCollision )

end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local bombgroup = self.view
	
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