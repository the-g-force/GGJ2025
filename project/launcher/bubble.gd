extends RigidBody3D

const GOBLIN_INTERACTION_FRICTION := 0.3
const COLORS := [PlayerColors.BLUE, PlayerColors.RED]

var _material : ShaderMaterial
var id := -1 :
	set(value):
		id = value
		var new_material := ShaderMaterial.new()
		new_material.shader = preload("res://launcher/bubble.gdshader")
		new_material.set_shader_parameter("color", COLORS[id])
		$MeshInstance3D.material_override = new_material
		_material = new_material
var goblins := 0


func absorb_goblin() -> void:
	goblins += 1
	mass += 1
	$Goblin.visible = true
	# apply friction
	apply_central_impulse(-linear_velocity * GOBLIN_INTERACTION_FRICTION)


func pop() -> void:
	sleeping = true
	$CPUParticles3D.emitting = true
	get_tree().create_tween()\
		.tween_method(func (value): _material.set_shader_parameter("y_threshold", value), 1.0, 0.0, 0.3)\
		.set_trans(Tween.TRANS_SINE)
	get_tree().create_tween().tween_property($Goblin, "position", Vector3(0, -1, 0), 0.5).set_trans(Tween.TRANS_QUAD)
	await $CPUParticles3D.finished
	queue_free()
