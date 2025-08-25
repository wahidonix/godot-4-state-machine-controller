extends State
class_name IdleState

func physics_update(delta: float):
	if not player.is_on_floor():
		state_machine.change_state("falling")
		return
	
	if Input.is_action_just_pressed("dash") and player.can_dash():
		player.start_dash_cooldown()
		state_machine.change_state("dash")
		return
		
	if Input.is_action_just_pressed("jump"):
		state_machine.change_state("jumping")
		return
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if input_dir != Vector2.ZERO:
		state_machine.change_state("walking")
		return
	
	player.velocity.x = move_toward(player.velocity.x, 0, player.movement_speed)
	player.velocity.z = move_toward(player.velocity.z, 0, player.movement_speed)
	
	player.move_and_slide()
