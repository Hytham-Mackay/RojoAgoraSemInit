local StateMachine = require(script.Parent.Parent.Libs.StateMachine)
local PlayerStates = require(script.Parent.PlayerStates)

local PlayerManager = {}
PlayerManager.__index = PlayerManager

local function GetCurrentMoveDirection(humanoid, root)
	local moveDirection = humanoid.MoveDirection

	if moveDirection.Magnitude > 0.05 then
		return moveDirection.Unit
	end

	local look = root.CFrame.LookVector
	local flatLook = Vector3.new(look.X, 0, look.Z)

	if flatLook.Magnitude > 0.05 then
		return flatLook.Unit
	end

	return Vector3.new(0, 0, -1)
end

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

function PlayerManager:IsDashing()
	return self.FSM.CurrentState == "Dashing"
end

function PlayerManager:RequestDash()
	local character = self.Player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not root then
		return
	end

	if humanoid.Health <= 0 then
		return
	end

	if humanoid.FloorMaterial == Enum.Material.Air then
		return
	end

	self.DashDirection = GetCurrentMoveDirection(humanoid, root)

	self.FSM:Goto("Dashing")
end

function PlayerManager:ApplyDashImpulse(distance, duration)
	local character = self.Player.Character
	if not character then
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local speed = distance / duration
	local velocity = self.DashDirection * speed

	local attachment = Instance.new("Attachment")
	attachment.Name = "DashAttachment"
	attachment.Parent = root

	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Name = "DashVelocity"
	linearVelocity.Attachment0 = attachment
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	linearVelocity.MaxForce = math.huge
	linearVelocity.VectorVelocity = velocity
	linearVelocity.Parent = root

	self._DashAttachment = attachment
	self._DashVelocity = linearVelocity
end

function PlayerManager:ClearDashImpulse()
	if self._DashVelocity then
		self._DashVelocity:Destroy()
		self._DashVelocity = nil
	end

	if self._DashAttachment then
		self._DashAttachment:Destroy()
		self._DashAttachment = nil
	end
end

function PlayerManager:Update()
	self.FSM:Update()
end

return PlayerManager
