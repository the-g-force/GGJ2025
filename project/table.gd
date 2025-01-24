extends StaticBody3D


func _physics_process(_delta: float) -> void:
	%LeftHinge["motor/enable"] = Input.is_action_pressed("flipper_left")
