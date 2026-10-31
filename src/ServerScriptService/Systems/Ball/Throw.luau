local Throw = {}

function Throw:Execute(manager, player, target)
	if not manager:CanThrow(player) then
		return false
	end

	return manager:ThrowSuccess(player, target)
end

return Throw
