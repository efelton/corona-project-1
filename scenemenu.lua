----------------------------------------------------------------------------------
-- scene1.lua
----------------------------------------------------------------------------------
--
-- Resources used 
-- Right facing arrow icon : Wikimedia commons
-- http://commons.wikimedia.org/wiki/File:Right-facing-Arrow-icon.jpg
--
-- Popcorn 2 icon free for non-commercial use, author is iTweek on deviantart
-- http://itweek.deviantart.com/
-- http://www.iconseeker.com/search-icon/curtains/popcorn-2.html
--
-- Bomb icon
-- The black burning bomb is a free online resource, see 
-- http://kar928.wordpress.com/2011/09/14/87/
--
-- Explosion sound effect (free to download an duse)
-- http://www.mediacollege.com/downloads/sound-effects/explosion/
--
-- Beep sound -- beep-7.mp3	
-- "You are allowed to use the sounds on our website free of charge and royalty 
-- free in your projects but you are NOT allowed to post the sounds on any web 
-- site for others to download, link directly to individual audio files, or sell 
-- the sounds to anyone else."
-- terms and conditions http://www.soundjay.com/tos.html
-- http://www.soundjay.com/beep-sounds-1.html

-- background music is Luna's City Night by AgileDash
-- http://www.youtube.com/watch?v=_WqNtc3sRG8


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

-- Event Handlers for each of the 3 buttons
function game1Button(event)
	if event.phase == "ended" then
		storyboard.gotoScene("bombGameScene")
	end
end

function game2Button(event)
	if event.phase == "ended" then
		storyboard.gotoScene("moveManScene")
	end
end

function game3Button(event)
	if event.phase == "ended" then
		storyboard.gotoScene("jigsawScene")
	end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	-----------------------------------------------------------------------------
	--	CREATE display objects and add them to 'group' here.
	--	Example use-case: Restore 'group' from previously saved state.
	-----------------------------------------------------------------------------
	
	background = display.newImageRect ("sceneBG.png", 768, 1024)
	background.x = display.contentWidth/2
	background.y = display.contentHeight/2
	group:insert(background)

	-- Make 3 right arrows each of which points to one of the apps
	button1 = display.newImageRect ("arrowRight.png",120, 120)
	button1.x = display.contentWidth *0.2
	button1.y = display.contentHeight *0.2
	group:insert(button1)

	message1 = display.newText ("Game 1", display.contentWidth * 0.35, display.contentHeight *0.170, nil, 60)
	group:insert(message1)

	button2 = display.newImageRect ("arrowRight.png",120, 120)
	button2.x = display.contentWidth *0.2
	button2.y = display.contentHeight *0.4
	group:insert(button2)

	message2 = display.newText ("Game 2", display.contentWidth * 0.35, display.contentHeight *0.370, nil, 60)
	group:insert(message2)

	button3 = display.newImageRect ("arrowRight.png",120, 120)
	button3.x = display.contentWidth *0.2
	button3.y = display.contentHeight *0.6
	group:insert(button3)

	message3 = display.newText ("Game 3", display.contentWidth * 0.35, display.contentHeight *0.570, nil, 60)
	group:insert(message3)

	-- load background music
	bgmusic = audio.loadSound("agiledash-lunas-citynight.mp3")
    bgMusicChannel = audio.play(bgmusic, {loops = -1})

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view

	storyboard.removeAll()

	-----------------------------------------------------------------------------
	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	-----------------------------------------------------------------------------
	message1:setTextColor(255,0,0)
	message2:setTextColor(255,0,0)
	message3:setTextColor(255,0,0)

	 -- Listeners for the 3 app buttons
	 button1:addEventListener("touch",game1Button)
	 button2:addEventListener("touch",game2Button)
	 button3:addEventListener("touch",game3Button)

	 -- resume playing the background music
	 audio.resume(bgMusicChannel)
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
	
	--	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)
	
	-----------------------------------------------------------------------------
	 button1:removeEventListener("touch",game1Button)
	 button2:removeEventListener("touch",game2Button)
	 button3:removeEventListener("touch",game3Button)

	 --stop playing the background music
	 audio.pause(bgMusicChannel)
	
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