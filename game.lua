local composer = require "composer"
local blur = require "blur"
local machine = require('statemachine')

local scene = composer.newScene()

-- resources
local spiders = {}
local blurredGroup
local background

function scene:create( event )
	local sceneGroup = self.view

	-- loading background
	background = display.newImage("wall.jpg")
	background.x = display.contentWidth / 2
	background.y = display.contentHeight / 2

	sceneGroup:insert(background)

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

	for i = 1, 50 do
		local spider = display.newSprite( imageSheet, sequenceData )

		spider:scale(0.25, 0.25)
		spider.x = math.random(display.contentWidth)
		spider.y = math.random(display.contentHeight)
		spider.blendMode = "ond"
		spider.fsm = machine.create({
		  initial = 'idle',
		  events = {
		    { name = 'roam',  from = {'idle', 'roaming'},  to = 'roaming' },
		    { name = 'stay',  from = 'roaming',  to = 'idle' },
		    { name = 'attack',  from = {'waiting', 'roaming'},  to = 'scarejump' },
		    { name = 'wait',  from = 'roaming',  to = 'waiting' }
		  },
		  callbacks = {
		    onroam =    function(self, event, from, to, idx)
		    	local angle = math.random(360)
				local angleX = spiders[idx].x + 50 * math.cos( math.rad( angle - 90 ) )
				local angleY = spiders[idx].y + 50 * math.sin( math.rad( angle - 90 ) )

				spiders[idx]:play()
				spiders[idx].rotation = 0
		    	spiders[idx]:rotate(angle)
		        transition.to ( spiders[idx], { time=math.random(1500, 5000), x=angleX , y=angleY , onComplete=function() 
		        	if (math.random(5) == 5) then
		        		spiders[idx].fsm:stay(idx)
		        	else
		        		spiders[idx].fsm:roam(idx)
		        	end
		        end})
			end,
		    onidle =    function(self, event, from, to, idx)
		    	spiders[idx]:pause()

		    	timer.performWithDelay(math.random(1500, 5000), function()
					spiders[idx].fsm:roam(idx)
		    	end)
		    end,
		    onattack =    function(self, event, from, to)
		    end,
		    onwaiting = function (self, event, from, to, idx)
		    	timer.performWithDelay(350, function() 
		    		-- spiders[idx].fsm:attack(idx) 
		    	end)
		    end,
		    onscarejump =    function(self, event, from, to, idx) 
		    	spiders[idx].blendMode = "one"
		    	background.fill.effect = "filter.blurGaussian"
				
				transition.to( background.fill.effect.horizontal, { time=1000, blurSize=30, transition=easing.outCirc } )
				transition.to( background.fill.effect.vertical, { time=1000, blurSize=30, transition=easing.outCirc } )			

				for i, v in ipairs(spiders) do 
					if (i ~= idx) then
						v.fill.effect = "filter.blurGaussian"
						--transition.to( v.fill.effect.horizontal, { time=1000, blurSize=30, transition=easing.outCirc } )
						--transition.to( v.fill.effect.vertical, { time=1000, blurSize=30, transition=easing.outCirc } )			
					end
				end

				transition.scaleTo( spiders[idx], { xScale=20, yScale=20, time=300, transition=easing.inExpo } )		    

				spiders[idx]:toFront()
			end
		  }
		})
		spider.index = table.getn(spiders) + 1
		spider:addEventListener("touch", function(event)
		  if(event.phase == "ended") then
		    spider.fsm:attack(spider.index)
		  end
		end)
		spiders[table.getn(spiders) + 1] = spider
		spider.fsm:roam(table.getn(spiders))	
	
		sceneGroup:insert(spider)
	end

	local rect1 = display.newRect(display.contentWidth / 4, display.contentHeight / 2, 10, display.contentHeight)
	local rect2 = display.newRect(display.contentWidth - (display.contentWidth / 4), display.contentHeight / 2, 10, display.contentHeight)

	sceneGroup:insert(rect1)
	sceneGroup:insert(rect2)

	rect1:toFront(); rect2:toFront()
end

function scene:show( event )
	local sceneGroup = self.view

	if (event.phase == "will") then

	end
	if (event.phase == "did") then

		-- spider.x = display.contentWidth/2 ; spider.y = display.contentHeight/2
		for i,v in ipairs(spiders) do 
			v.y = display.contentHeight/2
			v:play()
		end
		
		timer.performWithDelay(2000, function()

--			background.fill.effect = "filter.blurGaussian"


			
		end
		)

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