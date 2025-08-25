extends CharacterBody3D

var state_machine: StateMachine
var debug_ui: Control
var phantom_camera: PhantomCamera3D

@export_group("Camera Controls")
@export var mouse_sensitivity: float = 0.05
@export var controller_sensitivity: float = 2.0
@export var min_pitch: float = -89.9
@export var max_pitch: float = 50

@export_group("Movement Physics")
@export var movement_speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var ground_rotation_speed: float = 10.0
@export var air_rotation_speed: float = 8.0

@export_group("Physics Settings")
@export var gravity_multiplier: float = 1.0
@export var air_control_factor: float = 1.0

@export_group("Dash Settings")
@export var dash_speed: float = 15.0
@export var dash_duration: float = 0.3
@export var dash_cooldown: float = 1.0

var dash_cooldown_timer: float = 0.0

func _ready():
	phantom_camera = get_tree().current_scene.get_node("PlayerCam")
	state_machine = StateMachine.new(self, phantom_camera)
	
	state_machine.add_state("idle", IdleState.new(self))
	state_machine.add_state("walking", WalkingState.new(self))
	state_machine.add_state("jumping", JumpingState.new(self))
	state_machine.add_state("falling", FallingState.new(self))
	state_machine.add_state("dash", DashState.new(self))
	
	state_machine.change_state("idle")
	
	var debug_scene = preload("res://scenes/debug_ui.tscn")
	debug_ui = debug_scene.instantiate()
	get_tree().current_scene.add_child.call_deferred(debug_ui)
	debug_ui.set_player(self)
	
	if phantom_camera and phantom_camera.get_follow_mode() == phantom_camera.FollowMode.THIRD_PERSON:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	state_machine.physics_update(delta)

func _process(delta: float) -> void:
	state_machine.update(delta)
	if phantom_camera and phantom_camera.get_follow_mode() == phantom_camera.FollowMode.THIRD_PERSON:
		_handle_controller_camera(delta)
	
	# Update dash cooldown
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
		
	if debug_ui:
		debug_ui.update_debug_info()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug"):
		if debug_ui:
			debug_ui.toggle_visibility()
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if phantom_camera and phantom_camera.get_follow_mode() == phantom_camera.FollowMode.THIRD_PERSON:
		_handle_camera_input(event)
	
	state_machine.handle_input(event)

func _handle_camera_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var camera_rotation_degrees: Vector3 = phantom_camera.get_third_person_rotation_degrees()
		
		camera_rotation_degrees.x -= event.relative.y * mouse_sensitivity
		camera_rotation_degrees.x = clampf(camera_rotation_degrees.x, min_pitch, max_pitch)
		
		camera_rotation_degrees.y -= event.relative.x * mouse_sensitivity
		camera_rotation_degrees.y = wrapf(camera_rotation_degrees.y, 0, 360)
		
		phantom_camera.set_third_person_rotation_degrees(camera_rotation_degrees)

func can_dash() -> bool:
	return dash_cooldown_timer <= 0.0

func start_dash_cooldown():
	dash_cooldown_timer = dash_cooldown

func _handle_controller_camera(delta: float) -> void:
	var look_vector := Vector2.ZERO
	look_vector.x = Input.get_action_strength("camera_look_right") - Input.get_action_strength("camera_look_left")
	look_vector.y = Input.get_action_strength("camera_look_down") - Input.get_action_strength("camera_look_up")
	
	if look_vector.length() > 0.1:
		var camera_rotation_degrees: Vector3 = phantom_camera.get_third_person_rotation_degrees()
		
		camera_rotation_degrees.x -= look_vector.y * controller_sensitivity * 60.0 * delta
		camera_rotation_degrees.x = clampf(camera_rotation_degrees.x, min_pitch, max_pitch)
		
		camera_rotation_degrees.y -= look_vector.x * controller_sensitivity * 60.0 * delta
		camera_rotation_degrees.y = wrapf(camera_rotation_degrees.y, 0, 360)
		
		phantom_camera.set_third_person_rotation_degrees(camera_rotation_degrees)
