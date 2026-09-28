local Pickup = require(script.Parent.Pickup)
local Throw = require(script.Parent.Throw)

local ballManager = {}
ballManager.__index = ballManager

local FLIGHT_HEIGHT = 2.5

function ballManager.new(ball)
	local self = setmetatable({}, ballManager)

	self.ball = ball
	self.State = "Free"
	self.Holder = nil
	self.weld = nil

	self.Flight = {
		Direction = nil,
		Speed = 0,
		Y = nil,
		Travelled = 0,
	}

	self.Physics = {
		BounceFactor = 0.92,
		WallBounceFactor = 0.85,
	}

	self.FallConfig = {
		Gravity = 45, -- cai devagar
		BounceDamping = 0.90, -- QUICA ALTO (antes 0.82)
		GroundFriction = 0.965, -- desliza bastante
		AirResistance = 0.998,
	}

	self.Fall = nil
	self.Roll = nil

	self.FlightRaycastParams = RaycastParams.new()
	self.FlightRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
	self.FlightRaycastParams.FilterDescendantsInstances = { ball }

	self.HeightRaycastParams = RaycastParams.new()
	self.HeightRaycastParams.FilterType = Enum.RaycastFilterType.Exclude

	self:ConnectEvents()
	return self
end

function ballManager:ConnectEvents()
	self.ball.ProximityPrompt.Triggered:Connect(function(player)
		print(player.Name .. " tentou pegar a bola")
		self:Pickup(player)
	end)
end

function ballManager:CanPickup()
	return self.State == "Free"
end

function ballManager:Pickup(player)
	return Pickup:Execute(self, player)
end

function ballManager:PickupSuccess(player)
	self:SetHolder(player)
	self:SetState("Held")
	self.ball.Anchored = false

	local character = player.Character
	if not character then
		return false
	end

	local hand = character:WaitForChild("RightHand")
	self.ball.CFrame = hand.CFrame

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = self.ball
	weld.Part1 = hand
	weld.Parent = self.ball
	self.weld = weld

	print("O jogador " .. player.Name .. " pegou a bola")
	return true
end

function ballManager:CanThrow(player)
	return self.Holder == player and self.State == "Held"
end

function ballManager:ThrowRequest(player, chargeTime, target)
	return Throw:Execute(self, player, chargeTime, target)
end

function ballManager:ThrowSuccess(player, chargeTime, target)
	local MIN_THROW_SPEED = 30
	local MAX_THROW_SPEED = 300
	local MAX_CHARGE_TIME = 5

	local direction = target - self.ball.Position
	direction = Vector3.new(direction.X, 0, direction.Z)

	if direction.Magnitude < 1 then
		return false
	end

	direction = direction.Unit

	local chargeAlpha = math.clamp(chargeTime / MAX_CHARGE_TIME, 0, 1)
	local speed = MIN_THROW_SPEED + (MAX_THROW_SPEED - MIN_THROW_SPEED) * chargeAlpha

	local flightY = self:GetFlightHeight(player)
	if not flightY then
		warn("Não foi possível encontrar o chão.")
		return false
	end

	self.Flight.Direction = direction
	self.Flight.Speed = speed
	self.Flight.Y = flightY
	self.Flight.Travelled = 0

	if self.weld then
		self.weld:Destroy()
		self.weld = nil
	end

	self.Holder = nil
	self.ball.Anchored = true

	self.ball.Position = Vector3.new(self.ball.Position.X, flightY, self.ball.Position.Z)

	self:SetState("Flying")

	print("Bola lançada | Velocidade:", speed, "| Altura:", flightY)
	return true
end

function ballManager:GetFlightHeight(player)
	local character = player.Character
	if not character then
		return nil
	end

	self.HeightRaycastParams.FilterDescendantsInstances = {
		self.ball,
		character,
	}

	local origin = self.ball.Position
	local direction = Vector3.new(0, -100, 0)
	local result = workspace:Raycast(origin, direction, self.HeightRaycastParams)

	if not result then
		return nil
	end

	local groundY = result.Position.Y
	local flightY = groundY + FLIGHT_HEIGHT

	local charHRP = character:FindFirstChild("HumanoidRootPart")
	if charHRP then
		flightY = math.max(flightY, charHRP.Position.Y + 1)
	end

	return flightY
