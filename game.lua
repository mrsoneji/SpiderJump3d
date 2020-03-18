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
local lives = 3
local combo_counter_delta = 0
local combo_counter_quantity = 1

local text_score, score_title, hearth_ui_1, hearth_ui_2, hearth_ui_3, pause_dialog, combo_counter_text, transition_id_combo_animation

display.setDefault( 'isShaderCompilerVerbose', true )

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

local function save_lives()
	if (lives == 2) then
		hearth_ui_1.isVisible = false
	end
	if (lives == 1) then
		hearth_ui_1.isVisible = false
		hearth_ui_2.isVisible = false
	end
	if (lives == 0) then
		hearth_ui_1.isVisible = false
		hearth_ui_2.isVisible = false
		hearth_ui_3.isVisible = false

		showRestartWindow()
	end
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

    appodeal.show( "banner", { yAlign="bottom" } )

	if event.isError then
    	
	else
	end
end

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

-- sounds
local spider_attacking_sound
local ant_splat_sound

-- level settings
_G.spiders_quantity = composer.getVariable("spiders_quantity")
_G.ants_quantity = composer.getVariable("ants_quantity")
_G.current_level = composer.getVariable("current_level")
_G.allow_scare_jump = composer.getVariable("allow_scare_jump")

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
			width = "40%",
			height = "20%",
			parentGroup = nil,
			name   = "Win1",
			theme  = _G.theme,
			caption  = "UUGGHHHH!",
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
            	-- composer.setVariable("spiders_quantity", _G.spiders_quantity + 1)
				composer.setVariable("ants_quantity", _G.ants_quantity + 3)
				composer.setVariable("current_level", _G.current_level + 1)

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

function loadKernel(name)
	local kernel = require( "kernel." .. name )
	graphics.defineEffect( kernel )
end

function freeze_bugs()
	for i = 1, tonumber(_G.ants_quantity) do
		ants[i]:pause()
		transition.pause(ants[i].transitionId)
		if (ants[i].timerId ~= nil) then
			timer.pause(ants[i].timerId)
		end
	end
end

function unfreeze_bugs()
	for i = 1, tonumber(_G.ants_quantity) do
		if (ants[i].fsm.current == 'roaming') then
			ants[i]:play()
		end
		transition.resume(ants[i].transitionId)

		if (ants[i].timerId ~= nil) then
			timer.resume(ants[i].timerId)
		end
	end
end

function pause_game()
	freeze_bugs()

	-- Show pause dialog
	pause_dialog.isVisible = true
	resume_button.isVisible = true
	reload_button.isVisible = true
end

function resume_game()
	unfreeze_bugs()

	-- Hide pause dialog
	pause_dialog.isVisible = false
	resume_button.isVisible = false
	reload_button.isVisible = false
end

function get_initial_random_position(multiplier)
	if (math.random(2) == 2) then
		return display.contentWidth + (75 * multiplier), math.random(25, display.contentHeight - 45), 'right'
	end
	return -(25 * multiplier), math.random(25, display.contentHeight - 45), 'left'
end

