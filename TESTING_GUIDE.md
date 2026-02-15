# Testing Checklist for NavyField Features

## Prerequisites
- Godot Engine 4.2 or higher installed
- Naval Wars project opened in Godot

## How to Test

### 1. Launch the Game
1. Open the project in Godot Engine
2. Press F5 or click "Run Project"
3. The main scene should load

### 2. Test Ship Class System
**Expected Behavior**:
- Player ship displays class name in HUD (bottom-left)
- Default player ship is Cruiser
- Enemy ships spawn with varied classes (Destroyer, Cruiser, or Battleship)
- Different sized ships visible based on class

**To Test Different Player Classes**:
1. Open `scenes/ship.tscn` or `scenes/main.tscn`
2. Select PlayerShip node
3. In Inspector, find "Ship Class" property
4. Change value:
   - 0 = Destroyer (fast, small, weak)
   - 1 = Cruiser (balanced)
   - 2 = Battleship (slow, large, powerful)
   - 3 = Carrier (medium, excellent detection)
5. Run game to test each class

**What to Observe**:
- Ship size changes based on class
- Speed differences (Destroyer fastest, Battleship slowest)
- Damage output differences (Battleship hits hardest)
- Health differences (Battleship has most HP)

### 3. Test Minimap
**Expected Behavior**:
- Minimap appears in bottom-right corner
- Blue background with border
- Green dot shows player position with direction line
- Red dots show enemy positions
- Updates in real-time as ships move

**To Test**:
1. Run the game
2. Move around with WASD keys
3. Watch green dot move on minimap
4. Rotate ship and watch direction indicator
5. Observe red dots (enemies) on minimap
6. Destroy enemies and watch red dots disappear

### 4. Test World Boundaries
**Expected Behavior**:
- Blue boundary lines visible at edges of map
- Corner markers (X shapes) at four corners
- Ship cannot pass through boundaries
- Collides and stops at boundary

**To Test**:
1. Run the game
2. Hold W to move forward
3. Continue in one direction until reaching boundary
4. Ship should stop at boundary line
5. Try different directions to test all edges

### 5. Test Visual Effects

#### Explosion Effects
**Expected Behavior**:
- Explosions appear when ships are destroyed
- Orange/yellow/red gradient circles
- Expanding and fading animation
- Lasts about 1 second

**To Test**:
1. Run the game
2. Destroy an enemy ship with weapons
3. Observe explosion effect
4. Get destroyed (let enemy kill you)
5. Observe player explosion (larger)

#### Muzzle Flash Effects
**Expected Behavior**:
- Brief yellow-white flash when firing guns
- Appears at gun positions
- Very short duration (~0.1 seconds)

**To Test**:
1. Run the game
2. Press SPACE to fire main guns
3. Watch for muzzle flashes at turret positions
4. Click left mouse button to fire secondary guns
5. Observe rapid flashes

#### Projectile Explosions
**Expected Behavior**:
- Small explosion when projectile hits
- Small explosion when projectile times out

**To Test**:
1. Run the game
2. Fire at enemy (SPACE or Left Click)
3. Watch projectile impact with explosion
4. Fire away from enemies and watch timeout explosion

### 6. Test Enhanced HUD
**Expected Behavior**:
- Bottom-left shows:
  - Hull Integrity: percentage (decreases when hit)
  - Speed: in knots (changes as you accelerate)
  - Main Guns: Ready or Reloading
  - Ship: [Class Name]
- Top-right shows: Score

**To Test**:
1. Run the game
2. Press W to accelerate, watch speed increase
3. Press S to brake, watch speed decrease
4. Fire main guns (SPACE), watch status change to "Reloading"
5. Take damage from enemy, watch Hull Integrity decrease
6. Destroy enemy, watch Score increase by 100

### 7. Test Ship Class Differences

#### Test Destroyer
1. Set player ship class to 0 (Destroyer)
2. Run game
3. Observe:
   - Fast acceleration and speed
   - Quick turning
   - Lower damage output
   - Lower health (dies quickly)
   - Smaller visual size

#### Test Cruiser (Default)
1. Set player ship class to 1 (Cruiser)
2. Run game
3. Observe:
   - Balanced speed and maneuverability
   - Medium damage
   - Medium health
   - Standard size

#### Test Battleship
1. Set player ship class to 2 (Battleship)
2. Run game
3. Observe:
   - Slow acceleration and speed
   - Poor turning
   - Very high damage (one-shots enemies)
   - High health (can tank many hits)
   - Large visual size

### 8. Test Combat System
**Expected Behavior**:
- Main guns reload in 3 seconds (Cruiser)
- Secondary guns reload in 1 second (Cruiser)
- Projectiles fly in straight lines
- Projectiles deal damage on hit
- Ships explode when health reaches 0

**To Test**:
1. Run the game
2. Fire main guns (SPACE) twice quickly
   - First shot fires
   - Second shot blocked (must wait for reload)
3. Fire secondary guns (Hold Left Mouse)
   - Rapid fire capability
4. Aim at enemy and fire
   - Watch health bar decrease (if visible)
   - Destroy enemy to see explosion

### 9. Test Enemy AI with Classes
**Expected Behavior**:
- Enemies spawn with different classes
- Different enemies behave differently
- Destroyers faster and more aggressive
- Battleships slower but hit harder

**To Test**:
1. Run the game
2. Wait for enemies to spawn
3. Observe different sized enemies
4. Notice different movement speeds
5. Test combat against different classes
6. Observe damage differences

## Common Issues and Solutions

### Minimap not showing
- Check that `minimap.gd` is attached to the Minimap node in `main.tscn`
- Verify UI/HUD/Minimap node exists in scene tree

### Explosions not appearing
- Check that `explosion.tscn` exists in `scenes/` folder
- Verify `explosion.gd` is attached to explosion scene

### Ship class not changing
- Make sure to modify ship_class value in Inspector
- Value must be 0-3 (0=DD, 1=CA, 2=BB, 3=CV)
- Save scene after changing

### Boundaries not visible
- WorldBoundary node should be in main scene
- Check that `world_boundary.gd` is attached
- May need to zoom out to see boundaries (they're at edges)

### Muzzle flash too fast to see
- This is normal - flashes are intentionally brief (0.1s)
- Look carefully when firing
- Multiple guns fire = multiple flashes

## Performance Testing

### Frame Rate
- Game should run smoothly at 60+ FPS
- No lag when enemies spawn
- No lag when multiple explosions occur

### Memory
- No memory leaks over time
- Destroyed ships cleanup properly
- Explosions cleanup automatically

## Success Criteria

✅ Game launches without errors
✅ Player ship displays correct class name
✅ Minimap shows player and enemies
✅ World boundaries visible and functional
✅ Explosions appear on ship destruction
✅ Muzzle flashes appear when firing
✅ Different ship classes behave differently
✅ HUD displays all information correctly
✅ Combat mechanics work as expected
✅ Enemy AI functions with different classes

## Reporting Issues

If you find issues:
1. Note which feature is not working
2. Check the console for error messages (F3 in Godot)
3. Verify file paths are correct (res://scenes/... and res://scripts/...)
4. Ensure all script files are attached to their respective nodes
5. Check that export variables are set correctly in Inspector

## Next Steps After Testing

Once testing is complete and features work:
1. Consider adding team-based gameplay (Red vs Blue)
2. Add more weapon types (torpedoes)
3. Implement sound effects
4. Add game modes (team deathmatch, capture objectives)
5. Create ship selection menu
6. Add port/repair system
7. Implement crew system with experience points
