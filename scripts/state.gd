extends Resource
class_name State

var player: CharacterBody3D
var state_machine

func _init(player_ref: CharacterBody3D):
	player = player_ref

func get_camera_relative_direction(input_dir: Vector2) -> Vector3:
	if not state_machine or not state_machine.camera:
		return (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var camera_transform = state_machine.camera.global_transform
	var camera_forward = -camera_transform.basis.z
	var camera_right = camera_transform.basis.x
	
	camera_forward.y = 0
	camera_right.y = 0
	camera_forward = camera_forward.normalized()
	camera_right = camera_right.normalized()
	
	return (camera_right * input_dir.x + camera_forward * -input_dir.y).normalized()

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