local UserInputService = game:GetService("UserInputService")

local InputController = {}

-- Lib genérica: as ações e os bindings vêm do config passado no Init.
-- config.Actions:  { [nome] = nome }
-- config.Bindings: { [ação] = { Enum.KeyCode | Enum.UserInputType, ... } } :D
local validActions = {}
local bindingsForAction = {}

local actionForBinding = {} -- tecla/botão -> ação
local pressedSources = {} -- origem (tecla, InputObject de toque ou token virtual) -> ação
local downCount = {} -- ação -> quantas origens estão seguradas
local virtualTokens = {} -- [action][owner] = token
local initialized = false
local connections = {}

local DEFAULT_OWNER = "Default"

local function assertAction(action)
	if not validActions[action] then
		error(`[InputController] Ação desconhecida: "{tostring(action)}"`, 3)
	end
end

-- Eventos. Troque getEvent/fire/connect
-- Network se quiser usar os Bindables dele.

local events = {} -- [action] = { Pressed = BindableEvent, Released = BindableEvent }

local function getEvent(action, phase)
	local pair = events[action]
	if not pair then
		pair = {
			Pressed = Instance.new("BindableEvent"),
			Released = Instance.new("BindableEvent"),
		}
		events[action] = pair
	end
	return pair[phase]
end

local function fire(action, phase)
	getEvent(action, phase):Fire()
end

-- Núcleo: contagem de origens por ação

local function press(source, action)
	if pressedSources[source] then
		return
	end
	pressedSources[source] = action
	downCount[action] = (downCount[action] or 0) + 1
	if downCount[action] == 1 then
		fire(action, "Pressed")
	end
end

local function release(source)
	local action = pressedSources[source]
	if not action then
		return
	end
	pressedSources[source] = nil
	downCount[action] -= 1
	if downCount[action] == 0 then
		fire(action, "Released")
	end
end

-- Copia as chaves antes de liberar: se um callback de Released
-- chamar press() com origem nova, o loop não é afetado
local function releaseAll()
	local sources = {}
	for source in pressedSources do
		table.insert(sources, source)
	end
	for _, source in sources do
		release(source)
	end
end

local function releaseAction(action)
	local sources = {}
	for source, sourceAction in pressedSources do
		if sourceAction == action then
			table.insert(sources, source)
		end
	end
	for _, source in sources do
		release(source)
	end
end

-- Conflito na configuração é erro de programação
local function rebuildLookup()
	table.clear(actionForBinding)
	for action, bindings in bindingsForAction do
		for _, binding in bindings do
			local existing = actionForBinding[binding]
			if existing and existing ~= action then
				error(`[InputController] Binding duplicado: {binding} em "{existing}" e "{action}"`)
			end
			actionForBinding[binding] = action
		end
	end
end

local function findConflict(action, bindings)
	for _, binding in bindings do
		for otherAction, otherBindings in bindingsForAction do
			if otherAction ~= action and table.find(otherBindings, binding) then
				return binding, otherAction
			end
		end
	end
	return nil, nil
end

-- Teclado e gamepad têm KeyCode; botões do mouse e toque usam UserInputType
local UNKNOWN_KEY = (Enum.KeyCode :: any).Unknown

local function resolveBinding(input)
	if input.KeyCode ~= UNKNOWN_KEY then
		return input.KeyCode
	end
	return input.UserInputType
end

