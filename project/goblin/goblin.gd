extends Area3D


func _ready() -> void:
	$AnimationPlayer.seek(randf() * $AnimationPlayer.current_animation_length)


func _on_body_entered(body: Node3D) -> void:
	if body is RigidBody3D:
		body.absorb_goblin()
		queue_free()
