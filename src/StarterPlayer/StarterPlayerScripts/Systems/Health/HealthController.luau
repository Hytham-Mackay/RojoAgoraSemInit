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
	-- Checage para cancelar caso haja um novo tween
	if self.Bar then
		if self.BarTween then
			self.BarTween:Cancel()
		end
		self.BarTween = TweenService:Create(self.Bar, BAR_TWEEN_INFO, {
			Size = UDim2.fromScale(percentage, 1),
		})
		self.BarTween:Play()
	end

	-- Barra de dano (efeito de rastro suave ao perder vida, hoje eu to potente)
	if self.DamageBar then
		self.damageVersion = (self.damageVersion or 0) + 1
		local version = self.damageVersion

		task.delay(0.2, function()
			-- se chegou um acerto mais novo nesse intervalo, este delay é descartado
			if version ~= self.damageVersion then
				return
			end
			if not (self.DamageBar and self.DamageBar.Parent) then
				return
			end

			if self.damageTween then
				self.damageTween:Cancel()
			end
			self.damageTween = TweenService:Create(self.DamageBar, DAMAGE_TWEEN_INFO, {
				Size = UDim2.fromScale(percentage, 1),
			})
			self.damageTween:Play()
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

	if self.barTween then
		self.barTween:Cancel()
		self.barTween = nil
	end
	if self.damageTween then
		self.damageTween:Cancel()
		self.damageTween = nil
	end
	self.damageVersion = (self.damageVersion or 0) + 1 -- invalida delays antigos, sem zerar

	-- no respawn as barras começam cheias, sem animar
	if self.Bar then
		self.Bar.Size = UDim2.fromScale(1, 1)
	end
	if self.DamageBar then
		self.DamageBar.Size = UDim2.fromScale(1, 1)
	end

	local humanoid = character:WaitForChild("Humanoid")

	updateHealth(self, humanoid)

	self.healthConn = humanoid.HealthChanged:Connect(function()
		updateHealth(self, humanoid)
	end)

	self.damageVersion = 0
end

function healthController:Start()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)

	self.gui = Player.PlayerGui:WaitForChild("healthGUI")
	self.healthFrame = self.gui:WaitForChild("healthFrame")
	self.Container = self.healthFrame:WaitForChild("Container")
	self.Bar = self.Container:WaitForChild("healthBar")
	self.DamageBar = self.Container:FindFirstChild("damageBar")
	self.DamageBar = self.Container:FindFirstChild("damageBar")

	if self.DamageBar then
		self.DamageBar.BackgroundColor3 = Color3.new(1, 1, 1)
	end
	self.HealthText = self.Container:FindFirstChild("healthText") or self.healthFrame:FindFirstChild("healthText")

	Player.CharacterAdded:Connect(function(character)
		setupCharacter(self, character)
	end)

	if Player.Character then
		setupCharacter(self, Player.Character)
	end
end

return healthController
