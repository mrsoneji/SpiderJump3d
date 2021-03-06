local composer = require "composer"

composer.setVariable("ants_quantity", 5)
composer.setVariable("spiders_quantity", 1)
composer.setVariable("current_level", 1)

composer.setVariable("allow_scare_jump", true)

composer.setVariable("score", 0)

-- https://docs.coronalabs.com/api/library/display/setStatusBar.html
display.setStatusBar( display.HiddenStatusBar ) 
-- Removes bottom bar on Android 
if system.getInfo( "androidApiLevel" ) and system.getInfo( "androidApiLevel" ) < 19 then
    native.setProperty( "androidSystemUiVisibility", "lowProfile" )
else
    native.setProperty( "androidSystemUiVisibility", "immersiveSticky" ) 
end

io.output():setvbuf('no')

composer.gotoScene("mainmenu")