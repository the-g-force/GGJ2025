extends StaticBody3D

@export var pegs := 6
@export var peg_radius := 3.0


func _ready() -> void:
	for i in pegs:
		var peg := preload("res://table/peg.tscn").instantiate()
		peg.translate(Vector3(peg_radius,0,0).rotated(Vector3.UP, TAU/6 * i))
		add_child(peg)
