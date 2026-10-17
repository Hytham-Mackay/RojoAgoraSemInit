local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage:WaitForChild("Network"))

local ParryController = {}
local player = Players.LocalPlayer
local COOLDOWN_FALLBACK = 5

local COLORS = {
	ready = Color3.fromRGB(78, 220, 155),
	cooldown = Color3.fromRGB(255, 177, 74),
	background = Color3.fromRGB(19, 25, 34),
	text = Color3.fromRGB(242, 246, 250),
}

local gui
local label
local fill
local stroke
local version = 0

local function createGui()
	local playerGui = player:WaitForChild("PlayerGui")
	local previous = playerGui:FindFirstChild("parryCooldownGUI")
	if previous then
		previous:Destroy()
	end

	gui = Instance.new("ScreenGui")
	gui.Name = "parryCooldownGUI"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 2
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local panel = Instance.new("Frame")
	panel.Name = "CooldownFrame"
	panel.AnchorPoint = Vector2.new(0, 1)
	panel.Position = UDim2.new(0, 25, 1, -73)
	panel.Size = UDim2.fromOffset(190, 42)
	panel.BackgroundColor3 = COLORS.background
	panel.BackgroundTransparency = 0.12
	panel.BorderSizePixel = 0
	panel.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 9)
	corner.Parent = panel

	stroke = Instance.new("UIStroke")
	stroke.Color = COLORS.ready
	stroke.Thickness = 1.5
	stroke.Transparency = 0.12
	stroke.Parent = panel

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(12, 4)
	title.Size = UDim2.new(1, -24, 0, 17)
	title.Font = Enum.Font.GothamBold
	title.Text = "PARRY  •  BOTÃO DIREITO"
	title.TextColor3 = COLORS.text
	title.TextSize = 11
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = panel

	label = Instance.new("TextLabel")
	label.Name = "Status"
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(12, 20)
	label.Size = UDim2.new(1, -24, 0, 17)
	label.Font = Enum.Font.GothamMedium
	label.Text = string.format("PRONTO  •  %.0fs", COOLDOWN_FALLBACK)
	label.TextColor3 = COLORS.ready
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = panel

	local barBack = Instance.new("Frame")
	barBack.Name = "BarBackground"
	barBack.AnchorPoint = Vector2.new(1, 0.5)
	barBack.Position = UDim2.new(1, -12, 0.5, 0)
	barBack.Size = UDim2.fromOffset(5, 25)
	barBack.BackgroundColor3 = Color3.fromRGB(52, 62, 74)
	barBack.BorderSizePixel = 0
	barBack.Parent = panel

	local backCorner = Instance.new("UICorner")
	backCorner.CornerRadius = UDim.new(1, 0)
	backCorner.Parent = barBack

	fill = Instance.new("Frame")
	fill.Name = "Progress"
	fill.AnchorPoint = Vector2.new(0.5, 1)
	fill.Position = UDim2.new(0.5, 0, 1, 0)
	fill.Size = UDim2.fromScale(1, 0)
	fill.BackgroundColor3 = COLORS.ready
	fill.BorderSizePixel = 0
	fill.Parent = barBack

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill

	gui.Parent = playerGui
end

local function updateCooldown(duration, serverStart)
	version += 1
	local currentVersion = version
	duration = math.max(tonumber(duration) or COOLDOWN_FALLBACK, 0)
	serverStart = tonumber(serverStart) or workspace:GetServerTimeNow()
	local endAt = serverStart + duration

	stroke.Color = COLORS.cooldown
	fill.BackgroundColor3 = COLORS.cooldown
	label.TextColor3 = COLORS.cooldown

	task.spawn(function()
		while currentVersion == version do
			local remaining = math.max(0, endAt - workspace:GetServerTimeNow())
			if remaining <= 0 then
				break
			end

			label.Text = string.format("RECARGANDO  %.1fs", remaining)
			fill.Size = UDim2.fromScale(1, math.clamp(remaining / math.max(duration, 0.001), 0, 1))
			task.wait(0.05)
		end

		if currentVersion ~= version then
			return
		end

		label.Text = "PRONTO"
		label.TextColor3 = COLORS.ready
		stroke.Color = COLORS.ready
		fill.BackgroundColor3 = COLORS.ready
		fill:TweenSize(UDim2.fromScale(1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.16, true)
	end)
end

function ParryController:Start()
	createGui()
	Network.OnClientEvent("ParryCooldown"):Connect(updateCooldown)
end

return ParryController