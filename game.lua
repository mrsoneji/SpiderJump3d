local composer = require "composer"
local blur = require "blur"
local machine = require('statemachine')


local fsm

local scene = composer.newScene()

-- resources
local spider
local blurredGroup
local background

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

	spider:scale(0.10, 0.10)

	local rect1 = display.newRect(display.contentWidth / 4, display.contentHeight / 2, 10, display.contentHeight)
	local rect2 = display.newRect(display.contentWidth - (display.contentWidth / 4), display.contentHeight / 2, 10, display.contentHeight)

	-- loading background
	background = display.newImage("wall.jpg")
	background.x = display.contentWidth / 2
	background.y = display.contentHeight / 2

	sceneGroup:insert(background)
	sceneGroup:insert(rect1)
	sceneGroup:insert(rect2)
	sceneGroup:insert(spider)

	rect1:toFront(); rect2:toFront()
end

function scene:show( event )
	local sceneGroup = self.view

	if (event.phase == "will") then

	end
	if (event.phase == "did") then

		-- spider.x = display.contentWidth/2 ; spider.y = display.contentHeight/2
		spider.x = 0
		spider.y = display.contentHeight/2
		spider:play()

		timer.performWithDelay(2000, function()

--			background.fill.effect = "filter.blurGaussian"


			
		end
		)

		fsm = machine.create({
		  initial = 'idle',
		  events = {
		    { name = 'roam',  from = 'idle',  to = 'roaming' },
		    { name = 'stay',  from = 'roaming',  to = 'idle' },
		    { name = 'attack',  from = 'waiting',  to = 'scarejump' },
		    { name = 'wait',  from = 'roaming',  to = 'waiting' }
		  },
		  callbacks = {
		    onroam =    function(self, event, from, to)      transition.to ( spider, { time=2500, x=display.contentWidth / 2, onComplete=function() fsm:wait() end } )        end,
		    onidle =    function(self, event, from, to)      print('stay')         end,
		    onattack =    function(self, event, from, to)
		    end,
		    onwaiting = function (self, event, from, to)
		    	print("waiting")
		    	timer.performWithDelay(350, function() fsm:attack() end )
		    end,
		    onscarejump =    function(self, event, from, to) 
		    	background.fill.effect = "filter.blurGaussian"

				transition.to( background.fill.effect.horizontal, { time=1000, blurSize=15, transition=easing.outCirc } )
				transition.to( background.fill.effect.vertical, { time=1000, blurSize=15, transition=easing.outCirc } )			

				transition.scaleTo( spider, { xScale=20, yScale=20, time=300, transition=easing.inExpo } )		    

				spider:toFront()
			end
		  }
		})

		fsm:roam()

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