extends RigidBody3D

var power := 10

func _physics_process(_delta: float) -> void:
	var direction = Input.get_vector("left", "right", "down", "up")
	apply_central_force(Vector3(direction.x, 0, -direction.y)*power)
