class_name PitchField
extends Control

signal move_closer_requested
signal move_farther_requested
signal batter_call_displayed(call_text: String, color: Color)
signal field_tapped(field_position: Vector2)

const Content = preload("res://scripts/content.gd")
const MAX_VISUAL_BALLS := 4000
const WEB_MAX_VISUAL_BALLS := 512
const STREAM_WRAP_SECONDS := 3600.0
const MAX_VISUAL_TRAVEL_SECONDS := 120.0
const MAX_DETAILED_RESULTS_PER_SECOND := 30.0
const MAX_RETURN_BALLS := 512
const WEB_MAX_RETURN_BALLS := 96
const DETAILED_RETURN_BALL_LIMIT := 64
const MAX_STAR_DENSITY := 190
const WEB_MAX_STAR_DENSITY := 96
const MAX_CLONE_VISUALS := 32
const WEB_MAX_CLONE_VISUALS := 16
const FLIGHT_METER_COLOR := Color("ffd36b")
const REPRESENTATIVE_RESULT_INTERVAL := 0.12
const PITCHER_COLOR := Color("68d5ff")
const BASE_PITCHER_INTRINSIC_SIZE := 1.08
const RANGE_CONTROL_TOUCH_SIZE := 44.0
const BATTER_CONTACT_HOLD := 0.18
const BATTER_ENTRY_DURATION := 0.25
const LOOT_POPUP_DURATION := 2.40
const FIELD_TAP_EFFECT_DURATION := 0.48
const MAX_FIELD_TAP_EFFECTS := 18
const BATTER_EXIT_DURATIONS := [1.00, 0.72, 0.55, 0.42, 0.30, 0.20, 0.26, 0.12]
# Total contact + exit + empty plate + entrance closely matches the authoritative
# downtime in BaseballGameState: Grand Slams make the player wait twelve full
# seconds, while a clean strikeout uses a believable three-second handoff.
const BATTER_REPLACEMENT_DELAYS := [10.57, 6.85, 5.02, 4.15, 3.27, 0.00, 3.31, 2.45]
const BATTER_LIFECYCLE_TOTALS := [12.0, 8.0, 6.0, 5.0, 4.0, 0.63, 4.0, 3.0]

var ball_stream: MultiMeshInstance2D
var ball_multimesh: MultiMesh
var ball_material: ShaderMaterial
var stream_time := 0.0
var total_time := 0.0
var next_ball_slot := 0
var pitch_serial := 0
var spawn_credit := 0.0
var logical_pitch_rate := 0.25
var visual_spawn_rate := 0.25
var travel_time := 3.0
var visual_weight := 1.0
var slot_expiry_times := PackedFloat64Array()
var slot_launch_data: Array[Dictionary] = []
var active_pitch_slots := {}
var throw_animation := 0.0
var pitch_cycle_sample_time := 0.0
var bat_swing_animation := 0.0
var last_contact_outcome := Content.STRIKE_INDEX
var strike_icon_flash := 0.0
var removed_strike_icon := -1
var move_closer_arrow: Button
var move_farther_arrow: Button
var portrait_up_icon: ImageTexture
var portrait_down_icon: ImageTexture
var landscape_left_icon: ImageTexture
var landscape_right_icon: ImageTexture

var snapshot := {
	"opponent_index": 0,
	"distance_index": 0,
	"max_distance_index": 0,
	"distance_feet": 3.0,
	"distance_label": "3 ft",
	"distance_gear_multiplier": 1.0,
	"arms": 1.0,
	"clones": 1.0,
	"time_layers": 1.0,
	"batter_downtimes": [12.0, 8.0, 6.0, 5.0, 4.0, 0.0, 4.0, 3.0],
	"velocity": 1.0,
	"distance_penalty_multiplier": 1.0,
		"pitch_rate": 0.25,
		"recovery_rate": 0.25,
		"volley_size": 1,
		"pitch_cycle_progress": 0.0,
		"pitcher_size_multiplier": 1.0,
		"strike_limit": 3,
		"ball_limit": 4,
		"opponent_bat_count": 1,
		"authoritative_strikes": 0,
		"authoritative_balls": 0,
		"batter_cooldown": 0.0,
		"batter_generation": 0,
		"batter_name": "Little Timmy",
		"batter_body_scale": 1.0,
		"opponent_loadout": [],
		"opponent_body_color": Color("f28a62"),
		"opponent_bat_color": Color("a9b6c5"),
	"xp_multiplier": 1.0,
		"ball_tier": 0,
		"pitch_colors": [Color.WHITE],
		"gear_colors": {},
		"clone_gear_linked": false,
		"can_move_closer": false,
		"can_move_farther": false,
		"representative_pitch_speed": 1.0,
		"drag_per_foot": 0.0,
		"tap_rate": 0.0,
		"tap_laps": 0.0,
		"tap_signal": 0.0,
		"automatic_clickers": 0,
		"automatic_rate_each": 0.0,
	}

var impact_color := Color.TRANSPARENT
var impact_strength := 0.0
var pending_results: Array[Dictionary] = []
var return_balls: Array[Dictionary] = []
var result_popups: Array[Dictionary] = []
var loot_popups: Array[Dictionary] = []
var field_tap_effects: Array[Dictionary] = []
var last_screen_touch_msec := -100000
var last_result_scheduled_at := -100.0
var result_sequence := 0
var configured_opponent_index := -1
var current_batter_name := ""
var batter_generation := 0
var visual_strike_count := 0
var visual_ball_count := 0
var batter_phase := "active"
var batter_phase_age := 0.0
var batter_phase_duration := 0.0
var batter_end_pending := false
var batter_end_delay := 0.0
var batter_exit_outcome := Content.STRIKE_INDEX
var batter_lifecycle_total_override := -1.0
var batter_terminal_in_flight := false
var volley_in_flight := false
var active_visual_volleys := {}
var volley_release_time := 0.0
var volley_flight_duration := 0.0
var volley_plate_position := Vector2.ZERO
var last_pitch_id := "dead_fish"
var last_pitch_name := "DEAD-FISH LOB"
var last_pitch_volley_size := 1
var last_pitch_speed_fps := 1.0
var last_pitch_plate_speed_fps := 1.0
var last_pitch_drag_loss_fraction := 0.0
var last_pitch_distance_index := 0
var pitch_call_age := 99.0
var last_pitch_visual_travel_time := 3.0
var cached_star_lines := PackedVector2Array()
var cached_bright_star_lines := PackedVector2Array()
var cached_star_size := Vector2.ZERO
var cached_star_density := -1
var browser_visual_profile := false
var portrait_layout := false
var visual_ball_capacity := MAX_VISUAL_BALLS
var return_ball_capacity := MAX_RETURN_BALLS
var star_density_capacity := MAX_STAR_DENSITY
var clone_visual_capacity := MAX_CLONE_VISUALS

func _ready() -> void:
	browser_visual_profile = OS.has_feature("web") or OS.has_feature("browser_build")
	if browser_visual_profile:
		visual_ball_capacity = WEB_MAX_VISUAL_BALLS
		return_ball_capacity = WEB_MAX_RETURN_BALLS
		star_density_capacity = WEB_MAX_STAR_DENSITY
		clone_visual_capacity = WEB_MAX_CLONE_VISUALS
	mouse_filter = Control.MOUSE_FILTER_PASS
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tooltip_text = "Tap the open field to advance the active timer. Repeated input on one timer smoothly loses effectiveness."
	clip_contents = true
	_setup_ball_stream()
	_setup_range_arrows()
	gui_input.connect(_on_field_gui_input)
	resized.connect(_on_resized)
	set_process(true)

func reset_visual_state() -> void:
	# Hard-resetting progression must also retire every GPU instance and every
	# delayed cosmetic result. Otherwise an old body's pitch can briefly cross
	# the fresh toddler field after the save has already been erased.
	for slot in visual_ball_capacity:
		slot_expiry_times[slot] = 0.0
		slot_launch_data[slot] = {}
		if ball_multimesh != null:
			ball_multimesh.set_instance_custom_data(slot, Color(0.0, 0.0, 0.5, 0.0))
			ball_multimesh.set_instance_transform_2d(
				slot,
				Transform2D(0.0, Vector2.ONE, 0.0, Vector2(-1000.0, -1000.0))
			)
	active_pitch_slots.clear()
	next_ball_slot = 0
	pitch_serial = 0
	spawn_credit = 0.0
	pending_results.clear()
	return_balls.clear()
	result_popups.clear()
	loot_popups.clear()
	field_tap_effects.clear()
	last_result_scheduled_at = -100.0
	result_sequence = 0
	configured_opponent_index = -1
	current_batter_name = ""
	batter_generation = 0
	visual_strike_count = 0
	visual_ball_count = 0
	batter_phase = "active"
	batter_phase_age = 0.0
	batter_phase_duration = 0.0
	batter_end_pending = false
	batter_end_delay = 0.0
	batter_exit_outcome = Content.STRIKE_INDEX
	batter_lifecycle_total_override = -1.0
	batter_terminal_in_flight = false
	active_visual_volleys.clear()
	volley_in_flight = false
	volley_release_time = 0.0
	volley_flight_duration = 0.0
	volley_plate_position = Vector2.ZERO
	throw_animation = 0.0
	bat_swing_animation = 0.0
	impact_strength = 0.0
	strike_icon_flash = 0.0
	removed_strike_icon = -1
	last_pitch_id = "dead_fish"
	last_pitch_name = "DEAD-FISH LOB"
	last_pitch_volley_size = 1
	last_pitch_speed_fps = 1.0
	last_pitch_plate_speed_fps = 1.0
	last_pitch_drag_loss_fraction = 0.0
	last_pitch_distance_index = 0
	pitch_call_age = 99.0
	last_pitch_visual_travel_time = 3.0
	queue_redraw()

func set_portrait_layout(enabled: bool) -> void:
	if portrait_layout == enabled:
		return
	portrait_layout = enabled
	# Every live projectile stores an immutable screen-space launch. Recreate an
	# unresolved authoritative pitch after an orientation change so it follows the
	# newly rotated field without altering its outcome, speed, or remaining time.
	reset_visual_state()
	_update_shader_parameters()
	_update_range_arrows()
	queue_redraw()

func is_portrait_layout() -> bool:
	return portrait_layout

func _setup_ball_stream() -> void:
	ball_multimesh = MultiMesh.new()
	ball_multimesh.transform_format = MultiMesh.TRANSFORM_2D
	ball_multimesh.use_colors = true
	ball_multimesh.use_custom_data = true
	var quad := QuadMesh.new()
	quad.size = Vector2(8.0, 8.0)
	ball_multimesh.mesh = quad
	ball_multimesh.instance_count = visual_ball_capacity
	ball_multimesh.visible_instance_count = visual_ball_capacity
	slot_expiry_times.resize(visual_ball_capacity)
	slot_launch_data.resize(visual_ball_capacity)
	for index in visual_ball_capacity:
		slot_expiry_times[index] = 0.0
		slot_launch_data[index] = {}
		ball_multimesh.set_instance_transform_2d(
			index,
			Transform2D(0.0, Vector2.ONE, 0.0, Vector2(-1000.0, -1000.0))
		)
		ball_multimesh.set_instance_color(index, Color(1.0, 1.0, 1.0, 0.05))
		ball_multimesh.set_instance_custom_data(index, Color(0.0, 0.0, 0.5, 0.0))

	ball_stream = MultiMeshInstance2D.new()
	ball_stream.name = "ImmutableGPUInstancedPitchStream"
	ball_stream.multimesh = ball_multimesh
	ball_material = ShaderMaterial.new()
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
render_mode unshaded;

uniform float stream_time = 0.0;
uniform float maximum_field_length = 600.0;
uniform float maximum_arc_height = 120.0;
uniform float flight_drag_exponent = 0.0;
varying float pitch_active;

void vertex() {
	float stored_duration = INSTANCE_CUSTOM.y * 120.0;
	float spawn_time = INSTANCE_CUSTOM.x * 3600.0;
	float age = stream_time - spawn_time;
	if (age < 0.0) {
		age += 3600.0;
	}
	float duration = max(stored_duration, 0.001);
	pitch_active = step(0.001, stored_duration) * (1.0 - step(duration, age));
	float progress = clamp(age / duration, 0.0, 1.0);
	float drag_exponent = max(flight_drag_exponent, 0.0);
	if (drag_exponent > 0.00001) {
		progress = log(1.0 + progress * (exp(drag_exponent) - 1.0)) / drag_exponent;
	}
	float trail_length = max(COLOR.a * 20.0, 1.0);
	float flight_length = INSTANCE_CUSTOM.w * maximum_field_length;
	float signed_arc = (INSTANCE_CUSTOM.z * 2.0 - 1.0) * maximum_arc_height;
	VERTEX.x *= trail_length;
	VERTEX.x += progress * flight_length;
	VERTEX.y += sin(progress * 3.14159265) * signed_arc;
	VERTEX.y += sin(progress * 6.28318530) * signed_arc * 0.16;
}

