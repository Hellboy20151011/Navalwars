# Player Statistics Storage - Recommendations

## Summary

This document provides recommendations for storing player statistics in the Naval Wars game, including:
- Ship ownership
- Crew management
- Currency system

**Note:** These are suggestions and recommendations only. No code changes are made.

---

## 1. Current State

### What Already Exists:

The game currently uses a **GameState Singleton** (`scripts/game_state.gd`) to manage player data:

```gdscript
# Current implementation in GameState:
- player_username: String       # Player username
- ship_config: Dictionary        # Current ship configuration
  - ship_class                   # Ship class (0-3)
  - main_gun_type                # Main gun type
  - secondary_gun_type           # Secondary gun type
  - engine_type                  # Engine type
  - fire_control_type            # Fire control system
  - crew_assigned                # Whether crew is assigned (boolean)
```

### What's Missing:

❌ **No persistent data storage** - Data is lost when the game closes
❌ **No currency system** - No way to earn or spend money
❌ **No ship ownership system** - Only temporary ship configuration
❌ **No crew management** - Only a boolean flag for "crew_assigned"
❌ **No statistics/progression** - No tracking of wins, losses, experience

---

## 2. Recommended Data Structure

### 2.1 Extended GameState Structure

```gdscript
# Recommended extension of game_state.gd

# Player base data
var player_data = {
    "username": "",
    "level": 1,
    "experience": 0,
    "created_date": "",
    "last_played": ""
}

# Currency system
var player_currency = {
    "credits": 10000,           # Main currency
    "premium_currency": 0,      # Premium currency (optional)
    "total_earned": 0,          # Total earned
    "total_spent": 0            # Total spent
}

# Crew management
var player_crew = {
    "available_crew": 100,      # Available crew
    "total_crew": 100,          # Total crew
    "crew_experience": 0,       # Crew experience
    "crew_quality": 1.0         # Quality multiplier (1.0 = normal)
}

# Ship ownership
var owned_ships = [
    # Example:
    {
        "id": "ship_001",
        "ship_class": 1,        # Cruiser
        "name": "USS Liberty",  # Individual ship name
        "purchased_date": "",
        "crew_assigned": 20,    # Assigned crew
        "configuration": {
            "main_gun_type": 0,
            "secondary_gun_type": 0,
            "engine_type": 0,
            "fire_control_type": 0,
            "upgrades": []      # List of upgrades
        }
    }
]

# Unlocked content
var unlocked_content = {
    "ship_classes": [0, 1],     # Destroyer and Cruiser unlocked
    "weapons": [0],             # Only standard weapons
    "upgrades": []              # No upgrades unlocked
}

# Player statistics
var player_statistics = {
    "battles_played": 0,
    "battles_won": 0,
    "battles_lost": 0,
    "total_kills": 0,
    "total_deaths": 0,
    "total_damage_dealt": 0,
    "total_damage_taken": 0,
    "highest_score": 0,
    "playtime_seconds": 0
}
```

---

## 3. Storage Options for Persistence

### Option 1: Local File Storage (Recommended for Singleplayer)

**Advantages:**
✅ Easy to implement
✅ Works offline
✅ Fast access
✅ No server required

**Disadvantages:**
❌ Vulnerable to manipulation
❌ No cloud sync
❌ Lost if file is deleted

**Implementation approach:**
```gdscript
# Godot's ConfigFile for simple data
var config = ConfigFile.new()
config.set_value("player", "username", player_username)
config.set_value("player", "credits", player_currency.credits)
config.save("user://player_data.cfg")

# Or JSON for complex data structures
var save_data = {
    "player_data": player_data,
    "currency": player_currency,
    "owned_ships": owned_ships,
    "statistics": player_statistics
}
var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
file.store_string(JSON.stringify(save_data))
file.close()
```

**Storage location:**
- Godot uses `user://` as a cross-platform storage location
- Windows: `%APPDATA%/Godot/app_userdata/[ProjectName]/`
- Linux: `~/.local/share/godot/app_userdata/[ProjectName]/`
- macOS: `~/Library/Application Support/Godot/app_userdata/[ProjectName]/`

---

### Option 2: Database Storage (Recommended for Multiplayer)

**Advantages:**
✅ Secure storage
✅ Cloud synchronization
✅ Multiplayer support
✅ Hard to manipulate

