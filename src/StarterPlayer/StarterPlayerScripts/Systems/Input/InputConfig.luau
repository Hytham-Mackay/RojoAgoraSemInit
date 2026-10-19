print("InputConfig carregou")
local Actions = {
	Throw = "Throw",
	Parry = "Parry",
}

return {
	Actions = Actions,
	Bindings = {
		[Actions.Throw] = { Enum.UserInputType.MouseButton1 },
		[Actions.Parry] = { Enum.UserInputType.MouseButton2 },
	},
}
