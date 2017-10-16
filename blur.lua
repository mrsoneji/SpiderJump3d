-- -------------------------------------------------------------------------------
--  blur.lua
-- -------------------------------------------------------------------------------

local _M = {}

local capture

function _M.start()
    capture = display.captureScreen()
    capture.x, capture.y = display.contentCenterX, display.contentCenterY
    capture.fill.effect = "filter.blurGaussian"
    capture.fill.effect.horizontal.blurSize = 25
    capture.fill.effect.vertical.blurSize = 25
end

function _M.stop()
    display.remove(capture)
    capture = nil
end

return _M