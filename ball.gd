extends RigidBody2D

signal caught

var is_being_carried = false

func catch():
	is_being_carried = true
	freeze = true
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	emit_signal("caught")

func release():
	is_being_carried = false
	freeze = false

func reset_to(pos):
	freeze = true
	# Directly setting position while frozen works in Godot 4
	global_position = pos
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
