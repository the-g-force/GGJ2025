extends Node3D

var color : Color:
	set(value):
		color = value
		_material.albedo_color = color

var _material : StandardMaterial3D

func _ready() -> void:
	_material = $Handle.material.duplicate()
	$Handle.material = _material
	$Loop.material = _material
