# Navalwars

A naval warfare game inspired by NavyField, built with Godot Engine 4.

## Features

### NavyField-Inspired Gameplay
- **Ship Combat**: Control warships with realistic movement and turning mechanics
- **Weapon Systems**: Fire naval guns with cooldown timers
- **Health System**: Ships have health points and can be destroyed
- **Enemy AI**: Computer-controlled enemy ships that detect, pursue, and attack the player
- **Naval Environment**: Ocean setting with camera following your ship

## Controls
- **W** - Move Forward
- **S** - Move Backward  
- **A** - Turn Left
- **D** - Turn Right
- **SPACE** - Fire Weapons

## How to Play
1. Open the project in Godot Engine 4.0 or higher
2. Run the main scene (scenes/main.tscn)
3. Control your ship using WASD keys
4. Fire at enemy ships with the SPACE bar
5. Avoid enemy fire and destroy all enemies

## Game Mechanics
- **Movement**: Ships accelerate and decelerate realistically, mimicking naval vessel physics
- **Combat**: Projectile-based combat system with bullet travel time
- **Enemy AI**: Enemies detect the player within range, pursue at appropriate distance, and fire when in attack range
- **Health Management**: Monitor your health bar in the top-left corner

## Technical Details
- Built with Godot Engine 4.0
- Uses GDScript for game logic
- 2D top-down perspective
- Modular scene structure for easy expansion

## Future Enhancements
- Multiple ship classes (destroyers, cruisers, battleships)
- Power-ups and upgrades
- Multiplayer support
- Additional weapon types
- Team-based combat
- Larger maps with obstacles