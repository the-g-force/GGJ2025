extends Node3D

signal _settled

@export var inner_scoring_ring_radius := 3.0
@export var outer_scoring_ring_radius := 6.0

@onready var left_launcher := $LeftLauncher
@onready var right_launcher := $RightLauncher

var _left_score := 0
var _right_score := 0


func _process(_delta: float) -> void:
	%LeftShotsRemaining.text = "Bubbles: %d" % %LeftLauncher.shots_remaining
	%RightShotsRemaining.text = "Bubbles: %d" % %RightLauncher.shots_remaining
	
	# If all the bubbles are asleep, we are done.
	var bubbles := get_tree().get_nodes_in_group("bubble")
	for bubble in bubbles:
		if not bubble.sleeping:
			return
	_settled.emit()


func _on_board_zone_body_exited(body: Node3D) -> void:
	if body is RigidBody3D:
		body.queue_free()


func _on_normal_state_entered() -> void:
	%HUD.visible = true
	
	while %LeftLauncher.shots_remaining > 0:
		for launcher in [left_launcher, right_launcher]:
			launcher.start_turn()
			await launcher.shot
			await _settled
	
	$StateChart.send_event("done")


func _on_launcher_out_of_shots() -> void:
	if left_launcher.shots_remaining == 0 and right_launcher.shots_remaining == 0:
		$StateChart.send_event("wait_for_end")


func _on_done_state_entered() -> void:
	for bubble : RigidBody3D in get_tree().get_nodes_in_group("bubble"):
		var points_for_bubble := 0
		var distance_from_center := Vector2(bubble.global_position.x, bubble.global_position.z).length()
		if distance_from_center <= inner_scoring_ring_radius:
			points_for_bubble = 15
		elif distance_from_center <= outer_scoring_ring_radius:
			points_for_bubble = 10
		else:
			points_for_bubble = 5
		if bubble.id == 0:
			_left_score += points_for_bubble * (1 + bubble.goblins)
		else:
			_right_score += points_for_bubble * (1 + bubble.goblins)
	%LeftScore.text = "Score: %d" % _left_score
	%RightScore.text = "Score: %d" % _right_score


func _on_title_state_exited() -> void:
	%Logo.visible = false
	%TitleCanvasLayer.visible = false


func _on_play_button_pressed() -> void:
	$StateChart.send_event("start")
