# Player Controller Template Documentation

This project provides a modular 3D player controller for Godot 4.4.1 using a state machine architecture.

## Quick Start

1. Open the project in Godot 4.4.1
2. Run the `test.tscn` scene
3. Use WASD to move, Space to jump
4. Move mouse to look around (camera-relative movement)
5. Press ESC to toggle mouse capture
6. Press `~` (tilde) to toggle debug UI

## Documentation Structure

- [State Machine Architecture](docs/state-machine.md) - Detailed explanation of the state machine system
- [Adding New States](docs/adding-states.md) - Guide for extending the controller with new behaviors
- [Debug Tools](docs/debug-tools.md) - Using the built-in debugging features
- [API Reference](docs/api-reference.md) - Complete class and method documentation

## Features

- ✅ Modular state-based architecture
- ✅ Smooth movement and jumping physics
- ✅ **Dark Souls-style camera controls** with mouse look
- ✅ **Camera-relative movement** - WASD moves relative to camera direction
- ✅ **Automatic character rotation** - player faces movement direction
- ✅ **Third-person camera** with Phantom Camera integration
- ✅ **Dash system** with cooldown and camera-relative direction
- ✅ **Lock-on targeting system** with visual indicators
- ✅ **Target cycling** with mouse/gamepad controls
- ✅ **Smart target detection** within range and view angle
- ✅ Real-time debug UI
- ✅ Easy to extend with new states
- ✅ Clean separation of concerns

## Controls

- **WASD** - Move relative to camera direction
- **Mouse** - Look around / rotate camera (when not locked on)
- **Mouse Left/Right** - Cycle targets (when locked on)
- **Space** - Jump
- **Left Shift** - Dash (with cooldown)
- **Q** - Toggle lock-on target
- **ESC** - Toggle mouse capture/release
- **`** (backtick) - Toggle debug overlay

## Controller Support

- **Left Stick** - Movement
- **Right Stick** - Camera look (when not locked on) / Cycle targets (when locked on)
- **A Button** - Jump (Xbox) / X Button (PlayStation)
- **B Button** - Dash (Xbox) / Circle Button (PlayStation)
- **R3 (Right Stick Click)** - Toggle lock-on target

## Lock-On System

The lock-on system allows you to target and focus on enemies for combat and navigation:

### **Features:**
- **Smart Target Detection** - Finds enemies within configurable range and view angle
- **Visual Indicator** - Red dot with pulsing white ring marks locked targets
- **Camera Lock** - Camera smoothly follows locked target
- **Target Cycling** - Switch between multiple targets in view
- **Auto-Unlock** - Releases lock when target moves too far away

### **How to Use:**
1. **Lock On** - Press Q (keyboard) or R3 (gamepad) to lock onto nearest enemy
2. **Cycle Targets** - Move mouse left/right (keyboard) or right stick (gamepad) to switch targets
3. **Combat** - All movement and abilities work normally while locked on
4. **Unlock** - Press Q/R3 again or move too far from target

### **Configuration:**
Lock-on settings can be adjusted in the Player inspector:
- **Lock-On Range** - Maximum distance to detect targets (default: 25.0)
- **Lock-On Angle** - Detection cone angle in degrees (default: 120°)
- **Auto Unlock Distance** - Distance that breaks lock automatically (default: 35.0)
- **Target Switch Delay** - Cooldown between target switches (default: 0.3s)

### **Enemy Setup:**
To make enemies lockable:
1. Add to "lockable" group: `add_to_group("lockable")`
2. Add `LockOnPoint` child node positioned where you want the indicator
3. Implement `get_lock_on_point()` method returning the Node3D reference
