local VFXController = {}

local function fetchEffects( fxName: string )
	return VFXController[fxName]
end

local function load( module: ModuleScript )
	local effect = require( module )
	for i, v in pairs( effect ) do
		VFXController[i] = v
	end
	
	effect.getFx = fetchEffects()
end

for i, v in pairs(script.Parent:GetChildren()) do
    if ( v == script ) then continue end
	if ( v:IsA('ModuleScript') ) then
		load(v)
	end
end

return VFXController