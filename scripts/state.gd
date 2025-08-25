extends Resource
class_name State

var player: CharacterBody3D
var state_machine

func _init(player_ref: CharacterBody3D):
	player = player_ref

func enter():
	pass

func exit():
	pass

func update(delta: float):
	pass

func physics_update(delta: float):
	pass

func handle_input(event: InputEvent):
	pass