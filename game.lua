-- package.path = package.path .. ';' .. system.pathForFile( "", system.ResourceDirectory ) .. '\\?.luac'

local composer = require "composer"
local blur = require "blur"
local machine = require('statemachine')
local _ = require("underscore")
local appodeal = require( "plugin.appodeal" )
local Shadows = require('2dshadows.shadows')
local adNetwork = "admob"
local appID = "DontTouchTheSpider"

local score = composer.getVariable("score")

local text_score

_G.GUI = require( "widget_candy" )

_G.GUI.LoadTheme("theme_1", "themes/theme_1/")
_G.GUI.LoadTheme("theme_2", "themes/theme_2/")
_G.GUI.LoadTheme("theme_3", "themes/theme_3/")
_G.GUI.LoadTheme("theme_4", "themes/theme_4/")
_G.GUI.LoadTheme("theme_5", "themes/theme_5/")
_G.GUI.LoadTheme("theme_3", "themes/theme_3/")
_G.GUI.LoadTheme("theme_7", "themes/theme_7/")

_G.GUI.ShowTouches(true, 10, {1,.5,0})

_G.theme = "theme_2"

local scene = composer.newScene()

-- resources
local spiders = {}
local ants = {}
local blurredGroup
local background
local rect1, rect2

-- sounds
local spider_attacking_sound
local ant_splat_sound

-- ambient sounds
local rain_drop_sound

-- level settings
_G.spiders_quantity = composer.getVariable("spiders_quantity")
_G.ants_quantity = composer.getVariable("ants_quantity")

-- constants
local DEFAULT_SCALE = 0.08

function load_records()
	local contents = "0"

	-- Path for the file to read
	local path = system.pathForFile( "records", system.DocumentsDirectory )
	 
	-- Open the file handle
	local file, errorString = io.open( path, "r" )
	 
	if not file then
	    -- Error occurred; output the cause
	    print( "File error: " .. errorString )
	else
	    -- Read data from file
	    contents = file:read( "*a" )
	    -- Output the file contents
	    print( "Contents of " .. path .. "\n" .. contents )

	    -- Close the file handle
	    io.close( file )
	end
	 
	file = nil	

	return contents
end

local function save_score()

	composer.setVariable("score", score)
	text_score.text = score
	if (tonumber(load_records()) > score) then
		return
	end

	-- Path for the file to write
	local path = system.pathForFile( "records", system.DocumentsDirectory )
	 
	-- Open the file handle
	local file, errorString = io.open( path, "w" )
	 
	if not file then
	    -- Error occurred; output the cause
	    print( "File error: " .. errorString )
	else
	    -- Write data to file
	    file:write( score )
	    -- Close the file handle
	    io.close( file )
	end
	 
	file = nil
end

local function adListener( event )
	-- event table includes:
	-- 		event.provider
	--		event.isError (e.g. true/false )

	local msg = event.response

	-- just a quick debug message to check what response we got from the library
	-- print("Message received from the ads library: ", msg)

    appodeal.show( "banner", { yAlign="top" } )

	if event.isError then
    	
	else
	end
end

function antKilledEvent(idx)
	if (_.every(ants, function(o) return o.fsm.current == "dying" end)) then
		showFinishWindow()
	end

	local spider = _.detect(
			spiders, function(o) local antAimed =  o.antAimed == nil and 0 or o.antAimed; return antAimed == idx end
		)

	if (spider ~= nil) then
		spider.fsm:attack(spider.index)
	end
end

function showRestartWindow ()
	local o = nil
     o = _G.GUI.GetHandle("Win1")
     if (o ~= nil) then
     	return
     end

	local window = _G.GUI.NewWindow(
		{
			x      = "center",
			y      = "center",
			width = "50%",
			height = "20%",
			parentGroup = nil,
			name   = "Win1",
			theme  = _G.theme,
			caption  = "                  UUGGHHHH!",
			gradientColor1 = { 1,.5,0,0.3 },
			gradientColor2 = { 0,0,0,.3 },
			gradientDirection = "up"
		} 
	)
	local restartButton = _G.GUI.NewButton(
        {
        	parentGroup = "Win1",
        	name = "restartButton",
            x               = "center", 
            y               = "38%", 
			width = "42%",
			height = "auto",            
            theme      = _G.theme,
            textAlign  = "left",
            caption = "restart",
            pressColor = {1,1,1,.25},
            onRelease = function( event ) 
            	composer.removeScene("game")
            	composer.gotoScene("restart")
        	end
        })	

	_G.GUI.GetHandle("Win1"):layout(true) 	

	scene.view:insert(window)
	-- scene.view:insert(restartButton)
