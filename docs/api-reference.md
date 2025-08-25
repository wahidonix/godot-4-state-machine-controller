# API Reference

Complete documentation for all classes and methods in the state machine system.

## Core Classes

### State (Base Class)
**File:** `scripts/state.gd`

Abstract base class for all player states.

#### Properties
```gdscript
var player: CharacterBody3D      # Reference to the player
var state_machine: StateMachine  # Reference to the state machine
```

#### Methods

##### `_init(player_ref: CharacterBody3D)`
Constructor that sets the player reference.

**Parameters:**
- `player_ref`: The CharacterBody3D player instance

##### `enter() -> void`
Called when transitioning into this state. Override for state initialization.

**Usage:**
```gdscript
func enter():
    print("Entering idle state")
    player.animation_player.play("idle")
```

##### `exit() -> void`
Called when transitioning out of this state. Override for cleanup.

**Usage:**
```gdscript
func exit():
    print("Exiting walking state")
```

##### `update(delta: float) -> void`
Called every frame during `_process()`. Override for non-physics updates.

**Parameters:**
- `delta`: Time since last frame

##### `physics_update(delta: float) -> void`
Called every physics frame during `_physics_process()`. Override for physics logic.

**Parameters:**
- `delta`: Physics timestep

##### `handle_input(event: InputEvent) -> void`
Called for input events during `_input()`. Override for input handling.

**Parameters:**
- `event`: The input event

##### `get_camera_relative_direction(input_dir: Vector2) -> Vector3`
Converts 2D input vector to 3D world direction relative to camera orientation.

**Parameters:**
- `input_dir`: 2D input vector from Input.get_vector()

**Returns:**
- `Vector3`: Normalized world direction relative to camera

**Usage:**
```gdscript
var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
var direction = get_camera_relative_direction(input_dir)
player.velocity.x = direction.x * SPEED
player.velocity.z = direction.z * SPEED
```

---

### StateMachine
**File:** `scripts/state_machine.gd`

Manages state transitions and delegates method calls to the active state.

#### Properties
```gdscript
var current_state: State         # Currently active state
var states: Dictionary = {}     # All registered states
var player: CharacterBody3D     # Reference to player
var camera: PhantomCamera3D      # Reference to camera for movement calculations
```

#### Methods

##### `_init(player_ref: CharacterBody3D, camera_ref: PhantomCamera3D = null)`
Constructor that sets the player and camera references.

**Parameters:**
- `player_ref`: The CharacterBody3D player instance
- `camera_ref`: Optional PhantomCamera3D for camera-relative movement

##### `add_state(state_name: String, state: State) -> void`
Registers a new state with the state machine.

**Parameters:**
- `state_name`: Unique identifier for the state
- `state`: The state instance to register

**Example:**
```gdscript
state_machine.add_state("idle", IdleState.new(self))
```

##### `change_state(state_name: String) -> void`
Transitions to a different state.

**Parameters:**
- `state_name`: Name of the state to transition to

**Example:**
```gdscript
state_machine.change_state("jumping")
```

**Behavior:**
1. Calls `exit()` on current state (if any)
2. Sets new current state
3. Calls `enter()` on new state

##### `update(delta: float) -> void`
Delegates to current state's `update()` method.

##### `physics_update(delta: float) -> void`
Delegates to current state's `physics_update()` method.

##### `handle_input(event: InputEvent) -> void`
Delegates to current state's `handle_input()` method.

---

## State Implementations

### IdleState
**File:** `scripts/states/idle_state.gd`

Handles stationary player behavior.

#### Constants
```gdscript
const SPEED = 5.0  # Deceleration speed
```

#### Key Behaviors
- Applies deceleration to stop movement
- Transitions to walking on input
- Transitions to jumping on jump input
- Transitions to falling when not on ground

---

### WalkingState
**File:** `scripts/states/walking_state.gd`

Handles ground-based movement.

#### Constants
```gdscript
const SPEED = 5.0  # Movement speed
```

#### Key Behaviors
- Applies **camera-relative** movement based on input direction
- Character **automatically rotates** to face movement direction
- Transitions to idle when no input
- Transitions to jumping/falling as appropriate
- **Smooth rotation** using `lerp_angle()` with 10.0 speed multiplier

---

### JumpingState
**File:** `scripts/states/jumping_state.gd`

Handles the ascending phase of jumps.

#### Constants
```gdscript
const SPEED = 5.0           # Air control speed
const JUMP_VELOCITY = 4.5   # Initial jump velocity
```

#### Key Behaviors
- Sets upward velocity on enter
- Applies gravity
- Allows **camera-relative air control**
- Character **rotates to face movement direction** while jumping
- **Slower rotation speed** (8.0) for realistic air movement
- Transitions to falling when velocity becomes negative

---

### FallingState
**File:** `scripts/states/falling_state.gd`

Handles falling and air control.

#### Constants
```gdscript
const SPEED = 5.0  # Air control speed
```

#### Key Behaviors
- Applies gravity continuously
- Allows **camera-relative air control**
- Character **rotates to face movement direction** while falling
- **Slower rotation speed** (8.0) for realistic air movement
- Transitions to idle/walking when landing

---

### DashState
**File:** `scripts/states/dash_state.gd`

Handles quick burst movement for evasion and traversal.

#### Key Behaviors
- **High-speed movement** using exported `dash_speed` variable (15.0 by default)
- **Camera-relative direction** or forward direction if no input
- **Timed duration** with automatic state transition when complete
- **Cooldown system** prevents dash spam
- **Reduced gravity** (30%) during dash for smoother feel
- **Instant rotation** to face dash direction
- **Smart transitions** back to appropriate state based on context

