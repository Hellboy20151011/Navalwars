# Naval Wars - Testing Guide for New Features

## Overview
This document describes the newly implemented features: Login Screen, Ship Yard (Dry Dock), and Battle Menu navigation.

## New Features

### 1. Login Screen
- **Location**: Entry point of the game (`scenes/login_screen.tscn`)
- **Features**:
  - Username input field
  - Password input field (secret)
  - Login button
  - Enter key support for quick login
  - Simple validation (requires non-empty username)

### 2. Ship Yard / Dry Dock
- **Location**: Main configuration screen (`scenes/ship_yard.tscn`)
- **Features**:
  - Visual ship display in dry dock
  - Color-coded ship classes:
    - Destroyer: Blue
    - Cruiser: Green
    - Battleship: Red
    - Carrier: Yellow
  - Configuration panels for:
    - **Ship Class**: Navigate between Destroyer, Cruiser, Battleship, Carrier
    - **Weapons**: 
      - Main Guns (Standard, Heavy, Rapid Fire)
      - Secondary Guns (Standard, Heavy, Rapid Fire)
    - **Propulsion**: Engine types (Standard, High Speed, Heavy Duty)
    - **Fire Control System**: FCS types (Basic, Advanced, Tactical)
    - **Crew Assignment**: Toggle crew assignment
  - "Enter Battle" button to proceed to battle menu

### 3. Battle Menu
- **Location**: Battle selection screen (`scenes/battle_menu.tscn`)
- **Features**:
  - Displays current ship configuration
  - "Start Practice Battle" button
  - "Return to Ship Yard" button
  - Description of test map

### 4. Battle Scene (Updated)
- **Location**: Actual combat scene (`scenes/main.tscn`)
- **Features**:
  - Applies ship configuration from Ship Yard
  - Two practice enemy ships spawn at start
  - "Return to Menu" button in top-left corner
  - Returns player to Battle Menu

## Navigation Flow

```
Login Screen → Ship Yard → Battle Menu → Battle Scene
                  ↑             ↑            ↓
                  └─────────────┴────────────┘
```

## Testing Instructions

### In Godot Editor

1. **Open the project** in Godot Engine 4.2 or higher

2. **Test Login Screen**:
   - Run the project (F5)
   - Enter any username (password is optional for now)
   - Click "Login" or press Enter
   - Should transition to Ship Yard

3. **Test Ship Yard**:
   - Use "< PREV" and "NEXT >" buttons to cycle through options
   - Change ship class and observe color change
   - Configure weapons, engine, and fire control
   - Toggle crew assignment
   - Click "Enter Battle" to proceed

4. **Test Battle Menu**:
   - Verify ship configuration is displayed
   - Click "Start Practice Battle" to enter combat
   - Or click "Return to Ship Yard" to go back

5. **Test Battle Scene**:
   - Verify the configured ship class is active
   - Two enemy ships should spawn
   - Use WASD to move, Space to fire
   - Click "Return to Menu" to exit battle

## Global Game State

A new singleton `GameState` manages player data across scenes:
- Player username
- Ship configuration (class, weapons, engine, FCS, crew)

Configuration is automatically saved when navigating from Ship Yard to Battle Menu and applied when entering battle.

## Files Added/Modified

### New Files
- `scenes/login_screen.tscn` - Login UI
- `scripts/login_screen.gd` - Login logic
- `scenes/ship_yard.tscn` - Ship configuration UI
- `scripts/ship_yard.gd` - Ship yard logic
- `scenes/battle_menu.tscn` - Battle selection UI
- `scripts/battle_menu.gd` - Battle menu logic
- `scripts/game_state.gd` - Global state manager

### Modified Files
- `project.godot` - Changed main scene to login_screen, added GameState autoload
- `scenes/main.tscn` - Added return button
- `scripts/game_manager.gd` - Reads ship config from GameState, handles return button

## Expected Behavior

1. **Login**: Accept any non-empty username
2. **Ship Configuration**: All options cycle through available choices
3. **Ship Class Visual**: Color changes based on selected class
4. **Battle Entry**: Ship configuration persists into battle
5. **Navigation**: All buttons transition to correct scenes
6. **Return Flow**: Can return from battle to menu to ship yard

## Known Limitations

- No actual authentication (login accepts any username)
- Ship configuration visual is simplified (colored rectangle)
- Weapon/engine types are cosmetic (don't affect stats yet)
- No game over screen when player dies in battle

## Future Enhancements

- Implement actual authentication system
- Add 3D or detailed 2D ship models for ship yard
- Make weapon/engine configurations affect actual ship stats
- Add ship upgrade progression system
- Implement game over/victory screens
- Add multiplayer battle options
