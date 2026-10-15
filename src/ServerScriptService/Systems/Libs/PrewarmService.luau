local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage:WaitForChild("Network"))

local PrewarmService = {}

function PrewarmService:Start()
	Network.Prewarm({
		remoteEvents = { "ScoreChanged" },
		remoteFunctions = { "GetScores" },
		bindableEvents = { "BallHit", "BallPickedUp", "ValidHit" },
	})
end

return PrewarmService
