extends Node3D

signal shot

@export var shots_remaining := 6
@export var projectile_scene : PackedScene
@export var base_power := 20.0
@export var speed := 1.50
@export var id := 0
@export var input_action : String

@onready var _path_follow = $Path3D/PathFollow3D
@onready var _timer := $PingPongTimer
@onready var _wand := %Wand

## Public and exported so it can be animated
@export var power_ratio := 0.5:
	set(value):
		power_ratio = value
		%PowerIndicator.scale.y = remap(power_ratio, 0, 1, 0.5, 1)


func _ready() -> void:
	_wand.color = PlayerColors.BLUE if id == 0 else PlayerColors.RED
	print("Set color to %s" + str(_wand.color))


func start_turn() -> void:
	$StateChart.send_event("start_turn")


func _on_selecting_position_state_entered() -> void:
	# Seed the timer to be wherever the wand currently is
	_timer.value = _path_follow.progress_ratio


func _on_selecting_position_state_physics_processing(_delta: float) -> void:
	_path_follow.progress_ratio = _timer.value
	_check_for_input()


func _on_selecting_rotation_state_physics_processing(_delta: float) -> void:
	_wand.rotation.y = remap(_timer.value, 0, 1, -TAU/8,TAU/8)
	_check_for_input()


func _on_selecting_power_state_physics_processing(_delta: float) -> void:
	power_ratio = _timer.value
	_check_for_input()


func _on_shooting_state_entered() -> void:
	_launch()
	_wand.rotation = Vector3.ZERO
	$StateChart.send_event("shot")


func _launch() -> void:
	var direction : Vector3 = Vector3.LEFT.rotated(Vector3.UP, _wand.global_rotation.y)
	var power := base_power * remap(power_ratio, 0, 1, 0.5, 1.5)
	
	var ball : RigidBody3D = projectile_scene.instantiate()
	add_child(ball)
	ball.global_position = _path_follow.global_position
	
	ball.apply_impulse(direction * power)
	ball.id = id
	
	shots_remaining -= 1
	shot.emit()
	

func _on_selecting_power_state_entered() -> void:
	%PowerIndicator.visible = true


func _on_selecting_power_state_exited() -> void:
	%PowerIndicator.visible = false


func _check_for_input() -> void:
	if Input.is_action_just_pressed(input_action):
		$StateChart.send_event('action_pressed')
