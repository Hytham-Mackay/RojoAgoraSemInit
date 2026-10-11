local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage:WaitForChild("Network"))

PrewarmService = {}

function PrewarmService:Start()
	Network.Prewarm({
		bindableEvents = { "BallHit" },
	})
end

return PrewarmService
