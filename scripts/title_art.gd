class_name NoHitterTitleArt
extends Control

const HUMAN_FINAL_INDEX := 29
const ALIEN_FINAL_INDEX := 39
const FINAL_BOSS_INDEX := 44

var highest_opponent := 0
var genetic_revealed := false
var eldritch_revealed := false
var divine_revealed := false
var animation_time := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)

func configure(
	reached_opponent: int,
	has_genetics: bool,
	has_eldritch: bool,
	has_divine: bool
) -> void:
	highest_opponent = clampi(reached_opponent, 0, FINAL_BOSS_INDEX)
	genetic_revealed = has_genetics
	eldritch_revealed = has_eldritch
	divine_revealed = has_divine
	queue_redraw()

func _process(delta: float) -> void:
	animation_time = fmod(animation_time + maxf(delta, 0.0), 120.0)
	queue_redraw()

func _draw() -> void:
	var extent := size
	if extent.x <= 1.0 or extent.y <= 1.0:
		return
	var era := _visible_era()
	var background := Color("102f25")
	if era == 1:
		background = Color("262145")
	elif era >= 2:
		background = Color("030711")
	draw_rect(Rect2(Vector2.ZERO, extent), background)
	_draw_environment(extent, era)
	_draw_matchup(extent, era)

func _visible_era() -> int:
	if divine_revealed:
		return 3
	if eldritch_revealed or highest_opponent > ALIEN_FINAL_INDEX:
		return 2
	if genetic_revealed or highest_opponent > HUMAN_FINAL_INDEX:
		return 1
	return 0

func _draw_environment(extent: Vector2, era: int) -> void:
	var center := extent * Vector2(0.5, 0.56)
	if era == 0:
		for ring_index in 5:
			var radius := minf(extent.x, extent.y) * (0.16 + float(ring_index) * 0.10)
			draw_arc(center, radius, PI * 1.08, PI * 1.92, 48, Color("315d4d"), 1.2, true)
		draw_line(center, Vector2(extent.x * 0.08, extent.y * 0.08), Color("315d4d"), 1.2, true)
		draw_line(center, Vector2(extent.x * 0.92, extent.y * 0.08), Color("315d4d"), 1.2, true)
		return
	if era == 1:
		draw_circle(Vector2(extent.x * 0.14, extent.y * 0.18), minf(extent.x, extent.y) * 0.11, Color("503b76"))
		draw_circle(Vector2(extent.x * 0.14, extent.y * 0.18), minf(extent.x, extent.y) * 0.075, Color("6b5992"))
		for band_index in 4:
			var y := extent.y * (0.18 + float(band_index) * 0.18)
			draw_line(Vector2(0.0, y), Vector2(extent.x, y + extent.y * 0.04), Color("3f3861"), 1.0, true)
		return
	var star_count := 34 + maxi(highest_opponent - ALIEN_FINAL_INDEX, 0) * 9
	if era == 3:
		star_count += 36
	for star_index in star_count:
		var x := fmod(float(star_index * 83 + 29), 997.0) / 997.0 * extent.x
		var y := fmod(float(star_index * 149 + 71), 991.0) / 991.0 * extent.y
		var radius := 0.7 + float(star_index % 4) * 0.35
		var alpha := 0.28 + float(star_index % 5) * 0.12
		draw_circle(Vector2(x, y), radius, Color(0.70, 0.86, 1.0, alpha))
	if era == 3:
		for halo_index in 3:
			draw_arc(
				center,
				minf(extent.x, extent.y) * (0.28 + float(halo_index) * 0.09),
				0.0,
				TAU,
				72,
				Color(1.0, 0.78, 0.32, 0.18 - float(halo_index) * 0.035),
				2.0,
				true
			)

