extends Control
class_name LockOnIndicator

@onready var dot: ColorRect = $Dot
@onready var ring: ColorRect = $Ring

var target_position: Vector3
var camera: Camera3D
var is_active: bool = false

func _ready():
	visible = false
	# Make dot and ring circular
	dot.pivot_offset = dot.size / 2
	ring.pivot_offset = ring.size / 2

func set_camera(cam: Camera3D):
	camera = cam

func show_indicator(world_position: Vector3):
	target_position = world_position
	is_active = true
	visible = true

func hide_indicator():
	is_active = false
	visible = false

func _process(delta: float):
	if not is_active or not camera:
		return
	
	# Convert 3D world position to 2D screen position
	var screen_pos = camera.unproject_position(target_position)
	
	# Check if target is behind camera or off screen
	var is_on_screen = camera.is_position_in_frustum(target_position)
	
	if is_on_screen:
		# Position the indicator at the screen coordinates
		dot.position = screen_pos - dot.size / 2
		ring.position = screen_pos - ring.size / 2
		
		# Animate the ring for a pulsing effect
		var pulse_scale = 1.0 + sin(Time.get_unix_time_from_system() * 4.0) * 0.2
		ring.scale = Vector2.ONE * pulse_scale
		
		modulate.a = 1.0
	else:
		# Hide if target is off screen or behind camera
		modulate.a = 0.3
