local ReplicatedStorage = game:GetService("ReplicatedStorage")

local mouseSegment = require(script.Parent.Parent.Camera.MouseController)
local InputController = require(script.Parent.Parent.Libs.InputController)
local InputConfig = require(script.Parent.InputConfig)
local Network = require(ReplicatedStorage:WaitForChild("Network"))

local Actions = InputConfig.Actions

local PlayerController = {}

function PlayerController:Start()
	InputController.Init(InputConfig)

	InputController.OnPressed(Actions.Parry, function()
		Network.FireServer("ParryRequest")
	end)

	InputController.OnPressed(Actions.Throw, function()
		local target = mouseSegment:GetTargetPosition()
		if not target then
			warn("[PlayerController] MouseHit é nil, arremesso cancelado.")
			return
		end

		Network.FireServer("ThrowRequest", target)
	end)
end

return PlayerController
