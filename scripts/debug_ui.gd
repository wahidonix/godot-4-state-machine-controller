extends Control

@onready var current_state_label = $Panel/VBoxContainer/CurrentState
@onready var velocity_label = $Panel/VBoxContainer/Velocity
@onready var on_floor_label = $Panel/VBoxContainer/OnFloor
@onready var input_vector_label = $Panel/VBoxContainer/InputVector

var player: CharacterBody3D

func _ready():
	visible = false

func set_player(player_ref: CharacterBody3D):
	player = player_ref

func update_debug_info():
	if not player or not visible:
		return
	
	var current_state = ""
	if player.state_machine and player.state_machine.current_state:
		current_state = player.state_machine.current_state.get_script().get_global_name()
		if current_state.is_empty():
			current_state = str(player.state_machine.current_state).get_file().get_basename()
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	current_state_label.text = "Current State: " + current_state
	velocity_label.text = "Velocity: " + str(player.velocity.round())
	on_floor_label.text = "On Floor: " + str(player.is_on_floor())
	input_vector_label.text = "Input: " + str(input_dir.round())

func toggle_visibility():
	visible = !visible
