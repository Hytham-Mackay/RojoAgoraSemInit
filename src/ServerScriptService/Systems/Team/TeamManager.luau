-- Estado e lógica pura de times. Sem rede, sem instâncias.
-- Quem orquestra é o TeamService.

local TeamConfig = require(script.Parent.TeamConfig)

local TeamManager = {}

-- { [Player]: teamId }

local playerTeams = {}

-- { [teamId]: {Player} }

local teamPlayers = {}

-- Inicializa as tabelas de cada time

for _, teamId in ipairs(TeamConfig.TEAMS) do
	teamPlayers[teamId] = {}
end

------------------------------------------------------------------------

-- Atribui um jogador a um time.
-- Única porta de entrada — valida tudo aqui.
-- Retorna (true) ou (false, motivo).

function TeamManager.AssignPlayer(player: Player, teamId: string): (boolean, string?)
	if playerTeams[player] then
		return false, "Jogador já está em um time"
	end

	if not teamPlayers[teamId] then
		return false, "Time inválido: " .. tostring(teamId)
	end

	if #teamPlayers[teamId] >= TeamConfig.MAX_PLAYERS_PER_TEAM then
		return false, "Time cheio"
	end

	playerTeams[player] = teamId
	table.insert(teamPlayers[teamId], player)

	return true
end

------------------------------------------------------------------------

function TeamManager.GetTeam(player: Player): string?
	return playerTeams[player]
end

function TeamManager.GetPlayers(teamId: string): { Player }
	return teamPlayers[teamId] or {}
end

function TeamManager.IsTeamFull(teamId: string): boolean
	local players = teamPlayers[teamId]
	if not players then
		return true -- time inválido = tratado como "cheio"
	end
	return #players >= TeamConfig.MAX_PLAYERS_PER_TEAM
end

function TeamManager.HasTeam(player: Player): boolean
	return playerTeams[player] ~= nil
end

------------------------------------------------------------------------

-- Cleanup quando o jogador sai do jogo.

function TeamManager.RemovePlayer(player: Player)
	local teamId = playerTeams[player]
	if not teamId then
		return
	end

	playerTeams[player] = nil

	local players = teamPlayers[teamId]
	if players then
		local index = table.find(players, player)
		if index then
			table.remove(players, index)
		end
	end
end

return TeamManager
