extends Node2D

var returns_count = 0
var is_dragging = false
var drag_start_pos = Vector2.ZERO

const GOAL_RETURNS = 5

@onready var ball = $Ball
@onready var dog = $Dog
@onready var player = $Player
@onready var counter_label = %CounterLabel
@onready var victory_panel = $UI/Control/VictoryPanel

func _ready():
	dog.home_node = player
	dog.connect("ball_returned", _on_dog_ball_returned)
	dog.target_ball = ball
	# Ensure starting position
	_reset_ball_to_player()

func _reset_ball_to_player():
	ball.reset_to(player.global_position)

func _input(event):
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.keycode == KEY_ESCAPE):
		get_tree().change_scene_to_file("res://menu.tscn")
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		get_tree().reload_current_scene()

	if event is InputEventMouseButton:
		if event.pressed:
			if not ball.is_being_carried and dog.current_state == dog.State.IDLE:
				is_dragging = true
				drag_start_pos = event.position
				_reset_ball_to_player()
		elif not event.pressed and is_dragging:
			is_dragging = false
			var drag_vector = event.position - drag_start_pos
			if drag_vector.length() > 10:
				throw_ball(drag_vector)

func throw_ball(vector):
	# 1. Unfreeze the ball
	ball.freeze = false
	
	# 2. Wait for the physics engine to synchronize the teleport and unfreeze
	# We wait two frames to be absolutely sure the transform is updated in the physics server
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	# 3. Apply the impulse. Since we reset_to(player) on click AND on return, 
	# and waited for sync, it should now originate from the player.
	var force_multiplier = 5.0
	ball.apply_central_impulse(vector * force_multiplier)

func _on_dog_ball_returned():
	returns_count += 1
	counter_label.text = str(returns_count)
	_reset_ball_to_player()
	
	if returns_count >= GOAL_RETURNS:
		victory_panel.show()
