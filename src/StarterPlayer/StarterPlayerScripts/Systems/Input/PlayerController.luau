local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local mouseSegment = require(script.Parent.Parent.Camera.MouseController)

local Network = require(ReplicatedStorage:WaitForChild("Network"))

local PlayerController = {}

local chargeStart

function PlayerController:Start()
	-- Throw
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			print("[PlayerController] MouseButton2 detectado -> Enviando ParryRequest...")
			Network.FireServer("ParryRequest")
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

			local chargeTime = tick() - chargeStart

			local target = mouseSegment:GetTargetPosition()

			if not target then
				warn("[PlayerController] MouseHit é nil, arremesso cancelado.")
				chargeStart = nil
				return
			end

			Network.FireServer("ThrowRequest", chargeTime, target)

			chargeStart = nil
		end
	end)
end

return PlayerController
