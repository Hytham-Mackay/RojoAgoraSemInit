local PlayerService = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PlayerManager = require(script.Parent.PlayerManager)

PlayerService.Managers = {}

function PlayerService:Start()
	for _, player in ipairs(Players:GetPlayers()) do
		self:AddPlayer(player)
	end

	Players.PlayerAdded:Connect(function(player)
		self:AddPlayer(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:RemovePlayer(player)
	end)

	RunService.Heartbeat:Connect(function(dt)
		for _, manager in pairs(self.Managers) do
			manager:Update(dt)
		end
	end)
end

function PlayerService:AddPlayer(player)
	local manager = PlayerManager.new(player)
	self.Managers[player] = manager

	local function onCharacter(character)
		local humanoid = character:WaitForChild("Humanoid")
		manager:Reset() -- aplica a velocidade base do manager

		humanoid.Died:Connect(function()
			manager:Reset()
		end)
	end

	player.CharacterAdded:Connect(onCharacter)
	if player.Character then
		task.spawn(onCharacter, player.Character)
	end
end

function PlayerService:RemovePlayer(player)
	self.Managers[player] = nil
end

function PlayerService:GetPlayerManager(player)
	return self.Managers[player]
end

return PlayerService
