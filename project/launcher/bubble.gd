extends RigidBody3D

var id := -1 :
	set(value):
		id = value
		if id == 1:
			var new_material := StandardMaterial3D.new()
			new_material.albedo_color = Color.RED
			$MeshInstance3D.material_override = new_material
