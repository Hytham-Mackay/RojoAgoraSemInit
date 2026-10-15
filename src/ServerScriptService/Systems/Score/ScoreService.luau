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

	local throwerTeam = TeamManager.GetTeam(thrower)
	local targetTeam = TeamManager.GetTeam(target)

	if not throwerTeam or not targetTeam then
		return -- alguém fora de time não entra na pontuação
	end

	if throwerTeam == targetTeam then
		print("[ScoreService] Acerto no próprio time: " .. thrower.Name .. " acertou " .. target.Name)
		return -- acerto no próprio time não conta
	end

	ScoreService.Add(thrower, 15, "acerto")
end

local POINTS_PICKUP = 10

Network.OnBindableEvent("BallPickedUp"):Connect(function(player: Player)
	ScoreService.Add(player, POINTS_PICKUP, "pegou a bola")
end)

Network.OnBindableEvent("BallHit"):Connect(function(thrower: Player, target: Player)
	ScoreService.OnBallHit(thrower, target)
end)

-- Estado atual do placar, para quem entra depois da partida começar.
Network.OnServerInvoke("GetScores", function(_player: Player)
	return ScoreManager.GetAll()
end)

return ScoreService
