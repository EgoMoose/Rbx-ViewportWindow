local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local Maid = require(script:WaitForChild("Maid"))
local SkyboxModel = require(script:WaitForChild("SkyboxModel"))

local UNIT_Y = Vector3.new(0, 1, 0)
local VEC_XZ = Vector3.new(1, 0, 1)
local VEC_YZ = Vector3.new(0, 1, 1)

local PI2 = math.pi / 2
local Y_SPIN = CFrame.fromEulerAnglesXYZ(0, math.pi, 0)

local PARENT_FOLDER = Instance.new("Folder")
PARENT_FOLDER.Name = "ViewportWindows"
PARENT_FOLDER.Parent = Players.LocalPlayer.PlayerGui

local VPF = Instance.new("ViewportFrame")
VPF.LightColor = Color3.new(0, 0, 0)
VPF.Size = UDim2.new(1, 0, 1, 0)
VPF.Position = UDim2.new(0, 0, 0, 0)
VPF.AnchorPoint = Vector2.new(0, 0)
VPF.BackgroundTransparency = 1
VPF.LightDirection = -Lighting:GetSunDirection()
VPF.Ambient = Lighting.Ambient

-- Class

local ViewportWindow = {}
ViewportWindow.__index = ViewportWindow
ViewportWindow.ClassName = "ViewportWindow"

-- Public Constructors

function ViewportWindow.new(surfaceGui)
	local self = setmetatable({}, ViewportWindow)

	self.Maid = Maid.new()

	self.SurfaceGui = surfaceGui

	self.Camera = Instance.new("Camera")
	self.Camera.Parent = surfaceGui

	self.WorldFrame = VPF:Clone()
	self.WorldFrame.Name = "WorldFrame"
	self.WorldFrame.ZIndex = 2
	self.WorldFrame.Parent = surfaceGui
	self.WorldFrame.CurrentCamera = self.Camera

	self.SkyboxFrame = VPF:Clone()
	self.SkyboxFrame.Name = "SkyboxFrame"
	self.SkyboxFrame.ZIndex = 1
	self.SkyboxFrame.Parent = surfaceGui
	self.SkyboxFrame.CurrentCamera = self.Camera
	
	return self
end

function ViewportWindow.FromPart(part, normalId)
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Face = normalId
	surfaceGui.CanvasSize = Vector2.new(1024, 1024)
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
	surfaceGui.Adornee = part
	surfaceGui.ClipsDescendants = true
	surfaceGui.Parent = PARENT_FOLDER

	return ViewportWindow.new(surfaceGui)
end

-- Public Methods

function ViewportWindow:AddSkybox(skybox)
	if skybox and skybox:IsA("Sky") then
		self.SkyboxFrame:ClearAllChildren()
		SkyboxModel(skybox).Parent = self.SkyboxFrame
	end
end

function ViewportWindow:GetSurface()
	local part = self.SurfaceGui.Adornee
	local partCF, partSize = part.CFrame, part.Size
	
	local back = -Vector3.FromNormalId(self.SurfaceGui.Face)
	local axis = (math.abs(back.y) == 1) and Vector3.new(back.y, 0, 0) or UNIT_Y
	local right = CFrame.fromAxisAngle(axis, PI2) * back
	local top = back:Cross(right).Unit
	
	local cf = partCF * CFrame.fromMatrix(-back*partSize/2, right, top, back)
	local size = Vector3.new((partSize * right).Magnitude, (partSize * top).Magnitude, (partSize * back).Magnitude)

	return cf, size
end

function ViewportWindow:Render(cameraCFrame, surfaceCFrame, surfaceSize)
	local camera = workspace.CurrentCamera

	cameraCFrame = cameraCFrame or camera.CFrame
	if not (surfaceCFrame and surfaceSize) then
		surfaceCFrame, surfaceSize = self:GetSurface()
	end

	local xCross = surfaceCFrame.YVector:Cross(cameraCFrame.ZVector)
	local xVector = xCross:Dot(xCross) > 0 and xCross.Unit or cameraCFrame.XVector
	local levelCameraCFrame = CFrame.fromMatrix(cameraCFrame.Position, xVector, surfaceCFrame.YVector)

	local tc = surfaceCFrame * Vector3.new(0, surfaceSize.y/2, 0)
	local bc = surfaceCFrame * Vector3.new(0, -surfaceSize.y/2, 0)
	local cstc = levelCameraCFrame:PointToObjectSpace(tc)
	local csbc = levelCameraCFrame:PointToObjectSpace(bc)

	local tv = (cstc * VEC_YZ).Unit
	local bv = (csbc * VEC_YZ).Unit
	local alpha = math.sign(tv.y) * math.acos(-tv.z)
	local beta = math.sign(bv.y) * math.acos(-bv.z)

	local fovH = 2 * math.tan(math.rad(camera.FieldOfView / 2))
	local surfaceFovH = math.tan(alpha) - math.tan(beta)
	local fovRatio = surfaceFovH / fovH

	local dv = surfaceCFrame:VectorToObjectSpace(surfaceCFrame.Position - cameraCFrame.Position)
	local dvXZ = (dv * VEC_XZ).Unit
	local dvXY = dv * VEC_YZ

	local dvx = -dvXZ.z
	local camXZ = (surfaceCFrame:VectorToObjectSpace(cameraCFrame.LookVector) * VEC_XZ).Unit
	local scale = camXZ:Dot(dvXZ) / dvx
	local tanArcCos = math.sqrt(1 - dvx*dvx) / dvx

	local w, h = 1, surfaceSize.x / surfaceSize.y
	local dx = math.sign(dv.x*dv.z) * tanArcCos
	local dy = dvXY.y / dvXY.z * h
	local d = math.abs(scale * fovRatio * h)

	local newCFrame = (surfaceCFrame - surfaceCFrame.Position) * Y_SPIN
					* CFrame.new(0, 0, 0, w, 0, 0, 0, h, 0, dx, dy, d)
	
	local max = 0
	local components = {newCFrame:GetComponents()}
	for i = 1, #components do
		max = math.max(max, math.abs(components[i]))
	end

	for i = 1, #components do
		components[i] = components[i] / max
	end

	local scaledCFrame = CFrame.new(unpack(components)) + cameraCFrame.Position

	self.Camera.FieldOfView = camera.FieldOfView
	self.Camera.CFrame = scaledCFrame
end

function ViewportWindow:Destroy()
	self.Maid:Sweep()
end

--

return ViewportWindow