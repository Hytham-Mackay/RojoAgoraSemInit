local StateMachine = require(script.Parent.Parent.Libs.StateMachine)
local PlayerStates = require(script.Parent.PlayerStates)

local PlayerManager = {}
PlayerManager.__index = PlayerManager

function PlayerManager.new(player)
	local self = setmetatable({
		Player = player,
		Invulnerable = false,
		DashDirection = Vector3.zero,
		FSM = StateMachine.new(),
		_DashAttachment = nil,
		_DashVelocity = nil,
	}, PlayerManager)

	self.FSM:DefineStates(PlayerStates.Create(player, self))

	return self
end

function PlayerManager:SetInvulnerable(value)
	self.Invulnerable = value
end

function PlayerManager:Update()
	self.FSM:Update()
end

return PlayerManager
