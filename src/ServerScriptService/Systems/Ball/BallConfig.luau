--!strict
-- Só valores. Nenhuma lógica aqui.
return table.freeze({
	-- Tags do CollectionService (aplique no Studio, aba Properties > Tags)
	ZONE_TAG = "BallZone", -- nas peças de zona
	CENTER_TAG = "ArenaCenter", -- numa peça no centro da arena

	-- Respawn
	RESPAWN_HEIGHT = 5, -- studs acima do centro
	RESPAWN_DELAY = 0, -- segundos em "Resetting" antes de voltar a "Idle"

	DEBUG = false, -- imprime o motivo de cada reset
})