func _draw_matchup(extent: Vector2, era: int) -> void:
	var pitcher := Vector2(extent.x * 0.22, extent.y * 0.64)
	var batter := Vector2(extent.x * 0.78, extent.y * 0.36)
	if extent.y > extent.x * 1.15:
		pitcher = Vector2(extent.x * 0.42, extent.y * 0.76)
		batter = Vector2(extent.x * 0.58, extent.y * 0.24)
	var progress := float(highest_opponent) / float(FINAL_BOSS_INDEX)
	var base_radius := minf(extent.x, extent.y) * 0.047
	var pitcher_radius := base_radius * (1.45 + progress * 0.34)
	var batter_radius := base_radius * (0.96 + progress * 0.85)
	if era == 1:
		batter_radius *= 1.22
	elif era >= 2:
		batter_radius *= 1.45
	_draw_player(pitcher, pitcher_radius, Color("63d9ff"), false, era)
	_draw_player(batter, batter_radius, Color("d78cff") if era > 0 else Color("ffd36b"), true, era)
	var source_count := 1
	if era == 1:
		source_count = 2 + clampi(highest_opponent - HUMAN_FINAL_INDEX, 0, 3)
	elif era == 2:
		source_count = 7
	elif era == 3:
		source_count = 10
	var travel := fmod(animation_time * (0.12 + float(era) * 0.035), 1.0)
	for ball_index in source_count:
		var spread := float(ball_index) - float(source_count - 1) * 0.5
		var source := pitcher + Vector2(0.0, spread * pitcher_radius * 0.24)
		var target := batter + Vector2(0.0, -spread * batter_radius * 0.16)
		if extent.y > extent.x * 1.15:
			source = pitcher + Vector2(spread * pitcher_radius * 0.24, 0.0)
			target = batter + Vector2(-spread * batter_radius * 0.16, 0.0)
		var sideways := Vector2(-(target - source).y, (target - source).x).normalized()
		var arc_strength := 0.0 if era == 0 else spread * minf(extent.x, extent.y) * 0.026
		var control := (source + target) * 0.5 + sideways * arc_strength
		var points := PackedVector2Array()
		for point_index in 17:
			points.append(_quadratic_bezier(source, control, target, float(point_index) / 16.0))
		draw_polyline(points, Color(0.39, 0.85, 1.0, 0.18 + float(era) * 0.05), 1.1, true)
		var staggered := fmod(travel + float(ball_index) / float(maxi(source_count, 1)) * 0.72, 1.0)
		var ball_position := _quadratic_bezier(source, control, target, staggered)
		draw_circle(ball_position, maxf(base_radius * 0.16, 2.0), Color("f4f7ff"))

func _draw_player(center: Vector2, radius: float, color: Color, is_batter: bool, era: int) -> void:
	draw_circle(center, radius, Color("07101b"))
	draw_arc(center, radius, 0.0, TAU, 48, color, maxf(radius * 0.13, 2.0), true)
	draw_circle(center, maxf(radius * 0.13, 2.0), color)
	var facing := Vector2(-1.0, 0.0) if is_batter else Vector2(1.0, 0.0)
	if size.y > size.x * 1.15:
		facing = Vector2(0.0, 1.0) if is_batter else Vector2(0.0, -1.0)
	var limb_count := 1
	if era == 1:
		limb_count = 3 if is_batter else 2
	elif era >= 2:
		limb_count = 6 if is_batter else 4
	for limb_index in limb_count:
		var spread := float(limb_index) - float(limb_count - 1) * 0.5
		var angle := facing.angle() + spread * (0.28 if era > 0 else 0.0)
		var direction := Vector2.from_angle(angle)
		var side := Vector2(-direction.y, direction.x)
		var start := center + side * spread * radius * 0.13
		var length := radius * (1.55 if is_batter else 1.12)
		draw_line(start, start + direction * length, Color("dbe7f4") if is_batter else color, maxf(radius * 0.18, 3.0), true)
	if era >= 2 and is_batter:
		draw_arc(center, radius * 1.38, -0.65, 3.95, 34, Color(color, 0.30), 1.5, true)

func _quadratic_bezier(start: Vector2, control: Vector2, finish: Vector2, t: float) -> Vector2:
	var inverse := 1.0 - clampf(t, 0.0, 1.0)
	return start * inverse * inverse + control * 2.0 * inverse * t + finish * t * t
