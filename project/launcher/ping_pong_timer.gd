## Generates values that "ping-pong" between minimum and maximum
extends Node2D

@export var minimum := 0.0
@export var maximum := 1.0

## Seconds it takes to go from min back to min
@export var period := 2.0

## The current value of this timer
var value := minimum

func _ready() -> void:
	var half_period := period / 2.0
	while true:
		await create_tween().tween_property(self, "value", maximum, half_period).finished
		await create_tween().tween_property(self, "value", minimum, half_period).finished
