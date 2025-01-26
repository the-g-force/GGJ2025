extends Node3D

signal shot

@export var shots_remaining := 6
@export var projectile_scene : PackedScene
@export var base_power := 20.0
@export var speed := 1.50
@export var id := 0
@export var input_action : String

@export_group("Attract mode")
@export var attract_rotation_speed := 1.2
## The amount the wands should raise in attract mode to stop them from clipping
## the board.
@export var attract_raise := 1.0
@export var raise_duration := 0.25

@onready var _path_follow = $Path3D/PathFollow3D
@onready var _timer := $PingPongTimer
@onready var _wand := %Wand

## Public and exported so it can be animated
@export var power_ratio := 0.5:
	set(value):
		power_ratio = value
		%PowerIndicator.scale.y = remap(power_ratio, 0, 1, 0.5, 1)
		%PowerIndicator.position.x = -%PowerIndicator.scale.y - 0.2


func _ready() -> void:
	_wand.color = PlayerColors.BLUE if id == 0 else PlayerColors.RED


func begin_game() -> void:
	$StateChart.send_event("begin_game")


func start_turn() -> void:
	$StateChart.send_event("start_turn")


func enter_attract_mode() -> void:
	$StateChart.send_event("enter_attract_mode")


func _on_attract_state_entered() -> void:
	create_tween().tween_property(_wand, "position:y", _wand.position.y+attract_raise, raise_duration)


func _on_attract_state_physics_processing(delta: float) -> void:
	_wand.rotate(Vector3.UP, TAU * attract_rotation_speed * delta)


func _on_attract_state_exited() -> void:
	create_tween().tween_property(_wand, "rotation:y", 0, 0.2)
	create_tween().tween_property(_wand, "position:y", _wand.position.y-attract_raise, raise_duration)


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
	Sfx.play_blow_sound()
	
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
