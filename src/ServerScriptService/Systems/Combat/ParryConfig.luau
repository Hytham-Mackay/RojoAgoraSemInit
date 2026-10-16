--!strict

-- Só valores bebê

return table.freeze({
	STARTUP = 0.05, -- Ainda não captura, evitar spam
	ACTIVE = 0.25, -- Janela de captura
	RECOVERY = 0.4, -- Custo da falha, continua lento
	COOLDOWN = 5.0, -- Contado após o inicio do parry
	LOCKED_WALKSPEED = 0.5, -- Velocidade de caminhada durante a animação de parry
})
