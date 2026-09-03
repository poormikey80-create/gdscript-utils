class_name MathX
extends Object

## Small maths helpers Godot does not already ship. Deliberately no wrappers for
## move_toward, snapped, remap, lerp_angle or angle_difference: those exist, use
## them directly.
##
## All static, so call them as MathX.damp(...) without instancing anything.


## Frame-rate independent smoothing. Unlike lerp(a, b, 0.1) in _process, the
## result does not change when the frame time does.
## smoothing is the fraction of the remaining distance left after one second:
## 0.01 is snappy, 0.5 is sluggish.
static func damp(from: float, to: float, smoothing: float, delta: float) -> float:
	return to + (from - to) * pow(clampf(smoothing, 0.0, 1.0), delta)


static func damp_vector(from: Vector2, to: Vector2, smoothing: float, delta: float) -> Vector2:
	var factor := pow(clampf(smoothing, 0.0, 1.0), delta)
	return to + (from - to) * factor


## remap() without the surprise of values outside the input range flying off.
static func remap_clamped(
	value: float,
	in_min: float,
	in_max: float,
	out_min: float,
	out_max: float
) -> float:
	if is_equal_approx(in_min, in_max):
		return out_min
	var t := clampf((value - in_min) / (in_max - in_min), 0.0, 1.0)
	return out_min + t * (out_max - out_min)


## World position to tile coordinate. Note this is not Vector2.snapped(): that
## gives you a position back, this gives you the cell index.
static func grid_cell(position: Vector2, cell_size: float) -> Vector2i:
	if cell_size <= 0.0:
		return Vector2i.ZERO
	return Vector2i(floori(position.x / cell_size), floori(position.y / cell_size))


## The centre of a cell in world space. Pairs with grid_cell for snapping.
static func cell_center(cell: Vector2i, cell_size: float) -> Vector2:
	return (Vector2(cell) + Vector2(0.5, 0.5)) * cell_size


## Pick an index from a weight table. Weights need not sum to 1. Returns -1 for
## an empty or all-zero table.
static func weighted_pick(weights: PackedFloat32Array) -> int:
	var total := 0.0
	for weight in weights:
		total += maxf(weight, 0.0)
	if total <= 0.0:
		return -1

	var roll := randf() * total
	for index in weights.size():
		roll -= maxf(weights[index], 0.0)
		if roll <= 0.0:
			return index
	return weights.size() - 1


## True with probability p. Reads better than randf() < p at the call site.
static func chance(p: float) -> bool:
	return randf() < clampf(p, 0.0, 1.0)


## Signed distance from a value to the nearest multiple of step. Useful for
## deciding whether something has drifted far enough off the grid to correct.
static func offset_from_step(value: float, step: float) -> float:
	if step <= 0.0:
		return 0.0
	return value - snappedf(value, step)
