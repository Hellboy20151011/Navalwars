class_name ArtilleryCalculator
# Artillery Calculation System (Artillerieberechnungen)
# Implements formulas for naval artillery fire control:
#   - MKS-Strichrechnung (mil-based range estimation)
#   - Seitenrichtwinkel / Azimut (bearing angle)
#   - Kosinussatz (law of cosines) for side-angle calculation
#   - Ballistische Flugbahn (ballistic trajectory: range & elevation)
#   - Trefferwahrscheinlichkeit (hit probability)
#   - Feuerkorrektur / Gabelverfahren (fire correction / bracketing)

# NATO standard: 6400 Strich (mils) per full circle
const STRICH_PER_CIRCLE: float = 6400.0
const STRICH_PER_DEGREE: float = STRICH_PER_CIRCLE / 360.0  # ≈ 17.778 Strich/°
const DEG_PER_STRICH: float = 360.0 / STRICH_PER_CIRCLE      # ≈ 0.05625°/Strich

# Game pseudo-gravity (must match ship.gd GRAVITY constant)
const GRAVITY: float = 300.0


# ── MKS formula (Strichrechnung) ──────────────────────────────────────────────
# Mil relation: 1 Strich ≈ 1 m target size per 1000 m range.
# Grundformel: E = M × 1000 / S  (E = Entfernung, M = Zielgröße, S = Winkel in Strich)

static func mks_entfernung(target_size: float, angle_strich: float) -> float:
	## Range estimate from target angular size: E = M × 1000 / S
	if angle_strich <= 0.0:
		return 0.0
	return (target_size * 1000.0) / angle_strich


static func mks_strich(target_size: float, range: float) -> float:
	## Observed angular size in Strich: S = M × 1000 / E
	if range <= 0.0:
		return 0.0
	return (target_size * 1000.0) / range


# ── Bearing angle (Seitenrichtwinkel / Azimut) ────────────────────────────────
# Azimuth measured clockwise from North (up = −Y in Godot screen space).

static func bearing_deg(from_pos: Vector2, to_pos: Vector2) -> float:
	## Bearing in degrees [0, 360) from from_pos to to_pos, clockwise from North
	var delta := to_pos - from_pos
	# atan2(East component, North component): East = +X, North = −Y in Godot
	var angle := atan2(delta.x, -delta.y)
	return fposmod(rad_to_deg(angle), 360.0)


static func bearing_strich(from_pos: Vector2, to_pos: Vector2) -> float:
	## Bearing in Strich (NATO mils) [0, 6400) from from_pos to to_pos
	return bearing_deg(from_pos, to_pos) * STRICH_PER_DEGREE


# ── Law of cosines (Kosinussatz) ──────────────────────────────────────────────
# c² = a² + b² − 2ab·cos(C)  →  C = acos((a²+b²−c²) / (2ab))
# Used for Seitenwinkelberechnung when all three side lengths are known.

static func law_of_cosines_angle_deg(a: float, b: float, c: float) -> float:
	## Angle C (°) opposite side c in a triangle with sides a, b, c
	if a <= 0.0 or b <= 0.0:
		return 0.0
	var cos_c := (a * a + b * b - c * c) / (2.0 * a * b)
	return rad_to_deg(acos(clamp(cos_c, -1.0, 1.0)))


# ── Required elevation for a given range ──────────────────────────────────────
# Ballistic range formula (no air resistance):
#   R = v₀² · sin(2θ) / g  →  sin(2θ) = R·g / v₀²
# Two solutions: low-angle (direct fire, θ < 45°) and high-angle (plunging fire, θ > 45°).

static func elevation_for_range(target_range: float, muzzle_speed: float, gravity: float = GRAVITY) -> Dictionary:
	## Required elevation angle(s) to reach target_range.
	## Returns {reachable: bool, low_deg: float, high_deg: float}
	var result := {"reachable": false, "low_deg": 0.0, "high_deg": 0.0}
	if muzzle_speed <= 0.0 or gravity <= 0.0:
		return result
	var sin2theta := target_range * gravity / (muzzle_speed * muzzle_speed)
	if sin2theta > 1.0:
		return result  # Target is beyond maximum range
	result["reachable"] = true
	var two_theta := asin(sin2theta)
	result["low_deg"] = rad_to_deg(two_theta / 2.0)                  # ≤ 45°
	result["high_deg"] = rad_to_deg((PI - two_theta) / 2.0)          # ≥ 45°
	return result


static func max_range(muzzle_speed: float, gravity: float = GRAVITY) -> float:
	## Maximum range at optimal 45° elevation: R_max = v₀² / g
	if gravity <= 0.0:
		return 0.0
	return (muzzle_speed * muzzle_speed) / gravity


# ── Hit probability (Trefferwahrscheinlichkeit) ───────────────────────────────
# Dispersion at range creates a spread radius = range · tan(dispersion_rad).
# Probability ≈ target_size / (2 · spread_radius), clamped to [0, 1].

static func hit_probability(dispersion_rad: float, range: float, target_size: float) -> float:
	## Probability [0..1] of a round landing within target_size at given range
	if range <= 0.0 or target_size <= 0.0:
		return 0.0
	var spread_radius := range * tan(dispersion_rad)
	if spread_radius <= 0.001:
		return 1.0
	return clamp(target_size / (2.0 * spread_radius), 0.0, 1.0)


# ── Fire correction / Gabelverfahren ─────────────────────────────────────────
# Bracketing method: alternately fire over and short of the target,
# halving the bracket each time, until the target is bracketed precisely.
# bracket_deg starts at a coarse value (e.g. 4°) and halves each bracket cycle.

static func gabel_correction_deg(is_over: bool, bracket_deg: float) -> float:
	## Elevation correction to apply: negative if over, positive if short
	return -(bracket_deg / 2.0) if is_over else (bracket_deg / 2.0)


static func next_bracket_size(bracket_deg: float, min_bracket_deg: float = 0.5) -> float:
	## Halve bracket after each bracketing cycle; stop at minimum bracket size
	return max(bracket_deg / 2.0, min_bracket_deg)
