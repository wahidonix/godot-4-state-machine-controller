# State Machine Architecture

## Overview

The player controller uses a finite state machine (FSM) to manage different player behaviors. This approach provides clean separation of concerns, making the code more maintainable and extensible.

## Core Components

### 1. State (Base Class)
**File:** `scripts/state.gd`

The abstract base class that all player states inherit from.

```gdscript
extends Resource
class_name State

var player: CharacterBody3D
var state_machine
```

**Key Methods:**
- `enter()` - Called when transitioning INTO this state
- `exit()` - Called when transitioning OUT OF this state
- `update(delta)` - Called every frame during `_process()`
- `physics_update(delta)` - Called every physics frame during `_physics_process()`
- `handle_input(event)` - Called for input events during `_input()`

### 2. StateMachine (Manager Class)
**File:** `scripts/state_machine.gd`

Manages state transitions and delegates calls to the current active state.

```gdscript
extends Node
class_name StateMachine

var current_state: State
var states: Dictionary = {}
```

**Key Methods:**
- `add_state(name, state)` - Registers a new state
- `change_state(name)` - Transitions to a different state
- `update(delta)` / `physics_update(delta)` / `handle_input(event)` - Delegates to current state

## State Implementations

### IdleState
**File:** `scripts/states/idle_state.gd`

**Purpose:** Handles when the player is stationary on the ground.

**Behavior:**
- Applies deceleration to gradually stop movement
- Transitions to "walking" when movement input is detected
- Transitions to "jumping" when jump is pressed
- Transitions to "falling" when not on ground

**Transition Conditions:**
```gdscript
if not player.is_on_floor():
    state_machine.change_state("falling")
elif Input.is_action_just_pressed("jump"):
    state_machine.change_state("jumping")
elif input_dir != Vector2.ZERO:
    state_machine.change_state("walking")
```

### WalkingState
**File:** `scripts/states/walking_state.gd`

**Purpose:** Handles player movement when on the ground.

**Behavior:**
- Applies movement based on input direction
- Maintains constant speed (5.0 units/second)
- Transitions to "idle" when no input detected
- Can transition to "jumping" or "falling"

**Movement Logic:**
```gdscript
var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
player.velocity.x = direction.x * SPEED
player.velocity.z = direction.z * SPEED
```

### JumpingState
**File:** `scripts/states/jumping_state.gd`

**Purpose:** Handles the ascending phase of a jump.

**Behavior:**
- Sets initial upward velocity (4.5 units/second)
- Applies gravity each frame
- Allows air control for movement
- Transitions to "falling" when vertical velocity becomes negative

**Air Control:**
- Player can still move horizontally while jumping
- Same movement speed as ground movement
- Smooth deceleration when no input

### FallingState
**File:** `scripts/states/falling_state.gd`

**Purpose:** Handles when the player is airborne and descending.

**Behavior:**
- Applies gravity continuously
- Allows air control for movement
- Transitions to "idle" or "walking" when landing (based on input)

**Landing Logic:**
```gdscript
if player.is_on_floor():
    if input_dir != Vector2.ZERO:
        state_machine.change_state("walking")
    else:
        state_machine.change_state("idle")
```

## State Transition Diagram

```
    [Idle] ←→ [Walking]
      ↓         ↓
    [Jumping] → [Falling]
      ↑         ↓
      └─────────┘
      (when landing)
```

## Constants and Configuration

All states share these constants (defined in each state file):
- `SPEED = 5.0` - Movement speed in units/second
- `JUMP_VELOCITY = 4.5` - Initial jump velocity

## Physics Integration

The state machine integrates seamlessly with Godot's `CharacterBody3D`:
- Uses `move_and_slide()` for collision detection
- Respects `get_gravity()` for consistent physics
- Uses `is_on_floor()` for ground detection

## Debugging

Each state can be monitored in real-time using the debug UI (toggle with `~`):
- Current active state name
- Player velocity vector
- Ground detection status
- Input vector values

## Benefits of This Architecture

1. **Modularity** - Each behavior is isolated and testable
2. **Extensibility** - Easy to add new states (running, crouching, wall-sliding)
3. **Maintainability** - Clear separation of concerns
4. **Debugging** - Easy to trace which state is handling behavior
5. **Performance** - Only active state logic runs each frame

## Performance Considerations

- State transitions are lightweight (no complex calculations)
- Only one state is active at a time
- No unnecessary condition checking across multiple states
- Debug UI updates can be toggled off in production builds