extends Node3D

@export var projectile_scene : PackedScene
@export var base_direction := Vector3(1,0,0)
@export var base_power := 20.0
@export var speed := 1.50

@onready var _path_follow = $Path3D/PathFollow3D
var _increasing := true

func _ready() -> void:
	# Normalize the base direction so that power stays sensible
	base_direction = base_direction.normalized()


func _process(delta: float) -> void:
	if _increasing:
		_path_follow.progress_ratio += speed * delta
		if _path_follow.progress_ratio >= 1.0:
			_path_follow.progress_ratio -= _path_follow.progress_ratio - 1.0
			_increasing = false
	else:
		_path_follow.progress_ratio -= speed * delta
		if _path_follow.progress_ratio <= 0:
			_path_follow.progress_ratio = -_path_follow.progress_ratio
			_increasing = true

func launch() -> void:
	var ball : RigidBody3D = projectile_scene.instantiate()
	add_child(ball)
	ball.global_position = _path_follow.global_position
	ball.apply_impulse(base_direction * base_power)
