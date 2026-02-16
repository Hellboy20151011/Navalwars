# Final Testing Checklist for Manual Testing in Godot

## Prerequisites
- Godot Engine 4.2 or higher installed
- Project cloned and opened in Godot

## Testing Procedure

### 1. Login Screen Test
**How to test:**
1. Run the project (F5)
2. Verify login screen appears first

**What to test:**
- [ ] Username input field accepts text
- [ ] Password input field masks input (shows dots)
- [ ] Login button is visible and clickable
- [ ] Error message appears when trying to login with empty username
- [ ] Enter key works when username field has focus
- [ ] Enter key works when password field has focus
- [ ] Successfully transitions to Ship Yard with valid username

**Expected Results:**
- Clean, centered UI with dark blue background
- Input fields are clearly labeled
- Error message in red appears for invalid input
- Smooth transition to Ship Yard on success

### 2. Ship Yard (Dry Dock) Test
**How to test:**
1. After logging in, observe Ship Yard screen

**What to test:**
- [ ] Ship visual displays in center with correct color
- [ ] Ship name displays below visual
- [ ] Configuration panel shows on right side
- [ ] All sections are visible and properly labeled
- [ ] Ship Class navigation:
  - [ ] "< PREV" cycles backward (Cruiser → Destroyer → Carrier → Battleship → Cruiser)
  - [ ] "NEXT >" cycles forward (Cruiser → Battleship → Carrier → Destroyer → Cruiser)
  - [ ] Ship color changes with class selection
  - [ ] Ship name label updates
- [ ] Weapons navigation (Main & Secondary):
  - [ ] Both gun types cycle through 3 options
  - [ ] Labels update correctly
- [ ] Propulsion navigation:
  - [ ] Engine cycles through 3 options
  - [ ] Label updates correctly
- [ ] Fire Control navigation:
  - [ ] FCS cycles through 3 options
  - [ ] Label updates correctly
- [ ] Crew assignment:
  - [ ] Button toggles between "Assign Crew" and "Unassign Crew"
  - [ ] Status label updates
- [ ] "Enter Battle" button is visible and clickable

**Expected Results:**
- All navigation buttons work smoothly
- No errors when cycling at boundaries
- Visual feedback for all configuration changes
- Smooth transition to Battle Menu

### 3. Battle Menu Test
**How to test:**
1. Click "Enter Battle" from Ship Yard

**What to test:**
- [ ] Battle Menu appears with dark background
- [ ] Current ship class is displayed correctly
- [ ] "Start Practice Battle" button is visible
- [ ] "Return to Ship Yard" button is visible
- [ ] Description text is readable
- [ ] Test map info is displayed
- [ ] Buttons are clickable

**Expected Results:**
- Clean UI with proper spacing
- Ship configuration from Ship Yard is displayed
- Both navigation buttons work

### 4. Battle Scene Test
**How to test:**
1. Click "Start Practice Battle" from Battle Menu

**What to test:**
- [ ] Battle scene loads successfully
- [ ] Player ship spawns at center
- [ ] Two enemy ships spawn (at (1500, 500) and (-1500, -500))
- [ ] Ship class matches selection from Ship Yard
- [ ] HUD displays correctly:
  - [ ] Ship status panel (bottom-left)
  - [ ] Return button (top-left)
  - [ ] Score (top-right)
  - [ ] Minimap (bottom-right)
- [ ] Controls work (WASD, Space, Mouse)
- [ ] "Return to Menu" button is visible and clickable

**Expected Results:**
- Smooth battle scene loading
- Correct ship class applied
- All game mechanics work as before
- Return button navigates to Battle Menu

### 5. Navigation Flow Test
**Complete flow:**
1. [ ] Login → Ship Yard (works)
2. [ ] Ship Yard → Battle Menu (works)
3. [ ] Battle Menu → Battle Scene (works)
4. [ ] Battle Scene → Battle Menu (works)
5. [ ] Battle Menu → Ship Yard (works)
6. [ ] Configure different ship, go to battle (config applies)

**Expected Results:**
- All transitions are smooth
- Configuration persists through navigation
- Can freely navigate between screens
- Ship configuration affects battle

### 6. Edge Cases Test
- [ ] Try login with very long username (should work)
- [ ] Try login with special characters (should work)
- [ ] Rapidly click navigation buttons (should not break)
- [ ] Change all configurations then go to battle
- [ ] Return from battle and verify configuration saved

### 7. Visual Quality Test
- [ ] All text is readable
- [ ] No UI elements overlap
- [ ] Buttons have clear labels
- [ ] Colors are appropriate
- [ ] Layout is balanced
- [ ] No visual glitches

## Screenshot Checklist
Take screenshots of:
- [ ] Login Screen
- [ ] Ship Yard with Destroyer selected
- [ ] Ship Yard with Battleship selected
- [ ] Battle Menu
- [ ] Battle Scene with return button
- [ ] Complete navigation flow diagram

## Bug Reporting Template
If bugs are found, report with:
- Screen where bug occurred
- Steps to reproduce
- Expected behavior
- Actual behavior
- Any error messages in console

## Performance Check
- [ ] No lag when changing configurations
- [ ] Smooth scene transitions
- [ ] Battle scene runs at good framerate
- [ ] No memory leaks after multiple navigation cycles

## Godot Console Check
Monitor console for:
- Print statements confirming navigation
- Any error messages
- Warning messages

Expected console output:
```
Login screen initialized
Login successful for user: [username]
GameState: Player username set to [username]
Ship Yard initialized
GameState: Ship config saved - {...}
Battle Menu initialized
Naval Wars - Starting Game
Applying ship configuration: {...}
```

## Acceptance Criteria
All features pass when:
- ✅ All screens load without errors
- ✅ All buttons work as expected
- ✅ Configuration persists correctly
- ✅ Navigation flow is complete
- ✅ No visual glitches
- ✅ Game mechanics unchanged
- ✅ Console shows no errors

## Additional Notes
- Save all screenshots to project documentation
- Note any unexpected behavior even if minor
- Test on different screen resolutions if possible
- Verify with both mouse and keyboard navigation
