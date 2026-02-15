# Naval Wars - Navyfield 1 Spinoff

A naval warfare game inspired by Navyfield 1, built with Godot 4.

## About

Naval Wars is a 2D naval combat game that draws inspiration from the classic Navyfield 1. Players control warships in tactical naval battles, managing speed, maneuverability, and various weapon systems.

## Features

- **Realistic Naval Physics**: Ships have realistic acceleration, turning radius that depends on speed, and water resistance
- **Weapon Systems**: 
  - Main Guns: High damage, slow reload (inspired by battleship main batteries)
  - Secondary Guns: Lower damage, faster reload (anti-ship and anti-aircraft capabilities)
- **Ship Management**: Monitor hull integrity, speed, and weapon status
- **Top-down Naval Combat**: Classic 2D perspective similar to Navyfield 1

## Controls

- **W**: Move Forward
- **S**: Move Backward
- **A**: Turn Left
- **D**: Turn Right
- **Space**: Fire Main Guns
- **Left Mouse Button**: Fire Secondary Guns

## Getting Started

### Prerequisites

- Godot Engine 4.2 or higher

### Running the Game

1. Clone this repository
2. Open the project in Godot Engine
3. Press F5 or click "Run Project" to start the game

## Project Structure

```
Navalwars/
├── scenes/           # Godot scene files
│   ├── main.tscn    # Main game scene
│   ├── ship.tscn    # Ship entity
│   ├── ocean.tscn   # Ocean environment
│   └── projectile.tscn # Projectile/shell
├── scripts/         # GDScript files
│   ├── game_manager.gd # Main game controller
│   ├── ship.gd         # Ship control and combat
│   ├── ocean.gd        # Ocean environment
│   └── projectile.gd   # Projectile physics
├── assets/          # Game assets
│   ├── sprites/     # Sprite images
│   └── sounds/      # Sound effects
└── project.godot    # Godot project configuration
```

## Game Mechanics

### Ship Movement
- Ships accelerate and decelerate gradually (realistic naval physics)
- Turning effectiveness increases with speed
- Water resistance affects movement

### Combat System
- **Main Guns**: Powerful weapons with 3-second reload time
  - Damage: 50 HP per hit
  - Range: 2000 units
  - Speed: 600 units/second
  
- **Secondary Guns**: Faster firing weapons with 1-second reload time
  - Damage: 15 HP per hit
  - Range: 2000 units
  - Speed: 700 units/second

### Ship Stats
- Hull Integrity: 100 HP (can be expanded for different ship classes)
- Maximum Speed: 200 units/second (~20 knots)
- Acceleration: 50 units/second²

## Future Development

- [ ] Multiple ship classes (Destroyer, Cruiser, Battleship, Carrier)
- [ ] Advanced AI formations and tactics
- [ ] Multiplayer support
- [ ] Additional weapon types (torpedoes, depth charges, aircraft)
- [ ] Port and repair systems
- [ ] Campaign mode with missions
- [ ] Ship upgrades and customization
- [ ] Realistic water shader effects
- [ ] Sound effects and music
- [ ] Particle effects for explosions and muzzle flashes

## Inspired by Navyfield 1

This project is inspired by the gameplay mechanics of Navyfield 1 (2006), including:
- Top-down naval combat perspective
- Ship class system with different roles
- Weapon reload mechanics
- Naval physics and movement
- Team-based naval warfare

## License

This project is a fan-made derivative work inspired by Navyfield 1 gameplay concepts.

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.
