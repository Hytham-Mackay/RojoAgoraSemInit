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

	Network.SetValidator("DashRequest", function(player, KeyCode)

		if KeyCode ~= Enum.KeyCode.Space then
			return false, "[PlayerService] Key inválida"
		end

		if not self.SetupCharacter(player) then
			return false, "[PlayerService] Tá morto fi, vai dar dash não"
		end

		return true
	end)

	Network.OnServerEvent("DashRequest"):Connect(function(player)

		local manager = self:GetPlayerManager(player)

		if not manager then
			warn("[PlayerService] Manager não encontrado:", player.Name)
			return
		end

		manager:RequestDash()
	end)

	RunService.Heartbeat:Connect(function()
		for _, manager in pairs(self.Managers) do
			manager:Update()
		end
	end)
end

function PlayerService:AddPlayer(player)
	self.Managers[player] = PlayerManager.new(player)
end

function PlayerService:RemovePlayer(player)
	local manager = self.Managers[player]

	if manager then
		manager:ClearDashImpulse()
	end

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