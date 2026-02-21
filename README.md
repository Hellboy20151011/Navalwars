# Naval Wars - Navyfield 1 Spinoff

A naval warfare game inspired by Navyfield 1, built with Godot 4.

## About

Naval Wars is a 2D naval combat game that draws inspiration from the classic Navyfield 1. Players control warships in tactical naval battles, managing speed, maneuverability, and various weapon systems.

## Features

- **Login System** (NEW!): Simple username-based login screen to start the game
- **Ship Yard / Dry Dock** (NEW!): Main configuration screen where players can:
  - Select ship class (Destroyer, Cruiser, Battleship, Carrier)
  - Configure weapons (Main guns and secondary guns)
  - Choose propulsion system
  - Select fire control system
  - Assign crew to the ship
- **Battle Menu** (NEW!): Select battle modes and start practice battles
- **Realistic Naval Physics**: Ships have realistic acceleration, turning radius that depends on speed, and water resistance
- **Ship Class System**: 
  - Destroyer: Fast and maneuverable, lower damage
  - Cruiser: Balanced all-around performance
  - Battleship: Slow but powerful, heavy armor
  - Carrier: Support vessel with excellent detection
- **Weapon Systems**: 
  - Main Guns: High damage, slow reload (inspired by battleship main batteries)
  - Secondary Guns: Lower damage, faster reload (anti-ship and anti-aircraft capabilities)
  - Muzzle flash effects for visual feedback
- **Ship Management**: Monitor hull integrity, speed, weapon status, and ship class
- **Top-down Naval Combat**: Classic 2D perspective similar to Navyfield 1
- **Tactical Minimap**: Real-time overview of battle arena showing player and enemy positions
- **World Boundaries**: Defined battle arena with visual boundary markers
- **Visual Effects**: Explosion effects for ship destruction and projectile impacts

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
4. You'll see the login screen:
   - Enter a username (password optional for now)
   - Press Enter or click "Login"
5. Configure your ship in the Ship Yard:
   - Choose ship class using "< PREV" and "NEXT >" buttons
   - Configure weapons, engine, and fire control
   - Assign crew if desired
6. Click "Enter Battle" to go to the Battle Menu
7. Click "Start Practice Battle" to begin combat
8. Use "Return to Menu" button to exit battle and reconfigure your ship

## Project Structure

```
naval-wars/
├── scenes/                # Godot scene files
│   ├── login_screen.tscn # Login screen (NEW!)
│   ├── ship_yard.tscn    # Ship configuration/dry dock (NEW!)
│   ├── battle_menu.tscn  # Battle selection menu (NEW!)
│   ├── main.tscn         # Main battle scene
│   ├── ship.tscn         # Ship entity
│   ├── ocean.tscn        # Ocean environment
│   └── projectile.tscn   # Projectile/shell
├── scripts/               # GDScript files
│   ├── login_screen.gd   # Login logic (NEW!)
│   ├── ship_yard.gd      # Ship configuration logic (NEW!)
│   ├── battle_menu.gd    # Battle menu logic (NEW!)
│   ├── game_state.gd     # Global state manager (NEW!)
│   ├── game_manager.gd   # Main game controller
│   ├── ship.gd           # Ship control and combat
│   ├── ocean.gd          # Ocean environment
│   └── projectile.gd     # Projectile physics
├── assets/                # Game assets
│   ├── sprites/          # Sprite images
│   └── sounds/           # Sound effects
└── project.godot         # Godot project configuration
```

## Game Mechanics

### Ship Movement
- Ships accelerate and decelerate gradually (realistic naval physics)
- Turning effectiveness increases with speed
- Water resistance affects movement

### Combat System
### Ship Classes (NavyField-Inspired)

**Destroyer (DD)**
- Health: 60 HP
- Speed: Fast (250 units/s, ~25 knots)
- Main Guns: 30 damage, 2.5s reload
- Role: Hit-and-run tactics, fast response

**Cruiser (CA)**
- Health: 100 HP
- Speed: Medium (200 units/s, ~20 knots)
- Main Guns: 50 damage, 3.0s reload
- Role: Balanced all-around combat

**Battleship (BB)**
- Health: 200 HP
- Speed: Slow (120 units/s, ~12 knots)
- Main Guns: 100 damage, 5.0s reload
- Role: Heavy firepower, tank damage

**Carrier (CV)**
- Health: 150 HP
- Speed: Medium-slow (150 units/s, ~15 knots)
- Main Guns: 10 damage, 4.0s reload
- Role: Support, excellent detection range

### Combat System

- **Main Guns**: Powerful weapons with class-specific reload times
  - Range: 2000 units
  - Speed: 600 units/second
  - Damage varies by ship class
  
- **Secondary Guns**: Faster firing weapons for sustained fire
  - Range: 2000 units
  - Speed: 700 units/second
  - Damage varies by ship class

### Map Features
- **Battle Arena**: 5000x5000 unit ocean battlefield
- **World Boundaries**: Visual markers showing map limits
- **Tactical Minimap**: Real-time 200x200 pixel overview

## Future Development

- [x] Multiple ship classes (Destroyer, Cruiser, Battleship, Carrier)
- [x] Visual effects (explosions, muzzle flashes)
- [x] Tactical minimap
- [x] World boundaries
- [x] Login system
- [x] Ship yard / dry dock configuration screen
- [x] Battle menu and navigation flow
- [ ] Apply ship configuration to actual battle stats
- [ ] Enhanced ship visual representation in dry dock
- [ ] Advanced AI formations and tactics
- [ ] Multiplayer support
- [ ] Additional weapon types (torpedoes, depth charges, aircraft)
- [ ] Port and repair systems
- [ ] Campaign mode with missions
- [ ] Ship upgrades and progression system
- [ ] Realistic water shader effects
- [ ] Sound effects and music
- [ ] Team-based combat (Red vs Blue teams)
- [ ] More detailed particle effects
- [ ] User authentication system

## Inspired by Navyfield 1

This project is inspired by the gameplay mechanics of Navyfield 1 (2006), including:
- Top-down naval combat perspective
- Ship class system with different roles
- Weapon reload mechanics
- Naval physics and movement
- Team-based naval warfare

## License

This project is a fan-made derivative work inspired by Navyfield 1 gameplay concepts.

## Documentation

Additional documentation is available in the following files:
- **[Player Statistics Recommendations (English)](PLAYER_STATISTICS_RECOMMENDATIONS.md)** - Comprehensive guide on implementing player statistics storage, currency systems, ship ownership, and crew management
- **[Spieler Statistiken Empfehlungen (Deutsch)](SPIELER_STATISTIKEN_EMPFEHLUNGEN.md)** - Deutsche Version der Empfehlungen für Spielerstatistiken

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.
