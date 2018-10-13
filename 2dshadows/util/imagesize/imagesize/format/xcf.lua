-- plugin helper --
if devilsquid == nil then
    devilsquid = {}
    if devilsquid.requirepath == nil then devilsquid.requirepath = "devilsquid." end
    if devilsquid.filepath == nil then devilsquid.filepath = "devilsquid/" end
end
-------------------

local Util = require ( devilsquid.requirepath .. "util.imagesize.imagesize.util" )

local MIME_TYPE=  "application/x-xcf"

-- Based on the draft specification here:
--    http://svn.gnome.org/viewvc/gimp/trunk/devel-docs/xcf.txt?view=markup
local function size (stream, options)
    local length = 22
    local buf = stream:read(length)
    if not buf or buf:len() ~= length then
        return nil, nil, "XCF file header incomplete"
    end

    return Util.get_uint32_be(buf, 15), Util.get_uint32_be(buf, 19), MIME_TYPE
end

return size
-- vi:ts=4 sw=4 expandtab
