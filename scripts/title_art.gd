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
	_draw_frame_and_badge(extent, era)

func _stage_rect(extent: Vector2) -> Rect2:
	# The title illustration deliberately behaves like a large, animated version
	# of the app icon. Portrait gets a tall card; desktop gets a broad lockup.
	var inset := clampf(minf(extent.x, extent.y) * 0.035, 8.0, 20.0)
	var available := extent - Vector2(inset * 2.0, inset * 2.0)
	var portrait := extent.y > extent.x * 1.15
	var target_ratio := 0.92 if portrait else 1.52
	var stage_size := available
	if stage_size.x / maxf(stage_size.y, 1.0) > target_ratio:
		stage_size.x = stage_size.y * target_ratio
	else:
		stage_size.y = stage_size.x / target_ratio
	return Rect2((extent - stage_size) * 0.5, stage_size)

func _visible_era() -> int:
	if divine_revealed:
		return 3
	if eldritch_revealed or highest_opponent > ALIEN_FINAL_INDEX:
		return 2
	if genetic_revealed or highest_opponent > HUMAN_FINAL_INDEX:
		return 1
	return 0

func _draw_environment(extent: Vector2, era: int) -> void:
	var stage := _stage_rect(extent)
	var center := stage.position + stage.size * Vector2(0.5, 0.54)
	var portrait := stage.size.y > stage.size.x * 1.15
	if era == 0:
		# Broad icon-like diagonals and quiet mowing bands frame the matchup without
		# shrinking it into the middle of a full-size field diagram.
		for stripe_index in 7:
			var stripe_color := Color(0.05, 0.18, 0.14, 0.14 if stripe_index % 2 == 0 else 0.045)
			if portrait:
				var stripe_height := stage.size.y / 7.0
				draw_rect(Rect2(stage.position.x, stage.position.y + stripe_height * stripe_index, stage.size.x, stripe_height), stripe_color)
			else:
				var stripe_width := stage.size.x / 7.0
				draw_rect(Rect2(stage.position.x + stripe_width * stripe_index, stage.position.y, stripe_width, stage.size.y), stripe_color)
		var cross_color := Color(0.22, 0.40, 0.37, 0.54)
		draw_line(stage.position + stage.size * Vector2(0.08, 0.82), stage.position + stage.size * Vector2(0.90, 0.12), cross_color, 2.0, true)
		draw_line(stage.position + stage.size * Vector2(0.08, 0.18), stage.position + stage.size * Vector2(0.90, 0.88), cross_color, 2.0, true)
		for ring_index in 3:
			var radius := minf(stage.size.x, stage.size.y) * (0.24 + float(ring_index) * 0.12)
			draw_arc(center, radius, PI * 1.10, PI * 1.90, 56, Color(0.23, 0.42, 0.35, 0.55), 1.3, true)
		return
	if era == 1:
		var planet := stage.position + stage.size * (Vector2(0.16, 0.16) if not portrait else Vector2(0.18, 0.12))
		draw_circle(planet, minf(stage.size.x, stage.size.y) * 0.13, Color("503b76"))
		draw_circle(planet, minf(stage.size.x, stage.size.y) * 0.088, Color("6b5992"))
		draw_arc(planet, minf(stage.size.x, stage.size.y) * 0.16, -0.20, 3.34, 52, Color(0.75, 0.60, 1.0, 0.32), 2.0, true)
		for band_index in 4:
			var y := stage.position.y + stage.size.y * (0.18 + float(band_index) * 0.18)
			draw_line(Vector2(stage.position.x, y), Vector2(stage.end.x, y + stage.size.y * 0.04), Color("514779"), 1.2, true)
		return
	var star_count := 34 + maxi(highest_opponent - ALIEN_FINAL_INDEX, 0) * 9
	if era == 3:
		star_count += 36
	for star_index in star_count:
		var x := stage.position.x + fmod(float(star_index * 83 + 29), 997.0) / 997.0 * stage.size.x
		var y := stage.position.y + fmod(float(star_index * 149 + 71), 991.0) / 991.0 * stage.size.y
		var radius := 0.7 + float(star_index % 4) * 0.35
		var alpha := 0.28 + float(star_index % 5) * 0.12
		draw_circle(Vector2(x, y), radius, Color(0.70, 0.86, 1.0, alpha))
	if era == 3:
		for halo_index in 3:
			draw_arc(
				center,
				minf(stage.size.x, stage.size.y) * (0.28 + float(halo_index) * 0.09),
				0.0,
				TAU,
				72,
				Color(1.0, 0.78, 0.32, 0.18 - float(halo_index) * 0.035),
				2.0,
				true
			)

