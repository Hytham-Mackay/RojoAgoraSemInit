for _, folder in ipairs(script.Parent.Systems:GetChildren()) do

	print("Pasta encontrada:", folder.Name)

	local initModule = folder:FindFirstChild("Initializer")

	if initModule then
		print("Init encontrado:", initModule.Name)
		require(initModule).init()
	else
		print("Sem init em:", folder.Name)
	end
end