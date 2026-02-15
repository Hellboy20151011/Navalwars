# Naval Wars - Development Guide

## Project Overview

This is a Godot 4 game project inspired by Navyfield 1, featuring top-down naval combat with realistic ship physics and weapon systems.

## Architecture

### Scene Structure

The game uses a modular scene architecture:

1. **Main Scene** (`scenes/main.tscn`)
   - Root game container
   - Contains camera, ocean, player ship, and UI
   - Manages game state via `game_manager.gd`

2. **Ship Scene** (`scenes/ship.tscn`)
   - Player-controlled warship
   - CharacterBody2D with collision
   - Visual representation using Polygon2D
   - Weapon timers for reload mechanics

3. **Enemy Ship Scene** (`scenes/enemy_ship.tscn`)
   - AI-controlled enemy vessels
   - Detection area for player tracking
   - Similar structure to player ship

4. **Projectile Scene** (`scenes/projectile.tscn`)
   - Artillery shells/projectiles
   - Area2D for collision detection
   - Visual trail effect

5. **Ocean Scene** (`scenes/ocean.tscn`)
   - Environment background
   - Water rendering

### Script Architecture

All scripts use GDScript (Godot's native scripting language):

1. **game_manager.gd**
   - Controls game flow
   - Manages enemy spawning
   - Updates HUD
   - Tracks score and game time

2. **ship.gd**
   - Player ship controller
   - Input handling (WASD + Space + Mouse)
   - Physics-based movement
   - Weapon systems

3. **enemy_ship.gd**
   - AI behavior (patrol, engage, evade)
   - Target detection and tracking
   - Combat logic
   - State machine implementation

4. **projectile.gd**
   - Projectile physics
   - Damage dealing
   - Collision detection
   - Trail rendering

5. **ocean.gd**
   - Environment properties
   - Water resistance calculation

## Gameplay Mechanics

### Ship Movement

Ships use realistic naval physics:
- Gradual acceleration/deceleration
- Speed-dependent turning radius
- Water resistance (0.99 multiplier per frame)
- Forward/backward movement with WASD keys

### Combat System

#### Main Guns
- High damage (50 HP player, 40 HP enemy)
- Long reload time (3s player, 4s enemy)
- Fires from front and rear turrets
- Projectile speed: 600 units/s

#### Secondary Guns
- Lower damage (15 HP player, 12 HP enemy)
- Fast reload time (1s player, 1.5s enemy)
- Rapid fire capability
- Projectile speed: 700 units/s

### AI System

Enemy ships use a three-state AI:

1. **Patrol State**
   - Default behavior
   - Moves to random waypoints
   - Searches for player

2. **Engage State**
   - Active when player detected
   - Maintains optimal combat range (500 units)
   - Circles target
   - Fires weapons when aimed

3. **Evade State**
   - Triggered at <30% health
   - Retreats from player
   - Returns to engage at >40% health

### Collision Layers

- Layer 1: Player ship
- Layer 2: Enemy ships
- Layer 4: Projectiles

## Adding New Features

### Adding a New Ship Class

1. Duplicate `ship.tscn` or `enemy_ship.tscn`
2. Modify stats in the script:
   ```gdscript
   @export var max_health: int = 150  # Battleship example
   @export var max_speed: float = 120.0  # Slower
   @export var main_gun_damage: int = 80  # More powerful
   ```
3. Adjust visual polygon for ship size
4. Update collision shape

### Adding New Weapons

1. Create new Timer node in ship scene
2. Add export variables for weapon stats
3. Implement fire method:
   ```gdscript
   func fire_torpedoes():
       if not can_fire_torpedoes:
           return
       can_fire_torpedoes = false
       $TorpedoTimer.start()
       _spawn_projectile(Vector2(20, 0), torpedo_damage, 300.0)
   ```
4. Connect timer timeout signal

### Adding Visual Effects

#### Explosion Effect
```gdscript
func _destroy_ship():
    # Create explosion particles
    var explosion = preload("res://scenes/explosion.tscn").instantiate()
    get_parent().add_child(explosion)
    explosion.global_position = global_position
    queue_free()
```

#### Muzzle Flash
```gdscript
func fire_main_guns():
    # ... existing code ...
    _create_muzzle_flash(Vector2(0, -30))
    
func _create_muzzle_flash(offset: Vector2):
    var flash = Sprite2D.new()
    add_child(flash)
    flash.position = offset
    # Add animation/timer to remove flash
```

## Testing

Since Godot is not available in this environment, testing should be done by:

1. Opening the project in Godot Engine 4.2+
2. Running the main scene (F5)
3. Testing controls:
   - W/S for forward/backward
   - A/D for turning
   - Space for main guns
   - Left mouse for secondary guns

### Expected Behavior

- Player ship should spawn at center
- Two enemy ships should spawn at start
- Enemies spawn every 20 seconds
- Projectiles should deal damage on hit
- Ships should be destroyed at 0 HP
- Score increases by 100 per enemy kill
- Game restarts on player death

## Performance Considerations

- Projectiles auto-delete after 5 seconds
- Enemy ships cleanup on destruction
- Trail renderer limits to 10 points
- Camera lerp for smooth following

## Future Enhancements

See README.md for planned features including:
- Multiple ship classes
- Advanced AI formations
- Multiplayer networking
- Campaign missions
- Upgrade systems
- Sound and visual effects

## File Naming Conventions

- Scenes: lowercase with underscores (e.g., `enemy_ship.tscn`)
- Scripts: match scene name (e.g., `enemy_ship.gd`)
- Assets: descriptive names (e.g., `battleship_sprite.png`)

## Godot Version

This project targets Godot 4.2 or higher. Key features used:
- CharacterBody2D for ship physics
- Area2D for projectiles and detection
- Signals for event communication
- @export variables for inspector editing
- Preload for scene instantiation
