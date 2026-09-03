# gdscript-utils

Three GDScript files I end up copying into every Godot 4 project. No addon, no
autoload, no dependencies on each other. Copy the one you need and delete the
rest.

Everything here exists because I wrote it badly at least twice in a jam first.

## What is in here

- `state_machine.gd` — `TinyStateMachine`, a `RefCounted` state machine built
  on callables. States are names with optional enter/update/exit handlers.
  Nothing has to be a Node, so it works for enemies, menus and cutscenes alike.
- `cooldown.gd` — `Cooldown`, a countdown you tick yourself. For the dozen small
  timers per project that do not deserve a `Timer` node: dash recharge, coyote
  time, i-frames. `try_use()` consumes and reports in one call.
- `mathx.gd` — `MathX`, static helpers Godot does not ship: frame-rate
  independent damping, clamped remap, world-to-grid-cell conversion, weighted
  random picks.

`MathX` deliberately does not wrap `move_toward`, `snapped`, `remap` or
`angle_difference`. Those already exist, use them directly.

## Install

Requires Godot 4.2 or newer.

```
git clone https://github.com/poormikey80-create/gdscript-utils.git
```

Drop the `.gd` files anywhere in your project. Each declares a `class_name`, so
Godot registers them globally after one editor scan. No autoload entry needed.

## Usage

```gdscript
var fsm := TinyStateMachine.new()
fsm.add_state(&"idle", _idle_update, _idle_enter)
fsm.add_state(&"run", _run_update)
fsm.travel(&"idle")

var dash := Cooldown.new(0.6)

func _physics_process(delta: float) -> void:
    fsm.update(delta)
    dash.tick(delta)
    if Input.is_action_just_pressed("dash") and dash.try_use():
        fsm.travel(&"run")
    camera.position.x = MathX.damp(camera.position.x, target.x, 0.01, delta)
```

`damp()` is the one worth reading the comment on: pass the fraction of distance
left after a full second, not a per-frame weight. That is what makes it stable
when the frame rate drops.

## Licence

MIT. Copy it into your commercial game, no credit needed.
