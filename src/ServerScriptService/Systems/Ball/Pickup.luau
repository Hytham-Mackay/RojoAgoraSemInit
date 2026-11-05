local Pickup = {}

function Pickup:Execute(manager, player)
	local ok, reason = manager:CanPickup(player)
	if not ok then
		return false, reason
	end

	return manager:PickupSuccess(player)
end

return Pickup
