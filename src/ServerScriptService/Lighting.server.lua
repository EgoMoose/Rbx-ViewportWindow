local Lighting = game:GetService("Lighting")

-- These are the suggest properties for a seamless viewport window
local Properties = {
	Ambient = Color3.new(1, 1, 1),
	Brightness = 0,
	ColorShift_Bottom = Color3.new(0, 0, 0),
	ColorShift_Top = Color3.new(0, 0, 0),
	EnvironmentDiffuseScale = 0,
	EnvironmentSpecularScale = 0,
}

for property, value in pairs(Properties) do
	Lighting[property] = value
end