local composer = require "composer"

local scene = composer.newScene()

-- resources
local spider

function scene:create( event )
	local sceneGroup = self.view

	-- loading spider
	local sequenceData =
	{
	    name="walking",
	    frames= { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 }, -- frame indexes of animation, in image sheet
	    time = 1000,
	    loopCount = 0        -- Optional ; default is 0
	}

	local sheetData = { width=120, height=148, numFrames=19, sheetContentWidth=480, sheetContentHeight=740 }
	local imageSheet = graphics.newImageSheet( "spider_crawl.png", sheetData )

	spider = display.newSprite( imageSheet, sequenceData )
	spider:scale(0.5, 0.5)

	local rect1 = display.newRect(display.contentWidth / 4, display.contentHeight / 2, 10, display.contentHeight)
	local rect2 = display.newRect(display.contentWidth - (display.contentWidth / 4), display.contentHeight / 2, 10, display.contentHeight)

	-- loading background
	local background = display.newImage("wall.jpg")
	background.x = display.contentWidth / 2
	background.y = display.contentHeight / 2

	sceneGroup:insert(background)
	sceneGroup:insert(rect1)
	sceneGroup:insert(rect2)
	sceneGroup:insert(spider)
end

function scene:show( event )
	local sceneGroup = self.view

	if (event.phase == "will") then

	end
	if (event.phase == "did") then
		spider.x = display.contentWidth/2 ; spider.y = display.contentHeight/2
		spider:play()
	end
end

function scene:hide( event )
end

function scene:destroy( event )
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene