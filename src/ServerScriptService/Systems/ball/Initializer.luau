local Initializer = {}

function Initializer.init()
	for _, child in ipairs(script.Parent.active:GetChildren()) do
		if child:IsA("ModuleScript") and child.name ~= "Initializer" then
			local loaded = require(child)

			if type(loaded.Start) == "function" then
				loaded:Start()
			end
		end
	end
end
return Initializer
