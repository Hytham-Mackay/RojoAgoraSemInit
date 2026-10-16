local ParryConfig = require(script.Parent.Parent.Combat.ParryConfig)

local PlayerStates = {}

function PlayerStates.Create(player, manager)
	return {
		{
			Name = "Normal",
			Started = function()
				print(string.format("[PlayerStates] [%s] Estado -> Normal (Movimento liberado)", player.Name))
				manager:UnlockMovement() -- Cobre toda a saída do parry
			end,
		},
		{
			Name = "ParryStartup",
			From = { "Normal" },
			Duration = ParryConfig.STARTUP,
			Started = function()
				print(string.format("[PlayerStates] [%s] Estado -> ParryStartup (Duração: %.2fs)", player.Name, ParryConfig.STARTUP))
				manager:LockMovement()
			end,
			Completed = function()
				return "ParryActive"
			end,
		},
		{
			Name = "ParryActive",
			From = { "ParryStartup" },
			Duration = ParryConfig.ACTIVE,
			Started = function()
				print(string.format("[PlayerStates] [%s] Estado -> ParryActive (Janela de parry aberta por %.2fs)", player.Name, ParryConfig.ACTIVE))
			end,
			Completed = function()
				return "ParryRecovery"
			end,
		},
		{
			Name = "ParryRecovery",
			From = { "ParryActive" },
			Duration = ParryConfig.RECOVERY,
			Started = function()
				print(string.format("[PlayerStates] [%s] Estado -> ParryRecovery (Recuperação por %.2fs)", player.Name, ParryConfig.RECOVERY))
			end,
			Completed = function()
				return "Normal"
			end,
		},
	}
end

return PlayerStates
