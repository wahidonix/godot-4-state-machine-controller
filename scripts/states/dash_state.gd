extends State
class_name DashState

var dash_timer: float = 0.0
var dash_direction: Vector3 = Vector3.ZERO

func enter():
	dash_timer = player.dash_duration
	
	# Get input direction when dash starts
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	if input_dir.length() > 0.1:
		# Dash in input direction (camera-relative)
		dash_direction = get_camera_relative_direction(input_dir).normalized()
	else:
		# Dash forward relative to player facing direction if no input
		dash_direction = -player.transform.basis.z.normalized()
	
	# Apply dash velocity
	player.velocity.x = dash_direction.x * player.dash_speed
	player.velocity.z = dash_direction.z * player.dash_speed
	
	# Reduce or eliminate Y velocity for ground dash
	if player.is_on_floor():
		player.velocity.y = 0.0
	else:
		# Slight downward momentum for air dash
		player.velocity.y = min(player.velocity.y, -1.0)

func physics_update(delta: float):
	dash_timer -= delta
	
	# Apply gravity during dash (reduced)
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * player.gravity_multiplier * delta * 0.3
	
	# Maintain dash velocity with slight decay
	var current_speed = Vector2(player.velocity.x, player.velocity.z).length()
	if current_speed > player.movement_speed:
		var decay_factor = pow(0.95, delta * 60.0)  # Smooth decay
		player.velocity.x *= decay_factor
		player.velocity.z *= decay_factor
	
	# Rotate player to face dash direction
	if dash_direction.length() > 0:
		var target_rotation = atan2(dash_direction.x, dash_direction.z)
		player.rotation.y = lerp_angle(player.rotation.y, target_rotation, player.ground_rotation_speed * 2.0 * delta)
	
	player.move_and_slide()
	
	# Check for dash end conditions
	if dash_timer <= 0.0 or player.velocity.length() <= player.movement_speed * 1.1:
		_end_dash()

func _end_dash():
	# Transition based on current state
	if not player.is_on_floor():
		if player.velocity.y > 0:
			state_machine.change_state("jumping")
		else:
			state_machine.change_state("falling")
	else:
		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		if input_dir.length() > 0.1:
			state_machine.change_state("walking")
		else:
			state_machine.change_state("idle")

func handle_input(event: InputEvent):
	# Can't dash again while already dashing
	pass