extends State
class_name FallingState

const SPEED = 5.0

func physics_update(delta: float):
	player.velocity += player.get_gravity() * delta
	
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
		player.velocity.x = direction.x * SPEED
		player.velocity.z = direction.z * SPEED
		
		var target_rotation = atan2(direction.x, direction.z)
		player.rotation.y = lerp_angle(player.rotation.y, target_rotation, 8.0 * delta)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
		player.velocity.z = move_toward(player.velocity.z, 0, SPEED)
	
	player.move_and_slide()