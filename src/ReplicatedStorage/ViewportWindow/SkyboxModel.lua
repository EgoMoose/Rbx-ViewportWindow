local SIDES = {
	["SkyboxBk"] = Enum.NormalId.Back,
	["SkyboxFt"] = Enum.NormalId.Front,
	["SkyboxLf"] = Enum.NormalId.Left,
	["SkyboxRt"] = Enum.NormalId.Right
}

local SIDE_PART = Instance.new("Part")
SIDE_PART.CanCollide = false
SIDE_PART.Anchored = true
SIDE_PART.Transparency = 1
SIDE_PART.Size = Vector3.new(1, 1, 1) 

local MESH = Instance.new("BlockMesh")
MESH.Scale = Vector3.new(10000, 10000, 10000)
MESH.Parent = SIDE_PART

local FLIP_X = CFrame.new(0, 0, 0, 1, 0, 0, 0, -1, 0, 0, 0, 1)
local SIDE_CFRAME = FLIP_X * CFrame.fromEulerAnglesXYZ(math.pi, math.pi, 0)
local TOP_CFRAME = FLIP_X * CFrame.fromEulerAnglesXYZ(math.pi, math.pi/2, 0)
local BOTTOM_CFRAME = FLIP_X * CFrame.fromEulerAnglesXYZ(math.pi, -math.pi/2, 0)

return function(skybox)
	local model = Instance.new("Model")
	local side = SIDE_PART:Clone()
	local top = SIDE_PART:Clone()
	local bottom = SIDE_PART:Clone()

	for property, enum in pairs(SIDES) do
		local decal = Instance.new("Decal")
		decal.Texture = skybox[property]
		decal.Face = enum
		decal.Parent = side
	end

	local decal = Instance.new("Decal")
	decal.Texture = skybox.SkyboxUp
	decal.Face = Enum.NormalId.Top
	decal.Parent = top
	
	local decal = Instance.new("Decal")
	decal.Texture = skybox.SkyboxDn
	decal.Face = Enum.NormalId.Bottom
	decal.Parent = bottom

	side.CFrame = SIDE_CFRAME
	top.CFrame = TOP_CFRAME
	bottom.CFrame = BOTTOM_CFRAME

	side.Parent = model
	top.Parent = model
	bottom.Parent = model
	model.Name = "SkyboxModel"

	return model
end