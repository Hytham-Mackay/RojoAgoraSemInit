local TeamManager = require(script.Parent.Parent.Team.TeamManager)
local ScoreManager = require(script.Parent.ScoreManager)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage:WaitForChild("Network"))

local ScoreService = {}

function ScoreService.Add(player: Player, amount: number, reason: string?)
	local teamId = TeamManager.GetTeam(player)

	if not teamId then
		warn("[ScoreService] Jogador " .. player.Name .. " não está em nenhum time — pontos ignorados")
		return
	end

	ScoreManager.Add(teamId, amount, reason)

	-- avisa todos os clientes do novo total do time
	Network.FireAllClients("ScoreChanged", teamId, ScoreManager.Get(teamId))
end

-- Se um dia usarem Reset, o placar dos clientes precisa ser avisado também.
function ScoreService.Reset()
	ScoreManager.Reset()

	for teamId, total in pairs(ScoreManager.GetAll()) do
		Network.FireAllClients("ScoreChanged", teamId, total)
	end
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

-- Estado atual do placar, para quem entra depois da partida começar.
Network.OnServerInvoke("GetScores", function(_player: Player)
	return ScoreManager.GetAll()
end)

return ScoreService
