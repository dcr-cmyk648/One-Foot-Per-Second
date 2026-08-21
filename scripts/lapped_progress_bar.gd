class_name NoHitterLappedProgressBar
extends Control

@export var value := 0.0:
	set(next_value):
		value = maxf(next_value, 0.0)
		queue_redraw()

var base_color := Color("63d9ff")
var lap_color := Color("64f28f")
var background_color := Color("07101b")
var border_color := Color("243a52")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size.y = 10.0

func _draw() -> void:
	var bounds := Rect2(Vector2.ZERO, size)
	if bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		return
	var radius := bounds.size.y * 0.5
	draw_style_box(_style(background_color, border_color, radius), bounds)
	var laps := value / 100.0
	if laps <= 0.0:
		return
	var completed := int(floor(laps))
	var fraction := fmod(laps, 1.0)
	if completed > 0:
		var completion_tint := 1.0 - exp(-float(completed) / 5.0)
		var completed_color := base_color.lerp(lap_color, completion_tint)
		draw_style_box(_style(completed_color, completed_color, radius), bounds.grow(-1.0))
	if completed == 0 or fraction > 0.000001:
		var fill_fraction := clampf(laps if completed == 0 else fraction, 0.0, 1.0)
		var fill_width := maxf((bounds.size.x - 2.0) * fill_fraction, 0.0)
		if fill_width > 0.5:
			var next_tint := 1.0 - exp(-float(completed + 1) / 5.0)
			var fill_color := base_color.lerp(lap_color, next_tint)
			var fill_rect := Rect2(Vector2(1.0, 1.0), Vector2(fill_width, bounds.size.y - 2.0))
			draw_style_box(_style(fill_color, fill_color, radius), fill_rect)
	# Hairline lap marks make repeated fills legible without adding another label.
	var visible_marks := mini(completed, 8)
	for mark in visible_marks:
		var x := bounds.size.x - 3.0 - float(mark) * 3.0
		draw_line(Vector2(x, 2.0), Vector2(x, bounds.size.y - 2.0), Color(1, 1, 1, 0.40), 1.0)

func _style(fill: Color, border: Color, radius: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	var corner := maxi(int(round(radius)), 1)
	style.corner_radius_top_left = corner
	style.corner_radius_top_right = corner
	style.corner_radius_bottom_left = corner
	style.corner_radius_bottom_right = corner
	return style
