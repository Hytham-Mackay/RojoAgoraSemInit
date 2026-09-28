local ScoreManager = {}

local scores = {}

function ScoreManager.Get(duplaID)
	return scores[duplaID] or 0
end

function ScoreManager.Add(duplaID, amount, reason)
	scores[duplaID] = ScoreManager.Get(duplaID) + amount

	-- replicação: atributo numa Instance que os dois jogadores da dupla enxergam
	local holder = workspace.Duplas:FindFirstChild(duplaID)
	if holder then
		holder:SetAttribute("Points", scores[duplaID])
	end
end

return ScoreManager
