class_name Cooldown
extends RefCounted

## A countdown you drive yourself, for the dozens of small timers a game needs
## that do not deserve their own Timer node: dash recharge, shot delay, coyote
## time, invulnerability frames.
##
##     var dash := Cooldown.new(0.6)
##     # in _physics_process:
##     dash.tick(delta)
##     if Input.is_action_just_pressed("dash") and dash.try_use():
##         _start_dash()

signal finished

## How long a use blocks the next one, in seconds.
var duration: float = 1.0

var _remaining: float = 0.0


func _init(seconds: float = 1.0) -> void:
	duration = maxf(seconds, 0.0)


## Advance the clock. Returns true only on the tick where it becomes ready
## again, so it doubles as a "just recharged" check.
func tick(delta: float) -> bool:
	if _remaining <= 0.0:
		return false
	_remaining -= delta
	if _remaining > 0.0:
		return false
	_remaining = 0.0
	finished.emit()
	return true


func is_ready() -> bool:
	return _remaining <= 0.0


## Consume the cooldown if it is available. Returns false when still charging,
## which keeps the caller down to a single if.
func try_use() -> bool:
	if not is_ready():
		return false
	_remaining = duration
	return true


## Start the countdown regardless of state, optionally with a one-off length.
func start(seconds: float = -1.0) -> void:
	_remaining = duration if seconds < 0.0 else maxf(seconds, 0.0)


func cancel() -> void:
	_remaining = 0.0


func time_left() -> float:
	return _remaining


## 0.0 right after a use, 1.0 when ready. Feed it straight to a ProgressBar.
func progress() -> float:
	if duration <= 0.0:
		return 1.0
	return clampf(1.0 - _remaining / duration, 0.0, 1.0)
