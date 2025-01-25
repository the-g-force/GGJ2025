extends Area3D

@onready var _turn_delay_timer := $Timer


func _ready() -> void:
	$AnimationPlayer.seek(randf() * $AnimationPlayer.current_animation_length)
	rotation.y = TAU * randf()
	_start_turn_delay_timer()


func _start_turn_delay_timer() -> void:
	_turn_delay_timer.start(lerp(1.0, 3.0, randf()))


func _on_body_entered(body: Node3D) -> void:
	if body is RigidBody3D and not body.popping:
		body.absorb_goblin()
		queue_free()


func _on_timer_timeout() -> void:
	await get_tree().create_tween()\
		.tween_property(self, "rotation", rotation + Vector3.UP * lerp(-PI / 6, PI / 6, randf()), 1.0)\
		.set_trans(Tween.TRANS_QUAD).finished
	_start_turn_delay_timer()
