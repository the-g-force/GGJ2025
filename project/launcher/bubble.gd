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


func absorb_goblin() -> void:
	goblins += 1
	mass += 1
	$Goblin.visible = true
	# apply friction
	apply_central_impulse(-linear_velocity * GOBLIN_INTERACTION_FRICTION)


func pop() -> void:
	sleeping = true
	$AnimationPlayer.stop()
	$CPUParticles3D.emitting = true
	get_tree().create_tween()\
		.tween_method(func (value): _material.set_shader_parameter("y_threshold", value), 1.0, 0.0, 0.3)\
		.set_trans(Tween.TRANS_SINE)
	
	# Warnings came from here when popping at end of round. Commenting out for now.
	#get_tree().create_tween().tween_property($Goblin, "position", Vector3(0, -1, 0), 0.5).set_trans(Tween.TRANS_QUAD)
	
	await $CPUParticles3D.finished
	queue_free()
