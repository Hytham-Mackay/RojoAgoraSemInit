local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local cameraController = {}

function cameraController:SetupCharacter(character)
	self.root = character:WaitForChild("HumanoidRootPart")
	self.camera = workspace.CurrentCamera
	self.camera.CameraType = Enum.CameraType.Scriptable
	self.camPosition = Vector3.new(0,25,40)
end

function cameraController:Start()
	

	local player = Players.LocalPlayer
	print("LocalPlayer:", Players.LocalPlayer)
	

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

		local position = self.root.Position + self.camPosition

		self.camera.CFrame = CFrame.lookAt(
			position,
			self.root.Position
		)
	end)
end

return cameraController