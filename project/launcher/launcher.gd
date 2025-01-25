extends Node3D

enum Facing {LEFT,RIGHT}

@export var shots_remaining := 6
@export var facing := Facing.RIGHT
@export var projectile_scene : PackedScene
@export var base_power := 20.0
@export var speed := 1.50

@onready var _path_follow = $Path3D/PathFollow3D
@onready var _rotation_indicator := $RotationIndicator
@onready var _timer := $PingPongTimer

## Public and exported so it can be animated
@export var power_ratio := 0.5:
	set(value):
		power_ratio = value
		var color := Color(value,value,value)
		$RotationIndicator/MeshInstance3D.get_active_material(0).albedo_color = color


func action_pressed() -> void:
	$StateChart.send_event('action_pressed')


func _on_selecting_position_state_physics_processing(_delta: float) -> void:
	_path_follow.progress_ratio = _timer.value


func _on_selecting_rotation_state_entered() -> void:
	_rotation_indicator.global_position = _path_follow.global_position
	_rotation_indicator.visible = true
	


func _on_selecting_rotation_state_physics_processing(_delta: float) -> void:
	_rotation_indicator.rotation.y = remap(_timer.value, 0, 1, -TAU/8,TAU/8)



func _on_selecting_power_state_physics_processing(_delta: float) -> void:
	power_ratio = _timer.value


func _on_shooting_state_entered() -> void:
	_rotation_indicator.visible = false
	_launch()
	if shots_remaining == 0:
		$StateChart.send_event("done")
	else:
		$StateChart.send_event("shoot_again")


func _launch() -> void:
	var direction := Vector3(1.0 if facing==Facing.RIGHT else -1.0, 0, 0)\
		.rotated(Vector3.UP, _rotation_indicator.rotation.y)
	var power := base_power * remap(power_ratio, 0, 1, 0.5, 1.5)
		
	var ball : RigidBody3D = projectile_scene.instantiate()
	add_child(ball)
	ball.global_position = _path_follow.global_position
	
	ball.apply_impulse(direction * power)
	
	shots_remaining -= 1
