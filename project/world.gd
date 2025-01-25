extends Node3D


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("fire_left"):
		%LeftLauncher.action_pressed()
	if Input.is_action_just_pressed("fire_right"):
		%RightLauncher.action_pressed()


func _on_board_zone_body_exited(body: Node3D) -> void:
	if body is RigidBody3D:
		body.queue_free()
		print("pop!")
