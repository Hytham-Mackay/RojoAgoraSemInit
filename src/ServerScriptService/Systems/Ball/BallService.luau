local ballManager = require(script.Parent.BallManager)
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

	function ballService:ReleaseFromPlayer(player, reason)
		for _, manager in pairs(self.Managers) do
			if manager.Holder == player then
				manager:Release(reason)
			end
		end
	end

	-- Para o fim de rodada: chame ballService:ReleaseAll("RoundEnded") antes do reset
	function ballService:ReleaseAll(reason)
		for _, manager in pairs(self.Managers) do
			manager:Release(reason)
		end
	end

	local function hookPlayer(player)
		local function onCharacter(character)
			local humanoid = character:WaitForChild("Humanoid")
			humanoid.Died:Connect(function()
				self:ReleaseFromPlayer(player, "HolderDied")
			end)
		end

		player.CharacterAdded:Connect(onCharacter)
		if player.Character then
			task.spawn(onCharacter, player.Character)
		end

		-- dispara antes de o personagem ser destruído
		player.CharacterRemoving:Connect(function()
			self:ReleaseFromPlayer(player, "CharacterRemoving")
		end)
	end

	for _, player in ipairs(game.Players:GetPlayers()) do
		hookPlayer(player)
	end
	game.Players.PlayerAdded:Connect(hookPlayer)

	game.Players.PlayerRemoving:Connect(function(player)
		self:ReleaseFromPlayer(player, "HolderLeft")
	end)

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

	Network.SetValidator("ThrowRequest", function(player, target)
		if typeof(target) ~= "Vector3" then
			return false, "target invalido"
		end

		-- NaN nunca é igual a si mesmo
		if target.X ~= target.X or target.Y ~= target.Y or target.Z ~= target.Z then
			return false, "target NaN"
		end

		return true
	end)

	Network.OnServerEvent("ThrowRequest"):Connect(function(player, target)
		local manager = self:GetManagerFromPlayer(player)

		if not manager then
			return -- clique sem bola é normal agora, sem warn
		end

		manager:ThrowRequest(player, target)
	end)
end

return ballService
