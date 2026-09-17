local Pickup = {}
function Pickup:Execute(manager, player)
	
	if not manager:CanPickup(player) then
		return false
	end
	
	manager:PickupSuccess(player)
	
	return true
end

return Pickup
