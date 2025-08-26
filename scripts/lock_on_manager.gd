extends Node
class_name LockOnManager

@export var lock_on_range: float = 15.0
@export var lock_on_angle: float = 60.0  # Degrees from camera forward
@export var auto_unlock_distance: float = 20.0

var current_target: Node3D = null
var player: CharacterBody3D
var camera: PhantomCamera3D

signal target_locked(target: Node3D)
signal target_unlocked()

func _init(player_ref: CharacterBody3D, camera_ref: PhantomCamera3D):
	player = player_ref
	camera = camera_ref

func find_best_target() -> Node3D:
	if not player or not player.get_tree():
		return null
		
	var lockable_enemies = player.get_tree().get_nodes_in_group("lockable")
	if lockable_enemies.is_empty():
		return null
	
	var best_target: Node3D = null
	var best_score: float = -1.0
	var camera_transform = camera.global_transform
	var camera_forward = -camera_transform.basis.z
	
	for enemy in lockable_enemies:
		if not enemy.has_method("get_lock_on_point"):
			continue
			
		var lock_point = enemy.get_lock_on_point()
		if not lock_point:
			continue
			
		var distance = player.global_position.distance_to(lock_point.global_position)
		if distance > lock_on_range:
			continue
		
		# Check if target is within lock-on angle
		var direction_to_target = (lock_point.global_position - camera.global_position).normalized()
		var angle = rad_to_deg(camera_forward.angle_to(direction_to_target))
		
		if angle > lock_on_angle / 2.0:
			continue
		
		# Score based on distance and angle (closer and more centered = better)
		var distance_score = 1.0 - (distance / lock_on_range)
		var angle_score = 1.0 - (angle / (lock_on_angle / 2.0))
		var total_score = (distance_score + angle_score) / 2.0
		
		if total_score > best_score:
			best_score = total_score
			best_target = enemy
	
	return best_target

func toggle_lock_on():
	if current_target:
		unlock_target()
	else:
		lock_on_to_best_target()

func cycle_target_left():
	if not is_locked_on():
		return
		
	var available_targets = get_available_targets()
	if available_targets.size() <= 1:
		return
		
	var current_index = available_targets.find(current_target)
	if current_index == -1:
		return
		
	# Move to previous target (wrapping around)
	var new_index = (current_index - 1 + available_targets.size()) % available_targets.size()
	lock_on_to_target(available_targets[new_index])

func cycle_target_right():
	if not is_locked_on():
		return
		
	var available_targets = get_available_targets()
	if available_targets.size() <= 1:
		return
		
	var current_index = available_targets.find(current_target)
	if current_index == -1:
		return
		
	# Move to next target (wrapping around)
	var new_index = (current_index + 1) % available_targets.size()
	lock_on_to_target(available_targets[new_index])

func get_available_targets() -> Array:
	if not player or not player.get_tree():
		return []
		
	var lockable_enemies = player.get_tree().get_nodes_in_group("lockable")
	var valid_targets = []
	
	if lockable_enemies.is_empty():
		return valid_targets
	
	var camera_transform = camera.global_transform
	var camera_forward = -camera_transform.basis.z
	
	for enemy in lockable_enemies:
		if not enemy.has_method("get_lock_on_point"):
			continue
			
		var lock_point = enemy.get_lock_on_point()
		if not lock_point:
			continue
			
		var distance = player.global_position.distance_to(lock_point.global_position)
		if distance > lock_on_range:
			continue
		
		# Check if target is within lock-on angle
		var direction_to_target = (lock_point.global_position - camera.global_position).normalized()
		var angle = rad_to_deg(camera_forward.angle_to(direction_to_target))
		
		if angle > lock_on_angle / 2.0:
			continue
			
		valid_targets.append(enemy)
	
	# Sort targets by horizontal position relative to camera (left to right)
	valid_targets.sort_custom(func(a, b): 
		var pos_a = camera.to_local(a.get_lock_on_point().global_position)
		var pos_b = camera.to_local(b.get_lock_on_point().global_position)
		return pos_a.x < pos_b.x
	)
	
	return valid_targets

func lock_on_to_best_target():
	var target = find_best_target()
	if target:
		lock_on_to_target(target)

func lock_on_to_target(target: Node3D):
	if current_target == target:
		return
		
	current_target = target
	target_locked.emit(target)

func unlock_target():
	if current_target:
		current_target = null
		target_unlocked.emit()

func update_lock_on(delta: float):
	if not current_target:
		return
	
	# Check if target still exists and is valid
	if not is_instance_valid(current_target) or not current_target.has_method("get_lock_on_point"):
		unlock_target()
		return
	
	var lock_point = current_target.get_lock_on_point()
	if not lock_point:
		unlock_target()
		return
	
	# Auto-unlock if target is too far
	var distance = player.global_position.distance_to(lock_point.global_position)
	if distance > auto_unlock_distance:
		unlock_target()
		return

func get_current_target_position() -> Vector3:
	if current_target and current_target.has_method("get_lock_on_point"):
		var lock_point = current_target.get_lock_on_point()
		if lock_point:
			return lock_point.global_position
	return Vector3.ZERO

func is_locked_on() -> bool:
	return current_target != null