end

function showFinishWindow ()
	local o = nil
     o = _G.GUI.GetHandle("Win1")
     if (o ~= nil) then
     	return
     end

	local window = _G.GUI.NewWindow(
		{
			x      = "center",
			y      = "center",
			width = "50%",
			height = "20%",
			parentGroup = nil,
			name   = "Win1",
			theme  = _G.theme,
			caption  = "                     Completed",
			gradientColor1 = { 1,.5,0,0.3 },
			gradientColor2 = { 0,0,0,.3 },
			gradientDirection = "up"
		} 
	)
	local restartButton = _G.GUI.NewButton(
        {
        	parentGroup = "Win1",
        	name = "restartButton",
            x               = "4%", 
            y               = "38%", 
            width      = "42%",
            height      = "auto",
            theme      = _G.theme,
            textAlign  = "left",
            icon = 48,
            caption = "restart",
            pressColor = {1,1,1,.25},
            onRelease = function( event ) 
            	composer.removeScene("game")
            	composer.gotoScene("restart")
        	end            
        })		
    local nextButton = _G.GUI.NewButton(
        {
        	parentGroup = "Win1",
        	name = "nextButton",
            x               = "54%", 
            y               = "38%", 
            width      = "42%",
            height      = "auto",
            theme      = _G.theme,
            textAlign  = "left",
            icon = 6,
            caption = "next",
            pressColor = {1,1,1,.25},
            onRelease = function( event ) 
            	composer.setVariable("spiders_quantity", _G.spiders_quantity + 1)
            	composer.setVariable("ants_quantity", _G.ants_quantity + 3)

            	composer.removeScene("game")
            	composer.gotoScene("restart")
        	end            
        })

    local newText = _G.GUI.NewText(
        {
            x               = "2.5%",                
            y               = "1.8%", 
            width           = "100%",
            --height          = get_value_according_orientation("9%", "15%"),
            scale           = 1,
            -- height          = "auto",
            name            = "TXT_SCORE",            
            fontSize        = 24,
            font            = "Gill Sans",
            parentGroup     = "Win1",                     
            align           = "center",
            theme           = _G.theme, 
            caption         = "Your score: " .. score,
            textAlign       = "center",
            textColor       = {0,0,0}
        } 
    )

	_G.GUI.GetHandle("Win1"):layout(true) 	

	scene.view:insert(window)
end

