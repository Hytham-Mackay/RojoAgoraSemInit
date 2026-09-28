-- Inicia os módulos ativos: qualquer ModuleScript terminado em "Controller"
-- dentro de Systems/<Sistema>/. Os demais (Manager, States...) são passivos
-- e só são requeridos por quem precisa deles.

for _, system in ipairs(script.Parent.Systems:GetChildren()) do
	for _, module in ipairs(system:GetChildren()) do
		if module:IsA("ModuleScript") and module.Name:match("Controller$") then
			local loaded = require(module)

			if type(loaded) == "table" and type(loaded.Start) == "function" then
				loaded:Start()
			end
		end
	end
end
