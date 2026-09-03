class_name TinyStateMachine
extends RefCounted

## A state machine small enough to read in one sitting. States are just names
## with up to three callables attached, so nothing has to be a Node and nothing
## has to live in the scene tree.
##
##     var fsm := TinyStateMachine.new()
##     fsm.add_state(&"idle", _idle_update, _idle_enter)
##     fsm.add_state(&"run", _run_update)
##     fsm.travel(&"idle")
##     # in _physics_process:
##     fsm.update(delta)

signal state_changed(from: StringName, to: StringName)

## Name of the active state, or &"" before the first travel().
var current: StringName = &""

var _states: Dictionary = {}


## on_update receives delta. on_enter and on_exit take no arguments. Any of the
## three may be left empty.
func add_state(
	name: StringName,
	on_update := Callable(),
	on_enter := Callable(),
	on_exit := Callable()
) -> void:
	_states[name] = {"update": on_update, "enter": on_enter, "exit": on_exit}


func has_state(name: StringName) -> bool:
	return _states.has(name)


## Switch states. Travelling to the state you are already in does nothing, which
## makes it safe to call from inside an update.
func travel(name: StringName) -> void:
	if name == current:
		return
	if not _states.has(name):
		push_error("TinyStateMachine: unknown state '%s'" % name)
		return

	var previous := current
	if _states.has(previous):
		_call_if_valid(_states[previous]["exit"])

	current = name
	_call_if_valid(_states[current]["enter"])
	state_changed.emit(previous, current)


## Call once per frame with the frame delta.
func update(delta: float) -> void:
	if not _states.has(current):
		return
	var handler: Callable = _states[current]["update"]
	if handler.is_valid():
		handler.call(delta)


func _call_if_valid(handler: Callable) -> void:
	if handler.is_valid():
		handler.call()
