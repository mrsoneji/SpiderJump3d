local composer = require "composer"

-- Removes status bar on iOS
-- https://docs.coronalabs.com/api/library/display/setStatusBar.html
display.setStatusBar( display.HiddenStatusBar ) 
-- Removes bottom bar on Android 
if system.getInfo( "androidApiLevel" ) and system.getInfo( "androidApiLevel" ) < 19 then
    native.setProperty( "androidSystemUiVisibility", "lowProfile" )
else
    native.setProperty( "androidSystemUiVisibility", "immersiveSticky" ) 
end

composer.setVariable("spiders_quantity", 1)
composer.setVariable("ants_quantity", 10)
composer.setVariable("current_level", 1)

composer.setVariable("allow_scare_jump", false)

composer.setVariable("score", 0)

composer.gotoScene("game")