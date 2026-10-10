local TeamManager = require(script.Parent.Parent.Team.TeamManager)
local ScoreManager = require(script.Parent.ScoreManager)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage:WaitForChild("Network"))

Network.Prewarm({
	bindableEvents = { "BallHit" },
})

local ScoreService = {}

function ScoreService.Add(player: Player, amount: number, reason: string?)
	local teamId = TeamManager.GetTeam(player)

	if not teamId then
		warn("[ScoreService] Jogador " .. player.Name .. " não está em nenhum time — pontos ignorados")
		return
	end

	ScoreManager.Add(teamId, amount, reason)
end

function ScoreService.OnBallHit(thrower: Player, target: Player)
	if thrower == target then
		return -- auto-acerto não conta
	end

	if thrower.Parent ~= Players then
		return -- o arremessador saiu durante o voo
	end

	ScoreService.Add(thrower, 1, "acerto")
end

Network.OnBindableEvent("BallHit"):Connect(function(thrower: Player, target: Player)
	ScoreService.OnBallHit(thrower, target)
end)

return ScoreService
