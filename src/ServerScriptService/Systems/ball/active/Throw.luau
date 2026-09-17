local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage:WaitForChild("Network"))

local Throw = {}

function Throw:Execute(manager, player, chargeTime, target)
	if not manager:CanThrow(player) then
		return false
	end
	manager:ThrowSuccess(player, chargeTime, target)
	return true  
end

return Throw
