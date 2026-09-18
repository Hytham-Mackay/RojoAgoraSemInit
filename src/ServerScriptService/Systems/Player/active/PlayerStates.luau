local PlayerStates = {}

local DASH_DURATION = 0.2
local DASH_DISTANCE = 25

local COOLDOWN_DURATION = 1.5

function PlayerStates.Create(player, manager)
	return {
		{
			Name = "Normal",
			Duration = 0,
		},
		{
			Name = "Dashing",
			Duration = DASH_DURATION,
			Enter = function(old_state)
				return old_state == "Normal"
			end,
			Started = function()
				manager:SetInvulnerable(true)
				manager:ApplyDashImpulse(DASH_DISTANCE, DASH_DURATION)
			end,
			Completed = function()
				manager:SetInvulnerable(false)
				manager:ClearDashImpulse()
				return "Cooldown"
			end,
		},
		{
			Name = "Cooldown",
			Duration = COOLDOWN_DURATION,
			Completed = function()
				return "Normal"
			end,
		},
	}
end

return PlayerStates
