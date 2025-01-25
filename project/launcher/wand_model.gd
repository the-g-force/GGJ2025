extends Node3D

var color : Color:
	set(value):
		color = value
		_material.albedo_color = color

var _material := StandardMaterial3D.new()


func _ready() -> void:
	$"mergedBlocks(Clone)".set_surface_override_material(0, _material)
