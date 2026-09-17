local Players = game:GetService("Players")

local player = Players.LocalPlayer

local function setupCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")

	humanoid:SetStateEnabled(
		Enum.HumanoidStateType.Jumping,
		false
	)
end

if player.Character then
	setupCharacter(player.Character)
end

player.CharacterAdded:Connect(setupCharacter)
