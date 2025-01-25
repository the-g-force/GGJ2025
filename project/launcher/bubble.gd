extends RigidBody3D

const GOBLIN_INTERACTION_FRICTION := 0.3
const COLORS := [Color.BLUE, Color.RED]

var id := -1 :
	set(value):
		id = value
		var new_material := StandardMaterial3D.new()
		new_material.albedo_color = Color(COLORS[id], 0.9)
		new_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		new_material.roughness = 0.3
		$MeshInstance3D.material_override = new_material
var goblins := 0


func absorb_goblin() -> void:
	goblins += 1
	mass += 1
	$Goblin.visible = true
	# apply friction
	apply_central_impulse(-linear_velocity * GOBLIN_INTERACTION_FRICTION)
