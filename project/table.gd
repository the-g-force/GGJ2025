extends CSGBox3D


func _physics_process(_delta: float) -> void:
	rotation.z = Input.get_joy_axis(0, JOY_AXIS_LEFT_X) * 0.5
	rotation.x = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y) * 0.5
#	%LeftHinge["motor/enable"] = Input.is_action_pressed("flipper_left")
