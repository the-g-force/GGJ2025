extends Node3D

signal _settled
signal _all_bubbles_scored
signal _camera_in_position

@export var shots_per_round := 6
@export var points_to_win := 100
@export var inner_scoring_ring_radius := 3.0
@export var outer_scoring_ring_radius := 6.0

@onready var left_launcher := $LeftLauncher
@onready var right_launcher := $RightLauncher

var _left_score := 0
var _right_score := 0
var _rounds := 0

var _camera : Camera3D

func _ready() -> void:
	_camera = $AngledCamera.duplicate()
	add_child(_camera)
	_camera.make_current()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("mute"):
		var index := AudioServer.get_bus_index("Music")
		AudioServer.set_bus_mute(index, not AudioServer.is_bus_mute(index))
	
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
		body.pop()


func _on_normal_state_entered() -> void:
	_rounds += 1
	
	for launcher in [left_launcher,right_launcher]:
		launcher.shots_remaining = shots_per_round
	
	_switch_to_play_camera()
	%HUD.visible = true
	
	while %LeftLauncher.shots_remaining > 0:
		for launcher in [left_launcher, right_launcher]:
			launcher.start_turn()
			await launcher.shot
			await _settled
	
	$StateChart.send_event("score_round")


func _on_launcher_out_of_shots() -> void:
	if left_launcher.shots_remaining == 0 and right_launcher.shots_remaining == 0:
		$StateChart.send_event("wait_for_end")


func _on_title_state_entered() -> void:
	%Logo.visible = true
	%TitleCanvasLayer.visible = true
	for launcher in [left_launcher, right_launcher]:
		launcher.enter_attract_mode()


func _on_title_state_exited() -> void:
	%Logo.visible = false
	%TitleCanvasLayer.visible = false
	for launcher in [left_launcher, right_launcher]:
		launcher.begin_game()


func _on_title_state_input(event: InputEvent) -> void:
	if _is_any_key_pressed(event):
		$StateChart.send_event("start")


func _switch_to_play_camera() -> void:
	_animate_change_to($PlayCamera)


func _switch_to_angled_camera() -> void:
	_animate_change_to($AngledCamera)


func _animate_change_to(target : Camera3D) -> void:
	var tween := create_tween()
	tween.tween_property(_camera, "global_transform", target.global_transform, 1.0)
	tween.parallel().tween_property(_camera, "size", target.size, 1.0)
	await tween.finished
	_camera_in_position.emit()


func _on_end_of_round_state_entered() -> void:
	%EndOfRoundView.visible = true
	%EndOfRoundCanvas.visible = true


func _score_round() -> void:
	var bubbles := get_tree().get_nodes_in_group("bubble")
	bubbles.shuffle()
	for bubble in bubbles:
		if not bubble.popping:
			var points_for_bubble := 0
			var distance_from_center := Vector2(bubble.global_position.x, bubble.global_position.z).length()
			if distance_from_center <= inner_scoring_ring_radius:
				points_for_bubble = 15
			elif distance_from_center <= outer_scoring_ring_radius:
				points_for_bubble = 10
			else:
				points_for_bubble = 5
			points_for_bubble *= (1 + bubble.goblins)
			bubble.points = points_for_bubble
			if bubble.id == 0:
				_left_score += points_for_bubble
			else:
				_right_score += points_for_bubble
	for bubble in bubbles:
		bubble.score()
		await get_tree().create_timer(0.25).timeout
	_all_bubbles_scored.emit()
	_update_score_labels()


func _update_score_labels() -> void:
	%LeftScore.text = "Score: %d" % _left_score
	%RightScore.text = "Score: %d" % _right_score


func _on_end_of_round_state_exited() -> void:
	_switch_to_play_camera()
	%EndOfRoundView.visible = false
	%EndOfRoundCanvas.visible = false
	_reset_board()


func _reset_board() -> void:
	var bubbles := get_tree().get_nodes_in_group("bubble")
	for bubble in bubbles:
		bubble.pop()
	# I think that waiting until all the bubbles are cleared looks better.
	await get_tree().get_first_node_in_group("bubble").tree_exited
	for goblin in get_tree().get_nodes_in_group("goblin"):
		goblin.queue_free()
	$Table.spawn_goblins(_rounds)


func _on_end_of_round_state_input(event: InputEvent) -> void:
	if _is_any_key_pressed(event):
		$StateChart.send_event("start_next_round")


func _on_done_state_entered() -> void:
	%HUD.visible = false
	%EndOfGameView.visible = true
	var blue_wins := _left_score > _right_score
	%BlueModel.visible = blue_wins
	%RedModel.visible = not blue_wins
	
	await get_tree().create_timer(5.0).timeout
	$StateChart.send_event("reset")


func _on_done_state_exited() -> void:
	%EndOfGameView.visible = false
	_left_score = 0
	_right_score = 0
	_rounds = 0
	_update_score_labels()
	_reset_board()


## Check if a key was pressed so we can move on to a new state.
##
## Contrary to the name, this actually checks if a key was *released*,
## because otherwise, one might press Z, trigger state change, release Z,
## and trigger selecting blue's position, unintentionally.
func _is_any_key_pressed(event : InputEvent) -> bool:
	return event is InputEventKey and not event.pressed


func _on_scoring_state_entered() -> void:
	_switch_to_angled_camera()
	# wait for camera to be in position
	await _camera_in_position
	# calculate scores
	_score_round()
	# wait for all score popups to display
	await _all_bubbles_scored
	# wait little bit more
	await get_tree().create_timer(0.75).timeout
	
	# proceed
	var is_game_over := _left_score != _right_score \
		and (_left_score >= points_to_win or _right_score >= points_to_win)
	if is_game_over:
		$StateChart.send_event("game_over")
	else:
		$StateChart.send_event("round_over")


func _on_scoring_state_exited() -> void:
	for bubble in get_tree().get_nodes_in_group("bubble"):
		bubble.hide_score()