**Disadvantages:**
❌ Requires server infrastructure
❌ More complex implementation
❌ Requires internet connection

**Possible technologies:**
- **SQLite** - Local database (with Godot SQL Plugin)
- **Firebase** - Cloud database (with GDScript Firebase Plugin)
- **PostgreSQL/MySQL** - Own server with REST API
- **Supabase** - Open-source Firebase alternative

---

### Option 3: Hybrid Approach (Best Solution)

**Concept:**
- Local storage for offline play
- Optional: Cloud backup for account sync
- Automatic synchronization on login

```
[Local Storage] <---> [GameState Singleton] <---> [Cloud Backup]
   (JSON/CFG)              (Runtime)              (Optional)
```

---

## 4. Recommended File Structure

```
user://
├── player_profile.json      # Player profile and base data
├── player_ships.json        # Ship ownership and configurations
├── player_progress.json     # Statistics and progression
└── settings.cfg             # Game settings
```

**Why split?**
- Better organization
- Faster access to frequently used data
- Easier backup of individual components
- Reduced risk of data corruption

---

## 5. Implementation Steps (Suggestion)

### Phase 1: Extend Data Structure
1. Extend `game_state.gd` with new variables
2. Add getter/setter methods for all statistics
3. Implement validation functions

### Phase 2: Save/Load System
1. Create `PlayerDataManager` singleton
2. Implement save functions
3. Implement load functions
4. Auto-save on important events

### Phase 3: Currency System
1. Create shop system
2. Implement rewards after battles
3. Maintain transaction log
4. UI for currency display

### Phase 4: Ship Ownership System
1. Ship purchase mechanic
2. Manage multiple ships
3. Select active ship
4. Ship upgrade system

### Phase 5: Crew System
1. Crew recruitment
2. Distribute crew to ships
3. Crew experience and level
4. Effects on ship performance

---

## 6. Security Considerations

### Protect Local Storage:

```gdscript
# Simple encryption (basic protection)
var crypto = Crypto.new()
var key = crypto.generate_random_bytes(32)

# Encrypt data before saving
var data_to_save = JSON.stringify(save_data)
var encrypted = crypto.encrypt(data_to_save.to_utf8_buffer(), key)

# Checksum for integrity check
var checksum = data_to_save.md5_text()
```

**Important:**
⚠️ Client-side encryption only protects against simple manipulation
⚠️ For real security: Server-side validation required
⚠️ Important game logic should be server-side

---

## 7. Example Workflows

### Ship Purchase Example:

```
1. Player has 10,000 Credits
2. Player wants to buy Battleship (Cost: 5,000 Credits)
3. System checks:
   - Enough credits? ✓
   - Battleship unlocked? ✓
   - Enough crew available? (minimum 50 required) ✓
4. Execute transaction:
   - Deduct credits: 10,000 - 5,000 = 5,000
   - Add ship to owned_ships
   - Assign crew: 50 crew to ship
   - Reduce available crew: 100 - 50 = 50
5. Save data
6. Update UI
```

### Battle Rewards Example:

```
1. Battle ends with victory
2. Calculate rewards:
   - Base Reward: 500 Credits
   - Kills Bonus: 100 Credits × 3 Kills = 300 Credits
   - Victory Bonus: 200 Credits
   - Total: 1000 Credits
3. Update statistics:
   - battles_won += 1
   - total_kills += 3
   - total_earned += 1000
   - credits += 1000
4. Save progress
5. Show rewards screen
```

---

## 8. Best Practices

### ✅ DO (Recommendations):

1. **Save regularly**
   - After each battle
   - On ship purchase/sale
   - On currency transactions
   - When exiting the game

2. **Implement validation**
   - Check values when loading
   - Set safe default values
   - Log suspicious changes

3. **Backup system**
   - Create automatic backups
   - Keep multiple save states
   - Allow manual backups

4. **Optimize performance**
   - Load only needed data
   - Use caching
   - Asynchronous saving

### ❌ DON'T (Avoid):

1. **No sensitive data in plain text**
2. **Don't accept invalid values**
3. **Don't save every frame**
4. **No game logic client-side without validation**

---

## 9. Advanced Features (Optional)

### Achievements
```gdscript
var achievements = {
    "first_kill": false,
    "win_10_battles": false,
    "own_all_ships": false,
    "reach_level_50": false
}
```

