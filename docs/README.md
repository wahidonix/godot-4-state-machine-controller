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

- [State Machine Architecture](state-machine.md) - Detailed explanation of the state machine system
- [Adding New States](adding-states.md) - Guide for extending the controller with new behaviors
- [Debug Tools](debug-tools.md) - Using the built-in debugging features
- [API Reference](api-reference.md) - Complete class and method documentation

## Features

- ✅ Modular state-based architecture
- ✅ Smooth movement and jumping physics
- ✅ **Dark Souls-style camera controls** with mouse look
- ✅ **Camera-relative movement** - WASD moves relative to camera direction
- ✅ **Automatic character rotation** - player faces movement direction
- ✅ **Third-person camera** with Phantom Camera integration
- ✅ Real-time debug UI
- ✅ Easy to extend with new states
- ✅ Clean separation of concerns

## Controls

- **WASD** - Move relative to camera direction
- **Mouse** - Look around / rotate camera
- **Space** - Jump
- **ESC** - Toggle mouse capture/release
- **`** (backtick) - Toggle debug overlay