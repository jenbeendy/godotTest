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
	# Initially target the ball but STAY IDLE
	dog.target_ball = ball
	# Ensure ball is at player's feet
	ball.reset_to(player.global_position)

func _input(event):
	# Return to Menu
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.keycode == KEY_ESCAPE):
		get_tree().change_scene_to_file("res://menu.tscn")
	
	# Restart game
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		get_tree().reload_current_scene()

	if event is InputEventMouseButton:
		if event.pressed:
			if not ball.is_being_carried and dog.current_state == dog.State.IDLE:
				is_dragging = true
				drag_start_pos = event.position
				# Snap ball to player feet once
				ball.reset_to(player.global_position)
		elif not event.pressed and is_dragging:
			is_dragging = false
			var drag_vector = event.position - drag_start_pos
			throw_ball(drag_vector)

func throw_ball(vector):
	# Don't throw if drag was too small
	if vector.length() < 10:
		return
		
	var force_multiplier = 5.0
	ball.freeze = false
	ball.apply_central_impulse(vector * force_multiplier)

func _on_dog_ball_returned():
	returns_count += 1
	counter_label.text = str(returns_count)
	
	# Reset ball position to player's feet safely
	ball.reset_to(player.global_position)
	
	if returns_count >= GOAL_RETURNS:
		victory_panel.show()
