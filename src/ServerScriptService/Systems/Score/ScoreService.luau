-- Camada que liga Score ao sistema de Times.
-- Busca o time do jogador via TeamManager antes de somar pontos.

local TeamManager = require(script.Parent.Parent.Team.TeamManager)
local ScoreManager = require(script.Parent.ScoreManager)

local ScoreService = {}

function ScoreService.Add(player: Player, amount: number, reason: string?)
	local teamId = TeamManager.GetTeam(player)

	if not teamId then
		warn("[ScoreService] Jogador " .. player.Name .. " não está em nenhum time — pontos ignorados")
		return
	end

	ScoreManager.Add(teamId, amount, reason)
end

return ScoreService