-- Origem da pressão: cada dedo é um InputObject próprio,
-- o mesmo no InputBegan e no InputEnded
local function resolveSource(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		return input
	end
	return resolveBinding(input)
end

-- Origens virtuais por dono
local function getToken(action, owner)
	owner = owner or DEFAULT_OWNER
	local byOwner = virtualTokens[action]
	if not byOwner then
		byOwner = setmetatable({}, { __mode = "k" })
		virtualTokens[action] = byOwner
	end
	local token = byOwner[owner]
	if not token then
		token = {}
		byOwner[owner] = token
	end
	return token
end

-- OnPressed/OnReleased retornam RBXScriptConnection: o consumidor é
-- responsável por desconectar ("quem conecta, desconecta").
-- Shutdown destrói os eventos, o que desconecta todos sem aviso.
function InputController.OnPressed(action, callback)
	assertAction(action)
	return getEvent(action, "Pressed").Event:Connect(callback)
end

function InputController.OnReleased(action, callback)
	assertAction(action)
	return getEvent(action, "Released").Event:Connect(callback)
end

function InputController.IsDown(action)
	assertAction(action)
	return (downCount[action] or 0) > 0
end

-- Substitui todas as teclas da ação (rebind).
-- Devolve false, sem alterar nada, se alguma tecla já pertence a outra ação.
-- A troca acontece antes da liberação: callbacks de Released já veem o estado novo.
function InputController.Rebind(action, ...)
	assertAction(action)
	local newBindings = { ... }

	local conflictBinding, conflictAction = findConflict(action, newBindings)
	if conflictBinding then
		warn(`[InputController] Rebind recusado: {conflictBinding} já pertence a "{conflictAction}"`)
		return false
	end

	bindingsForAction[action] = newBindings
	rebuildLookup()
	releaseAction(action)
	return true
end

-- Origem virtual: botão de mobile, teste, etc. Para uso de interface e testes,
-- não de gameplay. "owner" separa origens independentes na mesma ação.
function InputController.Press(action, owner)
	assertAction(action)
	press(getToken(action, owner), action)
end

function InputController.Release(action, owner)
	assertAction(action)
	release(getToken(action, owner))
end

-- Liga um GuiButton a uma ação. Guarda o InputObject que pressionou
-- e libera quando ele termina em qualquer lugar da tela.
-- Retorna uma função de limpeza, que o criador do botão deve guardar.
function InputController.BindButton(action, button)
	assertAction(action)

	local activeInput = nil
	local conns = {}

	local function isPointerPress(input)
		return input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1
	end

	local function finish()
		if activeInput then
			activeInput = nil
			release(getToken(action, button))
		end
	end

	table.insert(
		conns,
		button.InputBegan:Connect(function(input)
			if activeInput or not isPointerPress(input) then
				return
			end
			activeInput = input
			InputController.Press(action, button)
		end)
	)

	table.insert(
		conns,
		UserInputService.InputEnded:Connect(function(input)
			if not activeInput then
				return
			end
			local sameTouch = input == activeInput
			local sameMouse = activeInput.UserInputType == Enum.UserInputType.MouseButton1
				and input.UserInputType == Enum.UserInputType.MouseButton1
			if sameTouch or sameMouse then
				finish()
			end
		end)
	)

	table.insert(conns, button.Destroying:Connect(finish))

	return function()
		for _, c in conns do
			c:Disconnect()
		end
		finish()
	end
end

function InputController.Init(config)
	if initialized then
		return
	end
	assert(
		type(config) == "table" and type(config.Actions) == "table" and type(config.Bindings) == "table",
		"[InputController] Init espera { Actions = {...}, Bindings = {...} }"
	)
	initialized = true

	for _, name in config.Actions do
		validActions[name] = true
	end
	for action, bindings in config.Bindings do
		assertAction(action)
		bindingsForAction[action] = table.clone(bindings)
	end

	rebuildLookup()

	table.insert(
		connections,
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end
			if UserInputService:GetFocusedTextBox() then
				return
			end

			local action = actionForBinding[resolveBinding(input)]
			if action then
				press(resolveSource(input), action)
			end
		end)
	)

	-- Soltar sempre é processado, mesmo com gameProcessed,
	-- senão a ação fica presa como pressionada
	table.insert(
		connections,
		UserInputService.InputEnded:Connect(function(input)
			release(resolveSource(input))
		end)
	)

	-- Evita ação presa ao perder foco.
	-- Ao perder o foco da TextBox com a tecla ainda segurada, a ação NÃO reativa
	-- até soltar e apertar de novo.
	table.insert(connections, UserInputService.WindowFocusReleased:Connect(releaseAll))
	table.insert(connections, UserInputService.TextBoxFocused:Connect(releaseAll))
end

-- Desconecta tudo e limpa o estado (útil para testes e reload)
function InputController.Shutdown()
	if not initialized then
		return
	end
	initialized = false

	for _, connection in connections do
		connection:Disconnect()
	end
	table.clear(connections)

	releaseAll()

	for _, pair in events do
		pair.Pressed:Destroy()
		pair.Released:Destroy()
	end
	table.clear(events)
	table.clear(downCount)
	table.clear(pressedSources)
	table.clear(virtualTokens)
	table.clear(validActions)
	table.clear(bindingsForAction)
	table.clear(actionForBinding)
end

return InputController
