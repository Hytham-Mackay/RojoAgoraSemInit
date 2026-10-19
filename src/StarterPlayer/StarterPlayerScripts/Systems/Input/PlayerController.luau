local ReplicatedStorage = game:GetService("ReplicatedStorage")

local mouseSegment = require(script.Parent.Parent.Camera.MouseController)
local InputController = require(script.Parent.Parent.Libs.InputController)
local InputConfig = require(script.Parent.InputConfig)
local Network = require(ReplicatedStorage:WaitForChild("Network"))

local Actions = InputConfig.Actions

local PlayerController = {}

local chargeStart

function PlayerController:Start()
	InputController.Init(InputConfig)

	InputController.OnPressed(Actions.Parry, function()
		Network.FireServer("ParryRequest")
	end)

	InputController.OnPressed(Actions.Throw, function()
		chargeStart = tick()
	end)

	InputController.OnReleased(Actions.Throw, function()
		if not chargeStart then
			return
		end

		local chargeTime = tick() - chargeStart
		chargeStart = nil

		local target = mouseSegment:GetTargetPosition()
		if not target then
			warn("[PlayerController] MouseHit é nil, arremesso cancelado.")
			return
		end

		Network.FireServer("ThrowRequest", chargeTime, target)
	end)
end

return PlayerController
