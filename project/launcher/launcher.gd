extends Node3D

@export var projectile_scene : PackedScene
@export var base_direction := Vector3(1,0,0)
@export var base_power := 20.0

func _ready() -> void:
	# Normalize the base direction so that power stays sensible
	base_direction = base_direction.normalized()


func launch() -> void:
	var ball : RigidBody3D = projectile_scene.instantiate()
	add_child(ball)
	ball.apply_impulse(base_direction * base_power)
