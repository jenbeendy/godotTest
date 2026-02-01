extends RigidBody2D

signal caught

var is_being_carried = false
var _teleport_target = null

func _integrate_forces(state):
	if _teleport_target != null:
		var t = state.transform
		t.origin = _teleport_target
		state.transform = t
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0
		_teleport_target = null

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
	_teleport_target = pos
	freeze = true
	# Setting global_position here as well for immediate visual feedback
	# though _integrate_forces will do the "real" physics move
	global_position = pos
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
