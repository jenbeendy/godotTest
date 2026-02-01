extends CharacterBody2D

signal ball_returned

@export var speed = 400.0 # Slightly faster dog
@export var return_threshold = 10.0

enum State { IDLE, CHASING, RETURNING }
var current_state = State.IDLE

var target_ball = null
var home_position = Vector2.ZERO
var home_node = null
var carried_ball = null

func _ready():
	home_position = global_position

func _physics_process(_delta):
	# Update home position to be exactly at the player
	if home_node:
		home_position = home_node.global_position
	
	match current_state:
		State.IDLE:
			velocity = Vector2.ZERO
			# Only start chasing if ball is far enough and moving fast enough
			if target_ball and not target_ball.freeze:
				var dist = global_position.distance_to(target_ball.global_position)
				if target_ball.linear_velocity.length() > 50 and dist > 50:
					current_state = State.CHASING
		
		State.CHASING:
			if target_ball:
				var target_pos = target_ball.global_position
				var direction = (target_pos - global_position).normalized()
				velocity = direction * speed
				
				# Flip sprite based on direction
				if velocity.x != 0:
					$Sprite2D.flip_h = velocity.x < 0
			else:
				current_state = State.IDLE
		
		State.RETURNING:
			var direction = (home_position - global_position).normalized()
			velocity = direction * speed
			
			if velocity.x != 0:
				$Sprite2D.flip_h = velocity.x < 0
			
			if carried_ball:
				# Hold ball in mouth area
				var offset = Vector2(30 if velocity.x >= 0 else -30, 20)
				carried_ball.global_position = global_position + offset
			
			if global_position.distance_to(home_position) < return_threshold:
				drop_ball()

	move_and_slide()

func _on_detection_area_body_entered(body):
	if body == target_ball and current_state == State.CHASING:
		catch_ball(body)

func catch_ball(ball):
	carried_ball = ball
	ball.catch()
	current_state = State.RETURNING

func drop_ball():
	print("Dropped the ball at home.")
	if carried_ball:
		carried_ball.release()
		carried_ball = null
	current_state = State.IDLE
	emit_signal("ball_returned")
