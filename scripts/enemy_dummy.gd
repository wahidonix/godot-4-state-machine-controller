extends CharacterBody3D
class_name EnemyDummy

@onready var lock_on_point: Node3D = $LockOnPoint

func get_lock_on_point() -> Node3D:
	return lock_on_point

func _ready():
	# Add to lockable group for easy detection
	add_to_group("lockable")