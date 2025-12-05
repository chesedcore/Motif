@tool
class_name Arc extends Node2D

enum ColorScheme {
	CYBERPUNK_NEON,
	MATRIX_GREEN,
	VAPORWAVE,
	SYNTHWAVE,
	ICE_BLUE,
	FIRE_ORANGE,
	TOXIC_GREEN,
	CUSTOM
}

@export var color_scheme: ColorScheme = ColorScheme.CYBERPUNK_NEON
@export var custom_colors: Array[Color] = [Color.CYAN, Color.MAGENTA, Color.YELLOW]

#ring config
@export_range(1, 20) var min_rings: int = 3
@export_range(1, 20) var max_rings: int = 8
@export_range(16, 200) var min_radius: float = 32
@export_range(16, 300) var max_radius: float = 150
@export_range(1, 20) var min_width: float = 2
@export_range(1, 20) var max_width: float = 8

#arc seg config
@export var allow_full_circles: bool = true
@export_range(0.0, 1.0) var min_arc_coverage: float = 0.3  #min portion
@export_range(0.0, 1.0) var max_arc_coverage: float = 1.0  #max portion

#spin config
enum SpinMode { NONE, ALL_SAME, ALL_RANDOM, MIXED }
@export var spin_mode: SpinMode = SpinMode.ALL_RANDOM
@export_range(0.0, 10.0) var min_spin_speed: float = 0.5
@export_range(0.0, 10.0) var max_spin_speed: float = 3.0

#quality
@export_range(32, 360) var point_count: int = 180

@export_tool_button("Generate Random Rings") var generate_button = generate_rings

#internal data
@export_storage var rings: Array[Dictionary] = []

#func _ready() -> void:
	#if rings.is_empty():
		#generate_rings()

func generate_rings() -> void:
	rings.clear()
	
	var ring_count = randi_range(min_rings, max_rings)
	var colors = get_color_palette()
	var base_spin = randf_range(min_spin_speed, max_spin_speed) * (1 if randf() > 0.5 else -1)
	
	for i in range(ring_count):
		var ring = {}
		ring.radius = randf_range(min_radius, max_radius)
		ring.width = randf_range(min_width, max_width)
		ring.color = colors[randi() % colors.size()]
		
		#arc segment
		if allow_full_circles and randf() > 0.6:  #40% chance of full circle
			ring.start_angle = 0
			ring.end_angle = TAU
		else:
			var coverage = randf_range(min_arc_coverage, max_arc_coverage)
			var arc_length = TAU * coverage
			ring.start_angle = randf_range(0, TAU - arc_length)
			ring.end_angle = ring.start_angle + arc_length
		
		#speeeeen
		match spin_mode:
			SpinMode.NONE:
				ring["spin"] = 0
			SpinMode.ALL_SAME:
				ring["spin"] = base_spin
			SpinMode.ALL_RANDOM:
				ring["spin"] = randf_range(min_spin_speed, max_spin_speed) * (1 if randf() > 0.5 else -1)
			SpinMode.MIXED:
				ring["spin"] = base_spin if randf() > 0.5 else randf_range(min_spin_speed, max_spin_speed) * (1 if randf() > 0.5 else -1)
		
		ring.rotation = randf_range(0, TAU) #rand roation
		
		rings.append(ring)
	
	queue_redraw()

func get_color_palette() -> Array[Color]:
	match color_scheme:
		ColorScheme.CYBERPUNK_NEON:
			return [
				Color("#00FFFF"),  # Cyan
				Color("#FF00FF"),  # Magenta
				Color("#FF0080"),  # Hot Pink
				Color("#0080FF"),  # Electric Blue
				Color("#FFFF00"),  # Yellow
			]
		ColorScheme.MATRIX_GREEN:
			return [
				Color("#00FF00"),  # Bright Green
				Color("#00DD00"),  # Green
				Color("#00AA00"),  # Dark Green
				Color("#80FF80"),  # Light Green
			]
		ColorScheme.VAPORWAVE:
			return [
				Color("#FF71CE"),  # Pink
				Color("#01CDFE"),  # Cyan
				Color("#05FFA1"),  # Mint
				Color("#B967FF"),  # Purple
				Color("#FFFB96"),  # Pale Yellow
			]
		ColorScheme.SYNTHWAVE:
			return [
				Color("#FF006E"),  # Hot Pink
				Color("#8338EC"),  # Purple
				Color("#3A86FF"),  # Blue
				Color("#FB5607"),  # Orange
				Color("#FFBE0B"),  # Yellow
			]
		ColorScheme.ICE_BLUE:
			return [
				Color("#00D9FF"),  # Bright Cyan
				Color("#0099FF"),  # Blue
				Color("#66E0FF"),  # Light Blue
				Color("#FFFFFF"),  # White
			]
		ColorScheme.FIRE_ORANGE:
			return [
				Color("#FF4500"),  # Orange Red
				Color("#FF6B00"),  # Orange
				Color("#FFAA00"),  # Golden Orange
				Color("#FF0000"),  # Red
			]
		ColorScheme.TOXIC_GREEN:
			return [
				Color("#39FF14"),  # Neon Green
				Color("#00FF00"),  # Green
				Color("#7FFF00"),  # Chartreuse
				Color("#32CD32"),  # Lime Green
			]
		ColorScheme.CUSTOM:
			return custom_colors if not custom_colors.is_empty() else [Color.WHITE]
	
	return [Color.WHITE]

func _draw() -> void:
	for ring in rings:
		draw_arc(
			Vector2.ZERO,
			ring.radius,
			ring.start_angle + ring.rotation,
			ring.end_angle + ring.rotation,
			point_count,
			ring.color,
			ring.width,
			true
		)

func _physics_process(delta: float) -> void:
	for ring in rings:
		ring.rotation += deg_to_rad(ring["spin"]) * delta * 60
	
	queue_redraw()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
