local composer = require "composer"

io.output():setvbuf('no')

composer.setVariable("spiders_quantity", 1)
composer.setVariable("ants_quantity", 5)
composer.setVariable("score", 0)

composer.gotoScene("mainmenu")