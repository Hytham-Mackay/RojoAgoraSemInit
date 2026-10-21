local Players = game:GetService("Players")

local CharacterService = {}

local function setupCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff

	-- O Health padrão (regen) pode entrar no personagem um instante depois do spawn,
	-- então espera um pouco em vez de checar só uma vez.
	local healthScript = character:WaitForChild("Health", 3)
	if healthScript then
		healthScript:Destroy()
	end
end

local function setupPlayer(player)
	player.CharacterAdded:Connect(setupCharacter)
	if player.Character then
		task.spawn(setupCharacter, player.Character)
	end
end

function CharacterService:Start()
	Players.PlayerAdded:Connect(setupPlayer)
	for _, player in Players:GetPlayers() do
		setupPlayer(player)
	end
end

return CharacterService
