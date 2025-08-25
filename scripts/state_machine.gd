extends Node
class_name StateMachine

var current_state: State
var states: Dictionary = {}
var player: CharacterBody3D
var camera: PhantomCamera3D

func _init(player_ref: CharacterBody3D, camera_ref: PhantomCamera3D = null):
	player = player_ref
	camera = camera_ref

func add_state(state_name: String, state: State):
	states[state_name] = state
	state.state_machine = self

func change_state(state_name: String):
	if current_state:
		current_state.exit()
	
	current_state = states.get(state_name)
	if current_state:
		current_state.enter()

func update(delta: float):
	if current_state:
		current_state.update(delta)

func physics_update(delta: float):
	if current_state:
		current_state.physics_update(delta)

func handle_input(event: InputEvent):
	if current_state:
		current_state.handle_input(event)