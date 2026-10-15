local TeamManager = require(script.Parent.Parent.Team.TeamManager)
local ScoreManager = require(script.Parent.ScoreManager)
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

local POINTS_PICKUP = 5
local POINTS_HIT = 15
local POINTS_ELIMINATION = 30

function ScoreService.OnValidHit(hit)
	local points = hit.Killed and POINTS_ELIMINATION or POINTS_HIT
	ScoreService.Add(hit.Thrower, points, hit.Killed and "eliminação" or "acerto")
end

Network.OnBindableEvent("ValidHit"):Connect(function(hit)
	ScoreService.OnValidHit(hit)
end)

Network.OnBindableEvent("BallPickedUp"):Connect(function(player: Player)
	ScoreService.Add(player, POINTS_PICKUP, "pegou a bola")
end)

-- Estado atual do placar, para quem entra depois da partida começar.
Network.OnServerInvoke("GetScores", function(_player: Player)
	return ScoreManager.GetAll()
end)

return ScoreService
