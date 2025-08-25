# Adding New States

This guide shows how to extend the player controller with new states.

## Step 1: Create the State Class

Create a new file in `scripts/states/` directory:

```gdscript
# scripts/states/running_state.gd
extends State
class_name RunningState

const SPEED = 8.0  # Faster than walking

func enter():
    # Optional: Play running animation, sound effects, etc.
    print("Started running")

func exit():
    # Optional: Cleanup when leaving running state
    print("Stopped running")

func physics_update(delta: float):
    # Ground check
    if not player.is_on_floor():
        state_machine.change_state("falling")
        return
    
    # Jump check
    if Input.is_action_just_pressed("jump"):
        state_machine.change_state("jumping")
        return
    
    # Movement input
    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
    
    # Transition back to walking if shift is released
    if not Input.is_action_pressed("run"):
        if input_dir != Vector2.ZERO:
            state_machine.change_state("walking")
        else:
            state_machine.change_state("idle")
        return
    
    # Stop running if no input
    if input_dir == Vector2.ZERO:
        state_machine.change_state("idle")
        return
    
    # Apply running movement
    var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    player.velocity.x = direction.x * SPEED
    player.velocity.z = direction.z * SPEED
    
    player.move_and_slide()
```

## Step 2: Add Input Action

Add the new input action to your `project.godot`:

```ini
run={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194325,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)]
}
```

## Step 3: Register the State

Add the new state to the player's state machine in `scripts/player.gd`:

```gdscript
func _ready():
    state_machine = StateMachine.new(self)
    
    state_machine.add_state("idle", IdleState.new(self))
    state_machine.add_state("walking", WalkingState.new(self))
    state_machine.add_state("running", RunningState.new(self))  # Add this line
    state_machine.add_state("jumping", JumpingState.new(self))
    state_machine.add_state("falling", FallingState.new(self))
    state_machine.add_state("dash", DashState.new(self))  # Dash state is included
    
    state_machine.change_state("idle")
```

## Step 4: Add Transitions from Other States

Modify existing states to transition to your new state:

### In WalkingState:
```gdscript
func physics_update(delta: float):
    # ... existing code ...
    
    # Check for running
    if Input.is_action_pressed("run") and input_dir != Vector2.ZERO:
        state_machine.change_state("running")
        return
    
    # ... rest of existing code ...
```

### In IdleState:
```gdscript
func physics_update(delta: float):
    # ... existing code ...
    
    # Check for running
    if Input.is_action_pressed("run") and input_dir != Vector2.ZERO:
        state_machine.change_state("running")
        return
    
    # ... rest of existing code ...
```

## Common State Patterns

### State with Timer (Real Example: DashState)
The dash state is a perfect example of a timed state with cooldown system:

```gdscript
extends State
class_name DashState

var dash_timer: float = 0.0
var dash_direction: Vector3 = Vector3.ZERO

func enter():
    dash_timer = player.dash_duration  # Uses exported variable
    
    # Get input direction when dash starts
    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
    
    if input_dir.length() > 0.1:
        # Camera-relative dash direction
        dash_direction = get_camera_relative_direction(input_dir).normalized()
    else:
        # Forward dash if no input
        dash_direction = -player.transform.basis.z.normalized()
    
    # Apply dash velocity
    player.velocity.x = dash_direction.x * player.dash_speed
    player.velocity.z = dash_direction.z * player.dash_speed

func physics_update(delta: float):
    dash_timer -= delta
    
    # End dash when timer expires or speed drops too low
    if dash_timer <= 0.0 or player.velocity.length() <= player.movement_speed * 1.1:
        _end_dash()
        return
    
    # Smooth velocity decay and reduced gravity
    # ... rest of implementation
```

**Key Features:**
- **Timer-based duration** with automatic exit
- **Camera-relative direction** calculation  
- **Velocity management** with smooth decay
- **Smart state transitions** based on final conditions

### State with Animation
```gdscript
extends State
class_name CrouchState

func enter():
    # Assuming you have an AnimationPlayer
    if player.has_method("play_animation"):
        player.play_animation("crouch")

func exit():
    if player.has_method("play_animation"):
        player.play_animation("idle")
```

### State with Physics Changes
```gdscript
extends State
class_name SlideState

const SLIDE_SPEED = 6.0
var original_collision_shape

func enter():
    # Change collision shape for sliding
    original_collision_shape = player.collision_shape.shape
    # Set to a shorter capsule for sliding
    var new_shape = CapsuleShape3D.new()
    new_shape.height = original_collision_shape.height * 0.5
    player.collision_shape.shape = new_shape

func exit():
    # Restore original collision shape
    player.collision_shape.shape = original_collision_shape
```

## Best Practices

### 1. State Naming
- Use descriptive names ending in "State"
- Keep consistent with your game's terminology

### 2. Variables and Configuration
- **Use exported variables** from the player script instead of hardcoded constants
- Reference player properties like `player.movement_speed`, `player.jump_velocity`
- **Modern approach**: `player.dash_speed` instead of `const DASH_SPEED = 15.0`
- This allows real-time tuning in the inspector without code changes

### 3. Transitions
- **Check dash first** - it can interrupt any state when available
- Always check for higher-priority transitions (falling, jumping, dash)
- Group similar transition checks together  
- Use early returns to avoid nested conditions
- **Example priority order**: dash → falling → jumping → movement states

### 4. State Data
- Avoid storing data that persists between state changes in the state itself
- Use the player object for persistent data
- Use state variables for temporary state-specific data

### 5. Testing
- Test all possible transition paths
- Verify that states properly clean up on exit
- Use the debug UI to monitor state behavior

## Complex State Example: Wall Slide

```gdscript
extends State
class_name WallSlideState

const WALL_SLIDE_SPEED = 2.0
const WALL_JUMP_VELOCITY = Vector3(8.0, 6.0, 0.0)

var wall_normal: Vector3

func enter():
    # Find the wall we're sliding against
    for i in player.get_slide_collision_count():
        var collision = player.get_slide_collision(i)
        if abs(collision.get_normal().y) < 0.1:  # Vertical wall
            wall_normal = collision.get_normal()
            break

func physics_update(delta: float):
    # Apply gravity but limit fall speed
    player.velocity += player.get_gravity() * delta
    player.velocity.y = max(player.velocity.y, -WALL_SLIDE_SPEED)
    
    # Wall jump
    if Input.is_action_just_pressed("jump"):
        player.velocity = wall_normal * WALL_JUMP_VELOCITY.x
        player.velocity.y = WALL_JUMP_VELOCITY.y
        state_machine.change_state("jumping")
        return
    
    # Stop wall sliding if not against wall or no input
    if player.is_on_floor() or not _is_against_wall():
        state_machine.change_state("falling")
        return
    
    player.move_and_slide()

func _is_against_wall() -> bool:
    # Check if still against a wall
    for i in player.get_slide_collision_count():
        var collision = player.get_slide_collision(i)
        if abs(collision.get_normal().y) < 0.1:
            return true
    return false
```

This example shows advanced features like:
- Collision detection and normal calculation
- Limited gravity application
- Direction-based movement (wall jumping)
- Complex transition conditions