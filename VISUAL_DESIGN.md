# Visual Design Documentation

Since Godot is not available in this environment, this document describes what each screen should look like when running the game.

## 1. Login Screen

**Background**: Dark blue-gray color (#1A2640)

**Center Elements**:
- Large title "NAVAL WARS" (48pt font)
- Subtitle "Navyfield 1 Inspired" (20pt font)
- Username input field (400px wide, 50px tall)
- Password input field (400px wide, 50px tall, hidden characters)
- Error message area (red text, hidden by default)
- Large "LOGIN" button (400px wide, 60px tall, 24pt font)
- Info text "Press Enter to login" (14pt font)

**Colors**:
- Background: RGB(25, 38, 64) / #192640
- Text: White
- Input fields: Light gray background with dark text
- Button: Default Godot button style
- Error text: RGB(255, 76, 76) / #FF4C4C

## 2. Ship Yard (Dry Dock)

**Layout**: Full screen with three main areas

### Top Section:
- Title: "SHIP YARD - DRY DOCK" (36pt font, centered at top)

### Center-Left Section: Ship Display
- **Dock Background**: Dark gray rectangle (RGB(51, 64, 76) / #33404C)
- **Ship Visual**: Colored rectangle representing the ship (200x80px)
  - Destroyer: Light Blue RGB(76, 153, 230)
  - Cruiser: Green RGB(128, 179, 128)
  - Battleship: Red RGB(179, 76, 76)
  - Carrier: Yellow RGB(204, 179, 76)
- **Ship Name Label**: Below the ship, 24pt font

### Right Section: Configuration Panel
Vertical panel with sections:

1. **Ship Class Section**:
   - Title: "SHIP CLASS" (20pt)
   - Current class label (16pt)
   - Two buttons: "< PREV" and "NEXT >" (100px wide, 40px tall)

2. **Weapons Section**:
   - Title: "WEAPONS" (20pt)
   - Main guns label with navigation buttons
   - Secondary guns label with navigation buttons

3. **Propulsion Section**:
   - Title: "PROPULSION" (20pt)
   - Engine type label with navigation buttons

4. **Fire Control Section**:
   - Title: "FIRE CONTROL SYSTEM" (20pt)
   - FCS type label with navigation buttons

5. **Crew Section**:
   - Title: "CREW ASSIGNMENT" (20pt)
   - Crew status label
   - "ASSIGN CREW" / "UNASSIGN CREW" button (450px wide, 50px tall)

### Bottom Section:
- Large "ENTER BATTLE" button (400px wide, 80px tall, 28pt font, centered)

**Background**: Medium dark gray RGB(38, 38, 51) / #262633

**Separators**: Horizontal lines between configuration sections

## 3. Battle Menu

**Background**: Very dark blue-gray RGB(30, 30, 46) / #1E1E2E

**Center Elements**:
- Large title "BATTLE MENU" (48pt font)
- Ship info "Your Ship: [Class Name]" (24pt font)
- Description text:
  ```
  Practice your skills against enemy ships
  in a training environment.
  ```
  (18pt font, centered, 600px wide)
- Large "START PRACTICE BATTLE" button (500px wide, 80px tall, 28pt font)
- "RETURN TO SHIP YARD" button (500px wide, 60px tall, 20pt font)
- Small info text at bottom:
  ```
  Test Map: Ocean Training Grounds
  Enemy Ships: 2 practice targets
  ```
  (14pt font, gray color)

**Spacing**: Generous spacing between elements (20-30px)

## 4. Battle Scene (Main)

**Layout**: Full game view with HUD overlay

### Game View:
- Ocean background (blue tiled pattern)
- Player ship at center
- Enemy ships visible on map
- World boundary markers
- Camera follows player ship

### HUD Elements:

**Bottom-Left**: Ship Status Panel
- "Hull Integrity: XX%"
- "Speed: XX knots"
- "Main Guns: Ready/Reloading..."
- "Ship: [Class Name]"

**Top-Left**: 
- "RETURN TO MENU" button (200px wide, 50px tall, 18pt font)

**Top-Right**:
- "Score: XXX" (aligned right)

**Bottom-Right**: Minimap
- 200x200px square
- Shows player position (green dot)
- Shows enemy positions (red dots)
- Background: dark semi-transparent

### Colors:
- HUD text: White
- HUD background: Semi-transparent dark overlay
- Minimap border: Light gray
- Player indicator: Green
- Enemy indicators: Red

## Color Scheme Summary

**Primary Colors**:
- Dark backgrounds: #192640, #262633, #1E1E2E
- Text: White (#FFFFFF)
- Accents: Ship class colors (blue, green, red, yellow)

**UI Elements**:
- Buttons: Godot default style (grayish blue)
- Input fields: Light gray with dark text
- Separators: Subtle gray lines
- Error messages: Red (#FF4C4C)

## Typography

**Font Sizes**:
- Title: 48pt
- Subtitle/Section Headers: 28pt
- Section Labels: 20pt
- Regular Text: 16-18pt
- Small Info: 14pt
- Button Text: 18-28pt depending on button size

**Alignment**:
- Titles: Center aligned
- Labels: Left aligned
- Info text: Center aligned
- HUD elements: Context-dependent

## Responsive Behavior

- All screens designed for 1920x1080 resolution
- Elements use Godot's anchor system for positioning
- Central elements remain centered at different resolutions
- HUD elements stick to screen edges

## Navigation Visual Feedback

When transitioning between scenes:
- Godot's default scene transition (instant fade)
- Print statements to console for debugging
- No loading screens (scenes are lightweight)

## Interaction States

**Buttons**:
- Normal: Default Godot button appearance
- Hover: Slightly lighter
- Pressed: Darker/pressed effect
- Disabled: Grayed out (not currently used)

**Input Fields**:
- Normal: Gray background
- Focused: Slightly highlighted border
- Active: Blinking cursor

## Additional Notes

- All UI uses Godot's default theme
- No custom fonts (uses Godot default)
- No custom textures (uses ColorRect for backgrounds)
- Simple geometric shapes for ship representation
- Minimalist design focusing on functionality
