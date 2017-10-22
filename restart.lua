

local composer = require "composer"
local scene = composer.newScene()

function scene:create( event )

end

function scene:show( event )
composer.gotoScene("game")
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