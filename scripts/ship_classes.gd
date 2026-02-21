# Ship Class Definitions
# Defines stats and characteristics for different NavyField ship classes
class_name ShipClasses

enum ShipClass {
	DESTROYER,
	CRUISER,
	BATTLESHIP,
	CARRIER
}

# Ship class data structure
class ShipClassData:
	var ship_name: String
	var max_health: int
	var max_speed: float
	var acceleration: float
	var turn_speed: float
	var main_gun_damage: int
	var main_gun_reload: float
	var secondary_gun_damage: int
	var secondary_gun_reload: float
	var detection_range: float
	var ship_color: Color
	
	func _init(
		p_class_name: String,
		p_max_health: int,
		p_max_speed: float,
		p_acceleration: float,
		p_turn_speed: float,
		p_main_gun_damage: int,
		p_main_gun_reload: float,
		p_secondary_gun_damage: int,
		p_secondary_gun_reload: float,
		p_detection_range: float,
		p_ship_color: Color
	):
		ship_name = p_class_name
		max_health = p_max_health
		max_speed = p_max_speed
		acceleration = p_acceleration
		turn_speed = p_turn_speed
		main_gun_damage = p_main_gun_damage
		main_gun_reload = p_main_gun_reload
		secondary_gun_damage = p_secondary_gun_damage
		secondary_gun_reload = p_secondary_gun_reload
		detection_range = p_detection_range
		ship_color = p_ship_color

# Ship class definitions based on NavyField characteristics
# Returns a ShipClassData instance for the given ship_class
static func get_ship_class_data(ship_class: ShipClass):
	match ship_class:
		ShipClass.DESTROYER:
			return ShipClassData.new(
				"Destroyer",
				60,        # Low health
				250.0,     # Fast speed
				70.0,      # Quick acceleration
				2.0,       # Good turn speed
				30,        # Low main gun damage
				2.5,       # Fast main gun reload
				20,        # Moderate secondary damage
				0.8,       # Very fast secondary reload
				1000.0,    # Good detection
				Color(0.5, 0.7, 1.0)  # Light blue
			)
		ShipClass.CRUISER:
			return ShipClassData.new(
				"Cruiser",
				100,       # Medium health
				200.0,     # Medium speed
				50.0,      # Medium acceleration
				1.5,       # Medium turn speed
				50,        # Medium main gun damage
				3.0,       # Medium main gun reload
				15,        # Medium secondary damage
				1.0,       # Medium secondary reload
				900.0,     # Medium detection
				Color(0.7, 0.7, 0.9)  # Gray-blue
			)
		ShipClass.BATTLESHIP:
			return ShipClassData.new(
				"Battleship",
				200,       # High health
				120.0,     # Slow speed
				30.0,      # Slow acceleration
				1.0,       # Poor turn speed
				100,       # Very high main gun damage
				5.0,       # Slow main gun reload
				25,        # High secondary damage
				1.5,       # Slow secondary reload
				800.0,     # Lower detection
				Color(0.4, 0.4, 0.5)  # Dark gray
			)
		ShipClass.CARRIER:
			return ShipClassData.new(
				"Carrier",
				150,       # Medium-high health
				150.0,     # Medium-slow speed
				35.0,      # Slow acceleration
				1.2,       # Poor turn speed
				10,        # Minimal main gun damage
				4.0,       # Slow main gun reload
				10,        # Low secondary damage
				1.2,       # Medium secondary reload
				1200.0,    # Excellent detection
				Color(0.8, 0.6, 0.4)  # Light brown
			)
		_:
			# Default to cruiser
			return get_ship_class_data(ShipClass.CRUISER)

# Helper function to get ship visual scale based on class
static func get_ship_scale(ship_class: ShipClass) -> Vector2:
	match ship_class:
		ShipClass.DESTROYER:
			return Vector2(0.8, 0.8)  # Smaller
		ShipClass.CRUISER:
			return Vector2(1.0, 1.0)  # Normal
		ShipClass.BATTLESHIP:
			return Vector2(1.5, 1.5)  # Larger
		ShipClass.CARRIER:
			return Vector2(1.3, 1.8)  # Long and wide
		_:
			return Vector2(1.0, 1.0)

# Helper function to get ship description
static func get_ship_description(ship_class: ShipClass) -> String:
	match ship_class:
		ShipClass.DESTROYER:
			return "Fast and maneuverable.\nExcellent for hit-and-run tactics."
		ShipClass.CRUISER:
			return "Balanced combat vessel. Good all-around performance."
		ShipClass.BATTLESHIP:
			return "Heavy armor and firepower. Slow but devastating."
		ShipClass.CARRIER:
			return "Launches aircraft. Vulnerable without escort."
		_:
			return "Unknown ship class"