function getNearbyAnt( pCenter, pObjects, pRange, pDebug )
    if ( pCenter == nil ) or (pObjects == nil) then  --make sure the objects exists
        return false
    end
    
    local pDebug = pDebug or false

    if pDebug == true then
        local rect = display.newRect( pCenter.x, pCenter.y, pRange*2, pRange*2 )
        rect:setFillColor( 0,0,0,0 )
        rect:setStrokeColor( 1,0,0 )
        rect.strokeWidth = 1
    end

    local left      = pCenter.x - pRange
    local right     = pCenter.x + pRange
    local top       = pCenter.y - pRange
    local bottom    = pCenter.y + pRange

    local result = {}

    for i=1,#pObjects do
        if pObjects[i] ~= nil then
        	if pObjects[i].fsm.current ~= 'dying' then
	            if pObjects[i].x >= left and pObjects[i].x <= right then
	                if pObjects[i].y >= top and pObjects[i].y <= bottom then
	                    result[#result+1] = pObjects[i]
	                end
	            end
	        end
        end
    end

    return result
end

function scene:create( event )
	local sceneGroup = self.view

	text_score = display.newText( score, 50, 15, native.newFont("Gill Sans", 24), 24 )

	display.setDefault("magTextureFilter", "nearest")
	display.setDefault("minTextureFilter", "nearest")

	spider_attacking_sound = audio.loadSound( "assets/spider_attack_uagh.wav" )
	ant_splat_sound = audio.loadSound( "assets/splat.wav" )
	rain_drop_sound = audio.loadSound ( "assets/raindrops.wav" )

	-- loading background
	background = display.newImage("wall.jpg")
	background.x = display.contentWidth / 2
	background.y = display.contentHeight / 2

	sceneGroup:insert(background)

	-- loading ants
	local sequenceData =
	{
	    name="walking",
	    frames= { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 }, -- frame indexes of animation, in image sheet
	    time = 150,
	    loopCount = 0        -- Optional ; default is 0
	}

	-- local sheetData = { width=120, height=148, numFrames=19, sheetContentWidth=480, sheetContentHeight=740 }
	-- local imageSheet = graphics.newImageSheet( "spider_crawl.png", sheetData )

	local sheetData = { width=438, height=395, numFrames=1, sheetContentWidth=438, sheetContentHeight=395}
	local imageSheet = graphics.newImageSheet( "Black-Widow.png", sheetData )

	local shadows = Shadows:new( 0.9, {0.7,0.7,0.7} )

	-- CREATE A SHADOW CASTER OBJECT
	--local crate1 = shadows:AddShadowCaster({-90,-90, -90,90, 90,90, 90,-90}, "img/crate.png",180,180)
	--crate1.x,crate1.y = 150,0

	-- CREATE A SHADOW CASTER OBJECT
	--local crate2 = shadows:AddShadowCaster({-45,-45, -45,45, 45,45, 45,-45}, "img/crate.png",90,90)
	--crate2.x,crate2.y = -120, -200

	-- CREATE BLUE LIGHT
	local light1 = shadows:AddLight( 2, {1,1,1}, 0.9, 4 )
	light1.x, light1.y = -100, -100
	light1:SetFlicker( true, "damaged", 0.7 )


	for i = 1, tonumber(_G.ants_quantity) do
		local antSplat = display.newImage("splat01.png")
		local ant = display.newSprite( imageSheet, sequenceData )

		ant.splat = antSplat
		ant.splat.x = -1000
		ant.splat.y = -1000
		ant:scale(DEFAULT_SCALE, DEFAULT_SCALE)
		ant.x = math.random(display.contentWidth)
		ant.y = math.random(display.contentHeight)
		ant:setFillColor(255, 0, 255, 255)
		ant.fsm = machine.create({
		  initial = 'idle',
		  events = {
		    { name = 'roam',  from = {'idle', 'roaming'},  to = 'roaming' },
		    { name = 'stay',  from = 'roaming',  to = 'idle' },
		    { name = 'attack',  from = {'waiting', 'roaming'},  to = 'scarejump' },
		    { name = 'wait',  from = 'roaming',  to = 'waiting' },
		    { name = 'die',  from = {'waiting', 'roaming', 'idle'},  to = 'dying' }
		  },
		  callbacks = {
		  	ondying = function(self, event, from, to, idx)
		  		transition.pause(ants[idx].transitionId)

		    	ants[idx]:setFillColor(0, 255, 0, 125)
				ants[idx].timeScale = math.random(1, 10) / 10
				audio.play ( ant_splat_sound )

				ants[idx].splat.visible = true
				ants[idx].splat.x = ants[idx].x
				ants[idx].splat.y = ants[idx].y
				ants[idx].splat:scale(.5, .5)
--				ants[idx].splat:toBack()

				local scores = display.newText( "+100", ants[idx].x, ants[idx].y, native.newFont("Gill Sans", 9), 9 )
			    score = score + 100
			    save_score()

				transition.to ( scores, { time=1500, y=ants[idx].y - 15, onComplete=function() 

					scores:removeSelf() 
				end })

		    	timer.performWithDelay(math.random(250, 750), function()
		    		ants[idx]:pause()
		    	end)		  		

		    	antKilledEvent(idx)
		  	end,
		    onroam =    function(self, event, from, to, idx)
		    	local angle = math.random(360)
				local angleX = ants[idx].x + 120 * math.cos( math.rad( angle - 90 ) )
				local angleY = ants[idx].y + 120 * math.sin( math.rad( angle - 90 ) )

				angleX = (angleX < 0) and 0 or angleX
				angleX = (angleX > display.contentWidth) and display.contentWidth or angleX
				angleY = (angleY < 50) and 50 or angleY
				angleY = (angleY > display.contentHeight) and display.contentHeight or angleY

				ants[idx]:play()
				ants[idx].rotation = 0
		    	ants[idx]:rotate(angle)
		        ants[idx].transitionId = transition.to ( ants[idx], { time=math.random(1500, 3000), x=angleX , y=angleY , onComplete=function() 
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
		    		if (ants[idx].fsm.current ~= 'dying') then
						ants[idx].fsm:roam(idx)
					end
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

					transition.scaleTo( ants[idx], { xScale=20, yScale=20, time=300, transition=easing.inExpo, onComplete=function()
					end } )		    

					ants[idx]:toFront()	    			
	    		end)
			end
		  }
		})
		ant.index = table.getn(ants) + 1
		ant:addEventListener("touch", function(event)
		  if(event.phase == "ended") then
		    ant.fsm:die(ant.index)
		  end
		end)		
		ants[table.getn(ants) + 1] = ant
		ant.fsm:roam(table.getn(ants))	
	
		sceneGroup:insert(antSplat)
		sceneGroup:insert(ant)
	end

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

	for i = 1, tonumber(_G.spiders_quantity) do
		local spider = display.newSprite( imageSheet, sequenceData )

		spider:scale(0.35, 0.35)
		spider.x = math.random(display.contentWidth)
		spider.y = math.random(display.contentHeight)
		spider:setFillColor(255, 255, 255, 255)

		spider.fsm = machine.create({
		  initial = 'idle',
		  events = {
		    { name = 'roam',  from = {'killing', 'idle', 'roaming'},  to = 'roaming' },
		    { name = 'stay',  from = 'roaming',  to = 'idle' },
		    { name = 'attack',  from = {'idle', 'waiting', 'roaming'},  to = 'scarejump' },
		    { name = 'wait',  from = 'roaming',  to = 'waiting' },
		    { name = 'kill',  from = 'idle',  to = 'killing' },
		    { name = 'die',  from = 'idle',  to = 'dying' }
		  },
		  callbacks = {
		  	ondying = function(self, event, from, to, idx)
		    	spiders[idx]:setFillColor(0, 255, 0, 125)
				spiders[idx].timeScale = math.random(1, 10) / 10
				audio.play ( ant_splat_sound )

				local scores = display.newText( "+300", spiders[idx].x, spiders[idx].y, native.newFont("Gill Sans", 11), 11 )
			    score = score + 300
			    save_score()

				transition.to ( scores, { time=1500, y=spiders[idx].y - 15, onComplete=function() 
					scores:removeSelf() 
				end })

				if (spiders[idx].antAimed ~= nil or spiders[idx].aimCircle ~= nil) then
					spiders[idx].antAimed = nil
					spiders[idx].aimCircle:removeSelf()
					spiders[idx].aimCircle = nil
				end	

		    	timer.performWithDelay(math.random(250, 750), function()
		    		spiders[idx]:pause()
		    	end)		  		
		  	end,		  
		  	onkill =    function(self, event, from, to, idx, antidx)
				transition.to ( spiders[idx], { time=350, x=ants[antidx].x, y=ants[antidx].y, transition=easing.outCirc, onComplete=function() 
					ants[antidx].fsm:die(antidx)
					spiders[idx].fsm:roam(idx)
					if (spiders[idx].antAimed ~= nil and spiders[idx].aimCircle ~= nil) then
						spiders[idx].antAimed = nil
						spiders[idx].aimCircle:removeSelf()
						spiders[idx].aimCircle = nil
					end					
		        end})		  	
		  	end,
		    onroam =    function(self, event, from, to, idx)
		    	local angle = math.random(360)

		    	if (spiders[idx].x > display.contentWidth) then angle = 360 - angle end
		    	if (spiders[idx].y > display.contentHeight) then angle = 90 - angle end
		    	if (spiders[idx].x < 0) then angle = 360 - angle end
		    	if (spiders[idx].y < 0) then angle = 90 - angle end
				local angleX = spiders[idx].x + 50 * math.cos( math.rad( angle - 90 ) )
				local angleY = spiders[idx].y + 50 * math.sin( math.rad( angle - 90 ) )

				angleX = (angleX < 0) and 0 or angleX
				angleX = (angleX > display.contentWidth) and display.contentWidth or angleX
				angleY = (angleY < 50) and 50 or angleY
				angleY = (angleY > display.contentHeight) and display.contentHeight or angleY

				spiders[idx]:setFillColor(255, 255, 255, 255)
				spiders[idx].color = "none"

				spiders[idx]:play()
				spiders[idx].rotation = 0
		    	spiders[idx]:rotate(angle)
		        transition.to ( spiders[idx], { time=math.random(1500, 5000), x=angleX , y=angleY , onComplete=function() 
		        	if (math.random(3) == 3) then
		        		spiders[idx].fsm:stay(idx)
		        	else
		        		spiders[idx].fsm:roam(idx)
		        	end
		        end})
			end,
		    onidle =    function(self, event, from, to, idx)
		    	spiders[idx]:pause()

		    	timer.performWithDelay(1000, function()
					local nearbyAnt = getNearbyAnt(spiders[idx], ants, 100)[1]
					if (nearbyAnt ~= nil) then
						spider.aimCircle = display.newCircle(ants[nearbyAnt.index].x, ants[nearbyAnt.index].y, 10)
						spider.aimCircle:setFillColor(0,0,0,0)
						spider.aimCircle.strokeWidth = 2
						spider.aimCircle:setStrokeColor( 1, 0, 0 )
						spider.antAimed = nearbyAnt.index
						
						sceneGroup:insert(spider.aimCircle)
						
				    	timer.performWithDelay(math.random(1500, 4000), function()
							spiders[idx].fsm:kill(idx, nearbyAnt.index)
				    	end)
					else					
				    	timer.performWithDelay(math.random(1500, 4000), function()
							spiders[idx].fsm:roam(idx)
				    	end)					
					end		    		
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
				-- rect1.alpha = 1; rect2.alpha = 2
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

				--transition.to(background, { x = 100, y = 100, time = 100})
				--transition.scaleTo(background, { xScale = .35, yScale = .35, time = 100})

					transition.to( spiders[idx], { y=spiders[idx].y - 60, time=100, transition=easing.inExpo, onComplete=function(event)
						transition.scaleTo( spiders[idx], { xScale=20, yScale=20, time=250, transition=easing.inExpo } )		    
						transition.to( spiders[idx], { y=spiders[idx].y + 250, time=150, transition=easing.inExpo, onComplete=function(event)
							timer.performWithDelay(1000, function()
								spiders[idx].alpha = 0
								showRestartWindow()
							end)
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
				if (system.getTimer() - self.timer > 75) then
					if (self.color == "none") then
						self:setFillColor(0, 0, 255, 255)
						self.color = "blue"
					else
						self:setFillColor(255, 255, 255, 255)
						self.color = "none"
					end
					spider.timer = system.getTimer()
				end
				if (self.antAimed ~= nil and self.aimCircle ~= nil) then
					self.aimCircle.x = ants[self.antAimed].x
					self.aimCircle.y = ants[self.antAimed].y
				end
			end
		end
		spider.index = table.getn(spiders) + 1
		Runtime:addEventListener("enterFrame", spider)
		spider:addEventListener("touch", function(event)
			if (spider.fsm.current ~= "idle") then
				  if(event.phase == "ended") then
				    spider.fsm:attack(spider.index)
				  end
			else 
				spider.fsm:die(spider.index)
			end
		end)
		spiders[table.getn(spiders) + 1] = spider
		spider.fsm:roam(table.getn(spiders))	
	
		sceneGroup:insert(spider)
	end


	rect1 = display.newRect(display.contentWidth / 4, display.contentHeight / 2, 10, display.contentHeight)
	rect2 = display.newRect(display.contentWidth - (display.contentWidth / 4), display.contentHeight / 2, 10, display.contentHeight)

	rect1.alpha = 1; rect2.alpha = 1
	rect1:toFront(); rect2:toFront()

	sceneGroup:insert(shadows)
	sceneGroup:insert(rect1)
	sceneGroup:insert(rect2)
end

function scene:show( event )
	local sceneGroup = self.view

	if (event.phase == "will") then
        
	end
	if (event.phase == "did") then

		audio.play( rain_drop_sound, { loops = -1 })

		appodeal.init( adListener, { appKey="2b48850c59ebc26513bceb49edfbeda08aa473f0c5dc9846", smartBanners = false } )

		-- spider.x = display.contentWidth/2 ; spider.y = display.contentHeight/2
		for i,v in ipairs(spiders) do 
			v.y = display.contentHeight/2
			v:play()
		end
		for i,v in ipairs(ants) do 
			v.y = display.contentHeight/2
			v:play()
		end		

 	end
end

function scene:hide( event )
end

function scene:destroy( event )
     local o = nil
     o = _G.GUI.GetHandle("Win1")
     if (o ~= nil) then
     	 print("destroy win1")
         o:destroy()
     end

     o = _G.GUI.GetHandle("restartButton")
     if (o ~= nil) then
     	print("destroy restartButton")
         o:destroy()
     end

     text_score:removeSelf()
     text_score = nil
end

function scene:key(event)

    if ( event.keyName == "back" ) then
        composer.removeScene('game')
		composer.gotoScene('mainmenu', { effect = 'crossFade', time = 333 })
		
		return true
	end
end

Runtime:addEventListener( "key", scene )

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
