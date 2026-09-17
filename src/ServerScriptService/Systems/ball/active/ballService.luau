local ballManager = require(script.Parent.ballManager)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Network = require(ReplicatedStorage:WaitForChild("Network"))

local ballService = {}

ballService.Managers = {}


function ballService:Start()
	
	function ballService:GetManagerFromPlayer(player)
		for _, manager in pairs(self.Managers) do
			if manager.Holder == player then
				return manager
			end
		end

		return nil
	end

	for _, ball in ipairs(workspace.Balls:GetChildren()) do

		local manager = ballManager.new(ball)

		self.Managers[ball] = manager

	end


	RunService.Heartbeat:Connect(function(dt)
		for _, manager in pairs(self.Managers) do
			manager:updateState(dt)

		end
	end)
	
	function ballService:GetClosestPlayer(position)
		local closest = nil
		local minDist = math.huge
		for _, player in ipairs(game.Players:GetPlayers()) do
			local char = player.Character
			if char then
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if hrp then
					local dist = (hrp.Position - position).Magnitude
					if dist < minDist then
						minDist = dist
						closest = player
					end
				end
			end
		end
		return closest
	end

	Network.SetValidator("ThrowRequest", function(player, chargeStart, target)

		if typeof(chargeStart) ~= "number" then
			return false, "chargeStart invalido"
		end

		if typeof(target) ~= "Vector3" then
			return false, "target invalido"
		end

		local chargeTime = tick() - chargeStart

		if chargeTime < 0 then
			return false, "chargeStart futuro"
		end

		return true
	end)


	Network.OnServerEvent("ThrowRequest"):Connect(function(player, chargeStart, target)
		
		local manager = self:GetManagerFromPlayer(player)
		
		if not manager then
			warn("[ballService] " .. player.Name .. " tentou arremessar sem segurar bola.")
			return
		end

		local chargeTime = math.max(0, tick() - chargeStart)

		manager:ThrowRequest(player, chargeTime, target)

	end)
	

end


return ballService
