local PlayerStates = {}

function PlayerStates.Create(player, manager)
	return {
		{
			Name = "Normal",
			Duration = 0,
		},
	}
end

return PlayerStates
