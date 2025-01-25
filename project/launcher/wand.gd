extends Node3D

var color : Color:
	set(value):
		color = value
		material.albedo_color = color

var material : StandardMaterial3D

func _ready() -> void:
	material = $Handle.material.duplicate()
	$Handle.material = material
	$Loop.material = material
