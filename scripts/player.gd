extends CharacterBody3D

var state_machine: StateMachine
var debug_ui: Control

func _ready():
	state_machine = StateMachine.new(self)
	
	state_machine.add_state("idle", IdleState.new(self))
	state_machine.add_state("walking", WalkingState.new(self))
	state_machine.add_state("jumping", JumpingState.new(self))
	state_machine.add_state("falling", FallingState.new(self))
	
	state_machine.change_state("idle")
	
	var debug_scene = preload("res://scenes/debug_ui.tscn")
	debug_ui = debug_scene.instantiate()
	get_tree().current_scene.add_child.call_deferred(debug_ui)
	debug_ui.set_player(self)

func _physics_process(delta: float) -> void:
	state_machine.physics_update(delta)

func _process(delta: float) -> void:
	state_machine.update(delta)
	if debug_ui:
		debug_ui.update_debug_info()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug"):
		if debug_ui:
			debug_ui.toggle_visibility()
	
	state_machine.handle_input(event)
