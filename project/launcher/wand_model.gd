extends Node3D

var color : Color:
	set(value):
		color = value
		_material.albedo_color = color

var _material := preload("res://launcher/wand_material.tres").duplicate()


func _ready() -> void:
	$"mergedBlocks(Clone)".set_surface_override_material(0, _material)
