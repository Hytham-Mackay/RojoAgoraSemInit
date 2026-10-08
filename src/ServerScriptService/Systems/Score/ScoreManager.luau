local ScoreManager = {}

local scores = {}

function ScoreManager.Get(teamId: string): number
	return scores[teamId] or 0
end

function ScoreManager.Add(teamId: string, amount: number, reason: string?)
	scores[teamId] = ScoreManager.Get(teamId) + amount
	print("[ScoreManager] " .. teamId .. " +" .. amount .. " (" .. (reason or "sem motivo") .. ") → Total: " .. scores[teamId])
end

function ScoreManager.GetAll(): { [string]: number }
	return scores
end

function ScoreManager.Reset()
	for teamId in pairs(scores) do
		scores[teamId] = 0
	end
end

return ScoreManager
