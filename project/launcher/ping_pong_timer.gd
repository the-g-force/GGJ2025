## Generates values that "ping-pong" between minimum and maximum
extends Node2D

@export var minimum := 0.0
@export var maximum := 1.0

## Seconds it takes to go from min back to min
@export var period := 2.0

## The current value of this timer
var value := minimum

var _increasing := true

func _physics_process(delta: float) -> void:
	if _increasing:
		value = min(maximum, value + period/2.0 * delta)
		if value >= maximum:
			_increasing = false
	else:
		value = max(minimum, value - period/2.0 * delta)
		if value <= minimum:
			_increasing = true
