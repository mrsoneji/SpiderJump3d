local composer = require "composer"
local blur = require "blur"
local machine = require('statemachine')

local scene = composer.newScene()

-- resources
local spiders = {}
local ants = {}
local blurredGroup
local background

-- sounds
local spider_attacking_sound

function scene:create( event )
	local sceneGroup = self.view

	display.setDefault("magTextureFilter", "nearest")
	display.setDefault("minTextureFilter", "nearest")

	spider_attacking_sound = audio.loadSound( "spider_attacking.mp3" )

	-- loading background
	background = display.newImage("wall.jpg")
	background.x = display.contentWidth / 2
	background.y = display.contentHeight / 2

	sceneGroup:insert(background)

	-- loading spiders
	local sequenceData =
	{
	    name="walking",
	    frames= { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 }, -- frame indexes of animation, in image sheet
	    time = 1000,
	    loopCount = 0        -- Optional ; default is 0
	}

	local sheetData = { width=120, height=148, numFrames=19, sheetContentWidth=480, sheetContentHeight=740 }
	local imageSheet = graphics.newImageSheet( "spider_crawl.png", sheetData )

	for i = 1, 3 do
		local spider = display.newSprite( imageSheet, sequenceData )

		spider:scale(0.25, 0.25)
		spider.x = math.random(display.contentWidth)
		spider.y = math.random(display.contentHeight)
		spider:setFillColor(255, 255, 255, 255)

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

		    	if (spiders[idx].x > display.contentWidth) then angle = 360 - angle end
		    	if (spiders[idx].y > display.contentHeight) then angle = 90 - angle end
		    	if (spiders[idx].x < 0) then angle = 360 - angle end
		    	if (spiders[idx].y < 0) then angle = 90 - angle end
				local angleX = spiders[idx].x + 50 * math.cos( math.rad( angle - 90 ) )
				local angleY = spiders[idx].y + 50 * math.sin( math.rad( angle - 90 ) )

				spiders[idx]:setFillColor(255, 255, 255, 255)
				spiders[idx].color = "none"

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

		    	timer.performWithDelay(math.random(1500, 4000), function()
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
	    		audio.play( spider_attacking_sound )

	    		timer.performWithDelay(100, function()
			    	-- background.fill.effect = "filter.blurGaussian"
					
					-- transition.to( background.fill.effect.horizontal, { time=300, blurSize=30, transition=easing.outCirc } )
					-- transition.to( background.fill.effect.vertical, { time=300, blurSize=30, transition=easing.outCirc } )			

					for i, v in ipairs(spiders) do 
						if (i ~= idx) then
							-- v.fill.effect = "filter.blurGaussian"
							--transition.to( v.fill.effect.horizontal, { time=1000, blurSize=30, transition=easing.outCirc } )
							--transition.to( v.fill.effect.vertical, { time=1000, blurSize=30, transition=easing.outCirc } )			
						end
					end

					transition.to( spiders[idx], { y=spiders[idx].y - 60, time=100, transition=easing.inExpo, onComplete=function(event)
						transition.scaleTo( spiders[idx], { xScale=20, yScale=20, time=250, transition=easing.inExpo } )		    
						transition.to( spiders[idx], { y=spiders[idx].y + 250, time=150, transition=easing.inExpo, onComplete=function(event)
						end } )		    
					end } )		    
					

					spiders[idx]:toFront()	    			
	    		end)
			end
		  }
		})
		spider.timer = system.getTimer()
		spider.color = "none"
		spider.enterFrame = function ( self )
			if (self.fsm.current == "idle") then
				if (system.getTimer() - self.timer > 150) then
					if (self.color == "none") then
						self:setFillColor(0, 0, 255, 255)
						self.color = "blue"
					else
						self:setFillColor(255, 255, 255, 255)
						self.color = "none"
					end
					spider.timer = system.getTimer()
				end
			end
		end
		spider.index = table.getn(spiders) + 1
		Runtime:addEventListener("enterFrame", spider)
		spider:addEventListener("touch", function(event)
		  if(event.phase == "ended") then
		    spider.fsm:attack(spider.index)
		  end
		end)
		spiders[table.getn(spiders) + 1] = spider
		spider.fsm:roam(table.getn(spiders))	
	
		sceneGroup:insert(spider)
	end

	-- loading ants
	local sequenceData =
	{
	    name="walking",
	    frames= { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 }, -- frame indexes of animation, in image sheet
	    time = 150,
	    loopCount = 0        -- Optional ; default is 0
	}

	local sheetData = { width=120, height=148, numFrames=19, sheetContentWidth=480, sheetContentHeight=740 }
	local imageSheet = graphics.newImageSheet( "spider_crawl.png", sheetData )

	for i = 1, 10 do
		local ant = display.newSprite( imageSheet, sequenceData )

		ant:scale(0.25, 0.25)
		ant.x = math.random(display.contentWidth)
		ant.y = math.random(display.contentHeight)
		ant:setFillColor(255, 0, 255, 255)
		ant.fsm = machine.create({
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
				local angleX = ants[idx].x + 120 * math.cos( math.rad( angle - 90 ) )
				local angleY = ants[idx].y + 120 * math.sin( math.rad( angle - 90 ) )

				ants[idx]:play()
				ants[idx].rotation = 0
		    	ants[idx]:rotate(angle)
		        transition.to ( ants[idx], { time=math.random(750, 1500), x=angleX , y=angleY , onComplete=function() 
		        	if (math.random(5) == 5) then
		        		ants[idx].fsm:stay(idx)
		        	else
		        		ants[idx].fsm:roam(idx)
		        	end
		        end})
			end,
		    onidle =    function(self, event, from, to, idx)
		    	ants[idx]:pause()

		    	timer.performWithDelay(math.random(1500, 5000), function()
					ants[idx].fsm:roam(idx)
		    	end)
		    end,
		    onattack =    function(self, event, from, to)
		    end,
		    onwaiting = function (self, event, from, to, idx)
		    	timer.performWithDelay(350, function() 
		    		-- ants[idx].fsm:attack(idx) 
		    	end)
		    end,
		    onscarejump =    function(self, event, from, to, idx) 
	    		timer.performWithDelay(100, function()
			    	ants[idx].blendMode = "one"
			    	background.fill.effect = "filter.blurGaussian"
					
					transition.to( background.fill.effect.horizontal, { time=1000, blurSize=30, transition=easing.outCirc } )
					transition.to( background.fill.effect.vertical, { time=1000, blurSize=30, transition=easing.outCirc } )			

					for i, v in ipairs(ants) do 
						if (i ~= idx) then
							v.fill.effect = "filter.blurGaussian"
							--transition.to( v.fill.effect.horizontal, { time=1000, blurSize=30, transition=easing.outCirc } )
							--transition.to( v.fill.effect.vertical, { time=1000, blurSize=30, transition=easing.outCirc } )			
						end
					end

					transition.scaleTo( ants[idx], { xScale=20, yScale=20, time=300, transition=easing.inExpo } )		    

					ants[idx]:toFront()	    			
	    		end)
			end
		  }
		})
		ant.index = table.getn(ants) + 1
		
		ants[table.getn(ants) + 1] = ant
		ant.fsm:roam(table.getn(ants))	
	
		sceneGroup:insert(ant)
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
		for i,v in ipairs(ants) do 
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