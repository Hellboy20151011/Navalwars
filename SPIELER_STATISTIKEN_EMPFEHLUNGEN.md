# Spieler Statistiken Speichern - Empfehlungen

## Zusammenfassung

Dieses Dokument enthält Empfehlungen für die Speicherung von Spielerstatistiken im Naval Wars Spiel, einschließlich:
- Schiffsbesitz
- Mannschaftsverwaltung
- Währungssystem

**Hinweis:** Dies sind nur Vorschläge und Empfehlungen. Keine Code-Änderungen werden vorgenommen.

---

## 1. Aktueller Zustand

### Was bereits existiert:

Das Spiel verwendet derzeit einen **GameState Singleton** (`scripts/game_state.gd`) für die Verwaltung von Spielerdaten:

```gdscript
# Aktuelle Implementierung in GameState:
- player_username: String       # Spieler-Benutzername
- ship_config: Dictionary        # Aktuelle Schiffskonfiguration
  - ship_class                   # Schiffsklasse (0-3)
  - main_gun_type                # Hauptgeschütztyp
  - secondary_gun_type           # Sekundärgeschütztyp
  - engine_type                  # Motortyp
  - fire_control_type            # Feuerleitsystem
  - crew_assigned                # Ob Mannschaft zugewiesen ist (boolean)
```

### Was fehlt:

❌ **Keine persistente Datenspeicherung** - Daten gehen beim Schließen des Spiels verloren
❌ **Kein Währungssystem** - Keine Möglichkeit, Geld zu verdienen oder auszugeben
❌ **Kein Schiffsbesitzsystem** - Nur eine temporäre Schiffskonfiguration
❌ **Keine Mannschaftsverwaltung** - Nur ein boolean-Flag für "crew_assigned"
❌ **Keine Statistiken/Fortschritt** - Keine Aufzeichnung von Siegen, Verlusten, Erfahrung

---

## 2. Empfehlungen für die Datenstruktur

### 2.1 Erweiterte GameState-Struktur

```gdscript
# Empfohlene Erweiterung von game_state.gd

# Spieler Basisdaten
var player_data = {
    "username": "",
    "level": 1,
    "experience": 0,
    "created_date": "",
    "last_played": ""
}

# Währungssystem
var player_currency = {
    "credits": 10000,           # Hauptwährung
    "premium_currency": 0,      # Premium-Währung (optional)
    "total_earned": 0,          # Insgesamt verdient
    "total_spent": 0            # Insgesamt ausgegeben
}

# Mannschaftsverwaltung
var player_crew = {
    "available_crew": 100,      # Verfügbare Mannschaft
    "total_crew": 100,          # Gesamtmannschaft
    "crew_experience": 0,       # Mannschaftserfahrung
    "crew_quality": 1.0         # Qualitätsmultiplikator (1.0 = normal)
}

# Schiffsbesitz
var owned_ships = [
    # Beispiel:
    {
        "id": "ship_001",
        "ship_class": 1,        # Cruiser
        "name": "USS Liberty",  # Individueller Schiffsname
        "purchased_date": "",
        "crew_assigned": 20,    # Zugewiesene Mannschaft
        "configuration": {
            "main_gun_type": 0,
            "secondary_gun_type": 0,
            "engine_type": 0,
            "fire_control_type": 0,
            "upgrades": []      # Liste von Upgrades
        }
    }
]

# Freigeschaltete Inhalte
var unlocked_content = {
    "ship_classes": [0, 1],     # Destroyer und Cruiser freigeschaltet
    "weapons": [0],             # Nur Standardwaffen
    "upgrades": []              # Keine Upgrades freigeschaltet
}

# Spielstatistiken
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

## 3. Speicheroptionen für Persistenz

### Option 1: Lokale Datei-Speicherung (Empfohlen für Singleplayer)

**Vorteile:**
✅ Einfach zu implementieren
✅ Funktioniert offline
✅ Schneller Zugriff
✅ Keine Server erforderlich

**Nachteile:**
❌ Anfällig für Manipulation
❌ Keine Cloud-Synchronisation
❌ Verlust bei Datei-Löschung

**Implementierungsansatz:**
```gdscript
# Godot's ConfigFile für einfache Daten
var config = ConfigFile.new()
config.set_value("player", "username", player_username)
config.set_value("player", "credits", player_currency.credits)
config.save("user://player_data.cfg")

# Oder JSON für komplexe Datenstrukturen
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

**Speicherort:**
- Godot verwendet `user://` als plattformübergreifenden Speicherort
- Windows: `%APPDATA%/Godot/app_userdata/[Projektname]/`
- Linux: `~/.local/share/godot/app_userdata/[Projektname]/`
- macOS: `~/Library/Application Support/Godot/app_userdata/[Projektname]/`