end

function ballManager:GetBallRadius()
	return math.min(self.ball.Size.X, self.ball.Size.Y, self.ball.Size.Z) / 2
end

-- Voo horizontal

function ballManager:UpdateFlight(dt)
	local direction = self.Flight.Direction
	local speed = self.Flight.Speed
	local y = self.Flight.Y

	if not direction then
		return
	end

	local displacement = direction * speed * dt

	self.Flight.Travelled = self.Flight.Travelled + displacement.Magnitude
	if self.Flight.Travelled > 2000 then
		warn("[ballManager] Bola excedeu distância máxima. Parando.")
		self:ClearFlight()
		self:SetState("Free")
		return
	end

	local result =
		workspace:Spherecast(self.ball.Position, self:GetBallRadius(), displacement, self.FlightRaycastParams)

	if result then
		self:OnFlightHit(result)
		return
	end

	local newPosition = self.ball.Position + displacement
	self.ball.Position = Vector3.new(newPosition.X, y, newPosition.Z)
end

function ballManager:OnFlightHit(result)
	local hitPart = result.Instance
	local character = hitPart:FindFirstAncestorOfClass("Model")

	if character and character:FindFirstChildOfClass("Humanoid") then
		print("HIT PLAYER:", character.Name)
	else
		print("Atingiu:", hitPart.Name)
	end

	print("Bola atingiu:", result.Instance.Name)

	local normal = result.Normal
	local velocity = self.Flight.Direction * self.Flight.Speed

	local reflected = velocity - 2 * velocity:Dot(normal) * normal
	reflected = Vector3.new(reflected.X, 0, reflected.Z)

	reflected *= self.Physics.BounceFactor
	self:ClearFlight()

	-- Se bateu no chão, perde MENOS energia horizontal (antes era 0.5)
	if normal.Y > 0.7 then
		reflected *= 0.75
	end

	self:StartFalling(reflected)
end

function ballManager:ClearFlight()
	self.Flight.Direction = nil
	self.Flight.Speed = 0
	self.Flight.Y = nil
	self.Flight.Travelled = 0
end

function ballManager:StartFalling(horizontalVelocity)
	self.Fall = {
		HorizontalVelocity = horizontalVelocity,
		VerticalVelocity = 0,
		Gravity = self.FallConfig.Gravity,
		BounceDamping = self.FallConfig.BounceDamping,
		GroundFriction = self.FallConfig.GroundFriction,
		AirResistance = self.FallConfig.AirResistance,
		Position = self.ball.Position,
	}

	self:SetState("Falling")
end

