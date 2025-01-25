extends Node3D

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
	print("DONE")