func _draw_matchup(extent: Vector2, era: int) -> void:
	var stage := _stage_rect(extent)
	var portrait := stage.size.y > stage.size.x * 1.15
	var pitcher := stage.position + stage.size * Vector2(0.20, 0.58)
	var batter := stage.position + stage.size * Vector2(0.80, 0.42)
	if portrait:
		pitcher = stage.position + stage.size * Vector2(0.44, 0.76)
		batter = stage.position + stage.size * Vector2(0.56, 0.24)
	var progress := float(highest_opponent) / float(FINAL_BOSS_INDEX)
	var base_radius := minf(stage.size.x, stage.size.y) * 0.095
	var pitcher_radius := base_radius * (1.12 + progress * 0.12)
	var batter_radius := base_radius * (0.74 + progress * 0.34)
	if era == 1:
		batter_radius *= 1.24
	elif era >= 2:
		batter_radius *= 1.48
	var pitch_direction := (batter - pitcher).normalized()
	var side := Vector2(-pitch_direction.y, pitch_direction.x)
	var plate := batter - pitch_direction * batter_radius * 1.70
	var lane_color := Color(0.39, 0.85, 1.0, 0.18)
	draw_circle(pitcher, pitcher_radius * 1.38, Color(0.02, 0.05, 0.08, 0.24))
	draw_arc(pitcher, pitcher_radius * 1.28, 0.0, TAU, 48, Color(0.39, 0.85, 1.0, 0.20), 1.5, true)
	draw_dashed_line(pitcher + pitch_direction * pitcher_radius * 1.25, plate, lane_color, 1.4, 8.0, true)
	draw_line(plate, plate + side * batter_radius * 1.45 - pitch_direction * batter_radius * 1.55, Color(0.58, 0.76, 0.78, 0.22), 1.2, true)
	draw_line(plate, plate - side * batter_radius * 1.45 - pitch_direction * batter_radius * 1.55, Color(0.58, 0.76, 0.78, 0.22), 1.2, true)
	_draw_home_plate(plate, pitch_direction, batter_radius * 0.46)
	_draw_player(pitcher, pitcher_radius, Color("63d9ff"), false, era)
	_draw_player(batter, batter_radius, Color("d78cff") if era > 0 else Color("ffd36b"), true, era)
	var source_count := 1
	if era == 1:
		source_count = 2 + clampi(highest_opponent - HUMAN_FINAL_INDEX, 0, 3)
	elif era == 2:
		source_count = 7
	elif era == 3:
		source_count = 10
	var travel := fmod(animation_time * (0.14 + float(era) * 0.035), 1.0)
	for ball_index in source_count:
		var spread := float(ball_index) - float(source_count - 1) * 0.5
		var source := pitcher + Vector2(0.0, spread * pitcher_radius * 0.24)
		var target := batter + Vector2(0.0, -spread * batter_radius * 0.16)
		if portrait:
			source = pitcher + Vector2(spread * pitcher_radius * 0.24, 0.0)
			target = batter + Vector2(-spread * batter_radius * 0.16, 0.0)
		var sideways := Vector2(-(target - source).y, (target - source).x).normalized()
		var arc_strength := 0.0 if era == 0 else spread * minf(stage.size.x, stage.size.y) * 0.032
		var control := (source + target) * 0.5 + sideways * arc_strength
		var points := PackedVector2Array()
		for point_index in 17:
			points.append(_quadratic_bezier(source, control, target, float(point_index) / 16.0))
		draw_polyline(points, Color(0.39, 0.85, 1.0, 0.13 + float(era) * 0.05), maxf(base_radius * 0.08, 2.0), true)
		var staggered := fmod(travel + float(ball_index) / float(maxi(source_count, 1)) * 0.72, 1.0)
		var ball_position := _quadratic_bezier(source, control, target, staggered)
		for trail_index in 9:
			var trail_t := maxf(staggered - float(trail_index + 1) * 0.026, 0.0)
			var trail_position := _quadratic_bezier(source, control, target, trail_t)
			var trail_alpha := (0.30 - float(trail_index) * 0.026) * (1.0 if era == 0 else 0.82)
			draw_circle(trail_position, maxf(base_radius * (0.22 - float(trail_index) * 0.011), 2.0), Color(0.39, 0.85, 1.0, maxf(trail_alpha, 0.03)))
		for glow_index in range(3, 0, -1):
			draw_circle(ball_position, maxf(base_radius * (0.22 + glow_index * 0.12), 3.0), Color(0.55, 0.88, 1.0, 0.045 * glow_index))
		draw_circle(ball_position, maxf(base_radius * 0.30, 3.8), Color("f4f7ff"))
		draw_arc(ball_position, maxf(base_radius * 0.30, 3.8), 0.0, TAU, 20, Color("9fe9ff"), maxf(base_radius * 0.08, 1.4), true)

