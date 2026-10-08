--!strict
-- Só valores. Nenhuma lógica aqui.

return table.freeze({

	MAX_PLAYERS_PER_TEAM = 2,

	TEAMS = { "TeamA", "TeamB" },

	DEBOUNCE_TIME = 1, -- segundos entre toques válidos

	-- Configuração visual das Parts de seleção (criadas via script)

	PARTS = {
		TeamA = {
			Position = Vector3.new(-15, 3, 0),
			Color = Color3.fromRGB(50, 120, 255), -- Azul
			Size = Vector3.new(6, 8, 1),
		},
		TeamB = {
			Position = Vector3.new(15, 3, 0),
			Color = Color3.fromRGB(255, 60, 60), -- Vermelho
			Size = Vector3.new(6, 8, 1),
		},
	},
})
