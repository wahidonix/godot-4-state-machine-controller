extends State
class_name JumpingState

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func enter():
	player.velocity.y = JUMP_VELOCITY

func physics_update(delta: float):
	player.velocity += player.get_gravity() * delta
	
	if player.velocity.y <= 0:
		state_machine.change_state("falling")
		return
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		player.velocity.x = direction.x * SPEED
		player.velocity.z = direction.z * SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
		player.velocity.z = move_toward(player.velocity.z, 0, SPEED)
	
	player.move_and_slide()