function ballManager:UpdateFalling(dt)
	local fall = self.Fall
	if not fall then
		return
	end

	-- Gravidade
	fall.VerticalVelocity -= fall.Gravity * dt

	-- Resistência no ar mínima
	fall.HorizontalVelocity *= fall.AirResistance

	local velocity = Vector3.new(fall.HorizontalVelocity.X, fall.VerticalVelocity, fall.HorizontalVelocity.Z)

	local displacement = velocity * dt
	local nextPosition = self.ball.Position + displacement

	-- Detecção do chão

	local groundY = self:GetGroundYAtPosition(self.ball.Position)

	if groundY then
		local ballRadius = self:GetBallRadius()
		local nextBallBottomY = nextPosition.Y - ballRadius

		if nextBallBottomY <= groundY then
			-- Posiciona no chão
			self.ball.Position = Vector3.new(nextPosition.X, groundY + ballRadius, nextPosition.Z)
			fall.Position = self.ball.Position

			-- QUICADA: inverte e aplica damping

			fall.VerticalVelocity = math.abs(fall.VerticalVelocity) * fall.BounceDamping
			fall.HorizontalVelocity *= fall.GroundFriction

			print("[ballManager] QUICOU! VY:", fall.VerticalVelocity, "| HY:", fall.HorizontalVelocity.Magnitude)

			if math.abs(fall.VerticalVelocity) < 3 then
				fall.VerticalVelocity = 0
				self:StartRolling(fall.HorizontalVelocity)
				return
			end

			return
		end
	end

	-- Detectação de parede

	local horizontalDisplacement = Vector3.new(displacement.X, 0, displacement.Z)

	if horizontalDisplacement.Magnitude > 0.01 then
		local result = workspace:Spherecast(
			self.ball.Position,
			self:GetBallRadius(),
			horizontalDisplacement,
			self.FlightRaycastParams
		)

		if result then
			local normal = result.Normal

			if normal.Y <= 0.7 then
				local reflected = fall.HorizontalVelocity - 2 * fall.HorizontalVelocity:Dot(normal) * normal

				reflected = Vector3.new(reflected.X, 0, reflected.Z)
				reflected *= self.Physics.WallBounceFactor

				fall.HorizontalVelocity = reflected

				self.ball.Position = result.Position + normal * (self:GetBallRadius() + 0.05)

				fall.Position = self.ball.Position
				return
			end
		end
	end

	-- Sem colisão
	fall.Position = nextPosition
	self.ball.Position = nextPosition

	if nextPosition.Y < -500 then
		warn("[ballManager] Bola caiu no void. Resetando.")
		self:SetState("Free")
		self.ball.Position = Vector3.new(0, 10, 0)
		self.Fall = nil
	end
end

-- Rolamento

function ballManager:StartRolling(horizontalVelocity)
	self.Roll = {
		Velocity = horizontalVelocity,
		Friction = 0.97,
		StopThreshold = 5,
	}

	self.Fall = nil
	self:SetState("Rolling")
end

function ballManager:UpdateRolling(dt)
	local roll = self.Roll
	if not roll then
		return
	end

	roll.Velocity *= roll.Friction

	local displacement = Vector3.new(roll.Velocity.X * dt, 0, roll.Velocity.Z * dt)

	local result =
		workspace:Spherecast(self.ball.Position, self:GetBallRadius(), displacement, self.FlightRaycastParams)

	if result then
		local normal = result.Normal
		local reflected = roll.Velocity - 2 * roll.Velocity:Dot(normal) * normal
		reflected = Vector3.new(reflected.X, 0, reflected.Z)
		reflected *= self.Physics.WallBounceFactor

		roll.Velocity = reflected
		self.ball.Position = result.Position + normal * (self:GetBallRadius() + 0.05)
	else
		self.ball.Position = self.ball.Position + displacement
	end

	local groundY = self:GetGroundYAtPosition(self.ball.Position)
	if groundY then
		self.ball.Position = Vector3.new(self.ball.Position.X, groundY + self:GetBallRadius(), self.ball.Position.Z)
	end

	if roll.Velocity.Magnitude < roll.StopThreshold then
		roll.Velocity = Vector3.new(0, 0, 0)
		self.Roll = nil
		self:SetState("Free")
		self.ball.Anchored = true
	end
end

function ballManager:GetGroundYAtPosition(position)
	self.HeightRaycastParams.FilterDescendantsInstances = {
		self.ball,
	}

	local origin = Vector3.new(position.X, position.Y + 50, position.Z)
	local direction = Vector3.new(0, -200, 0)

	local result = workspace:Raycast(origin, direction, self.HeightRaycastParams)
	if result then
		return result.Position.Y
	end

	return nil
end

function ballManager:SetState(state)
	self.State = state
	self.ball.ProximityPrompt.Enabled = (state == "Free")
end

function ballManager:SetHolder(player)
	self.Holder = player
end

function ballManager:updateState(dt)
	if self.State == "Flying" then
		self:UpdateFlight(dt)
	elseif self.State == "Falling" then
		self:UpdateFalling(dt)
	elseif self.State == "Rolling" then
		self:UpdateRolling(dt)
	end
end

return ballManager
