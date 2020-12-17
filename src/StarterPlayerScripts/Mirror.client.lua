local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ViewportWindow = require(ReplicatedStorage:WaitForChild("ViewportWindow"))
local Maid = require(ReplicatedStorage.ViewportWindow:WaitForChild("Maid"))

local Mirror = workspace.Mirror
local MirrorVPW = ViewportWindow.FromPart(Mirror, Enum.NormalId.Front)
local MirrorCF = MirrorVPW:GetSurface()

local function reflectCFrame(cf, surfaceCF)
	local c = {surfaceCF:ToObjectSpace(cf):GetComponents()}
	local trueReflect = surfaceCF * CFrame.new(
		c[1], c[2], -c[3],
		c[4], c[5], c[6],
		c[7], c[8], c[9],
		-c[10], -c[11], -c[12]
	)
	return CFrame.fromMatrix(trueReflect.Position, -trueReflect.XVector, trueReflect.YVector, trueReflect.ZVector)
end

local function addCharacterToMirror(player)
	local character = player.Character
	local humanoid = character:WaitForChild("Humanoid")
	local matches = MirrorVPW:CloneHierarchyToWorld({character}, {})

	local function update()
		for child, match in pairs(matches) do
			if child:IsA("BasePart") then
				match.CFrame = reflectCFrame(child.CFrame, MirrorCF)
			end
		end
	end

	local maid = Maid.new()

	maid:Mark(RunService.RenderStepped:Connect(update))
	maid:Mark(matches[character])
	maid:Mark(player.CharacterRemoving:Connect(function()
		maid:Sweep()
	end))

	update()
	matches[humanoid].DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

	return maid
end

local function addWorldToMirror()
	local children = {}
	for _, child in pairs(workspace:GetChildren()) do
		if not Players:GetPlayerFromCharacter(child) then
			table.insert(children, child)
		end
	end

	local world = MirrorVPW:CloneHierarchyToWorld(children, {
		[Mirror] = true,
	})

	for child, match in pairs(world) do
		if child:IsA("BasePart") then
			match.CFrame = reflectCFrame(child.CFrame, MirrorCF)
		end
	end
end

for _, player in pairs(Players:GetPlayers()) do
	if player.Character then
		addCharacterToMirror(player)
	end
	player.CharacterAdded:Connect(function(character)
		wait(1)
		addCharacterToMirror(player)
	end)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		addCharacterToMirror(player)
	end)
end)

MirrorVPW.Maid:Mark(RunService.RenderStepped:Connect(function(dt)
	MirrorVPW:Render()
end))

addWorldToMirror()
MirrorVPW:AddSkybox(Lighting.Sky)

print("Running!")