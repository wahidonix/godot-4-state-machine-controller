# Debug Tools

The player controller includes built-in debugging tools to help you understand and tune the state machine behavior.

## Debug UI

### Activation
Press `~` (tilde key) to toggle the debug UI on/off during gameplay.

### Information Displayed

The debug panel shows real-time information:

- **Current State**: The active state name (e.g., "IdleState", "WalkingState")
- **Velocity**: The player's current velocity vector (x, y, z)
- **On Floor**: Whether the player is detected as being on the ground
- **Input**: The current input vector from WASD keys

### UI Layout

The debug UI appears as a semi-transparent panel in the bottom-left corner of the screen, containing:

```
Debug Info
──────────────
Current State: WalkingState
Velocity: (3, 0, -2)
On Floor: true
Input: (0.5, -0.3)
```

## Debug UI Implementation

### Files
- `scenes/debug_ui.tscn` - The UI scene layout
- `scripts/debug_ui.gd` - The debug UI controller script

### Key Methods

```gdscript
# Toggle debug UI visibility
func toggle_visibility():
    visible = !visible

# Update all debug information
func update_debug_info():
    # Updates all labels with current player state
```

## Custom Debug Information

You can extend the debug UI to show additional information:

### Adding New Debug Fields

1. **Add UI elements** to `debug_ui.tscn`:
```gdscript
# In the scene tree, add a new Label node
[node name="CustomInfo" type="Label" parent="Panel/VBoxContainer"]
layout_mode = 2
text = "Custom: 0"
```

2. **Update the script** in `debug_ui.gd`:
```gdscript
@onready var custom_info_label = $Panel/VBoxContainer/CustomInfo

func update_debug_info():
    # ... existing code ...
    
    # Add your custom debug info
    var custom_value = get_custom_debug_value()
    custom_info_label.text = "Custom: " + str(custom_value)

func get_custom_debug_value():
    # Your custom logic here
    return some_calculation()
```

### State-Specific Debug Info

You can add debug information that's specific to certain states:

```gdscript
func update_debug_info():
    # ... existing code ...
    
    # State-specific debugging
    if player.state_machine.current_state is JumpingState:
        var jump_state = player.state_machine.current_state as JumpingState
        # Show jump-specific info
        debug_label.text = "Jump Height: " + str(jump_state.get_jump_height())
```

## Performance Monitoring

Add performance monitoring to track frame rates and state transition frequency:

```gdscript
# Add to debug_ui.gd
var state_transitions: int = 0
var last_state_name: String = ""

func update_debug_info():
    # ... existing code ...
    
    # Track state transitions
    var current_state_name = get_current_state_name()
    if current_state_name != last_state_name:
        state_transitions += 1
        last_state_name = current_state_name
    
    # Show transition count
    transitions_label.text = "State Transitions: " + str(state_transitions)
    
    # Show FPS
    fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
```

## Console Output Debug

For more detailed debugging, you can add console output to states:

### In State Classes
```gdscript
# In any state file
func enter():
    if Debug.verbose_states:  # Custom debug flag
        print("[State] Entering ", get_script().get_global_name())

func exit():
    if Debug.verbose_states:
        print("[State] Exiting ", get_script().get_global_name())
```

### Create Debug Manager
```gdscript
# scripts/debug_manager.gd (singleton)
extends Node

var verbose_states: bool = false
var log_transitions: bool = false
var show_physics_info: bool = false

func _input(event):
    if event.is_action_pressed("debug_verbose"):
        verbose_states = !verbose_states
        print("Verbose states: ", verbose_states)
```

## Visual Debug Helpers

### State Visualization
Add visual indicators for different states:

```gdscript
# In player.gd
func _ready():
    # ... existing code ...
    
    # Create debug visual indicator
    if Debug.visual_states:
        create_state_indicator()

func create_state_indicator():
    var indicator = MeshInstance3D.new()
    var sphere = SphereMesh.new()
    sphere.radius = 0.2
    indicator.mesh = sphere
    add_child(indicator)
    indicator.position = Vector3(0, 2, 0)  # Above player
    
    # Change color based on state
    var material = StandardMaterial3D.new()
    update_state_color(material)
    indicator.material_override = material

func update_state_color(material: StandardMaterial3D):
    match state_machine.current_state.get_script().get_global_name():
        "IdleState":
            material.albedo_color = Color.BLUE
        "WalkingState":
            material.albedo_color = Color.GREEN
        "JumpingState":
            material.albedo_color = Color.YELLOW
        "FallingState":
            material.albedo_color = Color.RED
```

### Physics Debug Drawing
Show collision shapes and movement vectors:

```gdscript
# In debug_ui.gd or player.gd
func _draw_physics_debug():
    if not Debug.show_physics:
        return
    
    # Draw velocity vector
    var start_pos = player.global_position
    var end_pos = start_pos + player.velocity * 0.1
    
    # This would require a 3D debug drawing system
    draw_line_3d(start_pos, end_pos, Color.RED, 0.05)
    
    # Draw ground detection ray
    var ground_ray_end = start_pos + Vector3.DOWN * 1.1
    draw_line_3d(start_pos, ground_ray_end, Color.GREEN, 0.02)
```

## Debug Shortcuts

Add useful keyboard shortcuts for debugging:

```gdscript
# Add to project.godot input map
debug_reload_states={...}  # F5
debug_force_state={...}    # F6
debug_physics_info={...}   # F7

# In player.gd
func _input(event):
    if event.is_action_pressed("debug_reload_states"):
        reload_state_machine()
    elif event.is_action_pressed("debug_force_state"):
        cycle_through_states()
    elif event.is_action_pressed("debug_physics_info"):
        toggle_physics_debug()
```

## Production Builds

For production builds, you can disable debug features:

```gdscript
# In debug_ui.gd
func _ready():
    if OS.is_debug_build():
        visible = false
    else:
        # Hide debug UI in release builds
        queue_free()
```

Or use build flags:

```gdscript
# In project settings, define DEBUG_MODE
func _ready():
    if not ProjectSettings.get_setting("debug/debug_mode", false):
        queue_free()
```

## Troubleshooting Common Issues

### State Not Updating in Debug UI
- Check that `update_debug_info()` is being called every frame
- Verify the state machine has a valid current state
- Ensure the debug UI has a reference to the player

### Debug UI Not Toggling
- Confirm the `toggle_debug` input action is properly configured
- Check that the input event is reaching the player's `_input()` method
- Verify the debug UI scene is properly instantiated

### Performance Issues with Debug UI
- Only update debug info when UI is visible
- Consider using a timer to update less frequently (e.g., 10 times per second instead of 60)
- Disable string concatenation in release builds