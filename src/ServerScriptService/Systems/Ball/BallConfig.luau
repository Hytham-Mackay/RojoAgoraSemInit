--!strict
-- Só valores. Nenhuma lógica aqui.
return table.freeze({
	-- Tags do CollectionService (aplique no Studio, aba Properties > Tags)
	ZONE_TAG = "BallZone", -- nas peças de zona
	CENTER_TAG = "ArenaCenter", -- numa peça no centro da arena
	BOUNDS_TAG = "ArenaBounds", -- NOVO: na peça que delimita a arena

	-- Arena
	FLOOR_Y = 0, -- NOVO: topo do piso
	SPAWN_MARGIN = 0, -- NOVO: folga extra (studs) para não nascer colada na borda
	VOID_Y = -500, -- NOVO: abaixo disso a bola é resetada

	-- Bola
	THROW_SPEED = 100, -- NOVO
	FLIGHT_HEIGHT = 2.5, -- NOVO
	PICKUP_RANGE = 8, -- NOVO
	MAX_FLIGHT_DISTANCE = 2000, -- NOVO

	-- Respawn
	RESPAWN_HEIGHT = 5, -- studs acima do centro
	RESPAWN_DELAY = 0, -- segundos em "Resetting" antes de voltar a "Idle"

	DEBUG = false, -- imprime logs da bola (pickup, lançamento, quique, reset)
})