---

### Option 2: Datenbank-Speicherung (Empfohlen für Multiplayer)

**Vorteile:**
✅ Sichere Speicherung
✅ Cloud-Synchronisation
✅ Multiplayer-Unterstützung
✅ Schwer zu manipulieren

**Nachteile:**
❌ Benötigt Server-Infrastruktur
❌ Komplexere Implementierung
❌ Benötigt Internet-Verbindung

**Mögliche Technologien:**
- **SQLite** - Lokale Datenbank (mit Godot SQL Plugin)
- **Firebase** - Cloud-Datenbank (mit GDScript Firebase Plugin)
- **PostgreSQL/MySQL** - Eigener Server mit REST-API
- **Supabase** - Open-Source Firebase Alternative

---

### Option 3: Hybrid-Ansatz (Beste Lösung)

**Konzept:**
- Lokale Speicherung für Offline-Spiel
- Optional: Cloud-Backup für Konten-Synchronisation
- Automatische Synchronisation beim Login

```
[Lokaler Speicher] <---> [GameState Singleton] <---> [Cloud Backup]
     (JSON/CFG)              (Laufzeit)              (Optional)
```

---

## 4. Empfohlene Dateistruktur

```
user://
├── player_profile.json      # Spielerprofil und Basisdaten
├── player_ships.json        # Schiffsbesitz und Konfigurationen
├── player_progress.json     # Statistiken und Fortschritt
└── settings.cfg             # Spieleinstellungen
```

**Warum aufteilen?**
- Bessere Organisation
- Schnellerer Zugriff auf häufig verwendete Daten
- Einfacheres Backup einzelner Komponenten
- Reduziertes Risiko von Datenkorruption

---

## 5. Implementierungsschritte (Vorschlag)

### Phase 1: Datenstruktur erweitern
1. `game_state.gd` erweitern mit neuen Variablen
2. Getter/Setter-Methoden für alle Statistiken hinzufügen
3. Validierungsfunktionen implementieren

### Phase 2: Speicher/Lade-System
1. `PlayerDataManager` Singleton erstellen
2. Save-Funktionen implementieren
3. Load-Funktionen implementieren
4. Auto-Save bei wichtigen Ereignissen

### Phase 3: Währungssystem
1. Shop-System erstellen
2. Belohnungen nach Kämpfen implementieren
3. Transaktions-Log führen
4. UI für Währungsanzeige

### Phase 4: Schiffsbesitzsystem
1. Schiffskauf-Mechanik
2. Mehrere Schiffe verwalten
3. Aktives Schiff auswählen
4. Schiffs-Upgrade-System

### Phase 5: Mannschaftssystem
1. Mannschaftsrekrutierung
2. Mannschaft auf Schiffe verteilen
3. Mannschaftserfahrung und -level
4. Auswirkungen auf Schiffsleistung

---

## 6. Sicherheitsüberlegungen

### Lokale Speicherung schützen:

```gdscript
# Einfache Verschlüsselung (Basis-Schutz)
var crypto = Crypto.new()
var key = crypto.generate_random_bytes(32)

# Daten verschlüsseln vor dem Speichern
var data_to_save = JSON.stringify(save_data)
var encrypted = crypto.encrypt(data_to_save.to_utf8_buffer(), key)

# Checksum für Integritätsprüfung
var checksum = data_to_save.md5_text()
```

**Wichtig:**
⚠️ Clientseitige Verschlüsselung schützt nur vor einfacher Manipulation
⚠️ Für echte Sicherheit: Server-side Validierung erforderlich
⚠️ Wichtige Spiellogik sollte Server-seitig sein

---

## 7. Beispiel-Workflow

### Schiffskauf-Beispiel:

```
1. Spieler hat 10.000 Credits
2. Spieler möchte Battleship kaufen (Kosten: 5.000 Credits)
3. System prüft:
   - Genug Credits? ✓
   - Battleship freigeschaltet? ✓
   - Genug Crew verfügbar? (mindestens 50 benötigt) ✓
4. Transaktion durchführen:
   - Credits abziehen: 10.000 - 5.000 = 5.000
   - Schiff zu owned_ships hinzufügen
   - Crew zuweisen: 50 Crew auf Schiff
   - Verfügbare Crew reduzieren: 100 - 50 = 50
5. Daten speichern
6. UI aktualisieren
```

### Battle-Belohnungen-Beispiel:

```
1. Schlacht endet mit Sieg
2. Berechne Belohnungen:
   - Base Reward: 500 Credits
   - Kills Bonus: 100 Credits × 3 Kills = 300 Credits
   - Victory Bonus: 200 Credits
   - Total: 1000 Credits
3. Aktualisiere Statistiken:
   - battles_won += 1
   - total_kills += 3
   - total_earned += 1000
   - credits += 1000
4. Speichere Fortschritt
5. Zeige Belohnungsbildschirm
```

