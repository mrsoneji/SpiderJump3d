local composer = require "composer"
local scene = composer.newScene()

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

function scene:show( event )
	local sceneGroup = self.view

	if (event.phase == "will") then
        
	end
	if (event.phase == "did") then
		local paint = {
		    type = "gradient",
		    color1 = { 1, 0, 0.4 },
		    color2 = { 1, 0, 0, 0.2 },
		    direction = "up"
		}

		local rect = display.newRect( display.contentCenterX, display.contentCenterY, 600, 700 )
		rect.fill = paint

		local spiderIdle01 = display.newImage("idle01.png")
		spiderIdle01:scale(.5, .5)
		spiderIdle01.x = 100
		spiderIdle01.y = 100
		spiderIdle01.alpha = .15
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