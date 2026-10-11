local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage:WaitForChild("Network"))

local Player = Players.LocalPlayer

local GUI_NAME = "scoreFrame"

local ScoreController = {}

-- { [teamId]: number } — estado local, só para exibir
local scores = {}
-- { [teamId]: true } — times que já receberam atualização ao vivo
local updated = {}

-- Cada Frame dentro do ScreenGui "scoreFrame" representa um time:
-- o NOME do Frame é o teamId (TeamA, TeamB), com um Title e um Score dentro.
--
-- O ScreenGui tem ResetOnSpawn ligado, então é recriado a cada respawn.
-- Por isso ele é procurado de novo a cada render, nunca guardado numa variável.
local function render()
	local playerGui = Player:FindFirstChild("PlayerGui")
	local gui = playerGui and playerGui:FindFirstChild(GUI_NAME)
	if not gui then
		return
	end

	for _, frame in ipairs(gui:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local title = frame:FindFirstChild("Title")
		local score = frame:FindFirstChild("Score")

		if title and title:IsA("TextLabel") then
			title.Text = frame.Name
		end
		if score and score:IsA("TextLabel") then
			score.Text = tostring(scores[frame.Name] or 0)
		end
	end
end

function ScoreController:Start()
	-- Tudo que espera o servidor roda em task.spawn: o Loader chama Start()
	-- de cada Controller em sequência, e OnClientEvent/InvokeServer podem
	-- esperar. Sem isso, um problema no placar travaria os outros Controllers.
	task.spawn(function()
		-- respawn recria o GUI: desenha de novo com o que já sabemos
		local playerGui = Player:WaitForChild("PlayerGui")
		playerGui.ChildAdded:Connect(function(child)
			if child.Name == GUI_NAME then
				render()
			end
		end)

		render()

		-- atualizações ao vivo (conecta ANTES de pedir o snapshot)
		Network.OnClientEvent("ScoreChanged"):Connect(function(teamId: string, total: number)
			scores[teamId] = total
			updated[teamId] = true
			render()
		end)

		-- estado atual, para quem entrou no meio da partida
		local snapshot = Network.InvokeServer("GetScores")

		for teamId, total in pairs(snapshot) do
			if not updated[teamId] then
				scores[teamId] = total
			end
		end

		render()
	end)
end

return ScoreController