function scene:create( event )
	local sceneGroup = self.view

	local options = {
		text = score,
		x = 280 + 120,
		y = 60,
		font = "24358_MAIAN",
		fontSize = 52,
		align = "left"
	 }
	text_score = display.newText( options )
	score_title = display.newText({
		text = 'score',
		x = 140 + 120,
		y = 34,
		font = "24358_MAIAN",
		fontSize = 18,
		align = "left"
	})
	score_title:setFillColor( 164 / 255, 153 / 255, 153 / 255 )

	display.setDefault("magTextureFilter", "nearest")
	display.setDefault("minTextureFilter", "nearest")

	spider_attacking_sound = audio.loadSound( "assets/spider_attack_uagh.wav" )
	ant_splat_sound = audio.loadSound( "assets/splat.wav" )
	rain_drop_sound = audio.loadSound ( "assets/raindrops.wav" )

	-- loading shaders
	loadKernel("filter.spider.add")
	loadKernel("filter.spider.bulge")
	loadKernel("filter.spider.moon")

	-- loading background
	background = display.newImage("grass.png")
	background.x = display.contentWidth / 2
	background.y = display.contentHeight / 2
	-- background.fill.effect = "filter.spider.moon"
	sceneGroup:insert(background)

	-- loading fruits
	for i = 0, 4 do
		fruit_apple = display.newImage('apple.png')
		fruit_apple.x = 48 * i
		fruit_apple.y = math.random(-12, 12) + display.contentWidth / 2
		fruit_apple:rotate(math.random(-45,45))
		fruit_apple.isVisible = false
		fruit_apple:scale(6, 6)
		sceneGroup:insert(fruit_apple)
	end

	-- loading bottom ui
	down_marker = display.newImage('down marker ui.png')
	down_marker.x = display.contentWidth / 2
	down_marker.y = 646
	down_marker.isVisible = false
	sceneGroup:insert(down_marker)

	-- loading ants
	local sequenceData =
	{
		name="walking",
		frames= { 1, 2, 3, 4}, -- frame indexes of animation, in image sheet
	    -- frames= { 1, 2, 3, 5, 6, 7, 9, 4, 8 }, -- frame indexes of animation, in image sheet
	    time = 150,
	    loopCount = 0        -- Optional ; default is 0
	}

	--local sheetData = { width=120, height=148, numFrames=19, sheetContentWidth=480, sheetContentHeight=740 }
	-- local sheetData = { width=522, height=522, numFrames=11, sheetContentWidth=2088, sheetContentHeight=1566 }
	local sheetData = { width=100, height=140, numFrames=4, sheetContentWidth=400, sheetContentHeight=140 }
	local imageSheet = graphics.newImageSheet( "ants_v2.png", sheetData )

	-- local shadows = Shadows:new( 0.9, {0.7,0.7,0.7} )

	-- CREATE A SHADOW CASTER OBJECT
	--local crate1 = shadows:AddShadowCaster({-90,-90, -90,90, 90,90, 90,-90}, "img/crate.png",180,180)
	--crate1.x,crate1.y = 150,0

	-- CREATE A SHADOW CASTER OBJECT
	--local crate2 = shadows:AddShadowCaster({-45,-45, -45,45, 45,45, 45,-45}, "img/crate.png",90,90)
	--crate2.x,crate2.y = -120, -200

	-- CREATE BLUE LIGHT
	-- local light1 = shadows:AddLight( 2, {1,1,1}, 0.9, 4 )
	-- light1.x, light1.y = -100, -100
	-- light1:SetFlicker( true, "damaged", 0.7 )

	for i = 1, tonumber(_G.ants_quantity) do
		local antSplat = display.newImage("splat01.png")
		local ant = display.newSprite( imageSheet, sequenceData )

		ant.splat = antSplat
		ant.splat.x = -1000
		ant.splat.y = -1000		
		ant:scale(1, 1)

		local x, y, orientation = get_initial_random_position(i)
		-- ant.x = math.random(display.contentWidth)
		-- ant.y = math.random(display.contentHeight)
		ant.x = x
		ant.y = y
		ant.orientation = orientation
		-- ant:setFillColor(255, 0, 255, 255)
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
				ants[idx].splat:toBack()

				timer.performWithDelay(math.random(250, 750), function()
		    		ants[idx]:pause()
		    	end)		  		

				local extra = 0
				local ms_since_last_touch = system.getTimer() - combo_counter_delta
				combo_counter_delta = system.getTimer()
				if (ms_since_last_touch < 3000) then
					if (transition_id_combo_animation ~= nil) then
						transition.cancel(transition_id_combo_animation)
						combo_counter_text.isVisible = false
					end
					combo_counter_quantity = combo_counter_quantity + 1
					extra = 10
					combo_counter_text = display.newText( 'COMBO x'..combo_counter_quantity, ants[ant.index].x, ants[ant.index].y, native.newFont("Gill Sans", 32), 32 )
					transition_id_combo_animation = transition.to ( combo_counter_text, { time=1500, y=ants[ant.index].y - 45, onComplete=function() combo_counter_text:removeSelf() end })
				else 
					local scores = display.newText( "+10", ants[idx].x, ants[idx].y, native.newFont("Gill Sans", 32), 32 )
					transition.to ( scores, { time=1500, y=ants[idx].y - 45, onComplete=function() scores:removeSelf() end })

					combo_counter_quantity = 1
				end
	
				score = score + 10 + extra
	
		    	antKilledEvent(idx)
		  	end,
			onroam =    function(self, event, from, to, idx)
				-- Because we need to set a range of possible angles to reach the center
				local angle = math.random(45 + 20, 135 - 20)
				if (ants[idx].orientation == 'right') then
					angle = math.random(225 + 20, 315 - 20)
				end

				local angleX = ants[idx].x + 120 * math.cos( math.rad( angle - 90 ) )
				local angleY = ants[idx].y + 120 * math.sin( math.rad( angle - 90 ) )

				--angleX = (angleX > display.contentWidth) and display.contentWidth or angleX
				angleY = (angleY < 50) and 50 or angleY
				angleY = (angleY > display.contentHeight) and display.contentHeight or angleY

				ants[idx]:play()
				ants[idx].rotation = 0
		    	ants[idx]:rotate(angle)
				ants[idx].transitionId = transition.to ( ants[idx], { time=math.random(200, 750), x=angleX , y=angleY , onComplete=function() 
		        	if (math.random(5) > 3) then
		        		ants[idx].fsm:stay(idx)
		        	else
		        		ants[idx].fsm:roam(idx)
		        	end
				end})
				
				if (ants[idx].orientation == 'right') then
					-- angleX = (angleX < 0) and 0 or angleX
					if (angleX < -100) then
						lives = lives - 1
						save_lives()
						ants[idx]:pause()
						transition.pause(ants[idx].transitionId)
						print('Me pase de la raya')
					end
				end
				if (ants[idx].orientation == 'left') then
					-- angleX = (angleX < 0) and 0 or angleX
					if (angleX > display.contentWidth + 100) then
						lives = lives - 1
						save_lives()
						ants[idx]:pause()
						transition.pause(ants[idx].transitionId)
						print('Me pase de la raya')
					end
				end
			end,
		    onidle =    function(self, event, from, to, idx)
		    	ants[idx]:pause()

		    	ants[idx].timerId = timer.performWithDelay(math.random(1500, 5000), function()
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
					end })

					ants[idx]:toFront()	    			
	    		end)
			end
		  }
		})
		ant.index = table.getn(ants) + 1
		ant:addEventListener("touch", function(event)
		  if(event.phase == "ended") then
			ant.fsm:die(ant.index)
			
		    save_score()
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
	local imageSheet = graphics.newImageSheet( "spider_crawl_6pixel.png", sheetData )

	for i = 1, tonumber(_G.spiders_quantity) do
		local spider = display.newSprite( imageSheet, sequenceData )

		spider:scale(1, 1)
		spider.x = display.contentWidth / 2
		spider.y = display.contentHeight / 2
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

				local scores = display.newText( "+3", spiders[idx].x, spiders[idx].y, native.newFont("Gill Sans", 32), 32 )
				transition.to ( scores, { time=1500, y=spiders[idx].y - 45, onComplete=function() scores:removeSelf() end })
				if (spiders[idx].antAimed ~= nil and spiders[idx].aimCircle ~= nil) then
					spiders[idx].antAimed = nil
					spiders[idx].aimCircle:removeSelf()
					spiders[idx].aimCircle = nil
				end	

				score = score + 3
				save_score()

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
						spider.aimCircle = display.newCircle(ants[nearbyAnt.index].x, ants[nearbyAnt.index].y, 25)
						spider.aimCircle:setFillColor(0,0,0,0)
						spider.aimCircle.strokeWidth = 12
						spider.aimCircle:setStrokeColor( 233 / 255, 38 / 255, 52 / 255 )
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
				if (_G.allow_scare_jump == true) then
					audio.play( spider_attacking_sound )
				end

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
						if (_G.allow_scare_jump == true) then
							transition.scaleTo( spiders[idx], { xScale=20, yScale=20, time=250, transition=easing.inExpo } )		    
							transition.to( spiders[idx], { y=spiders[idx].y + 250, time=150, transition=easing.inExpo, onComplete=function(event)
								timer.performWithDelay(1000, function()
									showRestartWindow()
								end)
							end } )
						else 
							showRestartWindow()
						end
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

	-- local rect1 = display.newRect(display.contentWidth, 0, display.contentWidth, display.contentHeight * 2)
	-- local rect2 = display.newRect(0, 0, display.contentWidth, display.contentHeight * 2)

	-- rect1:toFront(); rect2:toFront()
	
	-- local colorTable = { 0, 0, 1, 0.3 }
	-- rect1:setFillColor( unpack(colorTable) )
	-- rect1:addEventListener("touch", function(event)
	-- 	score = score + 100
	-- 	save_score()
	-- end)
	-- sceneGroup:insert(rect1)
	-- local colorTable = { 1, 0, 0, 0.3 }
	-- rect2:setFillColor( unpack(colorTable) )
	-- rect2:addEventListener("touch", function(event)
	-- 	score = score + 100
	-- 	save_score()
	-- end)
	-- sceneGroup:insert(rect2)

	-- Creating pause UI
	local pause_button = display.newImage('pause button.png')
	pause_button.x = 25 * 3
	pause_button.y = 37 * 2
	pause_button:addEventListener("touch", function(event)
		if (event.phase == "ended") then
			pause_game()
		end
	end)
	sceneGroup:insert(pause_button)
	
	-- Creating score UI
	local score_ui = display.newImage('score ui.png')
	score_ui.x = 100 * 3
	score_ui.y = 37 * 2
	sceneGroup:insert(score_ui)

	-- Creating lives UI
	local lives_ui = display.newImage('lives ui.png')
	lives_ui.x = 1133
	lives_ui.y = 37 * 2
	sceneGroup:insert(lives_ui)

	-- Creating tutorial UI
	local tutorial_ui = display.newImage('tutorial ui.png')
	tutorial_ui.x = 548
	tutorial_ui.y = 590
	sceneGroup:insert(tutorial_ui) 

	-- Creating pause dialog
	pause_dialog = display.newImage('pause dialog.png')
	pause_dialog.x = display.contentWidth / 2
	pause_dialog.y = 350
	pause_dialog.isVisible = false
	sceneGroup:insert(pause_dialog) 
	
	-- Creating resume button
	resume_button = display.newImage('resume button.png')
	resume_button.x = display.contentWidth / 2 - 100
	resume_button.y = 385
	resume_button.isVisible = false
	resume_button:addEventListener("touch", function(event)
		if (event.phase == "ended") then
			resume_game()
		end
	end)
	sceneGroup:insert(resume_button) 

	-- Creating reload button
	reload_button = display.newImage('reload button.png')
	reload_button.x = display.contentWidth / 2 + 100
	reload_button.y = 385
	reload_button.isVisible = false
	reload_button:addEventListener("touch", function(event)
		composer.removeScene("game")
        composer.gotoScene("restart")
	end)
	sceneGroup:insert(reload_button) 
	
	local texts_tutorial = {}
	texts_tutorial[0] = "Don't touch the spider..!                Even when she tries to eat!"
	texts_tutorial[1] = "The Spider can help you killing the ants!"
	text_tutorial = display.newText({
		text = texts_tutorial[1],
		x = 375,
		y = 620,
		width = 625,
		font = "24358_MAIAN",
		fontSize = 36,
		align = "left"
	})
	text_tutorial:rotate(-7)
	sceneGroup:insert(text_tutorial)

	-- Creating wave UI
	local wave_ui = display.newImage('wave ui.png')
	wave_ui.x = 1124
	wave_ui.y = 355
	sceneGroup:insert(wave_ui)

	text_level = display.newText({
		text = 'LEVEL',
		x = 1075,
		y = 368,
		font = "24358_MAIAN",
		fontSize = 32,
		align = "left"
	})
	sceneGroup:insert(text_level)

	text_level_number = display.newText({
		text = string.format("%02d", _G.current_level),
		x = 1116,
		y = 396,
		font = "24358_MAIAN",
		fontSize = 32,
		align = "left"
	})
	text_level_number:setFillColor(unpack({ 212 / 255, 241 / 255, 25 / 255, 1 }))
	sceneGroup:insert(text_level_number)

	-- Creating hearth UI
	hearth_ui_1 = display.newImage('hearth.png')
	hearth_ui_1.x = 1133 - 56
	hearth_ui_1.y = 37 * 2
	sceneGroup:insert(hearth_ui_1)
	hearth_ui_2 = display.newImage('hearth.png')
	hearth_ui_2.x = 1133
	hearth_ui_2.y = 37 * 2
	sceneGroup:insert(hearth_ui_2)
	hearth_ui_3 = display.newImage('hearth.png')
	hearth_ui_3.x = 1133 + 56
	hearth_ui_3.y = 37 * 2
	sceneGroup:insert(hearth_ui_3)

	freeze_bugs()

	timer.performWithDelay(1000, function() 
		transition.to ( wave_ui, { time=500, x=1124+500, transition=easing.inBack, onComplete=function()  end })
		transition.to ( text_level, { time=750, x=1075+500, transition=easing.inBack, onComplete=function()  end })
		transition.to ( text_level_number, { time=750, x=1116+500, transition=easing.inBack, onComplete=function()  end })
	end)

	timer.performWithDelay(2500, function() 
		transition.to ( tutorial_ui, { time=300, y=590+500, transition=easing.inQuad, onComplete=function()  end })
		transition.to ( text_tutorial, { time=300, y=620+500, transition=easing.inQuad, onComplete=function()  end })

		unfreeze_bugs()
	end)

end

function scene:enterFrame( event )
	-- print(system.getTimer())
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
Runtime:addEventListener("enterFrame", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