---

## 8. Best Practices

### ✅ DO (Empfehlungen):

1. **Regelmäßig speichern**
   - Nach jedem Kampf
   - Bei Schiffskauf/-verkauf
   - Bei Währungstransaktionen
   - Beim Beenden des Spiels

2. **Validierung implementieren**
   - Prüfe Werte beim Laden
   - Setze sichere Standardwerte
   - Logge verdächtige Änderungen

3. **Backup-System**
   - Erstelle automatische Backups
   - Behalte mehrere Speicherstände
   - Ermögliche manuelle Backups

4. **Performance optimieren**
   - Lade nur benötigte Daten
   - Verwende Caching
   - Asynchrones Speichern

### ❌ DON'T (Vermeiden):

1. **Keine sensiblen Daten im Klartext**
2. **Keine ungültigen Werte akzeptieren**
3. **Nicht bei jedem Frame speichern**
4. **Keine Spiellogik client-side ohne Validierung**

---

## 9. Erweiterte Features (Optional)

### Achievements/Erfolge
```gdscript
var achievements = {
    "first_kill": false,
    "win_10_battles": false,
    "own_all_ships": false,
    "reach_level_50": false
}
```

### Seasons/Ranglisten
```gdscript
var seasonal_data = {
    "current_season": 1,
    "season_rank": 0,
    "season_points": 0,
    "season_rewards_claimed": false
}
```

### Clans/Gilden
```gdscript
var clan_data = {
    "clan_id": "",
    "clan_name": "",
    "clan_role": "",      # Member, Officer, Leader
    "joined_date": ""
}
```

---

## 10. Zusammenfassung der Empfehlungen

### Für den Anfang (MVP):

1. **Erweitere GameState.gd:**
   - Füge Währungsvariablen hinzu
   - Füge Schiffsbesitz-Array hinzu
   - Füge Mannschaftsverwaltung hinzu

2. **Implementiere einfaches Speichersystem:**
   - Verwende JSON für Datenspeicherung
   - Speichere in `user://savegame.json`
   - Lade beim Spielstart

3. **Erstelle grundlegende Wirtschaft:**
   - Belohnungen nach Kämpfen
   - Schiffskauf-System
   - Mannschaftsrekrutierung

### Für langfristige Entwicklung:

1. **Upgrade zu Hybrid-System:**
   - Behalte lokale Speicherung
   - Füge optionale Cloud-Synchronisation hinzu
   - Implementiere Account-System

2. **Erweitere Features:**
   - Fortgeschrittenes Upgrade-System
   - Achievements und Progression
   - Seasonal Content
   - Multiplayer-Synchronisation

---

## 11. Codebeispiele

### Einfaches Save/Load System:

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
            
            # Validierung und Laden
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

# Auto-Save beim Beenden
func _notification(what):
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        save_game()
```

---

## 12. Nächste Schritte

1. **Entscheidung treffen:**
   - Welche Speichermethode soll verwendet werden?
   - Welche Features haben Priorität?
   - Singleplayer oder Multiplayer-Fokus?

2. **Prototyp erstellen:**
   - Implementiere grundlegendes Save/Load
   - Teste mit Beispieldaten
   - Validiere Datenintegrität

3. **UI erstellen:**
   - Währungsanzeige
   - Schiffsauswahlmenü
   - Mannschaftsverwaltungs-UI
   - Statistik-Bildschirm

4. **Testen:**
   - Save/Load in verschiedenen Szenarien
   - Datenvalidierung
   - Fehlerbehandlung
   - Performance mit großen Datensätzen

---

## Fazit

Das Naval Wars Spiel hat bereits eine gute Grundlage mit dem GameState Singleton. Um ein vollständiges Spieler-Fortschrittssystem zu implementieren, sollten folgende Hauptbereiche erweitert werden:

1. **Persistente Datenspeicherung** - JSON-basiertes lokales Save/Load System
2. **Währungssystem** - Credits verdienen und ausgeben
3. **Schiffsbesitz** - Mehrere Schiffe kaufen und verwalten
4. **Mannschaftsverwaltung** - Crew rekrutieren und auf Schiffe verteilen
5. **Statistik-Tracking** - Fortschritt und Leistung aufzeichnen

Diese Empfehlungen bieten einen klaren Weg zur Implementierung eines robusten Spieler-Fortschrittssystems, das sowohl für Singleplayer als auch für zukünftige Multiplayer-Erweiterungen geeignet ist.

---

**Dokument erstellt:** 2026-02-16
**Version:** 1.0
**Status:** Empfehlungen - Keine Code-Änderungen
