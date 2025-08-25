extends State
class_name FallingState

func physics_update(delta: float):
	player.velocity += player.get_gravity() * player.gravity_multiplier * delta
	
	if player.is_on_floor():
		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		if input_dir != Vector2.ZERO:
			state_machine.change_state("walking")
		else:
			state_machine.change_state("idle")
		return
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := get_camera_relative_direction(input_dir)
	
	if direction.length() > 0:
		player.velocity.x = direction.x * player.movement_speed * player.air_control_factor
		player.velocity.z = direction.z * player.movement_speed * player.air_control_factor
		
		var target_rotation = atan2(direction.x, direction.z)
		player.rotation.y = lerp_angle(player.rotation.y, target_rotation, player.air_rotation_speed * delta)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.movement_speed)
		player.velocity.z = move_toward(player.velocity.z, 0, player.movement_speed)
	
	player.move_and_slide()