extends Node3D

@export var inner_scoring_ring_radius := 3.0
@export var outer_scoring_ring_radius := 6.0

@onready var left_launcher := $LeftLauncher
@onready var right_launcher := $RightLauncher


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("fire_left"):
		%LeftLauncher.action_pressed()
	if Input.is_action_just_pressed("fire_right"):
		%RightLauncher.action_pressed()


func _on_board_zone_body_exited(body: Node3D) -> void:
	if body is RigidBody3D:
		body.queue_free()


func _on_normal_state_entered() -> void:
	for launcher in [left_launcher,right_launcher]:
		launcher.out_of_shots.connect(_on_launcher_out_of_shots)


func _on_launcher_out_of_shots() -> void:
	if left_launcher.shots_remaining == 0 and right_launcher.shots_remaining == 0:
		$StateChart.send_event("wait_for_end")


func _on_waiting_for_end_state_physics_processing(_delta: float) -> void:
	# If all the bubbles are asleep, we are done.
	var bubbles := get_tree().get_nodes_in_group("bubble")
	for bubble in bubbles:
		if not bubble.sleeping:
			return
	$StateChart.send_event("done")


func _on_done_state_entered() -> void:
	# a negative score means player id 0 got points
	# a positive score means player id 1 got points
	var score := 0
	for bubble : RigidBody3D in get_tree().get_nodes_in_group("bubble"):
		var distance_from_center := Vector2(bubble.global_position.x, bubble.global_position.z).length()
		if distance_from_center <= inner_scoring_ring_radius:
			score += 15 * (-1 if bubble.id == 0 else 1)
		elif distance_from_center <= outer_scoring_ring_radius:
			score += 10 * (-1 if bubble.id == 0 else 1)
		else:
			score += 5 * (-1 if bubble.id == 0 else 1)
	if score == 0:
		print("it's a tie!")
	elif score > 0:
		print("red player got %d points!" % [score])
	else:
		print("blue player got %d points!" % [abs(score)])
