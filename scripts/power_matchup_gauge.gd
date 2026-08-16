extends Control

## A compact, vertical matchup gauge. The two markers intentionally use the
## called-Strike probability and its complement: unlike the old synthetic
## rating ratio, the picture therefore cannot claim parity during a 4% matchup.

const COLOR_TRACK := Color("26354a")
const COLOR_TEXT := Color("e8f2ff")
const COLOR_RED := Color("ff5f6f")
const COLOR_ORANGE := Color("ff9f43")
const COLOR_YELLOW := Color("ffd45e")
const COLOR_GREEN := Color("63df91")

var you_ratio := 0.5
var them_ratio := 0.5
var compact := false
var matchup_color := COLOR_YELLOW

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func set_compact(value: bool) -> void:
	if compact == value:
		return
	compact = value
	queue_redraw()

func set_matchup(called_strike_probability: float) -> void:
	var next_you := clampf(called_strike_probability, 0.0, 1.0)
	if is_equal_approx(next_you, you_ratio):
		return
	you_ratio = next_you
	them_ratio = 1.0 - next_you
	matchup_color = _color_for_player_share(you_ratio)
	queue_redraw()

func _color_for_player_share(value: float) -> Color:
	if value < 0.35:
		return COLOR_RED.lerp(COLOR_ORANGE, clampf((value - 0.12) / 0.23, 0.0, 1.0))
	if value < 0.48:
		return COLOR_ORANGE.lerp(COLOR_YELLOW, (value - 0.35) / 0.13)
	if value <= 0.55:
		return COLOR_YELLOW
	return COLOR_YELLOW.lerp(COLOR_GREEN, clampf((value - 0.55) / 0.25, 0.0, 1.0))

func _pill_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("09111e").lerp(color, 0.16)
	style.border_color = color
	style.set_border_width_all(1)
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	return style

func _track_style(color: Color, alpha: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(color, alpha)
	style.border_color = Color("8ca1b9", 0.55)
	style.set_border_width_all(1)
	style.corner_radius_top_left = 7
	style.corner_radius_top_right = 7
	style.corner_radius_bottom_left = 7
	style.corner_radius_bottom_right = 7
	return style

func _resolve_label_tops(
	you_marker_y: float,
	them_marker_y: float,
	minimum_y: float,
	maximum_y: float,
	label_height: float
) -> Vector2:
	var you_top := clampf(you_marker_y - label_height * 0.5, minimum_y, maximum_y)
	var them_top := clampf(them_marker_y - label_height * 0.5, minimum_y, maximum_y)
	var required_gap := label_height + 2.0
	if absf(you_top - them_top) >= required_gap:
		return Vector2(you_top, them_top)
	var midpoint := (you_top + them_top) * 0.5
	if you_marker_y <= them_marker_y:
		you_top = midpoint - required_gap * 0.5
		them_top = midpoint + required_gap * 0.5
	else:
		them_top = midpoint - required_gap * 0.5
		you_top = midpoint + required_gap * 0.5
	var top_overflow := minimum_y - minf(you_top, them_top)
	if top_overflow > 0.0:
		you_top += top_overflow
		them_top += top_overflow
	var bottom_overflow := maxf(you_top, them_top) - maximum_y
	if bottom_overflow > 0.0:
		you_top -= bottom_overflow
		them_top -= bottom_overflow
	return Vector2(you_top, them_top)

func _draw_marker(
	font: Font,
	marker_y: float,
	label_top: float,
	label_text: String,
	color: Color,
	track_right: float,
	label_left: float,
	label_width: float,
	label_height: float,
	font_size: int
) -> void:
	draw_circle(Vector2(track_right - 1.0, marker_y), 2.5, color)
	draw_line(
		Vector2(track_right + 1.0, marker_y),
		Vector2(label_left, label_top + label_height * 0.5),
		color,
		1.0,
		true
	)
	var label_rect := Rect2(label_left, label_top, label_width, label_height)
	draw_style_box(_pill_style(color), label_rect)
	var text_y := label_rect.position.y + (label_rect.size.y + font_size) * 0.5 - 2.0
	draw_string(
		font,
		Vector2(label_rect.position.x + 3.0, text_y),
		label_text,
		HORIZONTAL_ALIGNMENT_CENTER,
		label_rect.size.x - 6.0,
		font_size,
		COLOR_TEXT
	)

func _draw() -> void:
	if size.x < 40.0 or size.y < 80.0:
		return
	var font := ThemeDB.fallback_font
	var font_size := 8 if compact else 9
	var title_size := 8 if compact else 9
	draw_string(
		font,
		Vector2(0.0, float(title_size)),
		"POWER",
		HORIZONTAL_ALIGNMENT_CENTER,
		size.x,
		title_size,
		COLOR_TEXT
	)
	var track_top := 17.0 if compact else 19.0
	var track_bottom := size.y - 6.0
	var track_height := maxf(track_bottom - track_top, 40.0)
	var track_left := 5.0
	var track_width := 13.0 if compact else 15.0
	var track_rect := Rect2(track_left, track_top, track_width, track_height)
	draw_style_box(_track_style(COLOR_TRACK, 0.92), track_rect)
	# Dim bands keep the reference's thermometer readability without making the
	# field look like a large rainbow UI element.
	var bands := [COLOR_GREEN, Color("a9df4c"), COLOR_YELLOW, COLOR_ORANGE, COLOR_RED]
	var inner_rect := track_rect.grow(-2.0)
	var band_height := inner_rect.size.y / float(bands.size())
	for index in bands.size():
		draw_rect(
			Rect2(
				inner_rect.position.x,
				inner_rect.position.y + band_height * float(index),
				inner_rect.size.x,
				band_height + 0.5
			),
			Color(bands[index], 0.23)
		)
	var fill_top := track_bottom - track_height * you_ratio
	draw_rect(
		Rect2(track_left + 2.0, fill_top, track_width - 4.0, maxf(track_bottom - fill_top - 2.0, 1.0)),
		Color(matchup_color, 0.88)
	)
	var you_marker_y := track_bottom - track_height * you_ratio
	var them_marker_y := track_bottom - track_height * them_ratio
	var label_height := 18.0 if compact else 20.0
	var label_left := track_rect.end.x + 5.0
	var label_width := maxf(size.x - label_left - 2.0, 28.0)
	var label_tops := _resolve_label_tops(
		you_marker_y,
		them_marker_y,
		track_top,
		track_bottom - label_height,
		label_height
	)
	_draw_marker(
		font,
		you_marker_y,
		label_tops.x,
		"YOU",
		matchup_color,
		track_rect.end.x,
		label_left,
		label_width,
		label_height,
		font_size
	)
	_draw_marker(
		font,
		them_marker_y,
		label_tops.y,
		"THEM",
		matchup_color,
		track_rect.end.x,
		label_left,
		label_width,
		label_height,
		font_size
	)
