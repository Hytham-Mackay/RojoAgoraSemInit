local StateMachine = require(script.Parent.Parent.Libs.StateMachine)
local PlayerStates = require(script.Parent.PlayerStates)
local ParryConfig = require(script.Parent.Parent.Combat.ParryConfig)

local DEFAULT_WALKSPEED = 16

local PlayerManager = {}
PlayerManager.__index = PlayerManager

local function getHumanoid(player: Player): Humanoid?
	local character = player.Character
	if not character then
		return nil
	end
	return character:FindFirstChildOfClass("Humanoid")
end

function PlayerManager.new(player)
	local self = setmetatable({
		Player = player,
		Invulnerable = false,
		DashDirection = Vector3.zero,
		LastParry = 0,
		FSM = StateMachine.new(),
		_DashAttachment = nil,
		_DashVelocity = nil,
	}, PlayerManager)

	self.FSM:DefineStates(PlayerStates.Create(player, self))

	return self
end

function PlayerManager:LockMovement()
	local humanoid = getHumanoid(self.Player)
	if humanoid then
		humanoid.WalkSpeed = ParryConfig.LOCKED_WALKSPEED
		print(string.format("[PlayerManager] LockMovement: WalkSpeed de %s alterado para %.2f", self.Player.Name, humanoid.WalkSpeed))
	else
		warn(string.format("[PlayerManager] LockMovement falhou: Humanoid não encontrado para %s", self.Player.Name))
	end
end

function PlayerManager:UnlockMovement()
	local humanoid = getHumanoid(self.Player)
	if humanoid then
		humanoid.WalkSpeed = DEFAULT_WALKSPEED
		print(string.format("[PlayerManager] UnlockMovement: WalkSpeed de %s restaurado para %.2f", self.Player.Name, humanoid.WalkSpeed))
	else
		warn(string.format("[PlayerManager] UnlockMovement falhou: Humanoid não encontrado para %s", self.Player.Name))
	end
end

function PlayerManager:Reset()
	self.FSM:Goto("Normal")
end

function PlayerManager:SetInvulnerable(value)
	self.Invulnerable = value
end

function PlayerManager:Update(dt)
	self.FSM:Update(dt)
end

return PlayerManager
