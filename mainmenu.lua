local composer = require "composer"
local scene = composer.newScene()

local widget = require( "widget" )

local globalData = require( "globalData" )
local json = require( "json" )
 
globalData.gpgs = nil

local platform = system.getInfo( "platform" )
local environment = system.getInfo( "environment" )

local licensing = require( "licensing" )
 
local function licensingListener( event )
 
    if not ( event.isVerified ) then
        -- Failed to verify app from the Google Play store; print a message
        print( "Pirates!!!" )
    end
end
 
local licensingInit = licensing.init( "google" )
 
if ( licensingInit == true ) then
    licensing.verify( licensingListener )
end

globalData.gpgs = require( "plugin.gpgs" )

local function gpgsInitListener( event )
    if not event.isError then
        if ( event.name == "init" ) then  -- Initialization event
            -- Attempt to log in the user
            globalData.gpgs.login( { userInitiated=true, listener=gpgsInitListener } )
 
        elseif ( event.name == "login" ) then  -- Successful login event
            print( json.prettify(event) )
		end
	else
		for index, data in ipairs(event) do
			print(index)
		
			for key, value in pairs(data) do
				print('\t', key, value)
			end
		end
    end
end

if ( globalData.gpgs ) then
    -- Initialize Google Play Games Services
    globalData.gpgs.init( gpgsInitListener )
end

local function submitScoreListener( event )
    -- Google Play Games Services score submission
    if ( globalData.gpgs ) then
        if not event.isError then
            local isBest = nil
            if ( event.scores["daily"].isNewBest ) then
                isBest = "a daily"
            elseif ( event.scores["weekly"].isNewBest ) then
                isBest = "a weekly"
            elseif ( event.scores["all time"].isNewBest ) then
                isBest = "an all time"
            end
            if isBest then
                -- Congratulate player on a high score
                local message = "You set " .. isBest .. " high score!"
                native.showAlert( "Congratulations", message, { "OK" } )
            else
                -- Encourage the player to do better
                native.showAlert( "Sorry...", "Better luck next time!", { "OK" } )
            end
        end
    end
end

local function submitScore( score )
    if ( globalData.gpgs ) then
        -- Submit a score to Google Play Games Services
        globalData.gpgs.leaderboards.submit(
        {
            leaderboardId = "CgkI46XIg9kOEAIQAA",
            score = score,
            listener = submitScoreListener
        })
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

function load_records()
	-- Path for the file to read
	local path = system.pathForFile( "records", system.DocumentsDirectory )
	 
	-- Open the file handle
	local file, errorString = io.open( path, "r" )
	 
	if not file then
	    -- Error occurred; output the cause
	    print( "File error: " .. errorString )
	else
	    -- Read data from file
	    local contents = file:read( "*a" )
	    -- Output the file contents
	    print( "Contents of " .. path .. "\n" .. contents )
	    -- Close the file handle
	    io.close( file )
	end
	 
	file = nil	
end

function scene:create( event )
	
end

local function handleButtonEvent( event )

    if ( "ended" == event.phase ) then
        composer.gotoScene("game", { effect = "crossFade", time = 333 })
    end
end

local function handleHighScoreEvent( event )
	if ( "ended" == event.phase ) then
	
		if ( globalData.gpgs ) then
			for index, data in ipairs(globalData.gpgs) do
				print(index)
			
				for key, value in pairs(data) do
					print('\t', key, value)
				end
			end
			-- Show a Google Play Games Services leaderboard
			globalData.gpgs.leaderboards.show( "CgkI46XIg9kOEAIQAA" )
		end
    end
end

function scene:show( event )
	local sceneGroup = self.view

	if (event.phase == "will") then
        
	end
	if (event.phase == "did") then
		local sceneGroup = self.view

		local paint = {
		    type = "gradient",
		    color1 = { 1, 0, 0.4 },
		    color2 = { 1, 0, 0, 0.2 },
		    direction = "up"
		}

		local rect = display.newRect( display.contentCenterX, display.contentCenterY, 600, 700 )
		rect.fill = paint

		local spiderIdle01 = display.newImage("idle01.png")
		spiderIdle01:scale(1.8, 1.8)
		spiderIdle01.x = 160
		spiderIdle01.y = 100
		spiderIdle01.alpha = .15

		sceneGroup:insert(rect)
		sceneGroup:insert(spiderIdle01)

		local doneButton = widget.newButton({
			label = "Start",
			onEvent = handleButtonEvent,
			emboss = false,
			-- Properties for a rounded rectangle button
			shape = "roundedRect",
			width = 200,
			height = 32,
			cornerRadius = 2,
			fillColor = { default={1,1,1,1}, over={1,0.1,0.7,0.4} },
			strokeColor = { default={0,0,0}, over={0.8,0.8,1,1} },
			strokeWidth = 4
		})
		doneButton.x = display.contentCenterX
		doneButton.y = display.contentHeight - 90
		sceneGroup:insert( doneButton )

		local highscoreButton = widget.newButton({
			label = "Highscores",
			onEvent = handleHighScoreEvent,
			emboss = false,
			-- Properties for a rounded rectangle button
			shape = "roundedRect",
			width = 200,
			height = 32,
			cornerRadius = 2,
			fillColor = { default={1,1,1,1}, over={1,0.1,0.7,0.4} },
			strokeColor = { default={0,0,0}, over={0.8,0.8,1,1} },
			strokeWidth = 4
		})
		highscoreButton.x = display.contentCenterX
		highscoreButton.y = display.contentHeight - 40
		sceneGroup:insert( highscoreButton )
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