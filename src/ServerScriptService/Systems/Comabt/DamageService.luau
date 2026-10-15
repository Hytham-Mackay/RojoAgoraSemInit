local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage:WaitForChild("Network"))
local Players = game:GetService("Players")
local TeamManager = require(script.Parent.Parent.Team.TeamManager)

DamageService = {}

local DAMAGE = 20

local function getAliveHumanoid(player: Player): Humanoid?
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		return humanoid
	end
	return nil
end

function DamageService.OnBallHit(thrower: Player, target: Player)
	if thrower == target then
		return
	end

	if thrower.Parent ~= Players then
		return -- Saiu durante o lançamento
	end

	local throwerTeam = TeamManager.GetTeam(thrower)
	local targetTeam = TeamManager.GetTeam(target)

	if not throwerTeam or not targetTeam then
		return -- quem está fora de time não entra no combate
	end

	if throwerTeam == targetTeam then
		return -- Acerto no próprio time não conta
	end

	local humanoid = getAliveHumanoid(target)
	if not humanoid then
		return
	end

	humanoid:TakeDamage(DAMAGE)

	Network.FireBindable("ValidHit", {
		Thrower = thrower,
		Target = target,
		Damage = DAMAGE,
		Killed = humanoid.Health <= 0,
	})
end

Network.OnBindableEvent("BallHit"):Connect(function(thrower: Player, target: Player)
	DamageService.OnBallHit(thrower, target)
end)

return DamageService
