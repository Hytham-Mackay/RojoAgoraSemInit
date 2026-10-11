local ScoreManager = {}

local scores = {}

function ScoreManager.Get(teamId: string): number
	return scores[teamId] or 0
end

function ScoreManager.Add(teamId: string, amount: number, reason: string?)
	scores[teamId] = ScoreManager.Get(teamId) + amount
	print(
		"[ScoreManager] "
			.. teamId
			.. " +"
			.. amount
			.. " ("
			.. (reason or "sem motivo")
			.. ") → Total: "
			.. scores[teamId]
	)
end

-- Devolve uma CÓPIA: quem recebe não consegue alterar o estado interno.
function ScoreManager.GetAll(): { [string]: number }
	return table.clone(scores)
end

function ScoreManager.Reset()
	for teamId in pairs(scores) do
		scores[teamId] = 0
	end
end

return ScoreManager
