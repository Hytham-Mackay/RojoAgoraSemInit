local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")

local PlayerInput = {}

local player = Players.LocalPlayer

local function SinkJump()
	return Enum.ContextActionResult.Sink
end

local function SetupCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")

	humanoid:SetStateEnabled(
		Enum.HumanoidStateType.Jumping,
		false
	)
end

function PlayerInput.Start()
	ContextActionService:BindActionAtPriority(
		"DisableDefaultJump",
		SinkJump,
		false,
		Enum.ContextActionPriority.High.Value,
		Enum.PlayerActions.CharacterJump
	)

	if player.Character then
		SetupCharacter(player.Character)
	end

	player.CharacterAdded:Connect(SetupCharacter)
end

return PlayerInput