extends StaticBody3D

@export var pegs := 6
@export var peg_radius := 3.0


func _ready() -> void:
	for i in pegs:
		var peg := preload("res://table/peg.tscn").instantiate()
		peg.translate(Vector3(peg_radius,0,0).rotated(Vector3.UP, TAU/6 * i))
		add_child(peg)
	spawn_goblins()


func spawn_goblins() -> void:
	# spawns goblins in between the pegs
	for i in pegs:
		var goblin := preload("res://goblin/goblin.tscn").instantiate()
		goblin.position = Vector3.RIGHT.rotated(Vector3.UP, TAU * i / 6 + TAU / 12)\
			* peg_radius
		add_child(goblin)
