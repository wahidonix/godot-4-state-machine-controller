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
	
	var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	player.velocity.x = direction.x * SPEED
	player.velocity.z = direction.z * SPEED
	
	player.move_and_slide()