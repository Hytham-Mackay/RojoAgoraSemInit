local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local healthController = {}
local Player = Players.LocalPlayer

local BAR_TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local DAMAGE_TWEEN_INFO = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function updateHealth(self, humanoid)
	local health = math.max(0, humanoid.Health)
	local maxHealth = math.max(1, humanoid.MaxHealth)
	local percentage = math.clamp(health / maxHealth, 0, 1)

	-- Animação suave da barra de vida principal (vermelha)
	if self.Bar then
		TweenService:Create(self.Bar, BAR_TWEEN_INFO, {
			Size = UDim2.fromScale(percentage, 1),
		}):Play()
	end

	-- Barra de dano (efeito de rastro suave ao perder vida, hoje eu to potente)
	if self.DamageBar then
		task.delay(0.2, function()
			if self.DamageBar and self.DamageBar.Parent then
				TweenService:Create(self.DamageBar, DAMAGE_TWEEN_INFO, {
					Size = UDim2.fromScale(percentage, 1),
				}):Play()
			end
		end)
	end

	-- Atualização do texto numérico (ex: 100 / 100)
	if self.HealthText then
		self.HealthText.Text = string.format("%d / %d", math.floor(health), math.floor(maxHealth))
	end
end

local function setupCharacter(self, character)
	if self.healthConn then
		self.healthConn:Disconnect()
		self.healthConn = nil
	end

	local humanoid = character:WaitForChild("Humanoid")

	updateHealth(self, humanoid)

	self.healthConn = humanoid.HealthChanged:Connect(function()
		updateHealth(self, humanoid)
	end)
end

function healthController:Start()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)

	self.gui = Player.PlayerGui:WaitForChild("healthGUI")
	self.healthFrame = self.gui:WaitForChild("healthFrame")
	self.Container = self.healthFrame:WaitForChild("Container")
	self.Bar = self.Container:WaitForChild("healthBar")
	self.DamageBar = self.Container:FindFirstChild("damageBar")
	self.HealthText = self.Container:FindFirstChild("healthText") or self.healthFrame:FindFirstChild("healthText")

	Player.CharacterAdded:Connect(function(character)
		setupCharacter(self, character)
	end)

	if Player.Character then
		setupCharacter(self, Player.Character)
	end
end

return healthController
