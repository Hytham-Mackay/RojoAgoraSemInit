local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local healthScript = {}
local Player = Players.LocalPlayer

local function updateHealth(bar,humanoid)

	local percentage = humanoid.Health / humanoid.MaxHealth
	print(bar)
	bar.Size = UDim2.fromScale(percentage, 1)	
end

local function setupCharacter(self,character)

	local humanoid = character:WaitForChild("Humanoid")

	updateHealth(self.Bar, humanoid)

	humanoid.HealthChanged:Connect(function()
		updateHealth(self.Bar, humanoid)
	end)
end

function healthScript:Start()

	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
	self.gui = Player.PlayerGui:WaitForChild("healthGUI")
	self.healthFrame = self.gui.healthFrame
	self.Container = self.healthFrame.Container
	self.Bar = self.Container.healthBar
	
	Player.CharacterAdded:Connect(function(character)
		
		setupCharacter(self, character)
	end)


	if Player.Character then
		setupCharacter(self, Player.Character)
	end
end



return healthScript