func _draw_player(center: Vector2, radius: float, color: Color, is_batter: bool, era: int) -> void:
	draw_circle(center + Vector2(radius * 0.18, radius * 0.24), radius * 1.10, Color(0.0, 0.0, 0.0, 0.24))
	draw_circle(center, radius, Color("07101b"))
	draw_arc(center, radius, 0.0, TAU, 56, color, maxf(radius * 0.14, 2.0), true)
	draw_arc(center, radius * 0.79, -1.15, 1.95, 28, Color(color, 0.24), maxf(radius * 0.07, 1.0), true)
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
		var motion := sin(animation_time * 2.2 + float(limb_index) * 0.35)
		var action_angle := motion * (0.24 if is_batter else 0.13)
		var angle := facing.angle() + spread * (0.28 if era > 0 else 0.0) + action_angle
		var direction := Vector2.from_angle(angle)
		var side := Vector2(-direction.y, direction.x)
		var start := center + side * spread * radius * 0.13
		var length := radius * (1.55 if is_batter else 1.12)
		draw_line(start, start + direction * length, Color("dbe7f4") if is_batter else color, maxf(radius * 0.18, 3.0), true)
	if era >= 2 and is_batter:
		draw_arc(center, radius * 1.38, -0.65, 3.95, 34, Color(color, 0.30), 1.5, true)

func _draw_home_plate(center: Vector2, direction: Vector2, scale: float) -> void:
	var side := Vector2(-direction.y, direction.x)
	var points := PackedVector2Array([
		center + direction * scale * 0.65,
		center + side * scale - direction * scale * 0.20,
		center + side * scale * 0.70 - direction * scale,
		center - side * scale * 0.70 - direction * scale,
		center - side * scale - direction * scale * 0.20,
	])
	draw_colored_polygon(points, Color(0.07, 0.12, 0.16, 0.80))
	var outline := points.duplicate()
	outline.append(points[0])
	draw_polyline(outline, Color(0.72, 0.86, 0.89, 0.80), maxf(scale * 0.12, 1.2), true)

func _draw_frame_and_badge(extent: Vector2, era: int) -> void:
	# A small scoreboard chip anchors the illustration and changes only after its
	# corresponding era has actually been revealed.
	var badge_text := "BACKYARD  •  3 FT"
	if era == 1:
		badge_text = "OFF-WORLD BASEBALL"
	elif era == 2:
		badge_text = "REALITY SERIES"
	elif era == 3:
		badge_text = "UNIVERSE SAVED"
	var stage := _stage_rect(extent)
	var font_size := clampi(int(minf(stage.size.x, stage.size.y) * 0.030), 10, 14)
	var badge_width := minf(stage.size.x * 0.66, maxf(150.0, float(font_size) * float(badge_text.length()) * 0.59))
	var badge_rect := Rect2(stage.position + Vector2(12.0, 12.0), Vector2(badge_width, float(font_size) + 14.0))
	draw_rect(badge_rect, Color(0.02, 0.05, 0.09, 0.82), true)
	draw_rect(badge_rect, Color(0.39, 0.85, 1.0, 0.40), false, 1.0)
	draw_string(
		ThemeDB.fallback_font,
		Vector2(badge_rect.position.x, badge_rect.position.y + float(font_size) + 3.0),
		badge_text,
		HORIZONTAL_ALIGNMENT_CENTER,
		badge_rect.size.x,
		font_size,
		Color("dce9f7")
	)
	draw_rect(stage, Color(0.45, 0.70, 0.84, 0.20), false, 2.0)

func _quadratic_bezier(start: Vector2, control: Vector2, finish: Vector2, t: float) -> Vector2:
	var inverse := 1.0 - clampf(t, 0.0, 1.0)
	return start * inverse * inverse + control * 2.0 * inverse * t + finish * t * t
