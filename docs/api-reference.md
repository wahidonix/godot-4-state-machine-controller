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

---

### StateMachine
**File:** `scripts/state_machine.gd`

Manages state transitions and delegates method calls to the active state.

#### Properties
```gdscript
var current_state: State         # Currently active state
var states: Dictionary = {}     # All registered states
var player: CharacterBody3D     # Reference to player
```

#### Methods

##### `_init(player_ref: CharacterBody3D)`
Constructor that sets the player reference.

**Parameters:**
- `player_ref`: The CharacterBody3D player instance

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
- Applies movement based on input direction
- Transitions to idle when no input
- Transitions to jumping/falling as appropriate

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
- Allows air control
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
- Allows air control
- Transitions to idle/walking when landing

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
```

#### Methods

##### `_ready() -> void`
Initializes the state machine and debug UI:
1. Creates StateMachine instance
2. Registers all states
3. Sets initial state to "idle"
4. Instantiates debug UI

##### `_physics_process(delta: float) -> void`
Delegates physics processing to the state machine.

##### `_process(delta: float) -> void`
Updates state machine and debug UI.

##### `_input(event: InputEvent) -> void`
Handles debug toggle input and delegates to state machine.

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

### Debug
- `toggle_debug` - ~ key (physical_keycode: 96)

---

## Constants Reference

All movement and physics constants used across the system:

```gdscript
# Movement
const SPEED = 5.0                # Units per second
const JUMP_VELOCITY = 4.5        # Initial jump velocity

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