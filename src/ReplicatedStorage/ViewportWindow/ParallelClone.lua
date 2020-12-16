local INVALID_COPY = {
	["Script"] = true,
	["LocalScript"] = true,
	["ModuleScript"] = true,
	["Camera"] = true,
	["Terrain"] = true,
}

local function defaultCopy(child, partner)
	-- do nothing...
end

local function parallelClone(children, copyFunction, parent, lookup, ignore)
	copyFunction = copyFunction or defaultCopy

	for _, child in pairs(children) do
		if not INVALID_COPY[child.ClassName] and not ignore[child] then
			local canCopy = child.Archivable
			child.Archivable = true

			local copy = child:Clone()
			copy:ClearAllChildren()
			copyFunction(child, copy)
			copy.Parent = parent

			parallelClone(child:GetChildren(), copyFunction, copy, lookup)

			lookup[child] = copy
			child.Archivable = canCopy
		end
	end
end

return parallelClone