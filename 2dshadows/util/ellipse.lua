local function newArc(group, x,y,w,h,s,e,rot) -- modification of original code by: rmbsoft (Corona Forums Member)

	local xc,yc,xt,yt,cos,sin = 0,0,0,0,math.cos,math.sin --w/2,h/2,0,0,math.cos,math.sin
	s,e = s or 0, e or 360
	s,e = math.rad(s),math.rad(e)
	w,h = w/2,h/2
	local vertices = {}
 	
	for t=s,e,0.02 do 
		local cx,cy = xc + w*cos(t), yc - h*sin(t)
		table.insert(vertices, cx)
		table.insert(vertices, cy)
	end

	return display.newPolygon( group, 0, 0, vertices )
end
display.newArc = newArc

local function newEllipse(group, x, y, w, h, rot) -- modification of original code by: rmbsoft (Corona Forums Member)
	return newArc(group, x, y, w, h, nil, nil, rot)
end
display.newEllipse = newEllipse

