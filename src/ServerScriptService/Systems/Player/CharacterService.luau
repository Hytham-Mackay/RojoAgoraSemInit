-- CharacterService (ModuleScript, servidor)
local Players = game:GetService("Players")

local CharacterService = {}

local function setupCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff

	local healthScript = character:FindFirstChild("Health")
	if healthScript then
		healthScript:Destroy()
	end
end

local function setupPlayer(player)
	player.CharacterAdded:Connect(setupCharacter)
	if player.Character then
		setupCharacter(player.Character)
	end
end

function CharacterService.Init()
	Players.PlayerAdded:Connect(setupPlayer)
	for _, player in Players:GetPlayers() do
		setupPlayer(player)
	end
end

return CharacterService
