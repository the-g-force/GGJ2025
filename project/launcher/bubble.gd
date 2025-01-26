extends RigidBody3D

const GOBLIN_INTERACTION_FRICTION := 0.3
const COLORS := [PlayerColors.BLUE, PlayerColors.RED]

var _material : ShaderMaterial
var id := -1 :
	set(value):
		id = value
		_update_bubble_material()
		_update_particle_mesh()
var goblins := 0
var popping := false
var points := 0

@onready var _score_popup := $ScorePopup


func _update_bubble_material() -> void:
	var new_material := ShaderMaterial.new()
	new_material.shader = preload("res://launcher/bubble.gdshader")
	new_material.set_shader_parameter("color", COLORS[id])
	$MeshInstance3D.material_override = new_material
	_material = new_material


func _update_particle_mesh() -> void:
	var new_material := StandardMaterial3D.new()
	new_material.albedo_color = COLORS[id]
	var mesh := SphereMesh.new()
	mesh.radius = 0.05
	mesh.height = 0.1
	mesh.material = new_material
	$CPUParticles3D.mesh = mesh


func absorb_goblin(path: String) -> void:
	if $Goblin.get_child_count() == 0: # don't have multiple goblin meshes in the bubble
		var goblin_glb : Node3D = load(path).instantiate()
		$Goblin.add_child(goblin_glb)
	goblins += 1
	mass += 1
	# apply friction
	apply_central_impulse(-linear_velocity * GOBLIN_INTERACTION_FRICTION)


func pop() -> void:
	sleeping = true
	popping = true
	$AnimationPlayer.stop()
	$Goblin.hide()
	$CPUParticles3D.emitting = true
	_score_popup.hide()
	get_tree().create_tween()\
		.tween_method(func (value): _material.set_shader_parameter("y_threshold", value), 1.0, 0.0, 0.3)\
		.set_trans(Tween.TRANS_SINE)
	
	await $CPUParticles3D.finished
	queue_free()


func score() -> void:
	_score_popup.text = "+%d" % points
	_score_popup.modulate = COLORS[id].lightened(0.2)
	var tween := create_tween().set_trans(Tween.TRANS_QUAD)
	tween.tween_property(_score_popup, "position", Vector3.UP, 0.1)
	tween.parallel().tween_property(_score_popup, "scale", Vector3.ONE, 0.1)
