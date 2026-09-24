local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local mouseSegment = require(script.Parent.Parent.Parent.CameraSystem.active.mouseSegment)

local Network = require(ReplicatedStorage:WaitForChild("Network"))

local PlayerController = {}

local chargeStart

function PlayerController:Start()
	-- Throw
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			chargeStart = tick()
		end
	end)

	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if not chargeStart then
				return
			end

			local target = mouseSegment:GetTargetPosition()

			if not target then
				warn("[PlayerController] MouseHit é nil, arremesso cancelado.")
				chargeStart = nil
				return
			end

			Network.FireServer("ThrowRequest", chargeStart, target)

			chargeStart = nil
		end
	end)

	-- Dash
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		print("Dash")

		if input.KeyCode == Enum.KeyCode.Space then
			Network.FireServer("DashRequest", Enum.KeyCode.Space)
		end
	end)
end

return PlayerController