### Seasons/Leaderboards
```gdscript
var seasonal_data = {
    "current_season": 1,
    "season_rank": 0,
    "season_points": 0,
    "season_rewards_claimed": false
}
```

### Clans/Guilds
```gdscript
var clan_data = {
    "clan_id": "",
    "clan_name": "",
    "clan_role": "",      # Member, Officer, Leader
    "joined_date": ""
}
```

---

## 10. Summary of Recommendations

### For the Beginning (MVP):

1. **Extend GameState.gd:**
   - Add currency variables
   - Add ship ownership array
   - Add crew management

2. **Implement simple save system:**
   - Use JSON for data storage
   - Save to `user://savegame.json`
   - Load on game start

3. **Create basic economy:**
   - Rewards after battles
   - Ship purchase system
   - Crew recruitment

### For Long-term Development:

1. **Upgrade to Hybrid System:**
   - Keep local storage
   - Add optional cloud sync
   - Implement account system

2. **Extend features:**
   - Advanced upgrade system
   - Achievements and progression
   - Seasonal content
   - Multiplayer synchronization

---

## 11. Code Examples

### Simple Save/Load System:

```gdscript
# In game_state.gd

const SAVE_PATH = "user://player_save.json"

func save_game():
    var save_data = {
        "player_data": {
            "username": player_username,
            "level": player_level,
            "experience": player_experience
        },
        "currency": {
            "credits": player_credits,
            "total_earned": total_credits_earned
        },
        "crew": {
            "available": available_crew,
            "total": total_crew
        },
        "owned_ships": owned_ships,
        "statistics": player_statistics,
        "save_version": "1.0",
        "timestamp": Time.get_datetime_string_from_system()
    }
    
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(save_data, "\t"))
        file.close()
        print("Game saved successfully")
        return true
    else:
        push_error("Failed to save game")
        return false

func load_game():
    if not FileAccess.file_exists(SAVE_PATH):
        print("No save file found, using defaults")
        return false
    
    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file:
        var json_string = file.get_as_text()
        file.close()
        
        var json = JSON.new()
        var parse_result = json.parse(json_string)
        
        if parse_result == OK:
            var save_data = json.data
            
            # Validation and loading
            if save_data.has("player_data"):
                player_username = save_data.player_data.get("username", "")
                player_level = save_data.player_data.get("level", 1)
                player_experience = save_data.player_data.get("experience", 0)
            
            if save_data.has("currency"):
                player_credits = save_data.currency.get("credits", 10000)
                total_credits_earned = save_data.currency.get("total_earned", 0)
            
            if save_data.has("crew"):
                available_crew = save_data.crew.get("available", 100)
                total_crew = save_data.crew.get("total", 100)
            
            if save_data.has("owned_ships"):
                owned_ships = save_data.owned_ships
            
            if save_data.has("statistics"):
                player_statistics = save_data.statistics
            
            print("Game loaded successfully")
            return true
        else:
            push_error("Failed to parse save file")
            return false
    else:
        push_error("Failed to open save file")
        return false

# Auto-Save on exit
func _notification(what):
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        save_game()
```

---

## 12. Next Steps

1. **Make decisions:**
   - Which storage method to use?
   - Which features have priority?
   - Singleplayer or multiplayer focus?

2. **Create prototype:**
   - Implement basic save/load
   - Test with example data
   - Validate data integrity

3. **Create UI:**
   - Currency display
   - Ship selection menu
   - Crew management UI
   - Statistics screen

4. **Test:**
   - Save/load in different scenarios
   - Data validation
   - Error handling
   - Performance with large datasets

---

## Conclusion

The Naval Wars game already has a good foundation with the GameState singleton. To implement a complete player progression system, the following main areas should be extended:

1. **Persistent Data Storage** - JSON-based local save/load system
2. **Currency System** - Earn and spend credits
3. **Ship Ownership** - Purchase and manage multiple ships
4. **Crew Management** - Recruit crew and distribute to ships
5. **Statistics Tracking** - Record progress and performance

These recommendations provide a clear path to implementing a robust player progression system suitable for both singleplayer and future multiplayer expansions.

---

**Document created:** 2026-02-16
**Version:** 1.0
**Status:** Recommendations - No code changes
