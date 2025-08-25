extends State
class_name WalkingState

const SPEED = 5.0

func physics_update(delta: float):
	if not player.is_on_floor():
		state_machine.change_state("falling")
		return
	
	if Input.is_action_just_pressed("jump"):
		state_machine.change_state("jumping")
		return
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if input_dir == Vector2.ZERO:
		state_machine.change_state("idle")
		return
	
	var direction := get_camera_relative_direction(input_dir)
	if direction.length() > 0:
		player.velocity.x = direction.x * SPEED
		player.velocity.z = direction.z * SPEED
		
		var target_rotation = atan2(direction.x, direction.z)
		player.rotation.y = lerp_angle(player.rotation.y, target_rotation, 10.0 * delta)
	
	player.move_and_slide()
