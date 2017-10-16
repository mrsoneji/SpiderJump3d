-- -------------------------------------------------------------------------------
--  blur.lua
-- -------------------------------------------------------------------------------

local _M = {}

local capture

function _M.startGroup(grp, blur)
    local innerSnapshot = display.newSnapshot(grp.width+blur/2, grp.height+blur/2);
    
    innerSnapshot.canvas:insert(grp);
    innerSnapshot.canvasMode = "discard";
    innerSnapshot.fill.effect = "filter.blurGaussian";
    innerSnapshot.fill.effect.horizontal.blurSize = blur;
    innerSnapshot.fill.effect.vertical.blurSize = blur;
    innerSnapshot:invalidate("canvas");
    
    local outerSnapshot = display.newSnapshot(innerSnapshot.width, innerSnapshot.height);
    outerSnapshot.canvas:insert(innerSnapshot);
    outerSnapshot.canvasMode = "discard";
    outerSnapshot:invalidate("canvas");
    
    return outerSnapshot;
end

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