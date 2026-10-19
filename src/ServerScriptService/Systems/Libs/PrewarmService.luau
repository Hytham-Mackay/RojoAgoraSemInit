local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage:WaitForChild("Network"))

local PrewarmService = {}

function PrewarmService:Start()
	Network.Prewarm({
		remoteEvents = { "ScoreChanged", "ParryCooldown", "ParryRequest" },
		remoteFunctions = { "GetScores" },
		bindableEvents = { "BallHit", "BallPickedUp", "ValidHit", "BallParried" },
	})
end

return PrewarmService
