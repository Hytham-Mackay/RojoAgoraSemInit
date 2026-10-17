local _Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage:WaitForChild("Network"))

local PlayerService = require(script.Parent.Parent.Player.PlayerService)
local BallService = require(script.Parent.Parent.Ball.BallService)
local TeamManager = require(script.Parent.Parent.Team.TeamManager)
local ParryConfig = require(script.Parent.ParryConfig)

local ParryService = {}

local function isAlive(player: Player): boolean
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return humanoid ~= nil and humanoid.Health > 0
end

-- BallService:GetManagerFromPlayer só existe depois do Start do BallService;
-- aqui ele é chamado em runtime, então já tá suave.

local function holdsBall(player: Player): boolean
	return BallService:GetManagerFromPlayer(player) ~= nil
end

function ParryService.OnParryRequest(player: Player)
	local manager = PlayerService:GetPlayerManager(player)
	if not manager then
		warn("[ParryService] Parry ignorado: PlayerManager não encontrado para", player.Name)
		return
	end

	if not manager.FSM:Is("Normal") then
		warn("[ParryService] Parry ignorado: estado atual é", tostring(manager.FSM.CurrentState), "(precisa estar em 'Normal')")
		return
	end

	if not isAlive(player) then
		warn("[ParryService] Parry ignorado: jogador não está vivo")
		return
	end

	if not TeamManager.HasTeam(player) then
		warn("[ParryService] Parry ignorado: " .. player.Name .. " ainda NÃO escolheu um time! (Pise na Part de seleção de time)")
		return
	end

	if holdsBall(player) then
		warn("[ParryService] Parry ignorado: jogador está segurando a bola")
		return
	end

	local now = workspace:GetServerTimeNow()
	if now - manager.LastParry < ParryConfig.COOLDOWN then
		warn(string.format("[ParryService] Parry em cooldown! Restam %.2fs", ParryConfig.COOLDOWN - (now - manager.LastParry)))
		return
	end

	if manager.FSM:Goto("ParryStartup") then
		manager.LastParry = now
		Network.FireClient("ParryCooldown", player, ParryConfig.COOLDOWN, now)
		print("[ParryService] ✅ Parry ativado com sucesso para " .. player.Name .. "! Entrou em ParryStartup.")
	end
end

-- Chamado de forma SÍNCRONA pelo BallManager (BindableFunction). Sem yield aqui.

function ParryService.CanParry(thrower: Player, target: Player): boolean
	local manager = PlayerService:GetPlayerManager(target)
	if not manager or not manager.FSM:Is("ParryActive") then
		return false
	end

	return TeamManager.AreEnemies(thrower, target) and isAlive(target) and not holdsBall(target)
end

function ParryService:Start()
	Network.SetValidator("ParryRequest", function(_player, ...)
		if select("#", ...) > 0 then
			return false, "ParryRequest não recebe argumentos"
		end
		return true
	end)

	Network.OnServerEvent("ParryRequest"):Connect(ParryService.OnParryRequest)
	Network.OnBindableInvoke("ParryCheck", ParryService.CanParry)

	Network.OnBindableEvent("BallParried"):Connect(function(info)
		local manager = PlayerService:GetPlayerManager(info.Catcher)
		if manager then
			manager:Reset() -- captura encerra o parry sem passar pelo recovery
		end
	end)
end

return ParryService