#### Special Features
- **Velocity decay** smoothly reduces speed back to normal
- **Ground vs Air** handling - different Y-velocity behavior
- **Universal access** - can be triggered from any other state
- **Physics integration** - works with existing collision and gravity systems

---

## Debug System

### DebugUI
**File:** `scripts/debug_ui.gd`

Provides real-time debugging information display.

#### Methods

##### `set_player(player_ref: CharacterBody3D) -> void`
Sets the player reference for debug monitoring.

##### `update_debug_info() -> void`
Updates all debug information displays. Called every frame when visible.

##### `toggle_visibility() -> void`
Toggles debug UI visibility on/off.

---

## Player Controller

### Player
**File:** `scripts/player.gd`

Main player controller that coordinates the state machine.

#### Properties
```gdscript
var state_machine: StateMachine  # The state machine instance
var debug_ui: Control           # Debug UI instance
var phantom_camera: PhantomCamera3D  # Camera reference for controls

# Camera settings
@export var mouse_sensitivity: float = 0.05
@export var controller_sensitivity: float = 2.0
@export var min_pitch: float = -89.9
@export var max_pitch: float = 50

# Movement settings
@export var movement_speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var ground_rotation_speed: float = 10.0
@export var air_rotation_speed: float = 8.0

# Physics settings
@export var gravity_multiplier: float = 1.0
@export var air_control_factor: float = 1.0

# Dash settings
@export var dash_speed: float = 15.0
@export var dash_duration: float = 0.3
@export var dash_cooldown: float = 1.0

var dash_cooldown_timer: float = 0.0
```

#### Methods

##### `_ready() -> void`
Initializes the state machine and debug UI:
1. Gets PhantomCamera3D reference
2. Creates StateMachine instance with camera reference
3. Registers all states
4. Sets initial state to "idle"
5. Instantiates debug UI
6. Enables mouse capture for third-person camera

##### `_physics_process(delta: float) -> void`
Delegates physics processing to the state machine.

##### `_process(delta: float) -> void`
Updates state machine and debug UI.

##### `_input(event: InputEvent) -> void`
Handles debug toggle, mouse capture toggle, camera controls, and delegates to state machine.

##### `_handle_camera_input(event: InputEvent) -> void`
Processes mouse motion for camera rotation using Phantom Camera's third-person mode.

**Parameters:**
- `event`: Input event (specifically handles InputEventMouseMotion)

**Behavior:**
- Rotates camera based on mouse movement
- Applies sensitivity scaling
- Clamps vertical rotation (pitch) to prevent camera flipping
- Wraps horizontal rotation (yaw) for smooth 360° movement

##### `can_dash() -> bool`
Checks if dash is currently available (cooldown has expired).

**Returns:**
- `bool`: true if dash can be used, false if on cooldown

##### `start_dash_cooldown() -> void`
Starts the dash cooldown timer, preventing dash use until timer expires.

---

## Input Actions

The following input actions must be defined in `project.godot`:

### Movement
- `move_forward` - W key (physical_keycode: 87)
- `move_backward` - S key (physical_keycode: 83)
- `move_left` - A key (physical_keycode: 65)
- `move_right` - D key (physical_keycode: 68)

### Actions
- `jump` - Space key (physical_keycode: 32)
- `dash` - Left Shift key (physical_keycode: 4194325)

### Camera Controls
- **Mouse Movement** - Camera rotation (automatically captured)
- **ESC key** - Toggle mouse capture/release

### Debug
- `toggle_debug` - ~ key (physical_keycode: 96)

---

## Constants Reference

All movement and physics constants used across the system:

```gdscript
# Movement
const SPEED = 5.0                # Units per second
const JUMP_VELOCITY = 4.5        # Initial jump velocity

# Camera Controls
const MOUSE_SENSITIVITY = 0.05   # Mouse look sensitivity
const CONTROLLER_SENSITIVITY = 2.0  # Controller look sensitivity
const MIN_PITCH = -89.9          # Minimum camera pitch (degrees)
const MAX_PITCH = 50.0           # Maximum camera pitch (degrees)
const GROUND_ROTATION_SPEED = 10.0  # Character rotation speed on ground
const AIR_ROTATION_SPEED = 8.0   # Character rotation speed in air

# Dash System
const DASH_SPEED = 15.0          # Dash burst speed
const DASH_DURATION = 0.3        # Dash duration in seconds
const DASH_COOLDOWN = 1.0        # Cooldown between dashes

# Debug
const DEBUG_UPDATE_RATE = 60     # Updates per second (when visible)
```

---

## Extension Points

### Adding New States

1. **Create state class**:
```gdscript
extends State
class_name CustomState

func physics_update(delta: float):
    # Your logic here
    pass
```

2. **Register in player**:
```gdscript
state_machine.add_state("custom", CustomState.new(self))
```

3. **Add transitions in other states**:
```gdscript
if some_condition:
    state_machine.change_state("custom")
```

### Custom Debug Information

Extend the debug UI by adding new labels and updating them in `update_debug_info()`.

### State Machine Events

You can add an event system to the state machine:

```gdscript
# In StateMachine
signal state_changed(from_state, to_state)

func change_state(state_name: String):
    var old_state = current_state
    # ... existing logic ...
    emit_signal("state_changed", old_state, current_state)
```

---

## Performance Notes

- Only one state is active at a time
- State transitions are lightweight operations
- Debug UI updates only when visible
- No unnecessary condition checking across states
- Physics calculations respect Godot's physics timestep