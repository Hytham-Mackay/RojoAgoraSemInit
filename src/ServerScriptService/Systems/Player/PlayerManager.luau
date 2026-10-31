local StateMachine = require(script.Parent.Parent.Libs.StateMachine)
local PlayerStates = require(script.Parent.PlayerStates)
local ParryConfig = require(script.Parent.Parent.Combat.ParryConfig)

local BASE_PLAYER_SPEED = 30

local PlayerManager = {}
PlayerManager.__index = PlayerManager

function PlayerManager.new(player)
	local self = setmetatable({
		Player = player,
		FSM = StateMachine.new(),
		LastParry = -math.huge,
		BaseWalkSpeed = BASE_PLAYER_SPEED,
		_Locked = false,
	}, PlayerManager)

	self.FSM:DefineStates(PlayerStates.Create(player, self))

	return self
end

function PlayerManager:_GetHumanoid(): Humanoid?
	local character = self.Player.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end

function PlayerManager:_ApplyWalkSpeed()
	local humanoid = self:_GetHumanoid()
	if not humanoid then
		return
	end
	humanoid.WalkSpeed = if self._Locked then ParryConfig.LOCKED_WALKSPEED else self.BaseWalkSpeed
end

function PlayerManager:LockMovement()
	self._Locked = true
	self:_ApplyWalkSpeed()
end

function PlayerManager:UnlockMovement()
	self._Locked = false
	self:_ApplyWalkSpeed()
end

function PlayerManager:Reset()
	self._Locked = false
	self.FSM:Goto("Normal")
	self:_ApplyWalkSpeed()
end

function PlayerManager:Update(dt)
	self.FSM:Update(dt)
end

return PlayerManager
