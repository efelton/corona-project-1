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
local backButton
local earCornIcon
local popcornIcon
local bombIcon
local earCornOutline
local popcornOutline
local bombOutline

-- get distance between 2 points
local function getDistance(x1, x2, y1, y2)
	return math.sqrt((x1-x2) * (x1-x2) + (y1-y2) * (y1-y2))
end

--function earCornIcon:touch( event )
function drag( event )
      if event.phase == "began" then
      	-- move the object being dragged to the front
      	event.target:toFront()
	
        event.target.markX = event.target.x    -- store x location of object
        event.target.markY = event.target.y    -- store y location of object
        -- mark this object as the one being dragged
		event.target.isDragTarget = true
    elseif event.phase == "moved" and event.target.isDragTarget then
	
        local x = (event.x - event.xStart) + event.target.markX
        local y = (event.y - event.yStart) + event.target.markY
        
        event.target.x, event.target.y = x, y    -- move object based on calculations above

        -- don't allow dragging down to the back button
        if event.target.y > display.contentHeight * 0.76 then
        	event.target.y = display.contentHeight * 0.76
        end

    -- once the drag is over mark the item as no longer the target
    elseif event.phase == "ended" then
    	event.target.isDragTarget = false
	    -- detect if the object is close enough to its match to snap into place
	    distance = getDistance(event.target.x, event.target.matchX, event.target.y, event.target.matchY)

	    if distance < 40 then
	    	event.target.x = event.target.matchX
	    	event.target.y = event.target.matchY
	    	-- play success sound
	    	audio.play(successSound)
	    end
    end
    
    -- only return true if this object is the one being dragged
    if event.target.isDragTarget then
	    return true

	end
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

	--Add the images
	earCornIcon = display.newImage("ear-corn-target.png", display.contentWidth*0.5, display.contentHeight*0.7)
	physics. addBody(earCornIcon,"kinematic")
	group:insert(earCornIcon)

	popcornIcon = display.newImage("popcorn-2.png", display.contentWidth * 0.2, display.contentHeight * 0.7)
	physics. addBody(popcornIcon,"kinematic")
	group:insert(popcornIcon)

	bombIcon = display.newImage("bomb-icon.png", display.contentWidth * 0.8, display.contentHeight * 0.7)
	physics. addBody(bombIcon,"kinematic")
	group:insert(bombIcon)
	
	--Add the outlines
	earCornOutline = display.newImage("ear-corn-outline.png", display.contentWidth*0.5, display.contentHeight*0.3)
	physics. addBody(earCornOutline,"kinematic")
	group:insert(earCornOutline)

	popcornOutline = display.newImage("popcorn-outline.png", display.contentWidth * 0.2, display.contentHeight * 0.4)
	physics. addBody(popcornOutline,"kinematic")
	group:insert(popcornOutline)

	bombOutline = display.newImage("bomb-outline.png", display.contentWidth * 0.8, display.contentHeight * 0.3)
	physics. addBody(bombOutline,"kinematic")
	group:insert(bombOutline)

	--set up the draggable objects match values
	earCornIcon.matchX = earCornOutline.x
	earCornIcon.matchY = earCornOutline.y
	popcornIcon.matchX = popcornOutline.x
	popcornIcon.matchY = popcornOutline.y
	bombIcon.matchX = bombOutline.x
	bombIcon.matchY = bombOutline.y

	-- Add the back button (to go back to the menu screen)
	backButton = display.newImage("arrowLeft.png", 120, 120)
	backButton.x = display.contentWidth * 0.8
	backButton.y = display.contentHeight * 0.9
	group:insert(backButton)

	-- Load beep sound
	successSound = audio.loadSound("beep-7.mp3")

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	storyboard.removeAll()

	
	-----------------------------------------------------------------------------
	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	-----------------------------------------------------------------------------

	-- add the movement listeners to the jigsaw pieces
	earCornIcon:addEventListener( "touch", drag )
	popcornIcon:addEventListener( "touch", drag )
	bombIcon:addEventListener( "touch", drag )	

	backButton:addEventListener("touch",goBack)

	physics.start()


end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view

	-----------------------------------------------------------------------------
	--	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)	
	-----------------------------------------------------------------------------
	earCornIcon:removeEventListener("touch",drag)
	popcornIcon:removeEventListener("touch",drag)
	bombIcon:removeEventListener("touch",drag)
	
	backButton:removeEventListener("touch",goBack)

	physics.pause()
	
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