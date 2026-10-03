local CollectionService = game:GetService("CollectionService")

local Config = require(script.Parent.BallConfig)

local ZoneDetection = {}

-- bola -> callback. Uma única conexão de Touched por zona, não por bola.
local watchers: { [BasePart]: (zoneName: string) -> () } = {}
local zoneConnections: { [BasePart]: RBXScriptConnection } = {}
local started = false

local function bindZone(zone: Instance)
	if not zone:IsA("BasePart") then
		return
	end
	if zoneConnections[zone] then
		return
	end
	zoneConnections[zone] = zone.Touched:Connect(function(hit: BasePart)
		local callback = watchers[hit]
		if callback then
			callback(zone.Name)
		end
	end)
end

local function unbindZone(zone: Instance)
	if not zone:IsA("BasePart") then
		return
	end
	local connection = zoneConnections[zone]
	if connection then
		connection:Disconnect()
		zoneConnections[zone] = nil
	end
end

-- Liga as zonas na primeira chamada de Watch. Zonas criadas ou removidas depois
-- também são tratadas, porque escutamos o CollectionService.
local function start()
	if started then
		return
	end
	started = true

	for _, zone in CollectionService:GetTagged(Config.ZONE_TAG) do
		bindZone(zone)
	end
	CollectionService:GetInstanceAddedSignal(Config.ZONE_TAG):Connect(bindZone)
	CollectionService:GetInstanceRemovedSignal(Config.ZONE_TAG):Connect(unbindZone)
end

-- Avisa `onZoneTouched` quando `ball` tocar qualquer zona.
-- Retorna uma função que cancela a observação (use no Destroy do manager).
function ZoneDetection.Watch(ball: BasePart, onZoneTouched: (zoneName: string) -> ()): () -> ()
	start()
	watchers[ball] = onZoneTouched
	return function()
		watchers[ball] = nil
	end
end

return ZoneDetection
