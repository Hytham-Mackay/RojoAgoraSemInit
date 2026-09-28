local StateMachine = {}
StateMachine.__index = StateMachine

export type State = {
	Name: string,
	Duration: number,
	Completed: (() -> string)?,
	Started: (() -> ())?,
	Enter: ((string) -> boolean)?,
}

function StateMachine.new()
	local self = setmetatable({
		States = {},
		CurrentState = nil,
		_StartTime = 0,
		_Duration = 0,
	}, StateMachine)

	return self
end

function StateMachine:DefineStates(states: { State })
	for _, state in states do
		self.States[state.Name] = state
	end
	self.CurrentState = states[1].Name
end

function StateMachine:Goto(state_name: string)
	local old_state_name = self.CurrentState
	local next_state: State = self.States[state_name]

	if not next_state then
		warn("[FSM] sem indicação de estado:", state_name)
		return
	end

	local valid = true
	if next_state.Enter then
		valid = next_state.Enter(old_state_name)
	end

	if valid then
		self.CurrentState = state_name
		self._Duration = next_state.Duration
		self._StartTime = workspace:GetServerTimeNow()

		if next_state.Started then
			next_state.Started()
		end
	else
		self.CurrentState = old_state_name
	end
end

function StateMachine:Update()
	if self._Duration == 0 then return end
	if self.CurrentState == nil then return end

	local t_now = workspace:GetServerTimeNow()
	local elapsed_time = t_now - self._StartTime

	if elapsed_time < self._Duration then return end

	local current_state: State = self.States[self.CurrentState]

	if not current_state.Completed then
		
		return
	end

	local next_state_name = current_state.Completed()

	if self.States[next_state_name] then
		self:Goto(next_state_name)
	else
		warn("[FSM] Completed() retornou um estado inexistente:", next_state_name)
	end
end

return StateMachine