extends Node3D


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("fire_left"):
		%LeftLauncher.action_pressed()
	if Input.is_action_just_pressed("fire_right"):
		%RightLauncher.action_pressed()
