extends Area3D

const GOBLIN_SCENE_IDENTIFIERS := ["", "_blue", "_fangs_nose", "_round_ears", "_yellow"]

var scene_path := ""

@onready var _turn_delay_timer := $Timer


func _ready() -> void:
	$AnimationPlayer.seek(randf() * $AnimationPlayer.current_animation_length)
	rotation.y = TAU * randf()
	_start_turn_delay_timer()
	_load_goblin_glb()


func _load_goblin_glb() -> void:
	scene_path = "res://goblin/goblin%s.glb" % GOBLIN_SCENE_IDENTIFIERS.pick_random()
	var goblin : Node3D = load(scene_path).instantiate()
	$GoblinHandle.add_child(goblin)


func _start_turn_delay_timer() -> void:
	_turn_delay_timer.start(lerp(1.0, 3.0, randf()))


func _on_body_entered(body: Node3D) -> void:
	if body is RigidBody3D and not body.popping:
		body.absorb_goblin(scene_path)
		queue_free()


func _on_timer_timeout() -> void:
	await get_tree().create_tween()\
		.tween_property(self, "rotation", rotation + Vector3.UP * lerp(-PI / 6, PI / 6, randf()), 1.0)\
		.set_trans(Tween.TRANS_QUAD).finished
	_start_turn_delay_timer()
