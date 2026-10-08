local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage:WaitForChild("Network"))
local TeamManager = require(script.Parent.TeamManager)
local TeamConfig = require(script.Parent.TeamConfig)

local TeamService = {}

local debounces = {} -- { [Player]: number (tick) }

------------------------------------------------------------------------

-- Cria a pasta e as Parts de seleção de time no Workspace.

local function createSelectParts(): Folder
	local folder = Instance.new("Folder")
	folder.Name = "TeamSelect"
	folder.Parent = workspace

	for teamId, config in pairs(TeamConfig.PARTS) do
		local part = Instance.new("Part")
		part.Name = "Select_" .. teamId
		part.Size = config.Size
		part.Position = config.Position
		part.Color = config.Color
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 0.3
		part.Material = Enum.Material.Neon
		part.Parent = folder

		-- BillboardGui simples pra identificar o time

		local billboard = Instance.new("BillboardGui")
		billboard.Size = UDim2.new(0, 200, 0, 50)
		billboard.StudsOffset = Vector3.new(0, 5, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = part

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = teamId
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextStrokeTransparency = 0.5
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.Parent = billboard
	end

	return folder
end

------------------------------------------------------------------------

-- Extrai o teamId a partir do nome da Part: "Select_TeamA" → "TeamA"

local function getTeamIdFromPart(part: BasePart): string?
	return part.Name:match("^Select_(.+)$")
end

-- Checa debounce por jogador

local function isDebounced(player: Player): boolean
	local last = debounces[player]
	if not last then
		return false
	end
	return (tick() - last) < TeamConfig.DEBOUNCE_TIME
end

------------------------------------------------------------------------

function TeamService:Start()
	local folder = createSelectParts()

	-- Conecta Touched em cada Part de seleção

	for _, part in ipairs(folder:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Touched:Connect(function(hit)
			local character = hit:FindFirstAncestorOfClass("Model")
			if not character then
				return
			end

			local player = Players:GetPlayerFromCharacter(character)
			if not player then
				return
			end

			if isDebounced(player) then
				return
			end
			debounces[player] = tick()

			local teamId = getTeamIdFromPart(part)
			if not teamId then
				return
			end

			local ok, reason = TeamManager.AssignPlayer(player, teamId)

			if ok then
				print("[TeamService] " .. player.Name .. " entrou no " .. teamId)
				Network.FireClient("TeamAssigned", player, teamId)
			else
				warn("[TeamService] Recusado para " .. player.Name .. ": " .. (reason or "desconhecido"))
			end
		end)
	end

	-- Cleanup quando o jogador sai

	Players.PlayerRemoving:Connect(function(player)
		TeamManager.RemovePlayer(player)
		debounces[player] = nil
	end)

	print("[TeamService] Iniciado — " .. #folder:GetChildren() .. " Parts de seleção criadas")
end

return TeamService
