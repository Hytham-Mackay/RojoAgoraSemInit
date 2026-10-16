local PlayerService = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage:WaitForChild("Network"))
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
	self.Managers[player] = PlayerManager.new(player)
end

function PlayerService:RemovePlayer(player)
	local manager = self.Managers[player]
	self.Managers[player] = nil
end

function PlayerService:GetPlayerManager(player)
	return self.Managers[player]
end

function PlayerService.SetupCharacter(player)
	local character = player.Character
	if not character then
		return false
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.Health <= 0 then
		return false
	end

	return true
end

return PlayerService
