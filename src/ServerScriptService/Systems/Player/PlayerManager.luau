local StateMachine = require(script.Parent.Parent.Libs.StateMachine)
local PlayerStates = require(script.Parent.PlayerStates)
local ParryConfig = require(script.Parent.Parent.Combat.ParryConfig)

local PlayerManager = {}
PlayerManager.__index = PlayerManager

function PlayerManager.new(player)
	local self = setmetatable({
		Player = player,
		FSM = StateMachine.new(),
		LastParry = -math.huge,
		_SavedWalkSpeed = nil,
	}, PlayerManager)

	self.FSM:DefineStates(PlayerStates.Create(player, self))

	return self
end

function PlayerManager:_GetHumanoid(): Humanoid?
	local character = self.Player.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end

function PlayerManager:LockMovement()
	local humanoid = self:_GetHumanoid()
	if not humanoid then
		return
	end
	if not self._SavedWalkSpeed then
		self._SavedWalkSpeed = humanoid.WalkSpeed
	end
	humanoid.WalkSpeed = ParryConfig.LOCKED_WALKSPEED
end

function PlayerManager:UnlockMovement()
	local saved = self._SavedWalkSpeed
	if not saved then
		return -- seguro: o Normal.Started roda dentro do DefineStates
	end
	self._SavedWalkSpeed = nil

	local humanoid = self:_GetHumanoid()
	if humanoid then
		humanoid.WalkSpeed = saved
	end
end

function PlayerManager:Reset()
	self.FSM:Goto("Normal")
end

function PlayerManager:Update(dt)
	self.FSM:Update(dt)
end

return PlayerManager