void fragment() {
	vec2 centered = UV - vec2(0.5);
	float radius = length(centered);
	float alpha = 1.0 - smoothstep(0.30, 0.50, radius);
	COLOR = vec4(COLOR.rgb, alpha * pitch_active);
}
"""
	ball_material.shader = shader
	ball_stream.material = ball_material
	add_child(ball_stream)
	_on_resized()

func _setup_range_arrows() -> void:
	portrait_up_icon = _create_range_icon(Vector2i.UP)
	portrait_down_icon = _create_range_icon(Vector2i.DOWN)
	landscape_left_icon = _create_range_icon(Vector2i.LEFT)
	landscape_right_icon = _create_range_icon(Vector2i.RIGHT)
	move_farther_arrow = Button.new()
	move_farther_arrow.text = ""
	move_farther_arrow.tooltip_text = "Move the pitcher farther away"
	move_farther_arrow.custom_minimum_size = Vector2(38.0, 32.0)
	move_farther_arrow.size = Vector2(38.0, 32.0)
	move_farther_arrow.focus_mode = Control.FOCUS_NONE
	move_farther_arrow.z_index = 20
	move_farther_arrow.add_theme_font_size_override("font_size", 20)
	move_farther_arrow.pressed.connect(_request_move_farther)
	move_farther_arrow.visible = false
	move_farther_arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(move_farther_arrow)

	move_closer_arrow = Button.new()
	move_closer_arrow.text = ""
	move_closer_arrow.tooltip_text = "Move the pitcher closer to the batter"
	move_closer_arrow.custom_minimum_size = Vector2(38.0, 32.0)
	move_closer_arrow.size = Vector2(38.0, 32.0)
	move_closer_arrow.focus_mode = Control.FOCUS_NONE
	move_closer_arrow.z_index = 20
	move_closer_arrow.add_theme_font_size_override("font_size", 20)
	move_closer_arrow.pressed.connect(_request_move_closer)
	move_closer_arrow.visible = false
	move_closer_arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(move_closer_arrow)
	_update_range_arrows()

func _create_range_icon(direction: Vector2i) -> ImageTexture:
	var image := Image.create(28, 28, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	var color := Color("dce9f7")
	var source_pixels: Array[Vector2i] = []
	# Rasterized here instead of relying on arrow glyphs: browser fallback fonts
	# can substitute missing-glyph boxes on both phone and desktop Web exports.
	for y in range(4, 16):
		var half_width := mini(y - 3, 10)
		for x in range(14 - half_width, 15 + half_width):
			source_pixels.append(Vector2i(x, y))
	for y in range(14, 24):
		for x in range(11, 18):
			source_pixels.append(Vector2i(x, y))
	for source in source_pixels:
		var delta := source - Vector2i(14, 14)
		var target := source
		if direction == Vector2i.DOWN:
			target = Vector2i(14 - delta.x, 14 - delta.y)
		elif direction == Vector2i.LEFT:
			target = Vector2i(14 + delta.y, 14 - delta.x)
		elif direction == Vector2i.RIGHT:
			target = Vector2i(14 - delta.y, 14 + delta.x)
		if target.x >= 0 and target.x < 28 and target.y >= 0 and target.y < 28:
			image.set_pixelv(target, color)
	return ImageTexture.create_from_image(image)

func _request_move_closer() -> void:
	move_closer_requested.emit()

func _request_move_farther() -> void:
	move_farther_requested.emit()

func _on_field_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			last_screen_touch_msec = Time.get_ticks_msec()
			field_tapped.emit(touch.position)
	elif event is InputEventMouseButton:
		var click := event as InputEventMouseButton
		if (
			click.pressed
			and click.button_index == MOUSE_BUTTON_LEFT
			and Time.get_ticks_msec() - last_screen_touch_msec > 350
		):
			field_tapped.emit(click.position)

func apply_field_timer_advance(phase: String, seconds: float) -> void:
	var advance := maxf(seconds, 0.0)
	if advance <= 0.0:
		return
	match phase:
		"flight":
			stream_time = fmod(stream_time + advance, STREAM_WRAP_SECONDS)
			volley_release_time -= advance
			for id_value in active_visual_volleys.keys():
				var entry: Dictionary = active_visual_volleys[id_value]
				entry.released_at = float(entry.get("released_at", total_time)) - advance
				active_visual_volleys[id_value] = entry
			for slot_value in active_pitch_slots.keys():
				var slot := int(slot_value)
				slot_expiry_times[slot] = maxf(slot_expiry_times[slot] - advance, total_time)
		"lineup":
			_update_batter_lifecycle(advance)
		"recovery":
			# The meter extrapolates from its last authoritative sample. Backdating
			# only that sample makes it jump immediately without aging other effects.
			pitch_cycle_sample_time -= advance
	queue_redraw()

func show_field_tap(field_position: Vector2, result: Dictionary) -> void:
	var applied := bool(result.get("applied", false))
	var fraction := maxf(float(result.get("fraction", 0.0)), 0.0)
	var label := ""
	if applied and fraction > 0.00001:
		var percent := fraction * 100.0
		label = (
			"+%d%%" % int(round(percent))
			if absf(percent - round(percent)) < 0.05
			else "+%.1f%%" % percent
		)
	field_tap_effects.append({
		"position": Vector2(
			clampf(field_position.x, 16.0, maxf(size.x - 16.0, 16.0)),
			clampf(field_position.y, 16.0, maxf(size.y - 16.0, 16.0))
		),
		"age": 0.0,
		"duration": FIELD_TAP_EFFECT_DURATION,
		"applied": applied,
		"label": label,
	})
	while field_tap_effects.size() > MAX_FIELD_TAP_EFFECTS:
		field_tap_effects.pop_front()
	queue_redraw()

func _process(delta: float) -> void:
	stream_time = fmod(stream_time + delta, STREAM_WRAP_SECONDS)
	total_time += delta
	if ball_material != null:
		ball_material.set_shader_parameter("stream_time", stream_time)
	_retire_expired_pitch_slots()
	throw_animation = maxf(throw_animation - delta * 2.8, 0.0)
	bat_swing_animation = maxf(bat_swing_animation - delta * 2.1, 0.0)
	pitch_call_age += delta
	strike_icon_flash = maxf(strike_icon_flash - delta * 3.6, 0.0)
	impact_strength = maxf(impact_strength - delta * 2.2, 0.0)
	_update_field_tap_effects(delta)
	_update_batter_lifecycle(delta)
	_update_result_visuals(delta)
	queue_redraw()

func _update_field_tap_effects(delta: float) -> void:
	for index in range(field_tap_effects.size() - 1, -1, -1):
		field_tap_effects[index].age = float(field_tap_effects[index].age) + delta
		if float(field_tap_effects[index].age) >= float(field_tap_effects[index].duration):
			field_tap_effects.remove_at(index)

func configure_from_game(game: BaseballGameState, at_bat_metrics: Dictionary = {}) -> void:
	var incoming_opponent_index := game.current_opponent
	var variant := game.get_current_batter_variant()
	var opponent_loadout: Array = variant.get("loadout", [])
	var opponent_body_color := Color("f28a62")
	var opponent_bat_color := Color("a9b6c5")
	for entry_value in opponent_loadout:
		var entry: Dictionary = entry_value
		if str(entry.get("id", "")) == "body":
			opponent_body_color = Color(entry.get("color", opponent_body_color))
		elif str(entry.get("id", "")) == "bat":
			opponent_bat_color = Color(entry.get("color", opponent_bat_color))
	var colors: Array[Color] = []
	for pitch_id in game.unlocked_pitches:
		var pitch := Content.pitch_by_id(pitch_id)
		if not pitch.is_empty():
			colors.append(pitch.color)
	if colors.is_empty():
		colors.append(Color.WHITE)
	var gear_colors := {}
	for definition in Content.LOOT_SLOTS:
		var slot := str(definition.id)
		var item := game.get_equipped_loot_item(slot)
		if not item.is_empty():
			gear_colors[slot] = game.get_equipped_loot_color(slot, PITCHER_COLOR)
	var distance := game.get_current_distance()
	var batter_downtimes: Array[float] = []
	for outcome in Content.OUTCOME_NAMES.size():
		batter_downtimes.append(game.get_batter_downtime(outcome))
	snapshot = {
		"opponent_index": game.current_opponent,
		"distance_index": game.selected_distance_index,
		"max_distance_index": game.get_max_distance_index(),
		"distance_feet": game.get_pitch_distance_feet(),
		"distance_label": str(distance.label),
		# Legacy snapshot field retained for older rendering/debug consumers. Range
		# no longer pays XP; equipment now helps the range's threat instead.
		"distance_gear_multiplier": 1.0,
		"arms": game.get_arm_count(),
		"clones": game.get_clone_count(),
		"time_layers": game.get_time_multiplier(),
		"batter_downtimes": batter_downtimes,
		"velocity": game.get_velocity_fps(),
		"distance_penalty_multiplier": game.get_distance_penalty_multiplier(),
		"pitch_rate": game.get_pitch_rate(),
		"recovery_rate": game.get_recovery_rate(),
		"volley_size": game.get_volley_size(),
		"pitch_cycle_progress": game.get_pitch_cycle_progress(),
		"pitcher_size_multiplier": game.get_pitcher_size_multiplier(),
		"strike_limit": game.get_strikes_required(),
		"ball_limit": game.get_balls_required(),
		"opponent_bat_count": game.get_opponent_bat_count(),
		"authoritative_strikes": game.plate_strikes,
		"authoritative_balls": game.plate_balls,
		"batter_cooldown": game.batter_cooldown_remaining,
		"batter_generation": game.batter_generation,
		"batter_name": str(variant.name),
		"batter_body_scale": float(variant.get("body_scale", 1.0)),
		"opponent_loadout": opponent_loadout.duplicate(true),
		"opponent_body_color": opponent_body_color,
		"opponent_bat_color": opponent_bat_color,
		"pitch_in_flight": game.is_pitch_in_flight(),
		"overlap_flights": game.can_overlap_pitch_flights(),
		"flight_remaining": game.pitch_flight_remaining,
		"pending_volley_size": game.pending_volley_size,
		"xp_multiplier": game.get_xp_multiplier(),
		"ball_tier": game.purchased_ball_upgrades.size(),
		"pitch_colors": colors,
		"gear_colors": gear_colors,
		"clone_gear_linked": game.has_eldritch_upgrade("clone_dress_code"),
		"can_move_closer": false,
		"can_move_farther": false,
		"representative_pitch_speed": game.get_representative_pitch_speed(),
		"drag_per_foot": (
			game.pending_volley_drag_per_foot
			if game.is_pitch_in_flight()
			else game.get_ball_drag_per_foot()
		),
		"tap_rate": game.get_live_tap_rate(),
		"tap_laps": game.get_live_tap_rate() / maxf(game.get_field_tap_fatigue_tolerance(), 0.001),
		"tap_signal": game.get_tap_signal_ratio(),
		"automatic_clickers": game.get_automatic_clicker_count(),
		"automatic_rate_each": (
			game.get_effective_automatic_field_tap_rate()
			/ float(maxi(game.get_automatic_clicker_count(), 1))
		),
	}
	if game.is_pitch_in_flight():
		var pending_pitch := Content.pitch_by_id(game.pending_volley_pitch_id)
		last_pitch_id = game.pending_volley_pitch_id
		last_pitch_volley_size = maxi(game.pending_volley_size, 1)
		last_pitch_name = format_pitch_call(
			str(pending_pitch.get("name", "PITCH")),
			last_pitch_volley_size
		)
		last_pitch_speed_fps = game.pending_volley_speed_fps
		last_pitch_plate_speed_fps = game.pending_volley_plate_speed_fps
		last_pitch_distance_index = game.pending_volley_distance_index
		last_pitch_visual_travel_time = game.pending_volley_flight_duration
		last_pitch_drag_loss_fraction = clampf(
			1.0 - last_pitch_plate_speed_fps / maxf(last_pitch_speed_fps, 0.000001),
			0.0,
			1.0
		)
	elif pitch_serial == 0:
		last_pitch_speed_fps = game.get_representative_pitch_speed()
		last_pitch_plate_speed_fps = game.get_representative_plate_speed()
		last_pitch_drag_loss_fraction = game.get_pitch_drag_loss_fraction()
	pitch_cycle_sample_time = total_time
	if configured_opponent_index != incoming_opponent_index:
		var preserve_released_ball := volley_in_flight
		_reset_batter_for_opponent(incoming_opponent_index, preserve_released_ball)
		visual_strike_count = clampi(game.plate_strikes, 0, maxi(get_strike_limit() - 1, 0))
		visual_ball_count = clampi(game.plate_balls, 0, maxi(get_ball_limit() - 1, 0))
		if game.batter_cooldown_remaining > 0.0:
			# Loading a save during a replacement gap must not briefly resurrect a
			# batter or permit visual pitches. The exact departed name is cosmetic
			# and intentionally not part of the save contract; select the next one.
			batter_generation = game.batter_generation + 1
			current_batter_name = Content.batter_display_name(incoming_opponent_index, batter_generation)
			visual_strike_count = 0
			visual_ball_count = 0
			batter_phase = "waiting"
			batter_phase_age = 0.0
			batter_phase_duration = game.batter_cooldown_remaining
	elif game.batter_generation > batter_generation:
		batter_generation = game.batter_generation
		current_batter_name = str(variant.name)
	visual_strike_count = mini(visual_strike_count, get_strike_limit())
	visual_ball_count = mini(visual_ball_count, get_ball_limit())
	logical_pitch_rate = maxf(
		float(at_bat_metrics.get("active_pitches_per_second", 0.0))
		if not at_bat_metrics.is_empty()
		else game.get_effective_pitch_rate(),
		0.0
	)
	travel_time = game.get_resolved_flight_seconds()
	visual_spawn_rate = minf(logical_pitch_rate, float(visual_ball_capacity) / maxf(travel_time, 0.001))
	visual_weight = maxf(float(game.get_volley_size()) / float(visual_ball_capacity), 1.0)
	# Rehydrate every immutable volley after loading, rotating, or reopening the
	# browser. Release events normally populate this map first; the id check makes
	# this fallback safe to run on every UI refresh without duplicating balls.
	if game.is_pitch_in_flight() and _is_batter_visually_present():
		for volley_value in game.active_volleys:
			var saved_volley: Dictionary = volley_value
			var saved_id := int(saved_volley.get("id", 0))
			if active_visual_volleys.has(saved_id):
				_sync_visual_volley_clock(
					saved_id,
					float(saved_volley.get("remaining", 0.0)),
					float(saved_volley.get("duration", 0.001))
				)
				continue
			var saved_duration := maxf(float(saved_volley.get("duration", 0.16)), 0.001)
			var saved_remaining := clampf(
				float(saved_volley.get("remaining", saved_duration)),
				0.0,
				saved_duration
			)
			var backdate := maxf(saved_duration - saved_remaining, 0.0)
			_spawn_visual_volley(
				maxi(int(saved_volley.get("ball_count", 1)), 1),
				backdate,
				str(saved_volley.get("pitch_id", "dead_fish")),
				saved_duration,
				saved_id
			)
			_register_visual_volley(saved_id, backdate, saved_duration)
	_update_shader_parameters()
	_update_range_arrows()
	queue_redraw()

func sync_active_volley_clocks(authoritative_volleys: Array) -> void:
	# GameState owns flight time. The field shader used to keep advancing from
	# wall-clock release time, which meant active tapping could resolve a pitch
	# before its dot reached the plate. Rebase every rendered instance to the
	# immutable volley's authoritative remaining time after each simulation frame.
	# This changes only its progress clock; source, target, pitch, curve, color,
	# duration, and sampled outcome remain the released snapshot.
	var authoritative_ids := {}
	for volley_value in authoritative_volleys:
		var volley: Dictionary = volley_value
		var volley_id := int(volley.get("id", 0))
		authoritative_ids[volley_id] = true
		if not active_visual_volleys.has(volley_id):
			continue
		_sync_visual_volley_clock(
			volley_id,
			float(volley.get("remaining", 0.0)),
			float(volley.get("duration", 0.001))
		)
	# The field is only a projection of GameState's immutable volley queue. A
	# resolved volley can disappear from the authoritative queue before a field
	# rehydrate spawns its next frame, so retire stale projections instead of
	# leaving a FLIGHT meter frozen at 0.0 seconds.
	for visual_id_value in active_visual_volleys.keys():
		var visual_id := int(visual_id_value)
		if authoritative_ids.has(visual_id):
			continue
		for slot_value in active_pitch_slots.keys():
			var slot := int(slot_value)
			if int(slot_launch_data[slot].get("volley_id", -1)) == visual_id:
				_retire_pitch_slot(slot)
		active_visual_volleys.erase(visual_id)
	_refresh_visual_volley_compatibility()

func _sync_visual_volley_clock(volley_id: int, remaining_seconds: float, duration_seconds: float) -> void:
	var duration := maxf(duration_seconds, 0.001)
	var remaining := clampf(remaining_seconds, 0.0, duration)
	var elapsed := duration - remaining
	var released_at := total_time - elapsed
	var spawn_at := fmod(stream_time - elapsed + STREAM_WRAP_SECONDS, STREAM_WRAP_SECONDS)
	var entry: Dictionary = active_visual_volleys.get(volley_id, {})
	if entry.is_empty():
		return
	entry.released_at = released_at
	entry.duration = duration
	active_visual_volleys[volley_id] = entry
	for slot_value in active_pitch_slots.keys():
		var slot := int(slot_value)
		var launch: Dictionary = slot_launch_data[slot]
		if int(launch.get("volley_id", -1)) != volley_id:
			continue
		launch.released_at = released_at
		launch.spawn_time = spawn_at
		launch.duration = duration
		launch.authoritative_progress = elapsed / duration
		var custom_data := Color(launch.get("custom_data", Color(0.0, 0.0, 0.5, 0.0)))
		custom_data.r = spawn_at / STREAM_WRAP_SECONDS
		custom_data.g = duration / MAX_VISUAL_TRAVEL_SECONDS
		launch.custom_data = custom_data
		slot_launch_data[slot] = launch
		slot_expiry_times[slot] = total_time + remaining
		if ball_multimesh != null:
			ball_multimesh.set_instance_custom_data(slot, custom_data)

func _compress_travel_time(physical_seconds: float) -> float:
	# Compatibility helper retained for renderer tests. Authoritative and visual
	# timing now share the same physical duration.
	return maxf(physical_seconds, 0.000001)

func _spawn_pitch(
	backdate: float,
	flight_seconds := -1.0,
	color_override: Variant = null,
	volley_index := -1,
	volley_count := 1,
	pitch_id_override := "",
	volley_id := 0
) -> void:
	var slot := next_ball_slot
	next_ball_slot = (next_ball_slot + 1) % visual_ball_capacity
	pitch_serial += 1
	var mound := _get_mound_position(float(snapshot.distance_feet))
	var source := mound + _get_pitch_source_offset(pitch_serial)
	var target := _get_plate_position()
	var flight_vector := target - source
	var flight_length := maxf(flight_vector.length(), 1.0)
	var angle := flight_vector.angle()
	var launch_duration := travel_time if flight_seconds <= 0.0 else flight_seconds
	var spawn_at := fmod(stream_time - backdate + STREAM_WRAP_SECONDS, STREAM_WRAP_SECONDS)
	var curve_seed := fmod(float(pitch_serial * 73 + 19), 101.0) / 100.0
	var curve_sign := -1.0 if pitch_serial % 2 == 0 else 1.0
	var arc_strength := _get_salvo_strength()
	var signed_curve := curve_sign * arc_strength * (0.45 + curve_seed * 0.55)
	if volley_count > 1 and volley_index >= 0:
		# A multi-arm release owns distinct lanes. In particular, the first
		# two-ball mutation always produces a clean mirrored pair instead of two
		# nearly coincident projectiles. Larger salvos alternate sides and spread
		# outward with a small deterministic variation in curvature.
		var pair_count := int(ceil(float(volley_count) * 0.5))
		var pair_index := int(volley_index / 2)
		var lane_fraction := float(pair_index + 1) / float(maxi(pair_count, 1))
		curve_sign = -1.0 if volley_index % 2 == 0 else 1.0
		var readable_floor := 0.09 * (0.55 + lane_fraction * 0.45)
		var lane_strength := maxf(
			arc_strength * (0.35 + lane_fraction * 0.65),
			readable_floor
		)
		var variation := 1.0 if volley_count == 2 else 0.90 + curve_seed * 0.20
		signed_curve = curve_sign * lane_strength * variation
	var trail_length := _get_future_trail_length()
	var projectile_scale := _get_ball_visual_scale()
	var colors: Array = snapshot.pitch_colors
	var color: Color = (
		Color(color_override)
		if color_override != null
		else colors[pitch_serial % colors.size()]
	)
	color.a = clampf(trail_length / 20.0, 0.05, 1.0)
	var instance_transform := Transform2D(angle, Vector2.ONE * projectile_scale, 0.0, source)
	var custom_data := Color(
		spawn_at / STREAM_WRAP_SECONDS,
		launch_duration / MAX_VISUAL_TRAVEL_SECONDS,
		clampf((signed_curve / projectile_scale + 1.0) * 0.5, 0.0, 1.0),
		clampf(flight_length / maxf(_get_field_axis_length() * projectile_scale, 1.0), 0.0, 1.0)
	)
	ball_multimesh.set_instance_transform_2d(slot, instance_transform)
	ball_multimesh.set_instance_color(slot, color)
	ball_multimesh.set_instance_custom_data(slot, custom_data)
	slot_launch_data[slot] = {
		"volley_id": volley_id,
		"released_at": total_time - backdate,
		"spawn_time": spawn_at,
		"duration": launch_duration,
		"signed_curve": signed_curve,
		"volley_index": volley_index,
		"volley_count": volley_count,
		"pitch_id": pitch_id_override,
		"flight_length": flight_length,
		"source": source,
		"source_offset": source - mound,
		"target": target,
		"heading": angle,
		"color": color,
		"trail_length": trail_length,
		"projectile_scale": projectile_scale,
		"drag_per_foot": float(snapshot.get("drag_per_foot", 0.0)),
		"distance_feet": float(snapshot.get("distance_feet", 3.0)),
		"transform": instance_transform,
		"custom_data": custom_data,
	}
	slot_expiry_times[slot] = total_time - backdate + launch_duration
	active_pitch_slots[slot] = true
	throw_animation = 1.0

func _get_pitch_source_offset(serial: int) -> Vector2:
	var clone_count := clampi(int(snapshot.clones), 1, clone_visual_capacity)
	var arm_count := clampi(int(snapshot.arms), 1, 8)
	var source_number := serial % maxi(clone_count * arm_count, 1)
	var clone_index := source_number / arm_count
	var arm_index := source_number % arm_count
	var clone_offset := _get_clone_offset(clone_index)
	return clone_offset + _get_arm_release_offset(arm_index, arm_count)

func _get_arm_release_offset(arm_index: int, arm_count: int) -> Vector2:
	return Vector2(_get_throw_arm_geometry(arm_index, arm_count, 1.0).end)

func _get_throw_arm_geometry(arm_index: int, arm_count: int, motion: float) -> Dictionary:
	# Negative motion is the cocked-back pose.  It is visual-only: the release
	# source continues to request exactly 1.0, so immutable projectile snapshots
	# remain coupled to the forward endpoint.
	var bounded_motion := clampf(motion, -0.68, 1.0)
	var spread_position := (
		-0.5 + float(arm_index) / float(maxi(arm_count - 1, 1))
		if arm_count > 1
		else 0.0
	)
	# The opening pitcher is right-handed: below the body when facing right on a
	# desktop field, which rotates to screen-right when facing up on a phone.
	var resting_angle := 0.58 if arm_count == 1 else spread_position * 1.30
	var release_angle := 0.0 if arm_count == 1 else spread_position * 0.62
	var cocked_angle := resting_angle + (0.82 if arm_count == 1 else signf(spread_position if spread_position != 0.0 else 1.0) * 0.68)
	var angle := (
		lerp_angle(resting_angle, cocked_angle, -bounded_motion / 0.68)
		if bounded_motion < 0.0
		else lerp_angle(resting_angle, release_angle, bounded_motion)
	)
	var direction := Vector2(cos(angle), sin(angle))
	var body_scale := _get_pitcher_visual_scale()
	var forward_motion := maxf(bounded_motion, 0.0)
	var start_distance := (6.4 + forward_motion * 1.5) * body_scale
	var end_distance := (14.0 + forward_motion * 3.7) * body_scale
	var start := direction * start_distance
	var finish := direction * end_distance
	var normal := Vector2(-direction.y, direction.x)
	return {
		"start": _orient_pitch_vector(start),
		"end": _orient_pitch_vector(finish),
		"normal": _orient_pitch_vector(normal),
	}

func _orient_pitch_vector(local_vector: Vector2) -> Vector2:
	# Desktop throws left-to-right. A portrait phone uses the same local field
	# coordinates rotated counter-clockwise: pitcher below, batter above.
	if portrait_layout:
		return Vector2(local_vector.y, -local_vector.x)
	return local_vector

func _get_pitch_direction() -> Vector2:
	return Vector2.UP if portrait_layout else Vector2.RIGHT

func _get_lateral_direction() -> Vector2:
	return Vector2.RIGHT if portrait_layout else Vector2.DOWN

func _get_field_axis_length() -> float:
	return size.y if portrait_layout else size.x

func _get_field_lateral_length() -> float:
	return size.x if portrait_layout else size.y

func _get_clone_offset(clone_index: int) -> Vector2:
	if clone_index <= 0:
		return Vector2.ZERO
	var angle := float(clone_index) * 2.39996323
	var ring_index: float = floor(float(clone_index - 1) / 8.0)
	var body_diameter: float = 20.0 * _get_pitcher_visual_scale()
	var radius: float = maxf(body_diameter * 1.20, 24.0) * (1.0 + ring_index)
	return Vector2(cos(angle), sin(angle)) * radius

func _get_salvo_strength() -> float:
	var formation_steps := (
		log(maxf(float(snapshot.arms), 1.0)) / log(2.0)
		+ log(maxf(float(snapshot.clones), 1.0)) / log(2.0)
		+ log(maxf(float(snapshot.time_layers), 1.0)) / log(2.0)
	)
	var formation_strength := clampf(formation_steps / 10.0, 0.0, 1.0)
	var rate_strength := clampf(
		(log(logical_pitch_rate + 1.0) / log(10.0) - 1.0) / 3.0,
		0.0,
		1.0
	)
	return clampf(0.008 + maxf(formation_strength, rate_strength) * 0.82, 0.0, 0.98)

func _get_future_trail_length() -> float:
	# One arm on one body always reads as one ball. Anime missile streaks are a
	# visual reward for genuinely parallel throwing sources, not fake projectiles
	# attached to the opening wiffle-ball lob.
	var parallel_sources := (
		maxf(float(snapshot.arms), 1.0)
		* maxf(float(snapshot.clones), 1.0)
		* maxf(float(snapshot.time_layers), 1.0)
	)
	if parallel_sources <= 1.0:
		return 1.0
	var rate_scale := maxf(log(logical_pitch_rate + 1.0) / log(10.0), 0.0)
	var formation_scale := _get_salvo_strength() * 5.0
	return 1.0 + minf(rate_scale * 1.15 + float(snapshot.ball_tier) * 0.22 + formation_scale, 17.0)

func _retire_expired_pitch_slots() -> void:
	if ball_multimesh == null:
		return
	# The shader also fades expired instances, but clearing their duration and
	# moving them off-field makes the one-pitch/one-ball contract independent of
	# GPU varying precision. It also makes the on-screen count exact.
	for slot_value in active_pitch_slots.keys():
		var slot := int(slot_value)
		var expiry := slot_expiry_times[slot]
		if expiry <= 0.0 or expiry > total_time:
			continue
		_retire_pitch_slot(slot)

func _update_shader_parameters() -> void:
	if ball_material == null:
		return
	ball_material.set_shader_parameter("maximum_field_length", maxf(_get_field_axis_length(), 1.0))
	ball_material.set_shader_parameter("maximum_arc_height", maxf(_get_field_lateral_length() * 0.34, 20.0))
	ball_material.set_shader_parameter(
		"flight_drag_exponent",
		maxf(float(snapshot.get("drag_per_foot", 0.0)), 0.0)
		* maxf(float(snapshot.get("distance_feet", 3.0)), 0.0)
	)

func _on_resized() -> void:
	if ball_stream != null:
		ball_stream.position = Vector2.ZERO
	_update_shader_parameters()
	_reproject_active_pitch_slots()
	_update_range_arrows()
	queue_redraw()

func _reproject_active_pitch_slots() -> void:
	if ball_multimesh == null or active_pitch_slots.is_empty():
		return
	# Browser layouts can change the field rectangle when a side panel opens,
	# when the address bar collapses, or at the responsive breakpoint. Keep the
	# immutable pitch's elapsed time, duration, curve, color, and outcome, but
	# reproject its endpoints into the new field rectangle. Otherwise the shader's
	# resized axis and the old screen-space launch disagree and the ball appears to
	# detach from the arm or miss the plate.
	if volley_in_flight:
		volley_plate_position = _get_plate_position_unlocked()
	var target := _get_plate_position()
	var mound := _get_mound_position(float(snapshot.distance_feet))
	for slot_value in active_pitch_slots.keys():
		var slot := int(slot_value)
		var launch: Dictionary = slot_launch_data[slot]
		if launch.is_empty():
			continue
		var source_offset := Vector2(launch.get("source_offset", Vector2.ZERO))
		var source := mound + source_offset
		var flight_vector := target - source
		var flight_length := maxf(flight_vector.length(), 1.0)
		var heading := flight_vector.angle()
		var projectile_scale := maxf(float(launch.get("projectile_scale", 1.0)), 0.001)
		var signed_curve := float(launch.get("signed_curve", 0.0))
		var custom_data := Color(
			float(launch.get("spawn_time", 0.0)) / STREAM_WRAP_SECONDS,
			float(launch.get("duration", 0.001)) / MAX_VISUAL_TRAVEL_SECONDS,
			clampf((signed_curve / projectile_scale + 1.0) * 0.5, 0.0, 1.0),
			clampf(
				flight_length / maxf(_get_field_axis_length() * projectile_scale, 1.0),
				0.0,
				1.0
			)
		)
		var transform := Transform2D(
			heading,
			Vector2.ONE * projectile_scale,
			0.0,
			source
		)
		ball_multimesh.set_instance_transform_2d(slot, transform)
		ball_multimesh.set_instance_custom_data(slot, custom_data)
		launch.source = source
		launch.target = target
		launch.flight_length = flight_length
		launch.heading = heading
		launch.transform = transform
		launch.custom_data = custom_data
		slot_launch_data[slot] = launch

func _update_range_arrows() -> void:
	if move_closer_arrow == null or move_farther_arrow == null:
		return
	# Opponent level now assigns the thematic range. Keep these nodes as inert
	# compatibility anchors for old scenes/tests, but never expose a fake manual
	# optimization choice on desktop or phone.
	move_closer_arrow.visible = false
	move_farther_arrow.visible = false
	move_closer_arrow.disabled = true
	move_farther_arrow.disabled = true

func notify_batch(summary: Dictionary) -> int:
	var pitch_count := maxf(float(summary.get("pitches", 0.0)), 0.0)
	var elapsed_seconds := maxf(float(summary.get("elapsed_seconds", 0.0)), 0.0)
	var pitch_events: Array = summary.get("pitch_events", [])
	if not pitch_events.is_empty():
		if (pitch_events[0] as Dictionary).has("phase"):
			return _notify_phase_events(pitch_events, elapsed_seconds)
		return _notify_exact_pitch_events(pitch_events, elapsed_seconds)
	if pitch_count <= 0.0:
		return 0
	if not _is_batter_available_for_pitch():
		spawn_credit = 0.0
		return 0
	return _notify_aggregate_pitch_batch(summary, pitch_count, elapsed_seconds)

func _notify_phase_events(pitch_events: Array, elapsed_seconds: float) -> int:
	var launched := 0
	for event_value in pitch_events:
		var event: Dictionary = event_value
		match str(event.get("phase", "")):
			"release":
				if not _is_batter_available_for_pitch():
					continue
				var event_offset := clampf(
					float(event.get("elapsed_offset", elapsed_seconds)),
					0.0,
					elapsed_seconds
				)
				var backdate := maxf(elapsed_seconds - event_offset, 0.0)
				var pitch_id := str(event.get("pitch_id", "dead_fish"))
				var pitch_definition := Content.pitch_by_id(pitch_id)
				var exact_travel := maxf(float(event.get("flight_seconds", travel_time)), 0.001)
				last_pitch_id = pitch_id
				last_pitch_volley_size = maxi(int(event.get("ball_count", 1)), 1)
				last_pitch_name = format_pitch_call(
					str(event.get("pitch_name", pitch_definition.get("name", "PITCH"))),
					last_pitch_volley_size
				)
				last_pitch_speed_fps = maxf(float(event.get("pitch_speed_fps", snapshot.get("representative_pitch_speed", 1.0))), 0.000001)
				last_pitch_plate_speed_fps = maxf(float(event.get("plate_speed_fps", last_pitch_speed_fps)), 0.000001)
				last_pitch_drag_loss_fraction = clampf(
					1.0 - last_pitch_plate_speed_fps / maxf(last_pitch_speed_fps, 0.000001),
					0.0,
					1.0
				)
				last_pitch_distance_index = int(event.get("distance_index", snapshot.get("distance_index", 0)))
				pitch_call_age = 0.0
				var volley_id := int(event.get("volley_id", 0))
				launched += _spawn_visual_volley(
					maxi(int(event.get("ball_count", 1)), 1),
					backdate,
					pitch_id,
					exact_travel,
					volley_id
				)
				_register_visual_volley(volley_id, backdate, exact_travel)
				last_pitch_visual_travel_time = exact_travel
			"impact":
				_trigger_result_visual(event)
				_remove_visual_volley(int(event.get("volley_id", 0)))
			"target_lost":
				_veer_visual_volley(
					int(event.get("volley_id", 0)),
					int(event.get("veer_seed", 0))
				)
	return launched

func _spawn_visual_volley(
	ball_count: int,
	backdate: float,
	pitch_id := "",
	flight_seconds := -1.0,
	volley_id := 0
) -> int:
	var physical_count := maxi(ball_count, 0)
	if physical_count <= 0:
		return 0
	var render_count := mini(
		int(ceil(float(physical_count) / maxf(visual_weight, 1.0))),
		visual_ball_capacity
	)
	var definition := Content.pitch_by_id(pitch_id)
	var color_override: Variant = null if definition.is_empty() else Color(definition.color)
	for ball_index in render_count:
		_spawn_pitch(
			backdate,
			flight_seconds,
			color_override,
			ball_index,
			render_count,
			pitch_id,
			volley_id
		)
	return render_count

func _register_visual_volley(volley_id: int, backdate: float, duration: float) -> void:
	active_visual_volleys[volley_id] = {
		"released_at": total_time - maxf(backdate, 0.0),
		"duration": maxf(duration, 0.001),
		"plate": _get_plate_position_unlocked(),
	}
	_refresh_visual_volley_compatibility()

func _remove_visual_volley(volley_id: int) -> void:
	if active_visual_volleys.has(volley_id):
		active_visual_volleys.erase(volley_id)
	elif volley_id == 0 and not active_visual_volleys.is_empty():
		# Old exact events had no volley id. Remove only the soonest visual flight,
		# never the entire queue.
		var soonest_id := int(active_visual_volleys.keys()[0])
		var soonest_remaining := 1.0e300
		for id_value in active_visual_volleys.keys():
			var entry: Dictionary = active_visual_volleys[id_value]
			var remaining := (
				float(entry.get("released_at", total_time))
				+ float(entry.get("duration", 0.001))
				- total_time
			)
			if remaining < soonest_remaining:
				soonest_remaining = remaining
				soonest_id = int(id_value)
		active_visual_volleys.erase(soonest_id)
	_refresh_visual_volley_compatibility()

func _refresh_visual_volley_compatibility() -> void:
	volley_in_flight = not active_visual_volleys.is_empty()
	if not volley_in_flight:
		volley_release_time = 0.0
		volley_flight_duration = 0.0
		volley_plate_position = Vector2.ZERO
		return
	var display_entry: Dictionary = active_visual_volleys.values()[0]
	var shortest_remaining := 1.0e300
	for entry_value in active_visual_volleys.values():
		var entry: Dictionary = entry_value
		var remaining := (
			float(entry.get("released_at", total_time))
			+ float(entry.get("duration", 0.001))
			- total_time
		)
		if remaining < shortest_remaining:
			shortest_remaining = remaining
			display_entry = entry
	volley_release_time = float(display_entry.get("released_at", total_time))
	volley_flight_duration = maxf(float(display_entry.get("duration", 0.001)), 0.001)
	volley_plate_position = Vector2(display_entry.get("plate", _get_plate_position_unlocked()))

func _get_visual_pitch_position(launch: Dictionary) -> Vector2:
	var duration := maxf(float(launch.get("duration", 0.001)), 0.001)
	var raw_progress := (
		clampf(float(launch.authoritative_progress), 0.0, 1.0)
		if launch.has("authoritative_progress")
		else clampf(
			(total_time - float(launch.get("released_at", total_time))) / duration,
			0.0,
			1.0
		)
	)
	var drag_exponent := (
		maxf(float(launch.get("drag_per_foot", 0.0)), 0.0)
		* maxf(float(launch.get("distance_feet", 0.0)), 0.0)
	)
	var progress := raw_progress
	if drag_exponent > 0.00001:
		progress = log(1.0 + raw_progress * (exp(drag_exponent) - 1.0)) / drag_exponent
	var source := Vector2(launch.get("source", Vector2.ZERO))
	var target := Vector2(launch.get("target", source))
	var direction := (target - source).normalized()
	var normal := Vector2(-direction.y, direction.x)
	var arc_height := (
		float(launch.get("signed_curve", 0.0))
		* maxf(_get_field_lateral_length() * 0.34, 20.0)
	)
	var arc := (sin(progress * PI) + sin(progress * TAU) * 0.16) * arc_height
	return source.lerp(target, progress) + normal * arc

func _retire_pitch_slot(slot: int) -> void:
	if slot < 0 or slot >= slot_launch_data.size():
		return
	slot_expiry_times[slot] = 0.0
	slot_launch_data[slot] = {}
	active_pitch_slots.erase(slot)
	if ball_multimesh != null:
		ball_multimesh.set_instance_custom_data(slot, Color(0.0, 0.0, 0.5, 0.0))
		ball_multimesh.set_instance_transform_2d(
			slot,
			Transform2D(0.0, Vector2.ONE, 0.0, Vector2(-1000.0, -1000.0))
		)

func _veer_visual_volley(volley_id: int, veer_seed: int) -> void:
	var matching_slots: Array[int] = []
	for slot_value in active_pitch_slots.keys():
		var slot := int(slot_value)
		if int(slot_launch_data[slot].get("volley_id", 0)) == volley_id:
			matching_slots.append(slot)
	var random := RandomNumberGenerator.new()
	random.seed = veer_seed
	for slot in matching_slots:
		var launch := slot_launch_data[slot].duplicate(true)
		var start := _get_visual_pitch_position(launch)
		var direction := Vector2.RIGHT.rotated(random.randf_range(-PI, PI))
		var distance := random.randf_range(70.0, 145.0) * clampf(_get_camera_scale(), 0.75, 1.35)
		var finish := start + direction * distance
		var normal := Vector2(-direction.y, direction.x)
		var control := start.lerp(finish, 0.42) + normal * random.randf_range(-28.0, 28.0)
		var color := Color(launch.get("color", Color.WHITE))
		color.a = 1.0
		return_balls.append({
			"outcome": Content.STRIKE_INDEX,
			"color": color,
			"start": start,
			"control": control,
			"finish": finish,
			"age": 0.0,
			"duration": random.randf_range(0.28, 0.46),
			"saved": false,
			"relay": false,
			"relayed": false,
			"missed_strike": false,
			"fade_start": 0.0,
			"lost_target": true,
		})
		_retire_pitch_slot(slot)
	while return_balls.size() > return_ball_capacity:
		return_balls.pop_front()
	_remove_visual_volley(volley_id)

static func format_pitch_call(pitch_name: String, ball_count: int) -> String:
	var base_name := pitch_name.strip_edges().to_upper()
	match maxi(ball_count, 1):
		1:
			return base_name
		2:
			return "DOUBLE %s" % base_name
		3:
			return "TRIPLE %s" % base_name
		4:
			return "QUADRUPLE %s" % base_name
		5:
			return "QUINTUPLE %s" % base_name
		6:
			return "SEXTUPLE %s" % base_name
		7:
			return "SEPTUPLE %s" % base_name
		8:
			return "OCTUPLE %s" % base_name
		var count:
			return "%d-BALL %s" % [count, base_name]

func _notify_exact_pitch_events(pitch_events: Array, elapsed_seconds: float) -> int:
	var launched := 0
	var detailed_results := visual_spawn_rate <= MAX_DETAILED_RESULTS_PER_SECOND
	var representative_scheduled := false
	for event_value in pitch_events:
		var event: Dictionary = event_value
		var terminal := _pitch_event_is_terminal(event)
		spawn_credit += 1.0 / maxf(visual_weight, 1.0)
		if spawn_credit < 1.0:
			if terminal:
				_schedule_pitch_result(event, 0.0)
				break
			continue
		spawn_credit -= 1.0
		var event_offset := clampf(float(event.get("elapsed_offset", elapsed_seconds)), 0.0, elapsed_seconds)
		var backdate := maxf(elapsed_seconds - event_offset, 0.0)
		# A ball whose whole flight happened during a stalled frame should not be
		# replayed as a burst when rendering resumes.
		if backdate >= travel_time:
			if terminal:
				_schedule_pitch_result(event, 0.0)
				break
			continue
		_spawn_pitch(backdate)
		launched += 1
		if detailed_results:
			_schedule_pitch_result(event, travel_time - backdate)
		elif not representative_scheduled and _claim_representative_result_slot():
			_schedule_pitch_result(event, travel_time - backdate)
			representative_scheduled = true
		if terminal:
			break
	return launched

func _pitch_event_is_terminal(event: Dictionary) -> bool:
	if bool(event.get("holds_batter", false)):
		return false
	return bool(event.get("strikeout", false)) or (
		_result_has_unsaved_fair_hit(event)
	) or bool(event.get("walk", false))

func _result_has_unsaved_fair_hit(event: Dictionary) -> bool:
	var outcomes: Array = event.get("outcomes", [])
	var saved_flags: Array = event.get("saved_flags", [])
	if outcomes.is_empty():
		var outcome := clampi(
			int(event.get("outcome", Content.STRIKE_INDEX)),
			0,
			Content.OUTCOME_NAMES.size() - 1
		)
		var saved := (
			bool(event.get("saved", false))
			and outcome < Content.HIT_OUTCOME_COUNT
			and outcome != Content.GRAND_SLAM_INDEX
		)
		return outcome < Content.HIT_OUTCOME_COUNT and not saved
	for ball_index in outcomes.size():
		var outcome := clampi(int(outcomes[ball_index]), 0, Content.OUTCOME_NAMES.size() - 1)
		var saved := (
			ball_index < saved_flags.size()
			and bool(saved_flags[ball_index])
			and outcome < Content.HIT_OUTCOME_COUNT
			and outcome != Content.GRAND_SLAM_INDEX
		)
		if outcome < Content.HIT_OUTCOME_COUNT and not saved:
			return true
	return false

func _notify_aggregate_pitch_batch(
	summary: Dictionary,
	pitch_count: float,
	elapsed_seconds: float
) -> int:
	var sample_window := minf(maxf(elapsed_seconds, 0.001), travel_time)
	var recent_fraction := minf(sample_window / maxf(elapsed_seconds, 0.001), 1.0)
	spawn_credit += pitch_count * recent_fraction / maxf(visual_weight, 1.0)
	var launched := mini(int(floor(spawn_credit)), visual_ball_capacity)
	spawn_credit -= float(launched)
	for visual_index in launched:
		var backdate := sample_window * (
			float(launched - visual_index - 1) / float(maxi(launched, 1))
		)
		_spawn_pitch(backdate)
	if launched > 0 and _claim_representative_result_slot():
		_schedule_pitch_result({
			"outcome": int(summary.get("visual_outcome", Content.STRIKE_INDEX)),
			"xp": float(summary.get("visual_xp", 0.0)),
			"strikeout": bool(summary.get("visual_strikeout", false)),
			"saved": bool(summary.get("visual_saved", false)),
			"strike_count": int(summary.get("visual_strike_count", visual_strike_count)),
			"strike_requirement": int(summary.get("strike_requirement", get_strike_limit())),
		}, travel_time)
	return launched

func _schedule_pitch_result(event: Dictionary, delay: float) -> void:
	var outcome := clampi(
		int(event.get("outcome", Content.STRIKE_INDEX)),
		0,
		Content.OUTCOME_NAMES.size() - 1
	)
	var saved := bool(event.get("saved", false)) and outcome < Content.HIT_OUTCOME_COUNT and outcome != Content.GRAND_SLAM_INDEX
	var terminal := _pitch_event_is_terminal(event)
	if terminal:
		batter_terminal_in_flight = true
	pending_results.append({
		"delay": maxf(delay, 0.0),
		"outcome": outcome,
		"xp": float(event.get("xp", 0.0)),
		"salvo": _get_salvo_strength(),
		"strikeout": bool(event.get("strikeout", false)),
		"walk": bool(event.get("walk", false)),
		"saved": saved,
		"outcomes": (event.get("outcomes", []) as Array).duplicate(),
		"saved_flags": (event.get("saved_flags", []) as Array).duplicate(),
		"outcome_counts": (event.get("outcome_counts", []) as Array).duplicate(),
		"call_lines": (event.get("call_lines", []) as Array).duplicate(true),
		"call_text": str(event.get("call_text", "")),
		"strike_count": int(event.get("strike_count", visual_strike_count)),
		"plate_ball_count": int(event.get("plate_ball_count", visual_ball_count)),
		"strike_requirement": int(event.get("strike_requirement", get_strike_limit())),
		"ball_requirement": int(event.get("ball_requirement", get_ball_limit())),
		"ball_count": maxi(int(event.get("ball_count", 1)), 1),
		"opponent_bat_count": maxi(int(event.get("opponent_bat_count", 1)), 1),
		"batter_downtime": float(event.get("batter_downtime", -1.0)),
		"holds_batter": bool(event.get("holds_batter", false)),
		"story_taunt": str(event.get("story_taunt", "")),
	})

func _claim_representative_result_slot() -> bool:
	if total_time - last_result_scheduled_at < REPRESENTATIVE_RESULT_INTERVAL:
		return false
	last_result_scheduled_at = total_time
	return true

func _is_batter_available_for_pitch() -> bool:
	return (
		batter_phase == "active"
		and not batter_end_pending
		and not batter_terminal_in_flight
		and (not volley_in_flight or bool(snapshot.get("overlap_flights", false)))
	)

func _is_batter_visually_present() -> bool:
	return batter_phase == "active" and not batter_end_pending

func is_plate_ready_for_pitch() -> bool:
	return _is_batter_available_for_pitch()

func is_simulation_clock_available() -> bool:
	# A released volley still needs the authoritative flight clock to advance.
	# Only the visual batter turnover pauses new game-state transitions.
	return batter_phase == "active" or volley_in_flight

func _update_result_visuals(delta: float) -> void:
	# Age objects that existed at the start of the frame first. Pending impacts
	# are triggered last so a popup, continued strike, or new batter lifecycle is
	# never born and then charged the entire frame delta a second time.
	for index in range(return_balls.size() - 1, -1, -1):
		return_balls[index].age = float(return_balls[index].age) + delta
		if float(return_balls[index].age) >= float(return_balls[index].duration):
			if bool(return_balls[index].get("relay", false)) and not bool(return_balls[index].get("relayed", false)):
				var relay_start := Vector2(return_balls[index].finish)
				var relay_finish := Vector2(return_balls[index].relay_finish)
				var relay_flight := relay_finish - relay_start
				var relay_normal := Vector2(-relay_flight.y, relay_flight.x).normalized()
				return_balls[index].start = relay_start
				return_balls[index].finish = relay_finish
				return_balls[index].control = relay_start.lerp(relay_finish, 0.5) + relay_normal * 18.0
				return_balls[index].age = 0.0
				return_balls[index].duration = 0.34
				return_balls[index].relayed = true
			else:
				return_balls.remove_at(index)
	for index in range(result_popups.size() - 1, -1, -1):
		result_popups[index].age = float(result_popups[index].age) + delta
		if float(result_popups[index].age) >= float(result_popups[index].duration):
			result_popups.remove_at(index)
	for index in range(loot_popups.size() - 1, -1, -1):
		loot_popups[index].age = float(loot_popups[index].age) + delta
		if float(loot_popups[index].age) >= float(loot_popups[index].duration):
			loot_popups.remove_at(index)
	var due_results: Array[Dictionary] = []
	for index in range(pending_results.size() - 1, -1, -1):
		pending_results[index].delay = float(pending_results[index].delay) - delta
		if float(pending_results[index].delay) <= 0.0:
			# Insert at the front because removal is reverse-indexed. Calls then
			# remain in release order, leaving a terminal call as the final popup.
			due_results.push_front(pending_results[index])
			pending_results.remove_at(index)
	for result in due_results:
		_trigger_result_visual(result)

func _trigger_result_visual(result: Dictionary) -> void:
	var outcome := int(result.outcome)
	var salvo := float(result.get("salvo", _get_salvo_strength()))
	var ball_count := maxi(int(result.get("ball_count", 1)), 1)
	var outcomes: Array = (result.get("outcomes", []) as Array).duplicate()
	var saved_flags: Array = (result.get("saved_flags", []) as Array).duplicate()
	if outcomes.is_empty():
		for _ball_index in ball_count:
			outcomes.append(outcome)
			saved_flags.append(bool(result.get("saved", false)))
	while saved_flags.size() < outcomes.size():
		saved_flags.append(false)
	var any_unsaved_hit := _result_has_unsaved_fair_hit({
		"outcomes": outcomes,
		"saved_flags": saved_flags,
	})
	var holds_batter := bool(result.get("holds_batter", false))
	impact_color = Content.OUTCOME_COLORS[outcome]
	impact_strength = 1.0
	last_contact_outcome = outcome
	var any_contact := false
	for ball_outcome_value in outcomes:
		var ball_outcome := int(ball_outcome_value)
		if ball_outcome < Content.HIT_OUTCOME_COUNT or ball_outcome == Content.FOUL_INDEX:
			any_contact = true
			break
	bat_swing_animation = 1.0 if any_contact else 0.22
	result_sequence += 1
	var ends_batter := false
	if batter_phase == "active" and not batter_end_pending:
		var outcome_counts: Array = result.get("outcome_counts", [])
		var strike_events := 0
		var foul_events := 0
		var ball_events := 0
		if outcome_counts.size() == Content.OUTCOME_NAMES.size():
			foul_events = int(outcome_counts[Content.FOUL_INDEX])
			strike_events = int(outcome_counts[Content.STRIKE_INDEX]) + foul_events
			ball_events = int(outcome_counts[Content.BALL_INDEX])
		else:
			for ball_outcome_value in outcomes:
				var ball_outcome := int(ball_outcome_value)
				if ball_outcome == Content.STRIKE_INDEX or ball_outcome == Content.FOUL_INDEX:
					strike_events += 1
				if ball_outcome == Content.FOUL_INDEX:
					foul_events += 1
				elif ball_outcome == Content.BALL_INDEX:
					ball_events += 1
		if result.has("strike_count"):
			visual_strike_count = int(result.get("strike_count", visual_strike_count))
		else:
			visual_strike_count = mini(
				visual_strike_count + foul_events,
				maxi(get_strike_limit() - 1, 0)
			)
			visual_strike_count += strike_events - foul_events
		if result.has("plate_ball_count"):
			visual_ball_count = int(result.get("plate_ball_count", visual_ball_count))
		else:
			visual_ball_count += ball_events
		if strike_events > 0:
			removed_strike_icon = maxi(get_strike_limit() - visual_strike_count, 0)
			strike_icon_flash = 1.0
		if bool(result.get("strikeout", false)):
			visual_strike_count = get_strike_limit()
			ends_batter = true
		elif bool(result.get("walk", false)):
			visual_ball_count = get_ball_limit()
			ends_batter = true
		elif any_unsaved_hit and not holds_batter:
			ends_batter = true
		if ends_batter:
			batter_end_pending = true
			batter_lifecycle_total_override = float(result.get("batter_downtime", -1.0))
			batter_end_delay = BATTER_CONTACT_HOLD * _get_lifecycle_time_scale(outcome)
			batter_exit_outcome = outcome
	var call_lines: Array = result.get("call_lines", [])
	if call_lines.is_empty():
		var fallback_text := str(Content.OUTCOME_NAMES[outcome])
		if bool(result.get("strikeout", false)):
			fallback_text = "STRIKEOUT"
		elif bool(result.get("walk", false)):
			fallback_text = "WALK"
		call_lines = [{"outcome": outcome, "text": fallback_text}]
	var result_text := str(result.get("call_text", "")).strip_edges()
	if result_text.is_empty():
		var result_parts: Array[String] = []
		for line_value in call_lines:
			result_parts.append(str((line_value as Dictionary).get("text", "")))
		result_text = " • ".join(result_parts)
	result_popups.clear()
	var popup_font_size := 20 if call_lines.size() <= 2 else maxi(13, 19 - call_lines.size())
	var popup_spacing := float(popup_font_size + 4)
	for line_index in call_lines.size():
		var line: Dictionary = call_lines[line_index]
		var line_outcome := clampi(
			int(line.get("outcome", outcome)),
			0,
			Content.OUTCOME_NAMES.size() - 1
		)
		result_popups.append({
			"outcome": line_outcome,
			"text": str(line.get("text", Content.OUTCOME_NAMES[line_outcome])),
			"age": 0.0,
			"duration": 1.35 + minf(float(call_lines.size() - 1) * 0.08, 0.45),
			"vertical_offset": -float(line_index) * popup_spacing,
			"font_size": popup_font_size,
		})
	var story_taunt := str(result.get("story_taunt", "")).strip_edges()
	if not story_taunt.is_empty():
		result_popups.append({
			"outcome": outcome,
			"text": story_taunt,
			"age": 0.0,
			"duration": 1.65,
			"vertical_offset": -float(call_lines.size()) * popup_spacing - 5.0,
			"font_size": 15,
			"color": Color("f6e56f"),
		})
	batter_call_displayed.emit(result_text, Content.OUTCOME_COLORS[outcome])
	var return_count := mini(ball_count, return_ball_capacity)
	for render_index in return_count:
		var source_index := mini(
			int(floor(float(render_index) * float(outcomes.size()) / float(return_count))),
			outcomes.size() - 1
		)
		var return_outcome := clampi(
			int(outcomes[source_index]),
			0,
			Content.OUTCOME_NAMES.size() - 1
		)
		var return_saved := (
			source_index < saved_flags.size()
			and bool(saved_flags[source_index])
			and return_outcome < Content.HIT_OUTCOME_COUNT
			and return_outcome != Content.GRAND_SLAM_INDEX
		)
		_create_return_ball(
			return_outcome,
			salvo,
			return_saved,
			render_index,
			return_count
		)

func show_loot_popup(heading: String, detail: String, color: Color) -> void:
	loot_popups.clear()
	loot_popups.append({
		"heading": heading,
		"detail": detail,
		"color": color,
		"age": 0.0,
		"duration": LOOT_POPUP_DURATION,
	})
	queue_redraw()

func get_loot_popup_anchor() -> Vector2:
	return _get_batter_position()

func _reset_batter_for_opponent(opponent_index: int, preserve_released_ball := false) -> void:
	configured_opponent_index = opponent_index
	batter_generation = int(snapshot.get("batter_generation", 0))
	current_batter_name = str(snapshot.get(
		"batter_name",
		Content.batter_display_name(opponent_index, batter_generation)
	))
	visual_strike_count = 0
	visual_ball_count = 0
	strike_icon_flash = 0.0
	removed_strike_icon = -1
	batter_phase = "active"
	batter_phase_age = 0.0
	batter_phase_duration = 0.0
	batter_end_pending = false
	batter_end_delay = 0.0
	batter_exit_outcome = Content.STRIKE_INDEX
	batter_lifecycle_total_override = -1.0
	batter_terminal_in_flight = false
	if not preserve_released_ball:
		active_visual_volleys.clear()
		volley_in_flight = false
		volley_flight_duration = 0.0
		volley_plate_position = Vector2.ZERO

func _update_batter_lifecycle(delta: float) -> void:
	var remaining := maxf(delta, 0.0)
	if batter_end_pending:
		var pending_step := minf(remaining, batter_end_delay)
		batter_end_delay -= pending_step
		remaining -= pending_step
		if batter_end_delay <= 0.000001:
			batter_end_pending = false
			batter_phase = "leaving"
			batter_phase_age = 0.0
			batter_phase_duration = _get_batter_exit_duration(batter_exit_outcome)
		else:
			return
	while remaining > 0.000001 and batter_phase != "active":
		var phase_left := maxf(batter_phase_duration - batter_phase_age, 0.0)
		if remaining < phase_left:
			batter_phase_age += remaining
			return
		remaining -= phase_left
		if batter_phase == "leaving":
			batter_generation += 1
			visual_strike_count = 0
			visual_ball_count = 0
			strike_icon_flash = 0.0
			removed_strike_icon = -1
			current_batter_name = Content.batter_display_name(
				configured_opponent_index,
				batter_generation
			)
			batter_phase = "waiting"
			batter_phase_age = 0.0
			batter_phase_duration = _get_batter_replacement_delay(batter_exit_outcome)
		elif batter_phase == "waiting":
			batter_phase = "entering"
			batter_phase_age = 0.0
			batter_phase_duration = BATTER_ENTRY_DURATION * _get_lifecycle_time_scale(batter_exit_outcome)
		elif batter_phase == "entering":
			batter_phase = "active"
			batter_phase_age = 0.0
			batter_phase_duration = 0.0
			batter_lifecycle_total_override = -1.0
			batter_terminal_in_flight = false

func _get_batter_exit_duration(outcome: int) -> float:
	return (
		float(BATTER_EXIT_DURATIONS[clampi(outcome, 0, BATTER_EXIT_DURATIONS.size() - 1)])
		* _get_lifecycle_time_scale(outcome)
	)

func _get_batter_replacement_delay(outcome: int) -> float:
	return (
		float(BATTER_REPLACEMENT_DELAYS[clampi(outcome, 0, BATTER_REPLACEMENT_DELAYS.size() - 1)])
		* _get_lifecycle_time_scale(outcome)
	)

func _get_lifecycle_time_scale(outcome: int) -> float:
	var bounded := clampi(outcome, 0, BATTER_LIFECYCLE_TOTALS.size() - 1)
	var downtimes: Array = snapshot.get("batter_downtimes", BATTER_LIFECYCLE_TOTALS)
	var actual := (
		batter_lifecycle_total_override
		if batter_lifecycle_total_override >= 0.0
		else (
			float(downtimes[bounded])
			if bounded < downtimes.size()
			else float(BATTER_LIFECYCLE_TOTALS[bounded])
		)
	)
	return maxf(actual / maxf(float(BATTER_LIFECYCLE_TOTALS[bounded]), 0.001), 0.001)

func get_strike_limit() -> int:
	return maxi(int(snapshot.get("strike_limit", 3)), 3)

func get_remaining_strike_icons() -> int:
	return maxi(get_strike_limit() - visual_strike_count, 0)

func get_ball_limit() -> int:
	return maxi(int(snapshot.get("ball_limit", 4)), 1)

func get_remaining_ball_icons() -> int:
	return maxi(get_ball_limit() - visual_ball_count, 0)

func get_current_batter_name() -> String:
	if current_batter_name.is_empty():
		return Content.batter_display_name(maxi(configured_opponent_index, 0), batter_generation)
	if batter_phase == "waiting":
		return "ON DECK: %s" % current_batter_name
	return current_batter_name

func get_batter_status_text() -> String:
	if batter_end_pending:
		return "%s — CONTACT" % Content.OUTCOME_NAMES[batter_exit_outcome]
	match batter_phase:
		"leaving":
			return "%s — CLEARING THE PLATE" % (
				"STRIKEOUT" if batter_exit_outcome == Content.STRIKE_INDEX else Content.OUTCOME_NAMES[batter_exit_outcome]
			)
		"waiting":
			return "NEXT BATTER IN %.1fs" % maxf(batter_phase_duration - batter_phase_age, 0.0)
		"entering":
			return "STEPPING IN"
		_:
			return "%d / %d STRIKES  •  %d / %d BALLS" % [
				visual_strike_count,
				get_strike_limit(),
				visual_ball_count,
				get_ball_limit(),
			]

func _get_batter_transition_visual() -> Dictionary:
	var visual := {
		"visible": batter_phase != "waiting",
		"offset": Vector2.ZERO,
		"rotation": 0.0,
		"scale": 1.0,
	}
	if batter_phase == "leaving":
		var progress := clampf(batter_phase_age / maxf(batter_phase_duration, 0.001), 0.0, 1.0)
		match batter_exit_outcome:
			0:
				visual.offset = Vector2(72.0 * progress, -68.0 * sin(progress * PI * 0.72))
				visual.rotation = progress * TAU
				visual.scale = 1.0 + sin(progress * PI) * 0.18 - progress * 0.20
			1:
				visual.offset = Vector2(86.0 * progress, -48.0 * progress + sin(progress * PI * 3.0) * 7.0)
				visual.rotation = -0.18 * sin(progress * PI * 4.0)
			2:
				visual.offset = Vector2(66.0 * progress, -35.0 * progress)
				visual.rotation = 0.12 * sin(progress * PI * 3.0)
			3:
				visual.offset = Vector2(48.0 * progress, -42.0 * progress)
				visual.rotation = 0.08 * sin(progress * PI * 2.0)
			4:
				visual.offset = Vector2(34.0 * progress, -30.0 * progress)
				visual.rotation = -0.06 * sin(progress * PI * 2.0)
			Content.BALL_INDEX:
				# Walk: trot toward first base (screen-right/up) with mild indignity.
				visual.offset = Vector2(46.0 * progress, -34.0 * progress)
				visual.rotation = -0.08 * sin(progress * PI * 2.0)
			Content.STRIKE_INDEX:
				# Strikeout: a short, defeated peel toward the same exit side.
				visual.offset = Vector2(22.0 * progress, -48.0 * progress)
				visual.rotation = 0.42 * progress
				visual.scale = 1.0 - progress * 0.24
	elif batter_phase == "entering":
		var progress := clampf(batter_phase_age / maxf(batter_phase_duration, 0.001), 0.0, 1.0)
		visual.offset = Vector2(
			-72.0 * (1.0 - progress),
			48.0 * (1.0 - progress) + 7.0 * sin(progress * PI * 2.0)
		)
		visual.rotation = -0.14 * (1.0 - progress)
		visual.scale = 0.72 + progress * 0.28
	# The transition vectors above are authored in the desktop field basis. Rotate
	# them with the lane on portrait screens: desktop right becomes phone up and
	# desktop down becomes phone right. This keeps exits and entrances on their
	# baseball sides instead of mirroring them after the phone layout rotates.
	if portrait_layout:
		visual.offset = (
			_get_pitch_direction() * float(Vector2(visual.offset).x)
			+ _get_lateral_direction() * float(Vector2(visual.offset).y)
		)
	return visual

func _create_return_ball(
	outcome: int,
	salvo: float,
	saved := false,
	ball_index := 0,
	ball_count := 1
) -> void:
	var spread_position := (
		-0.5 + float(ball_index) / float(maxi(ball_count - 1, 1))
		if ball_count > 1
		else 0.0
	)
	var lane_spread := minf(float(ball_count - 1) * 1.2, _get_field_lateral_length() * 0.22)
	var start := _get_plate_position() + _get_lateral_direction() * spread_position * lane_spread
	var direction := -1.0 if (result_sequence + ball_index) % 2 == 0 else 1.0
	var finish := start
	var duration := 0.40
	var fade_start := 0.82
	var missed_strike := false
	var relay := false
	var relay_finish := Vector2.ZERO
	if saved:
		var mound := _get_mound_position(float(snapshot.distance_feet))
		var clone_count := clampi(int(snapshot.clones), 1, clone_visual_capacity)
		if clone_count > 1:
			var catcher_index := 1 + (result_sequence % (clone_count - 1))
			finish = mound + _get_clone_offset(catcher_index)
			relay_finish = mound
			relay = true
			duration = 0.48
		else:
			finish = mound + _orient_pitch_vector(Vector2(18.0, -24.0))
			duration = 0.72
	else:
		if portrait_layout:
			var lane_x := size.x * 0.50
			match outcome:
				0:
					finish = Vector2(lane_x + direction * size.x * (0.18 + salvo * 0.34), size.y + 180.0)
					duration = 1.65
				1:
					finish = Vector2(lane_x + direction * size.x * (0.10 + salvo * 0.30), size.y + 90.0)
					duration = 1.35
				2:
					finish = Vector2(lane_x + direction * size.x * (0.08 + salvo * 0.25), size.y - 12.0)
					duration = 1.12
				3:
					finish = Vector2(lane_x + direction * size.x * (0.06 + salvo * 0.20), size.y * 0.83)
					duration = 0.90
				4:
					finish = Vector2(lane_x + direction * size.x * (0.04 + salvo * 0.12), size.y * 0.65)
					duration = 0.66
				Content.FOUL_INDEX:
					finish = Vector2(-30.0 if direction < 0.0 else size.x + 30.0, size.y * 0.44)
					duration = 0.74
				Content.BALL_INDEX, Content.STRIKE_INDEX:
					missed_strike = true
					finish = Vector2(lane_x, -28.0)
		else:
			var lane_y := size.y * 0.56
			match outcome:
				0:
					finish = Vector2(-180.0, lane_y + direction * size.y * (0.18 + salvo * 0.34))
					duration = 1.65
				1:
					finish = Vector2(-90.0, lane_y + direction * size.y * (0.10 + salvo * 0.30))
					duration = 1.35
				2:
					finish = Vector2(12.0, lane_y + direction * size.y * (0.08 + salvo * 0.25))
					duration = 1.12
				3:
					finish = Vector2(size.x * 0.17, lane_y + direction * size.y * (0.06 + salvo * 0.20))
					duration = 0.90
				4:
					finish = Vector2(size.x * 0.48, lane_y + direction * size.y * (0.04 + salvo * 0.12))
					duration = 0.66
				Content.FOUL_INDEX:
					finish = Vector2(size.x * 0.56, -30.0 if direction < 0.0 else size.y + 30.0)
					duration = 0.74
				Content.BALL_INDEX, Content.STRIKE_INDEX:
					missed_strike = true
					finish = Vector2(size.x + 28.0, lane_y)
		if missed_strike:
			# A missed pitch continues through the plate at its unchanged approach
			# speed, regardless of which way the field is presented.
			var mound := _get_mound_position(float(snapshot.distance_feet))
			var incoming_distance := maxf(start.distance_to(mound), 1.0)
			var continuation_distance := maxf(start.distance_to(finish), 1.0)
			duration = maxf(last_pitch_visual_travel_time * continuation_distance / incoming_distance, 0.03)
			fade_start = 0.06
	var midpoint := start.lerp(finish, 0.5)
	var flight := finish - start
	var normal := Vector2(-flight.y, flight.x).normalized()
	var bend := 0.0 if missed_strike else _get_field_lateral_length() * 0.34 * salvo
	var control := midpoint + normal * bend * direction
	return_balls.append({
		"outcome": outcome,
		"start": start,
		"control": control,
		"finish": finish,
		"age": 0.0,
		"duration": duration,
		"saved": saved,
		"relay": relay,
		"relay_finish": relay_finish,
		"relayed": false,
		"missed_strike": missed_strike,
		"fade_start": fade_start,
	})
	if return_balls.size() > return_ball_capacity:
		return_balls.pop_front()

func get_visual_weight() -> float:
	return visual_weight

func get_rendered_pitch_count() -> int:
	return active_pitch_slots.size()

func get_visual_capacity() -> int:
	return visual_ball_capacity

func get_visual_profile_name() -> String:
	return "BROWSER" if browser_visual_profile else "DESKTOP"

func is_rendering_one_to_one() -> bool:
	return visual_weight < 1.01

func get_launch_snapshot(slot: int) -> Dictionary:
	if slot < 0 or slot >= slot_launch_data.size():
		return {}
	return slot_launch_data[slot].duplicate(true)

func _get_plate_position() -> Vector2:
	if volley_in_flight and volley_plate_position != Vector2.ZERO:
		return volley_plate_position
	return _get_plate_position_unlocked()

func _get_plate_position_unlocked() -> Vector2:
	var distance_progress := _get_lane_distance_progress()
	if portrait_layout:
		var close_plate_y := size.y * 0.43
		var far_plate_y := maxf(size.y * 0.23, 112.0)
		return Vector2(size.x * 0.50, lerpf(close_plate_y, far_plate_y, distance_progress))
	var plate_x := lerpf(size.x * 0.58, size.x - 210.0, distance_progress)
	return Vector2(plate_x, size.y * 0.56)

func _get_mound_position(distance_feet: float) -> Vector2:
	var plate := _get_plate_position()
	var minimum_separation := 132.0
	var normalized := _get_lane_distance_progress(distance_feet)
	if portrait_layout:
		var maximum_separation := maxf(size.y - plate.y - 76.0, minimum_separation)
		var separation := lerpf(minimum_separation, maximum_separation, normalized)
		return plate + Vector2(0.0, separation)
	var maximum_separation := maxf(plate.x - 76.0, minimum_separation)
	var separation := lerpf(minimum_separation, maximum_separation, normalized)
	return plate - Vector2(separation, 0.0)

func _get_distance_progress(distance_feet: float = -1.0) -> float:
	if distance_feet < 0.0:
		distance_feet = float(snapshot.distance_feet)
	var max_distance := float(Content.DISTANCE_TIERS.back().feet)
	var distance_decades := maxf(log(maxf(distance_feet / 3.0, 1.0)) / log(10.0), 0.0)
	var maximum_decades := log(max_distance / 3.0) / log(10.0)
	var compressed := log(1.0 + distance_decades * 2.8) / log(1.0 + maximum_decades * 2.8)
	return clampf(compressed, 0.0, 1.0)

func _get_human_perspective_progress(distance_feet: float = -1.0) -> float:
	if distance_feet < 0.0:
		distance_feet = float(snapshot.distance_feet)
	return clampf(
		log(maxf(distance_feet / 3.0, 1.0)) / log(60.5 / 3.0),
		0.0,
		1.0
	)

func _get_posthuman_perspective_progress(distance_feet: float = -1.0) -> float:
	if distance_feet < 0.0:
		distance_feet = float(snapshot.distance_feet)
	if distance_feet <= 60.5:
		return 0.0
	var maximum := float(Content.DISTANCE_TIERS.back().feet)
	return clampf(
		log(distance_feet / 60.5) / log(maximum / 60.5),
		0.0,
		1.0
	)

func _get_lane_distance_progress(distance_feet: float = -1.0) -> float:
	if distance_feet < 0.0:
		distance_feet = float(snapshot.distance_feet)
	if distance_feet <= 60.5:
		return _get_human_perspective_progress(distance_feet) * 0.62
	return 0.62 + _get_posthuman_perspective_progress(distance_feet) * 0.38

func _get_camera_scale() -> float:
	var distance := float(snapshot.distance_feet)
	if distance <= 60.5:
		return lerpf(3.10, 0.92, pow(_get_human_perspective_progress(distance), 0.76))
	return lerpf(0.92, 0.48, pow(_get_posthuman_perspective_progress(distance), 0.62))

func _get_character_camera_scale() -> float:
	# Human perspective gets its own real-distance curve. Normalizing 12 feet
	# against a galaxy had made everyone almost as large as at the three-foot gag.
	var distance := float(snapshot.distance_feet)
	if distance <= 60.5:
		return lerpf(1.82, 0.82, pow(_get_human_perspective_progress(distance), 0.82))
	return lerpf(0.82, 0.46, pow(_get_posthuman_perspective_progress(distance), 0.66))

func _get_ball_visual_scale() -> float:
	return clampf(_get_camera_scale() * 0.75, 1.0, 2.80)

func _get_pitcher_visual_scale() -> float:
	# Pitcher and batter share the same intrinsic-size × perspective model. The
	# fresh 1.08 pitcher is about 50% larger than a 0.72 toddler, then strength
	# smoothly approaches twice that original intrinsic size.
	return (
		_get_character_camera_scale()
		* BASE_PITCHER_INTRINSIC_SIZE
		* clampf(float(snapshot.get("pitcher_size_multiplier", 1.0)), 1.0, 2.0)
	)

func _get_pitcher_arm_scale() -> float:
	# Compatibility/readability helper used by focused tests. The actual throw is
	# a single compact rectangle whose geometry is defined above.
	return _get_pitcher_visual_scale()

func _get_batter_position() -> Vector2:
	return _get_plate_position() + _get_pitch_direction() * 52.0

func get_pitcher_position() -> Vector2:
	return _get_mound_position(float(snapshot.distance_feet))

func get_batter_position() -> Vector2:
	return _get_batter_position()

func _draw() -> void:
	var stage := _get_environment_stage()
	_draw_environment(stage)
	var height := size.y
	var mound := _get_mound_position(float(snapshot.distance_feet))
	var plate := _get_plate_position()
	var line_color := Color(0.45, 0.68, 0.59, 0.34) if stage == 0 else Color(0.38, 0.52, 0.70, 0.30)
	var wedge_color := Color(0.08, 0.20, 0.15, 0.34) if stage == 0 else Color(0.08, 0.10, 0.18, 0.32)
	var fair_wedge := (
		PackedVector2Array([plate, Vector2(18.0, height - 20.0), Vector2(size.x - 18.0, height - 20.0)])
		if portrait_layout
		else PackedVector2Array([plate, Vector2(20.0, 18.0), Vector2(20.0, height - 18.0)])
	)
	draw_colored_polygon(fair_wedge, wedge_color)
	draw_line(plate, fair_wedge[1], line_color, 1.5)
	draw_line(plate, fair_wedge[2], line_color, 1.5)
	for ring_index in 4:
		var ring_radius := 85.0 + float(ring_index) * 95.0
		var start_angle := PI * 0.16 if portrait_layout else PI * 0.66
		var end_angle := PI * 0.84 if portrait_layout else PI * 1.34
		draw_arc(plate, ring_radius, start_angle, end_angle, 48, Color(line_color, 0.25), 1.0)
	draw_dashed_line(mound, plate, Color(line_color, 0.65), 1.0, 8.0)
	_draw_distance_marker(mound, plate)
	_draw_pitcher(mound)
	_draw_pitch_call(mound)
	_draw_pitch_cooldown_meter(mound)
	_draw_home_plate(plate)
	_draw_lifecycle_batter()
	_draw_batter_arrival_timer()
	_draw_return_balls()
	if impact_strength > 0.0:
		var radius := 12.0 + (1.0 - impact_strength) * 60.0
		draw_arc(plate, radius, 0.0, TAU, 48, Color(impact_color, impact_strength * 0.75), 3.0)
	_draw_result_popups()
	_draw_loot_popups()
	_draw_tap_meter_and_clickers()
	_draw_field_tap_effects()

func _draw_tap_meter_and_clickers() -> void:
	var tap_laps := maxf(float(snapshot.get("tap_laps", 0.0)), 0.0)
	var tap_signal := clampf(float(snapshot.get("tap_signal", 0.0)), 0.0, 1.0)
	var clickers := maxi(int(snapshot.get("automatic_clickers", 0)), 0)
	if tap_laps <= 0.001 and clickers <= 0:
		return
	var center := Vector2(28.0, size.y - 31.0)
	var completed := int(floor(tap_laps))
	var fraction := fmod(tap_laps, 1.0)
	var color_mix := 1.0 - exp(-float(completed) / 3.0)
	var meter_color := PITCHER_COLOR.lerp(Color("78ff84"), color_mix)
	draw_circle(center, 16.0, Color("07101b"))
	draw_arc(center, 16.0, 0.0, TAU, 36, Color("36506a"), 2.0)
	if completed > 0:
		draw_arc(center, 13.0, -PI * 0.5, TAU - PI * 0.5, 36, Color(meter_color, 0.45 + tap_signal * 0.45), 4.0)
	if completed == 0 or fraction > 0.0001:
		var visible_fraction := clampf(tap_laps if completed == 0 else fraction, 0.0, 1.0)
		draw_arc(
			center,
			13.0,
			-PI * 0.5,
			-PI * 0.5 + TAU * visible_fraction,
			36,
			meter_color,
			4.0
		)
	if completed > 0:
		draw_string(
			ThemeDB.fallback_font,
			center + Vector2(-10.0, 4.0),
			"×%d" % (completed + 1),
			HORIZONTAL_ALIGNMENT_CENTER,
			20.0,
			9,
			Color(meter_color, 0.90)
		)
	if clickers <= 0:
		return
	var label_position := Vector2(50.0, size.y - 43.0)
	draw_string(
		ThemeDB.fallback_font,
		label_position,
		"AUTO-TAPPER",
		HORIZONTAL_ALIGNMENT_LEFT,
		110.0,
		9,
		Color(0.62, 0.74, 0.86, 0.70)
	)
	var shown := mini(clickers, 16)
	var rate_each := maxf(float(snapshot.get("automatic_rate_each", 0.0)), 0.0)
	var pulse_phase := fmod(total_time * rate_each, 1.0) if rate_each > 0.0 else 1.0
	var pulse := exp(-pulse_phase * 8.0) if rate_each > 0.0 else 0.0
	for index in shown:
		var column := index % 8
		var row := index / 8
		var dot := Vector2(55.0 + column * 11.0, size.y - 25.0 + row * 10.0)
		draw_circle(dot, 2.3 + pulse * 1.8, Color(PITCHER_COLOR, 0.42 + pulse * 0.50))
	if clickers > shown:
		draw_string(
			ThemeDB.fallback_font,
			Vector2(146.0, size.y - 20.0),
			"+%d" % (clickers - shown),
			HORIZONTAL_ALIGNMENT_LEFT,
			34.0,
			9,
			Color(PITCHER_COLOR, 0.75)
		)

func _draw_field_tap_effects() -> void:
	for effect in field_tap_effects:
		var duration := maxf(float(effect.duration), 0.001)
		var progress := clampf(float(effect.age) / duration, 0.0, 1.0)
		var fade := 1.0 - progress
		var center := Vector2(effect.position)
		var applied := bool(effect.applied)
		var color := Color(PITCHER_COLOR, fade * (0.58 if applied else 0.24))
		var radius := lerpf(6.0, 25.0, progress)
		draw_arc(center, radius, 0.0, TAU, 28, color, lerpf(2.5, 1.0, progress))
		draw_circle(center, lerpf(3.0, 1.0, progress), Color(color, fade * 0.72))
		var label := str(effect.label)
		if not label.is_empty():
			draw_string(
				ThemeDB.fallback_font,
				center + Vector2(-28.0, -12.0 - progress * 12.0),
				label,
				HORIZONTAL_ALIGNMENT_CENTER,
				56.0,
				11,
				Color(0.58, 0.91, 1.0, fade * 0.82)
			)

func _draw_lifecycle_batter() -> void:
	var visual := _get_batter_transition_visual()
	if not bool(visual.visible):
		return
	draw_set_transform(
		_get_batter_position() + Vector2(visual.offset),
		float(visual.rotation),
		Vector2.ONE * float(visual.scale)
	)
	_draw_batter(Vector2.ZERO)
	_draw_strike_icons(Vector2.ZERO)
	_draw_ball_icons(Vector2.ZERO)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func get_batter_arrival_progress() -> float:
	if batter_phase == "waiting":
		return clampf(batter_phase_age / maxf(batter_phase_duration, 0.001), 0.0, 1.0)
	if batter_phase == "entering":
		return 1.0
	return 0.0

func _draw_batter_arrival_timer() -> void:
	if batter_phase != "waiting":
		return
	var center := _get_batter_position()
	var readable_scale := clampf(_get_camera_scale(), 0.78, 1.35)
	var radius := 18.0 * readable_scale
	var progress := get_batter_arrival_progress()
	draw_circle(center, radius, Color(0.02, 0.07, 0.10, 0.82))
	draw_arc(center, radius, 0.0, TAU, 40, Color(0.55, 0.72, 0.78, 0.22), 3.0)
	if progress > 0.0:
		var segment_count := maxi(int(ceil(36.0 * progress)), 1)
		var wedge := PackedVector2Array([center])
		for segment in segment_count + 1:
			var angle := -PI * 0.5 + TAU * progress * float(segment) / float(segment_count)
			wedge.append(center + Vector2(cos(angle), sin(angle)) * (radius - 3.0))
		draw_colored_polygon(wedge, Color(PITCHER_COLOR, 0.18))
		draw_arc(
			center,
			radius,
			-PI * 0.5,
			-PI * 0.5 + TAU * progress,
			maxi(segment_count, 2),
			Color(PITCHER_COLOR, 0.92),
			3.0
		)
	draw_circle(center, 3.0 * readable_scale, Color(PITCHER_COLOR, 0.82))
	var seconds_left := maxf(batter_phase_duration - batter_phase_age, 0.0)
	var label_position := center + Vector2(-34.0, radius + 16.0)
	draw_string(
		ThemeDB.fallback_font,
		label_position,
		"NEXT  %.1fs" % seconds_left,
		HORIZONTAL_ALIGNMENT_CENTER,
		68.0,
		11,
		Color(0.74, 0.90, 0.94, 0.78)
	)

func get_pitch_cooldown_progress() -> float:
	if not should_draw_pitch_cooldown_meter():
		return 0.0
	var sampled := clampf(float(snapshot.get("pitch_cycle_progress", 0.0)), 0.0, 1.0)
	var since_sample := maxf(total_time - pitch_cycle_sample_time, 0.0)
	return clampf(sampled + since_sample * _get_pitch_cycle_rate(), 0.0, 1.0)

func _get_pitch_cycle_rate() -> float:
	return maxf(float(snapshot.get("recovery_rate", 0.0)), 0.0)

func should_draw_pitch_cooldown_meter() -> bool:
	# An active batter always has one explicit phase indicator. During flight it
	# becomes a separate gold flight dial; the cyan cooldown does not begin filling
	# until impact. An empty plate uses the on-deck dial instead.
	return (
		_is_batter_visually_present()
		and _get_pitch_cycle_rate() > 0.0
	)

func _draw_pitch_cooldown_meter(origin: Vector2) -> void:
	if not should_draw_pitch_cooldown_meter():
		return
	var readable_scale := clampf(_get_camera_scale(), 0.78, 1.35)
	var body_radius := 10.0 * _get_pitcher_visual_scale()
	var radius := 9.0 * readable_scale
	var center := origin + Vector2(-body_radius - 18.0 * readable_scale, 0.0)
	var flight_phase := volley_in_flight
	var progress := (
		clampf(
			(total_time - volley_release_time) / maxf(volley_flight_duration, 0.001),
			0.0,
			1.0
		)
		if flight_phase
		else get_pitch_cooldown_progress()
	)
	var meter_color := FLIGHT_METER_COLOR if flight_phase else PITCHER_COLOR
	draw_circle(center, radius, Color(0.02, 0.07, 0.10, 0.82))
	draw_arc(center, radius, 0.0, TAU, 32, Color(0.55, 0.72, 0.78, 0.22), 2.5)
	if progress > 0.0:
		var segment_count := maxi(int(ceil(32.0 * progress)), 1)
		var wedge := PackedVector2Array([center])
		for segment in segment_count + 1:
			var angle := -PI * 0.5 + TAU * progress * float(segment) / float(segment_count)
			wedge.append(center + Vector2(cos(angle), sin(angle)) * (radius - 2.5))
		draw_colored_polygon(wedge, Color(meter_color, 0.24))
		draw_arc(
			center,
			radius,
			-PI * 0.5,
			-PI * 0.5 + TAU * progress,
			maxi(segment_count, 2),
			Color(meter_color, 0.95),
			2.5
		)
	draw_circle(center, 2.0 * readable_scale, Color(meter_color, 0.86))
	var seconds_left := (
		maxf(volley_flight_duration - (total_time - volley_release_time), 0.0)
		if flight_phase
		else maxf(1.0 - progress, 0.0) / maxf(_get_pitch_cycle_rate(), 0.000001)
	)
	draw_string(
		ThemeDB.fallback_font,
		center + Vector2(-30.0, radius + 13.0),
		"%s  %.1fs" % ["FLIGHT" if flight_phase else "PITCH", seconds_left],
		HORIZONTAL_ALIGNMENT_CENTER,
		60.0,
		9,
		Color(0.74, 0.90, 0.94, 0.72)
	)

func _draw_strike_icons(origin: Vector2) -> void:
	var strike_limit := get_strike_limit()
	var remaining := get_remaining_strike_icons()
	var display_slots := mini(strike_limit, 12)
	var display_remaining := remaining
	if strike_limit > display_slots:
		display_remaining = int(ceil(float(remaining) / float(strike_limit) * float(display_slots)))
	var readable_scale := clampf(_get_camera_scale(), 0.72, 1.25)
	var spacing := 10.0 * readable_scale
	var icon_radius := 3.2 * readable_scale
	var total_width := float(display_slots - 1) * spacing
	var intrinsic_scale := _get_batter_intrinsic_size() * _get_character_camera_scale()
	var visual_radius := 10.0 * intrinsic_scale
	if int(snapshot.opponent_index) == Content.FINAL_BOSS_INDEX:
		visual_radius = 29.0 * maxf(intrinsic_scale * 0.72, 1.0)
	elif int(snapshot.opponent_index) == Content.ELDRITCH_FINAL_INDEX:
		visual_radius = 34.0 * maxf(intrinsic_scale * 0.72, 1.0)
	var start := origin + Vector2(-total_width * 0.5, -visual_radius - 11.0 * readable_scale)
	for icon_index in display_slots:
		var center := start + Vector2(float(icon_index) * spacing, 0.0)
		if icon_index < display_remaining:
			var diamond := PackedVector2Array([
				center + Vector2(0.0, -icon_radius),
				center + Vector2(icon_radius, 0.0),
				center + Vector2(0.0, icon_radius),
				center + Vector2(-icon_radius, 0.0),
			])
			draw_colored_polygon(diamond, Color(0.39, 0.85, 1.0, 0.58))
			draw_polyline(PackedVector2Array([diamond[0], diamond[1], diamond[2], diamond[3], diamond[0]]), Color(0.78, 0.95, 1.0, 0.72), maxf(1.0, readable_scale * 0.9))
		else:
			draw_circle(center, 0.9 * readable_scale, Color(0.50, 0.70, 0.78, 0.18))
		var display_removed := removed_strike_icon
		if strike_limit > display_slots:
			display_removed = display_remaining
		if icon_index == display_removed and strike_icon_flash > 0.0:
			var flash_radius := icon_radius + (1.0 - strike_icon_flash) * 7.0 * readable_scale
			draw_arc(center, flash_radius, 0.0, TAU, 16, Color(0.39, 0.85, 1.0, strike_icon_flash * 0.42), maxf(1.0, readable_scale))
	if strike_limit > display_slots:
		var count_text := "%d / %d K" % [visual_strike_count, strike_limit]
		draw_string(ThemeDB.fallback_font, start + Vector2(0.0, -8.0 * readable_scale), count_text, HORIZONTAL_ALIGNMENT_CENTER, total_width + spacing, 10, Color(0.68, 0.88, 1.0, 0.76))

func _draw_ball_icons(origin: Vector2) -> void:
	var ball_limit := get_ball_limit()
	var display_slots := mini(ball_limit, 8)
	var display_count := visual_ball_count
	if ball_limit > display_slots:
		display_count = int(ceil(float(visual_ball_count) / float(ball_limit) * float(display_slots)))
	var readable_scale := clampf(_get_camera_scale(), 0.72, 1.25)
	var spacing := 9.0 * readable_scale
	var radius := 2.8 * readable_scale
	var total_width := float(display_slots - 1) * spacing
	var intrinsic_scale := _get_batter_intrinsic_size() * _get_character_camera_scale()
	var visual_radius := 10.0 * intrinsic_scale
	if int(snapshot.opponent_index) == Content.FINAL_BOSS_INDEX:
		visual_radius = 29.0 * maxf(intrinsic_scale * 0.72, 1.0)
	elif int(snapshot.opponent_index) == Content.ELDRITCH_FINAL_INDEX:
		visual_radius = 34.0 * maxf(intrinsic_scale * 0.72, 1.0)
	var start := origin + Vector2(-total_width * 0.5, visual_radius + 12.0 * readable_scale)
	for icon_index in display_slots:
		var center := start + Vector2(float(icon_index) * spacing, 0.0)
		draw_circle(center, radius, Color(0.02, 0.05, 0.08, 0.76))
		draw_arc(center, radius, 0.0, TAU, 14, Color(1.0, 0.81, 0.40, 0.50), maxf(1.0, readable_scale * 0.8))
		if icon_index < display_count:
			draw_circle(center, radius - 1.0 * readable_scale, Color(1.0, 0.81, 0.40, 0.72))
	if ball_limit > display_slots:
		draw_string(
			ThemeDB.fallback_font,
			start + Vector2(0.0, 12.0 * readable_scale),
			"%d / %d B" % [visual_ball_count, ball_limit],
			HORIZONTAL_ALIGNMENT_CENTER,
			total_width + spacing,
			10,
			Color(1.0, 0.84, 0.48, 0.76)
		)

func _draw_pitch_speed_readout() -> void:
	var speed_text := BaseballGameState.format_speed(maxf(last_pitch_speed_fps, 0.000001))
	var label := "PITCH SPEED  %s" % speed_text
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(Vector2(13.0, 12.0), Vector2(226.0, 30.0)), Color(0.02, 0.05, 0.08, 0.68), true)
	draw_string(
		font,
		Vector2(24.0, 34.0),
		label,
		HORIZONTAL_ALIGNMENT_LEFT,
		204.0,
		14,
		Color(0.78, 0.93, 1.0, 0.94)
	)

func _draw_pitch_call(mound: Vector2) -> void:
	if pitch_call_age >= 1.30:
		return
	var progress := clampf(pitch_call_age / 1.30, 0.0, 1.0)
	var fade := 1.0 - smoothstep(0.62, 1.0, progress)
	var baseline := mound + Vector2(-92.0, -34.0 - progress * 16.0)
	draw_string(
		ThemeDB.fallback_font,
		baseline + Vector2(2.0, 2.0),
		last_pitch_name,
		HORIZONTAL_ALIGNMENT_CENTER,
		184.0,
		15,
		Color(0.0, 0.0, 0.0, fade * 0.82)
	)
	draw_string(
		ThemeDB.fallback_font,
		baseline,
		last_pitch_name,
		HORIZONTAL_ALIGNMENT_CENTER,
		184.0,
		15,
		Color(PITCHER_COLOR, fade)
	)

func _get_environment_stage() -> int:
	var opponent_index := int(snapshot.opponent_index)
	var league_stage := 0
	if opponent_index >= Content.ELDRITCH_EXHIBITION_INDEX:
		league_stage = 3
	elif opponent_index >= Content.ALIEN_EXHIBITION_INDEX:
		league_stage = 1
	var distance_stage := 0
	var distance_index := clampi(
		int(snapshot.distance_index),
		0,
		Content.DISTANCE_TIERS.size() - 1
	)
	match str(Content.DISTANCE_TIERS[distance_index].get("environment", "grass")):
		"alien_grass", "mars":
			distance_stage = 1
		"moon", "space":
			distance_stage = 2
		"deep_space", "outer_dark":
			distance_stage = 3
	return maxi(league_stage, distance_stage)

func _draw_environment(stage: int) -> void:
	var colors := [Color("102a22"), Color("291a21"), Color("111a35"), Color("03060d")]
	draw_rect(Rect2(Vector2.ZERO, size), colors[stage], true)
	if stage == 1:
		draw_circle(Vector2(size.x * 0.18, size.y * 0.22), size.y * 0.34, Color(0.42, 0.16, 0.12, 0.12))
		draw_arc(Vector2(size.x * 0.18, size.y * 0.22), size.y * 0.34, 0.0, TAU, 72, Color(0.86, 0.39, 0.24, 0.16), 2.0)
	elif stage == 2:
		draw_circle(Vector2(size.x * 0.30, size.y * 1.12), size.y * 0.76, Color(0.12, 0.30, 0.55, 0.22))
		draw_arc(Vector2(size.x * 0.30, size.y * 1.12), size.y * 0.76, PI, TAU, 80, Color(0.38, 0.68, 1.0, 0.25), 3.0)
	if stage >= 2:
		var density := 12 + maxi(int(snapshot.opponent_index) - 34, 0) * 13 + maxi(int(snapshot.distance_index) - 9, 0) * 14
		if stage == 3:
			density += 34
		_ensure_star_cache(mini(density, star_density_capacity))
		# Hundreds of individual circles made the cosmic field CPU-bound on older
		# Macs. Two batched line lists keep the same increasing star density and a
		# subtle two-phase twinkle at a tiny fraction of the draw-call cost.
		var dim_twinkle := 0.48 + sin(stream_time * 0.45) * 0.10
		var bright_twinkle := 0.68 + sin(stream_time * 0.45 + 1.8) * 0.14
		if not cached_star_lines.is_empty():
			draw_multiline(cached_star_lines, Color(0.72, 0.84, 1.0, dim_twinkle), 1.2)
		if not cached_bright_star_lines.is_empty():
			draw_multiline(cached_bright_star_lines, Color(0.84, 0.91, 1.0, bright_twinkle), 1.5)
	if stage == 3 and int(snapshot.distance_index) >= 13:
		var galaxy_center := Vector2(size.x * 0.31, size.y * 0.25)
		for ring in 6:
			var radius := 24.0 + float(ring) * 18.0
			draw_arc(galaxy_center, radius, -0.35 + ring * 0.16, PI + ring * 0.22, 42, Color(0.62, 0.38, 1.0, 0.10), 3.0)
	if stage == 3 and int(snapshot.distance_index) >= 14:
		var cosmic_center := Vector2(size.x * 0.55, size.y * 0.48)
		for ring in 7:
			draw_arc(cosmic_center, 70.0 + ring * 34.0, 0.0, TAU, 96, Color(0.36, 0.66, 1.0, 0.035), 2.0)

func _ensure_star_cache(density: int) -> void:
	if density == cached_star_density and size.is_equal_approx(cached_star_size):
		return
	cached_star_density = density
	cached_star_size = size
	cached_star_lines.clear()
	cached_bright_star_lines.clear()
	for star_index in density:
		var star_x := fmod(float(star_index * 97 + 31), maxf(size.x - 20.0, 1.0)) + 10.0
		var star_y := fmod(float(star_index * 53 + 17), maxf(size.y - 20.0, 1.0)) + 10.0
		var center := Vector2(star_x, star_y)
		var radius := 0.7 + float(star_index % 4) * 0.35
		cached_star_lines.append(center - Vector2(radius, 0.0))
		cached_star_lines.append(center + Vector2(radius, 0.0))
		if star_index % 4 == 0:
			cached_bright_star_lines.append(center - Vector2(0.0, radius))
			cached_bright_star_lines.append(center + Vector2(0.0, radius))

func _draw_distance_marker(mound: Vector2, plate: Vector2) -> void:
	var font := ThemeDB.fallback_font
	var text := str(snapshot.distance_label).to_upper()
	var midpoint := mound.lerp(plate, 0.5) + Vector2(-110.0, -14.0)
	draw_string(font, midpoint, text, HORIZONTAL_ALIGNMENT_CENTER, 220.0, 13, Color(0.66, 0.82, 0.82, 0.72))

func _draw_return_balls() -> void:
	var projectile_scale := _get_ball_visual_scale()
	if return_balls.size() > DETAILED_RETURN_BALL_LIMIT:
		_draw_batched_return_balls(projectile_scale)
		return
	for ball in return_balls:
		var duration := maxf(float(ball.duration), 0.001)
		var progress := clampf(float(ball.age) / duration, 0.0, 1.0)
		var previous_progress := maxf(progress - 0.075, 0.0)
		var position := _quadratic_bezier(ball.start, ball.control, ball.finish, progress)
		var previous_position := _quadratic_bezier(ball.start, ball.control, ball.finish, previous_progress)
		var outcome := int(ball.outcome)
		var color: Color = Color(ball.get("color", Content.OUTCOME_COLORS[outcome]))
		var fade := 1.0 - smoothstep(float(ball.get("fade_start", 0.82)), 1.0, progress)
		draw_line(previous_position, position, Color(color, fade * 0.70), (4.0 if outcome < 2 else 2.5) * projectile_scale)
		draw_circle(position, (5.0 if outcome == 0 else 3.8) * projectile_scale, Color(color, fade))
		if bool(ball.get("saved", false)):
			draw_arc(position, 7.0 * projectile_scale, 0.0, TAU, 14, Color(0.39, 0.85, 1.0, fade * 0.72), 1.5 * projectile_scale)
		if outcome == 0:
			draw_arc(position, 9.0 * projectile_scale, 0.0, TAU, 14, Color(color, fade * 0.42), 2.0 * projectile_scale)

func _draw_batched_return_balls(projectile_scale: float) -> void:
	var trails: Array[PackedVector2Array] = []
	var heads: Array[PackedVector2Array] = []
	for _outcome in Content.OUTCOME_NAMES.size():
		trails.append(PackedVector2Array())
		heads.append(PackedVector2Array())
	for ball in return_balls:
		var duration := maxf(float(ball.duration), 0.001)
		var progress := clampf(float(ball.age) / duration, 0.0, 1.0)
		var previous_progress := maxf(progress - 0.075, 0.0)
		var position := _quadratic_bezier(ball.start, ball.control, ball.finish, progress)
		var previous_position := _quadratic_bezier(ball.start, ball.control, ball.finish, previous_progress)
		var outcome := clampi(int(ball.outcome), 0, Content.OUTCOME_NAMES.size() - 1)
		trails[outcome].append(previous_position)
		trails[outcome].append(position)
		var head_half := Vector2(0.9 * projectile_scale, 0.0)
		heads[outcome].append(position - head_half)
		heads[outcome].append(position + head_half)
	for outcome in Content.OUTCOME_NAMES.size():
		if trails[outcome].is_empty():
			continue
		var color: Color = Content.OUTCOME_COLORS[outcome]
		draw_multiline(trails[outcome], Color(color, 0.58), 2.4 * projectile_scale)
		draw_multiline(heads[outcome], Color(color, 0.88), 4.2 * projectile_scale)

func _draw_result_popups() -> void:
	var font := ThemeDB.fallback_font
	for popup in result_popups:
		var progress := clampf(float(popup.age) / maxf(float(popup.duration), 0.001), 0.0, 1.0)
		var fade := 1.0 - smoothstep(0.64, 1.0, progress)
		var rise := progress * 34.0
		var outcome := int(popup.outcome)
		var color: Color = Color(popup.get("color", Content.OUTCOME_COLORS[outcome]))
		var font_size := int(popup.get("font_size", 20))
		var baseline := _get_batter_position() + Vector2(
			-117.0,
			-58.0 - rise + float(popup.get("vertical_offset", 0.0))
		)
		draw_string(font, baseline + Vector2(2.0, 2.0), str(popup.text), HORIZONTAL_ALIGNMENT_CENTER, 235.0, font_size, Color(0.0, 0.0, 0.0, fade * 0.85))
		draw_string(font, baseline, str(popup.text), HORIZONTAL_ALIGNMENT_CENTER, 235.0, font_size, Color(color, fade))

func _draw_loot_popups() -> void:
	var font := ThemeDB.fallback_font
	var width := minf(300.0, maxf(size.x - 20.0, 120.0))
	for popup in loot_popups:
		var progress := clampf(float(popup.age) / maxf(float(popup.duration), 0.001), 0.0, 1.0)
		var fade := 1.0 - smoothstep(0.70, 1.0, progress)
		var rise := progress * 28.0
		var color: Color = popup.color
		# Loot came from the batter's visible wardrobe, so its cue belongs to the
		# batter. Following the batter during the exit also makes the source legible.
		var baseline := get_loot_popup_anchor() + Vector2(-width * 0.5, -74.0 - rise)
		draw_string(
			font,
			baseline + Vector2(2.0, 2.0),
			str(popup.heading),
			HORIZONTAL_ALIGNMENT_CENTER,
			width,
			16,
			Color(0.0, 0.0, 0.0, fade * 0.90)
		)
		draw_string(
			font,
			baseline,
			str(popup.heading),
			HORIZONTAL_ALIGNMENT_CENTER,
			width,
			16,
			Color(color, fade)
		)
		draw_string(
			font,
			baseline + Vector2(1.0, 19.0),
			str(popup.detail),
			HORIZONTAL_ALIGNMENT_CENTER,
			width,
			12,
			Color(0.88, 0.93, 1.0, fade)
		)

func _quadratic_bezier(start: Vector2, control: Vector2, finish: Vector2, progress: float) -> Vector2:
	var inverse := 1.0 - progress
	return inverse * inverse * start + 2.0 * inverse * progress * control + progress * progress * finish

func _get_bat_shaft_angle(bat_index: int, bat_count: int, swing_phase: float) -> float:
	var spread_position := (
		-0.5 + float(bat_index) / float(maxi(bat_count - 1, 1))
		if bat_count > 1
		else 0.0
	)
	var resting_angle := -0.70 + spread_position * 0.70
	var contact_angle := PI + spread_position * 0.34
	return lerp_angle(resting_angle, contact_angle, clampf(swing_phase, 0.0, 1.0))

func _draw_pitcher(origin: Vector2) -> void:
	var camera_scale := _get_camera_scale()
	var pitcher_scale := _get_pitcher_visual_scale()
	var readable_scale := clampf(camera_scale, 0.72, 1.65)
	var gear_colors: Dictionary = snapshot.get("gear_colors", {})
	var jersey_color: Color = gear_colors.get("jersey", PITCHER_COLOR)
	var hat_color: Color = gear_colors.get("hat", Color("d4f7ff"))
	var pants_color: Color = gear_colors.get("pants", PITCHER_COLOR.darkened(0.22))
	var cleats_color: Color = gear_colors.get("cleats", Color("d4f7ff"))
	var jockstrap_color: Color = gear_colors.get("jockstrap", Color("d4f7ff"))
	var relic_color: Color = gear_colors.get("relic", Color("d68cff"))
	var glove_color: Color = gear_colors.get("glove", Color("ffffff"))
	var arm_visuals := clampi(int(snapshot.arms), 1, 8)
	# The compact rectangular arm advances through the visible cooldown, reaches
	# its release point exactly where a ball is spawned, then retracts in flight.
	# It never free-runs just because the rate stat is large.
	var motion := get_throw_arm_motion()
	var clone_visuals := clampi(int(snapshot.clones), 1, clone_visual_capacity)
	# Preserve every clone body. Once the bullpen becomes crowded, show a bounded
	# representative set of limbs per clone while the primary body still displays
	# every purchased arm and every released ball remains one-to-one.
	var clone_arm_visuals := mini(
		arm_visuals,
		maxi(1, int(64.0 / float(maxi(clone_visuals - 1, 1))))
	)
	for clone_index in range(1, clone_visuals):
		var clone_position := origin + _get_clone_offset(clone_index)
		var clone_gear_linked := bool(snapshot.get("clone_gear_linked", false))
		var clone_jersey := jersey_color if clone_gear_linked else PITCHER_COLOR
		var clone_hat := hat_color if clone_gear_linked else Color("d4f7ff")
		var clone_arm_color := (
			glove_color
			if clone_gear_linked and gear_colors.has("glove")
			else Color("d4f5ff")
		)
		var clone_radius := 10.0 * pitcher_scale
		var clone_ring_width := maxf(2.0, 3.0 * minf(pitcher_scale, 1.8))
		draw_circle(clone_position, clone_radius + clone_ring_width * 0.5, Color(clone_jersey, 0.58))
		draw_circle(clone_position, maxf(clone_radius - clone_ring_width * 0.5, 1.0), Color(0.02, 0.05, 0.08, 0.78))
		draw_circle(clone_position, 2.5 * clampf(pitcher_scale, 0.8, 1.8), Color(clone_hat, 0.68))
		_draw_pitcher_arm_rectangles(
			clone_position,
			clone_arm_visuals,
			motion,
			clone_arm_color,
			0.52
		)

	# Use the same point-and-ring grammar as every batter. Equipment adds small
	# marks inside that silhouette instead of changing its fundamental shape.
	var body_radius := 10.0 * pitcher_scale
	draw_circle(origin, body_radius, Color(0.02, 0.05, 0.08, 0.94))
	draw_arc(
		origin,
		body_radius + 1.0,
		0.0,
		TAU,
		28,
		jersey_color,
		maxf(2.0, 3.0 * minf(pitcher_scale, 1.8))
	)
	if gear_colors.has("cleats"):
		draw_circle(origin + Vector2(4.7, -3.5) * pitcher_scale, 1.7 * readable_scale, cleats_color)
		draw_circle(origin + Vector2(4.7, 3.5) * pitcher_scale, 1.7 * readable_scale, cleats_color)
	if gear_colors.has("pants"):
		draw_line(origin + Vector2(1.0, -3.0) * pitcher_scale, origin + Vector2(5.5, -3.4) * pitcher_scale, pants_color, 2.8 * readable_scale)
		draw_line(origin + Vector2(1.0, 3.0) * pitcher_scale, origin + Vector2(5.5, 3.4) * pitcher_scale, pants_color, 2.8 * readable_scale)
	if gear_colors.has("jockstrap"):
		draw_line(origin + Vector2(1.0, -4.5) * pitcher_scale, origin + Vector2(1.0, 4.5) * pitcher_scale, jockstrap_color, 1.6 * readable_scale)
	if gear_colors.has("hat"):
		draw_circle(origin + Vector2(-2.2, 0.0) * pitcher_scale, 3.2 * readable_scale, hat_color)
		draw_line(origin + Vector2(-4.0, -2.6) * pitcher_scale, origin + Vector2(-4.0, 2.6) * pitcher_scale, hat_color.lightened(0.18), 1.8 * readable_scale)
	if gear_colors.has("relic"):
		draw_arc(origin, body_radius + 5.0 * readable_scale, -0.75, 0.75, 12, Color(relic_color, 0.80), 1.5 * readable_scale)
	draw_circle(origin, 2.5 * clampf(pitcher_scale, 0.8, 1.8), Color("d4f7ff"))
	var arm_color := glove_color if gear_colors.has("glove") else Color("d4f5ff")
	_draw_pitcher_arm_rectangles(origin, arm_visuals, motion, arm_color, 0.94)

func _draw_pitcher_arm_rectangles(
	origin: Vector2,
	arm_count: int,
	motion: float,
	color: Color,
	alpha: float
) -> void:
	# Arms deliberately use the batter's bat-like rectangular grammar. Each one
	# slides and rotates toward the plate, and the immutable ball source is the
	# exact release tip returned by the same geometry function.
	var pitcher_scale := _get_pitcher_visual_scale()
	for arm_index in arm_count:
		var arm_motion := clampf(motion * (0.92 + float(arm_index % 3) * 0.04), -0.68, 1.0)
		var geometry := _get_throw_arm_geometry(arm_index, arm_count, arm_motion)
		var start := origin + Vector2(geometry.start)
		var finish := origin + Vector2(geometry.end)
		var half_width := maxf(1.8, 1.8 * minf(pitcher_scale, 1.8))
		# A square-ended wide line is the same compact rectangle visually, without
		# allocating and triangulating a new polygon for every limb every frame.
		draw_line(start, finish, Color(color, alpha), half_width * 2.0, false)

func get_throw_arm_motion() -> float:
	# Most of recovery is a readable, deliberate windup.  The last quarter whips
	# through release. Flight begins at that exact forward pose, then uses the
	# existing short follow-through decay while the immutable ball flies. An empty
	# plate rests the pitcher.
	if volley_in_flight:
		return clampf(throw_animation, 0.0, 1.0)
	if not _is_batter_visually_present():
		return 0.0
	var cooldown := get_pitch_cooldown_progress()
	const COCK_FRACTION := 0.76
	if cooldown <= COCK_FRACTION:
		return lerpf(0.0, -0.68, cooldown / COCK_FRACTION)
	return lerpf(-0.68, 1.0, (cooldown - COCK_FRACTION) / (1.0 - COCK_FRACTION))

func _draw_home_plate(origin: Vector2) -> void:
	# Plate and people share perspective. Letting the environmental zoom enlarge
	# only the plate made it compete with the toddler at close ranges.
	var plate_scale := clampf(_get_character_camera_scale(), 0.72, 1.65)
	var local_points := [
		Vector2(-9.0, -10.0),
		Vector2(5.0, -10.0),
		Vector2(11.0, 0.0),
		Vector2(5.0, 10.0),
		Vector2(-9.0, 10.0),
	]
	var points := PackedVector2Array()
	for local_point in local_points:
		points.append(origin + _orient_pitch_vector(local_point) * plate_scale)
	draw_polyline(points, Color(0.62, 0.77, 0.84, 0.88), maxf(1.5, 1.5 * plate_scale))
	draw_line(points[points.size() - 1], points[0], Color(0.62, 0.77, 0.84, 0.88), maxf(1.5, 1.5 * plate_scale))
	draw_arc(origin, 22.0 * plate_scale, 0.0, TAU, 32, Color(0.42, 0.75, 0.86, 0.24), maxf(1.0, plate_scale))

func _draw_batter(origin: Vector2) -> void:
	var opponent_index := int(snapshot.opponent_index)
	var within_era := opponent_index % 3
	var intrinsic_size := _get_batter_intrinsic_size()
	var variant_seed := maxi(batter_generation, 0) * 7 + opponent_index * 11
	var scale_factor := intrinsic_size * _get_character_camera_scale()
	var body_color := Color(snapshot.get("opponent_body_color", Color("f28a62")))
	var bat_color := Color(snapshot.get("opponent_bat_color", Color("a9b6c5")))
	var swing_phase := sin((1.0 - bat_swing_animation) * PI) * (
		1.0
		if last_contact_outcome < Content.HIT_OUTCOME_COUNT or last_contact_outcome == Content.FOUL_INDEX
		else 0.20
	)
	var swing_rotation := swing_phase * 0.95
	if opponent_index == Content.FINAL_BOSS_INDEX:
		var boss_scale := maxf(scale_factor * 0.72, 1.0)
		draw_circle(origin, 24.0 * boss_scale, Color("7d3bc4"))
		draw_arc(origin, 29.0 * boss_scale, 0.0, TAU, 48, Color("d9a6ff"), 3.0 * boss_scale)
		draw_circle(origin, 10.0 * boss_scale, Color("03060d"))
		for arm_index in 8:
			var angle := float(arm_index) / 8.0 * TAU - swing_rotation * (0.45 + arm_index * 0.025)
			var elbow := origin + Vector2(cos(angle), sin(angle)) * 34.0 * boss_scale
			var hand := elbow + Vector2(cos(angle + 0.34), sin(angle + 0.34)) * 16.0 * boss_scale
			var bat_end := hand + Vector2(cos(angle + 0.88), sin(angle + 0.88)) * 31.0 * boss_scale
			draw_line(origin, elbow, Color("b873ff"), 5.0 * boss_scale)
			draw_line(elbow, hand, Color("d9a6ff"), 4.0 * boss_scale)
			draw_line(hand, bat_end, bat_color, 5.0 * boss_scale)
			draw_arc(origin, 51.0 * boss_scale, angle + 0.22, angle + 0.76, 10, Color(bat_color, 0.25), 2.0 * boss_scale)
		return
	if opponent_index == Content.ELDRITCH_FINAL_INDEX:
		var boss_scale := maxf(scale_factor * 0.72, 1.0)
		draw_circle(origin, 18.0 * boss_scale, Color("020307"))
		draw_arc(origin, 25.0 * boss_scale, 0.0, TAU, 48, Color("ffcf66"), 3.0 * boss_scale)
		draw_arc(origin, 34.0 * boss_scale, -1.0 - swing_rotation, 1.2 - swing_rotation, 28, Color(0.66, 0.45, 1.0, 0.55), 4.0 * boss_scale)

	var body_radius := 10.0 * scale_factor
	draw_circle(origin, body_radius, Color(0.02, 0.05, 0.08, 0.94))
	draw_arc(origin, body_radius + 1.0, 0.0, TAU, 28, body_color, maxf(2.0, 3.0 * minf(scale_factor, 1.8)))
	draw_circle(origin, (2.5 + float(opponent_index % 3)) * clampf(scale_factor, 0.8, 1.8), body_color.lightened(0.28))
	var marker_count := variant_seed % 4
	for marker in marker_count:
		var marker_angle := float(marker) / float(maxi(marker_count, 1)) * TAU
		draw_circle(origin + Vector2(cos(marker_angle), sin(marker_angle)) * (body_radius + 5.0 * scale_factor), 1.6 * clampf(scale_factor, 0.8, 1.8), Color(body_color, 0.72))
	var bat_count := maxi(int(snapshot.get("opponent_bat_count", 1)), 1)
	var bat_length := (38.0 + float(within_era) * 2.0) * scale_factor
	for bat_index in bat_count:
		var angle := _get_bat_shaft_angle(bat_index, bat_count, swing_phase)
		var hand := origin + Vector2(cos(angle), sin(angle)) * body_radius * 0.45
		var bat_end := hand + Vector2(cos(angle), sin(angle)) * bat_length
		draw_line(hand, bat_end, bat_color, maxf(3.0, 5.0 * minf(scale_factor, 1.8)))
		draw_arc(origin, 31.0 * scale_factor, angle - 0.42, angle, 12, Color(bat_color, 0.25), maxf(1.5, 2.0 * minf(scale_factor, 1.8)))

func _get_batter_intrinsic_size() -> float:
	# Campaign body scale is already the opponent's complete authored intrinsic
	# footprint. Multiplying it by the retired 45-opponent lookup made later bodies
	# several times too large after the campaign expanded to 100 levels.
	return clampf(float(snapshot.get("batter_body_scale", 1.0)), 0.45, 8.0)
