local ScoreManager = require(script.Parent.ScoreManager)

local ScoreService = {}

function ScoreService.Add(player, amount, reason)
	local duplaID = player:GetAttribute("duplaID")

	if not duplaID then
		return
	end

	ScoreManager.Add(duplaID, amount, reason)
end

return ScoreService
