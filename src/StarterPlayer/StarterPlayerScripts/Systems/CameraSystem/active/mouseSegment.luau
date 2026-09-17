local players = game:GetService("Players")
local inputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local mouseSegment = {}

function mouseSegment:GetTargetPosition()
	-- Retorna o ultimo MouseHit VALIDO
	return self.LastValidMouseHit
end

function mouseSegment:SetupCharacter(character)
	self.root = character:WaitForChild("HumanoidRootPart")
	self.params.FilterDescendantsInstances = {character}
end

function mouseSegment:Start()
	local player = players.LocalPlayer
	self.camera = workspace.CurrentCamera
	self.params = RaycastParams.new()
	self.params.FilterType = Enum.RaycastFilterType.Exclude

	-- Inicializa com uma posicao segura
	self.LastValidMouseHit = Vector3.new(0, 0, 0)

	if player.Character then
		self:SetupCharacter(player.Character)
	end

	player.CharacterAdded:Connect(function(character)
		self:SetupCharacter(character)
	end)

	RunService.PreRender:Connect(function()
		if not self.root then
			return
		end

		local mousePosition = inputService:GetMouseLocation()
		local ray = self.camera:ScreenPointToRay(mousePosition.X, mousePosition.Y)

		local result = workspace:Raycast(
			ray.Origin,
			ray.Direction * 1000,
			self.params
		)

		if result then
			-- Só atualiza o cache quando tem resultado valido
			self.LastValidMouseHit = result.Position

			local target = Vector3.new(
				result.Position.X,
				self.root.Position.Y,
				result.Position.Z
			)

			self.root.CFrame = CFrame.lookAt(
				self.root.Position,
				target
			)
		end
		-- Se result for nil, mantem o ultimo valor valido em LastValidMouseHit
	end)
end


return mouseSegment

