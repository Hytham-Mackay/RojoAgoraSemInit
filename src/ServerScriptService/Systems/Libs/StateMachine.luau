--[[
	Regras:
	  - Nada de domínio do jogo aqui dentro (ProximityPrompt, Holder, etc.).
	  - Recursos novos entram como campos opcionais, só quando um uso concreto pedir.
	  - Se precisar ouvir mudanças de estado, um callback opcional OnChanged(old, new)
	    no new() resolve; não precisa de BindableEvent dentro da lib.
]]

local StateMachine = {}
StateMachine.__index = StateMachine

export type State = {
	Name: string,
	Duration: number?,
	From: { string }?,
	Enter: ((old: string) -> boolean)?,
	Started: (() -> ())?,
	Update: ((dt: number) -> ())?,
	Exited: ((next: string) -> ())?,
	Completed: (() -> string)?,
}

function StateMachine.new(clock: (() -> number)?)
	return setmetatable({
		States = {},
		CurrentState = nil,
		_Clock = clock or function()
			return workspace:GetServerTimeNow()
		end,
		_StartTime = 0,
		_Duration = 0,
	}, StateMachine)
end

function StateMachine:_Apply(state: State)
	self.CurrentState = state.Name
	self._Duration = state.Duration or 0
	self._StartTime = self._Clock()

	if state.Started then
		state.Started()
	end
end

function StateMachine:DefineStates(states: { State }, initial: string?)
	assert(#states > 0, "[FSM] DefineStates precisa de ao menos um estado")

	for _, state in states do
		self.States[state.Name] = state
	end

	local first: State = self.States[initial or states[1].Name]
	assert(first, "[FSM] estado inicial inexistente: " .. tostring(initial))

	self:_Apply(first)
end

function StateMachine:Goto(state_name: string): boolean
	local old_name = self.CurrentState
	local next_state: State = self.States[state_name]

	if not next_state then
		warn("[FSM] estado inexistente:", state_name)
		return false
	end

	if next_state.From and not table.find(next_state.From, old_name) then
		return false
	end

	if next_state.Enter and not next_state.Enter(old_name) then
		return false
	end

	local old_state: State = self.States[old_name]
	if old_state and old_state.Exited then
		old_state.Exited(state_name)
	end

	self:_Apply(next_state)
	return true
end

function StateMachine:Update(dt: number)
	local current: State = self.States[self.CurrentState]
	if not current then
		return
	end

	if current.Update then
		current.Update(dt)
		if self.CurrentState ~= current.Name then
			return -- o Update chamou Goto
		end
	end

	if self._Duration == 0 or not current.Completed then
		return
	end

	if self._Clock() - self._StartTime < self._Duration then
		return
	end

	self:Goto(current.Completed())
end

function StateMachine:Is(state_name: string): boolean
	return self.CurrentState == state_name
end

function StateMachine:GetRemaining(): number
	if self._Duration == 0 then
		return 0
	end
	return math.max(0, self._Duration - (self._Clock() - self._StartTime))
end

function StateMachine:Destroy()
	table.clear(self.States)
	self.CurrentState = nil
end

return StateMachine
