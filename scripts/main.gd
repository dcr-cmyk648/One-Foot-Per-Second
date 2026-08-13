extends Control

const Content = preload("res://scripts/content.gd")
const GameStateScript = preload("res://scripts/game_state.gd")
const PitchFieldScript = preload("res://scripts/pitch_field.gd")

const COLOR_BG := Color("050810")
const COLOR_PANEL := Color("101827")
const COLOR_PANEL_ALT := Color("142033")
const COLOR_TEXT := Color("dce9f7")
const COLOR_MUTED := Color("8396ad")
const COLOR_ACCENT := Color("63d9ff")
const COLOR_GOLD := Color("ffd36b")
const COLOR_GOOD := Color("6ee7a8")
const COLOR_BAD := Color("ff667d")
const WEB_UPDATE_CHECK_INTERVAL := 300.0
const WEB_UPDATE_SNOOZE_SECONDS := 600.0

var game: BaseballGameState
var pitch_field
var ui_elapsed := 0.0
var autosave_elapsed := 0.0
var development_session := false

var xp_label: Label
var rate_label: Label
var rings_label: Label
var prestige_header_stack: VBoxContainer
var prestige_header_heading: Label
var header_subtitle: Label
var save_label: Label
var era_label: Label
var opponent_label: Label
var quirk_label: Label
var mastery_label: Label
var mastery_bar: ProgressBar
var previous_button: Button
var next_button: Button
var distance_label: Label
var equipment_labels := {}
var equipment_summary_label: Label
var equipment_progression_heading: Label
var visual_weight_label: Label
var last_result_label: Label
var outcome_panels: Array[PanelContainer] = []
var outcome_name_labels: Array[Label] = []
var outcome_probability_labels: Array[Label] = []
var outcome_delay_labels: Array[Label] = []
var strikeout_payout_label: Label
var training_buttons := {}
var pitch_buttons := {}
var ball_upgrade_buttons := {}
var milestone_buttons := {}
var scale_buttons := {}
var genetic_buttons := {}
var eldritch_buttons := {}
var divine_buttons := {}
var automation_toggles := {}
var stat_labels := {}
var stat_rows := {}
var upgrade_tabs: TabContainer
var rebirth_tab: Control
var automation_section: VBoxContainer
var genetic_section: VBoxContainer
var eldritch_section: VBoxContainer
var divine_section: VBoxContainer
var guide_label: Label
var rebirth_story_label: Label
var ascension_currency_label: Label
var genetic_reset_button: Button
var eldritch_reset_button: Button
var divine_halo_button: Button
var save_button: Button
var export_save_button: Button
var load_save_button: Button
var hard_reset_button: Button
var event_log: RichTextLabel
var inventory_dock: HBoxContainer
var inventory_slot_buttons := {}
var field_stat_labels := {}
var opponent_loadout_dock: VBoxContainer
var opponent_loadout_signature := ""
var locker_dialog: Window
var locker_dialog_status_label: Label
var locker_dialog_items: VBoxContainer
var locker_dialog_slot_buttons := {}
var selected_loot_slot := "hat"
var last_loot_revision := -1
var last_loot_ui_signature := ""
var genetic_confirmation: ConfirmationDialog
var eldritch_confirmation: ConfirmationDialog
var divine_confirmation: ConfirmationDialog
var body_limit_dialog: AcceptDialog
var hard_reset_dialog: Window
var hard_reset_input: LineEdit
var hard_reset_confirm_button: Button
var export_save_dialog: FileDialog
var load_save_dialog: FileDialog
var import_save_confirmation: ConfirmationDialog
var save_transfer_message_dialog: AcceptDialog
var pending_import_save: Dictionary = {}
var pending_import_name := ""
var web_file_input: Variant = null
var web_file_reader: Variant = null
var web_file_selected_callback: Variant = null
var web_file_loaded_callback: Variant = null
var web_file_error_callback: Variant = null
var pending_divine_id := ""
var last_body_limit_popup_stage := ""
var last_reveal_mask := -1
var is_web_build := false
var web_storage_persistent := true
var web_backgrounded_at := 0.0
var web_last_wall_clock := 0.0
var web_update_check_elapsed := WEB_UPDATE_CHECK_INTERVAL - 5.0
var web_update_status_elapsed := 0.0
var web_update_ready := false
var web_update_snoozed_until := 0.0
var update_banner: PanelContainer
var update_banner_label: Label
var update_now_button: Button
var update_later_button: Button
var mobile_layout := false
var mobile_portrait_layout := false
var mobile_overlay_panel: Control
var mobile_overlay_surface: PanelContainer
var mobile_overlay_content: VBoxContainer
var mobile_overlay_title: Label
var mobile_nav: HBoxContainer
var mobile_overlay_control: Control
var mobile_overlay_home: Control
var mobile_overlay_home_index := -1
var root_margin: MarginContainer
var page_container: VBoxContainer
var body_container: HBoxContainer
var header_panel: PanelContainer
var header_row: HBoxContainer
var header_title_stack: VBoxContainer
var header_title: Label
var header_spacer: Control
var save_stack: VBoxContainer
var play_panel: PanelContainer
var play_stack: VBoxContainer
var opponent_row: HBoxContainer
var opponent_stack: VBoxContainer
var play_row: HBoxContainer
var equipment_sidebar: ScrollContainer
var field_stack: VBoxContainer
var field_footer: HBoxContainer
var outcomes_grid: GridContainer
var upgrade_panel: PanelContainer
var event_log_panel: PanelContainer
var field_stat_panel: PanelContainer
var locker_slot_grid: GridContainer
var header_metric_stacks: Array[VBoxContainer] = []
var header_metric_headings: Array[Label] = []

func _ready() -> void:
	is_web_build = OS.has_feature("web") or OS.has_feature("browser_build")
	if is_web_build:
		# Browser layouts use a fluid canvas rather than the desktop 1600×1000 base.
		# The canvas backing store is still rendered in device pixels, so a Retina
		# phone also needs its display scale applied to the logical 2D content. Without
		# that second step, a 3× iPhone makes every label and model one-third size.
		get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
		get_window().content_scale_size = Vector2i.ZERO
		_sync_browser_content_scale()
	else:
		get_window().min_size = Vector2i(1280, 800)
	theme = _build_theme()
	game = GameStateScript.new()
	game.name = "GameState"
	add_child(game)
	game.batch_resolved.connect(_on_batch_resolved)
	game.progression_changed.connect(_on_progression_changed)
	game.save_status_changed.connect(_on_save_status_changed)
	_build_interface()
	_configure_platform_ui()
	var offline_summary := game.load_game()
	_apply_development_arguments()
	if not offline_summary.is_empty():
		_log_offline_summary(offline_summary, "Welcome back")
	else:
		_log_event("The toddler is ready. Your arm is not.")
	if is_web_build and not web_storage_persistent:
		_log_event("Browser storage is temporary here. Use EXPORT after playing if you want to keep this run.")
	_refresh_interface()
	resized.connect(_on_root_resized)
	web_last_wall_clock = Time.get_unix_time_from_system()
	call_deferred("_apply_responsive_layout")
	call_deferred("_size_initial_window")

func _size_initial_window() -> void:
	if is_web_build or DisplayServer.get_name() == "headless":
		return
	get_window().mode = Window.MODE_MAXIMIZED

func _process(delta: float) -> void:
	if game == null:
		return
	if is_web_build:
		_update_browser_release_status(delta)
	if is_web_build and web_backgrounded_at > 0.0:
		web_last_wall_clock = Time.get_unix_time_from_system()
		return
	var simulation_delta := _consume_browser_wall_clock(delta)
	# The simulation may know a terminal result as soon as a ball is released,
	# while the top-down field still has to show that immutable ball reaching the
	# plate and the replacement batter entering. Do not resolve hidden pitches in
	# that visual gap.
	game.live_pitching_enabled = (
		pitch_field == null or pitch_field.is_simulation_clock_available()
	)
	game.advance(simulation_delta)
	ui_elapsed += delta
	autosave_elapsed += delta
	if ui_elapsed >= 0.20:
		ui_elapsed = 0.0
		_refresh_interface()
	if autosave_elapsed >= 10.0 and not development_session:
		autosave_elapsed = 0.0
		game.save_game()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and game != null:
		if not development_session:
			game.save_game()
		get_tree().quit()
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_web_build and game != null:
		web_backgrounded_at = Time.get_unix_time_from_system()
		if not development_session:
			game.save_game()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN and is_web_build and game != null:
		var now := Time.get_unix_time_from_system()
		# Returning to a long-running idle tab is the most useful time to ask the
		# service worker whether a newer release has landed.
		web_update_check_elapsed = WEB_UPDATE_CHECK_INTERVAL
		if web_backgrounded_at > 0.0:
			_apply_browser_offline_catchup(maxf(now - web_backgrounded_at, 0.0))
		web_backgrounded_at = 0.0
		web_last_wall_clock = now

func _configure_platform_ui() -> void:
	if not is_web_build:
		return
	web_storage_persistent = OS.is_userfs_persistent()
	if not JavaScriptBridge.pwa_update_available.is_connected(_on_browser_update_available):
		JavaScriptBridge.pwa_update_available.connect(_on_browser_update_available)
	if JavaScriptBridge.pwa_needs_update():
		_on_browser_update_available()
	header_subtitle.text = "A BASEBALL IDLE GAME ABOUT A VERY SLOW PITCH  •  BROWSER BUILD"
	var storage_note := (
		"Progress is stored in this browser. EXPORT creates a portable backup."
		if web_storage_persistent
		else "This browser is not providing persistent storage. EXPORT a backup before leaving."
	)
	save_button.tooltip_text = storage_note
	export_save_button.tooltip_text = "Download a portable JSON backup of this run."
	load_save_button.tooltip_text = "Choose a portable JSON backup to replace the current run."
	save_label.tooltip_text = storage_note

func _update_browser_release_status(delta: float) -> void:
	web_update_status_elapsed += delta
	web_update_check_elapsed += delta
	if web_update_status_elapsed >= 1.0:
		web_update_status_elapsed = 0.0
		if JavaScriptBridge.pwa_needs_update():
			_on_browser_update_available()
		elif web_update_ready:
			web_update_ready = false
			update_banner.visible = false
	if web_update_check_elapsed >= WEB_UPDATE_CHECK_INTERVAL:
		web_update_check_elapsed = 0.0
		# Browsers eventually check service workers themselves, but an idle game can
		# remain open for days. Ask for a lightweight update check every five minutes.
		JavaScriptBridge.eval(
			"if ('serviceWorker' in navigator) { navigator.serviceWorker.getRegistration().then(function (registration) { if (registration) { registration.update(); } }).catch(function () {}); }",
			true
		)
	if (
		web_update_ready
		and not update_banner.visible
		and Time.get_unix_time_from_system() >= web_update_snoozed_until
	):
		update_banner.visible = true
		update_banner.move_to_front()

func _on_browser_update_available() -> void:
	if not is_web_build:
		return
	web_update_ready = true
	if Time.get_unix_time_from_system() >= web_update_snoozed_until:
		update_banner.visible = true
		update_banner.move_to_front()

func _snooze_browser_update() -> void:
	web_update_snoozed_until = Time.get_unix_time_from_system() + WEB_UPDATE_SNOOZE_SECONDS
	update_banner.visible = false

func _install_browser_update() -> void:
	if not is_web_build or not JavaScriptBridge.pwa_needs_update():
		return
	update_now_button.disabled = true
	update_banner_label.text = "SAVING YOUR RUN…"
	if game != null and not development_session:
		game.save_game()
	# Web saves live in IndexedDB. Flush them before asking the service worker to
	# activate the new release and reload every open game tab.
	JavaScriptBridge.force_fs_sync()
	await get_tree().create_timer(0.35).timeout
	var update_error := JavaScriptBridge.pwa_update()
	if update_error != OK:
		update_now_button.disabled = false
		update_banner_label.text = "UPDATE READY — RELOAD THIS PAGE"
		_log_event("The browser could not activate the update automatically. Reload this page to try again.")

func _consume_browser_wall_clock(delta: float) -> float:
	if not is_web_build:
		return delta
	var now := Time.get_unix_time_from_system()
	if web_last_wall_clock <= 0.0:
		web_last_wall_clock = now
		return delta
	var wall_seconds := maxf(now - web_last_wall_clock, 0.0)
	web_last_wall_clock = now
	if wall_seconds <= maxf(delta + 1.0, 2.0):
		return delta
	var live_seconds := minf(delta, 0.25)
	_apply_browser_offline_catchup(maxf(wall_seconds - live_seconds, 0.0))
	return live_seconds

func _apply_browser_offline_catchup(seconds: float) -> void:
	if seconds < 1.0 or game == null:
		return
	var summary := game.simulate_offline(seconds)
	if pitch_field != null:
		pitch_field.reset_visual_state()
	if not summary.is_empty():
		_log_offline_summary(summary, "Browser catch-up")
	_refresh_interface()
	if not development_session:
		game.save_game()

func _log_offline_summary(summary: Dictionary, prefix: String) -> void:
	var loot_note := ""
	if int(summary.get("loot_found", 0)) > 0:
		loot_note = " Locker parcels: %d found, %d kept, %d cleared by slot limits." % [
			int(summary.get("loot_found", 0)),
			int(summary.get("loot_kept", 0)),
			int(summary.get("loot_discarded", 0)),
		]
	_log_event(
		"%s — %s produced %s pitches and %s XP.%s"
		% [
			prefix,
			BaseballGameState.format_duration(float(summary.get("offline_seconds", 0.0))),
			BaseballGameState.format_number(float(summary.get("pitches", 0.0))),
			BaseballGameState.format_number(float(summary.get("earned_xp", 0.0))),
			loot_note,
		]
	)

func _apply_development_arguments() -> void:
	var arguments := OS.get_cmdline_user_args()
	if "--fresh" in arguments:
		development_session = true
		game.reset_fresh()
	var preview := ""
	if "--alien-preview" in arguments:
		preview = "alien"
	elif "--eldritch-preview" in arguments:
		preview = "eldritch"
	elif "--stress-render" in arguments:
		preview = "final"
	if preview.is_empty():
		return
	development_session = true
	game.reset_fresh()
	game.highest_unlocked = 34 if preview == "alien" else (43 if preview == "eldritch" else 44)
	game.current_opponent = 33 if preview == "alien" else game.highest_unlocked
	game._reset_batter_identity()
	game.genetic_offer_unlocked = true
	game.genetic_rebirths = 1
	game.eldritch_offer_unlocked = preview != "alien"
	game.eldritch_ascensions = 1 if preview != "alien" else 0
	game.training_levels = {
		"velocity": 180 if preview == "alien" else 315,
		"command": 385 if preview == "alien" else 730,
		"recovery": 26,
		"turnover": 10,
		"hit_recovery": 8,
		"pitch_calling": 12,
		"distance_control": 20,
	}
	for definition in Content.GENETIC_UPGRADES:
		game.genetic_levels[definition.id] = mini(int(definition.max_level), 2) if preview == "alien" else int(definition.max_level)
	if preview != "alien":
		for definition in Content.ELDRITCH_UPGRADES:
			game.eldritch_levels[definition.id] = mini(int(definition.max_level), 3) if preview == "eldritch" else int(definition.max_level)
	game.selected_distance_index = game.get_max_distance_index()
	if preview == "alien":
		game.selected_distance_index = 9
	for definition in Content.PITCHES:
		if int(definition.required_level) <= game.highest_unlocked and str(definition.id) not in game.unlocked_pitches:
			game.unlocked_pitches.append(str(definition.id))
	for definition in Content.BALL_UPGRADES:
		if int(definition.required_level) <= game.highest_unlocked:
			game.purchased_ball_upgrades.append(str(definition.id))
	for definition in Content.MILESTONES:
		if int(definition.required_level) <= game.highest_unlocked:
			game.purchased_milestones.append(str(definition.id))
	game.xp = 1.0e40
	_log_event("%s preview active; this session will not overwrite your save." % preview.capitalize())

func _build_theme() -> Theme:
	var result := Theme.new()
	result.default_font_size = 18
	result.set_color("font_color", "Label", COLOR_TEXT)
	result.set_color("font_color", "Button", COLOR_TEXT)
	result.set_color("font_hover_color", "Button", Color.WHITE)
	result.set_color("font_pressed_color", "Button", COLOR_ACCENT)
	result.set_color("font_disabled_color", "Button", Color(COLOR_MUTED, 0.52))
	result.set_color("font_color", "TabBar", COLOR_TEXT)
	result.set_color("font_selected_color", "TabBar", COLOR_ACCENT)
	result.set_color("font_unselected_color", "TabBar", COLOR_MUTED)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = COLOR_PANEL
	panel_style.border_color = Color("263750")
	panel_style.set_border_width_all(1)
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel_style.content_margin_left = 12.0
	panel_style.content_margin_right = 12.0
	panel_style.content_margin_top = 10.0
	panel_style.content_margin_bottom = 10.0
	result.set_stylebox("panel", "PanelContainer", panel_style)

	var button_normal := StyleBoxFlat.new()
	button_normal.bg_color = COLOR_PANEL_ALT
	button_normal.border_color = Color("2c405c")
	button_normal.set_border_width_all(1)
	button_normal.corner_radius_top_left = 6
	button_normal.corner_radius_top_right = 6
	button_normal.corner_radius_bottom_left = 6
	button_normal.corner_radius_bottom_right = 6
	button_normal.content_margin_left = 12.0
	button_normal.content_margin_right = 12.0
	button_normal.content_margin_top = 9.0
	button_normal.content_margin_bottom = 9.0
	var button_hover := button_normal.duplicate()
	button_hover.bg_color = Color("1b3048")
	button_hover.border_color = COLOR_ACCENT
	var button_pressed := button_normal.duplicate()
	button_pressed.bg_color = Color("19394b")
	button_pressed.border_color = COLOR_ACCENT
	var button_disabled := button_normal.duplicate()
	button_disabled.bg_color = Color("0c121d")
	button_disabled.border_color = Color("1d2939")
	result.set_stylebox("normal", "Button", button_normal)
	result.set_stylebox("hover", "Button", button_hover)
	result.set_stylebox("pressed", "Button", button_pressed)
	result.set_stylebox("disabled", "Button", button_disabled)

	var progress_background := StyleBoxFlat.new()
	progress_background.bg_color = Color("09101a")
	progress_background.corner_radius_top_left = 4
	progress_background.corner_radius_top_right = 4
	progress_background.corner_radius_bottom_left = 4
	progress_background.corner_radius_bottom_right = 4
	var progress_fill := StyleBoxFlat.new()
	progress_fill.bg_color = COLOR_ACCENT
	progress_fill.corner_radius_top_left = 4
	progress_fill.corner_radius_top_right = 4
	progress_fill.corner_radius_bottom_left = 4
	progress_fill.corner_radius_bottom_right = 4
	result.set_stylebox("background", "ProgressBar", progress_background)
	result.set_stylebox("fill", "ProgressBar", progress_fill)
	return result

func _build_interface() -> void:
	var background := ColorRect.new()
	background.color = COLOR_BG
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	move_child(background, 0)

	root_margin = MarginContainer.new()
	root_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", 14)
	root_margin.add_theme_constant_override("margin_right", 14)
	root_margin.add_theme_constant_override("margin_top", 12)
	root_margin.add_theme_constant_override("margin_bottom", 12)
	add_child(root_margin)

	page_container = VBoxContainer.new()
	page_container.add_theme_constant_override("separation", 10)
	root_margin.add_child(page_container)
	_build_header(page_container)

	body_container = HBoxContainer.new()
	body_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_container.add_theme_constant_override("separation", 10)
	page_container.add_child(body_container)
	_build_play_area(body_container)
	_build_upgrade_area(body_container)
	_build_mobile_navigation(page_container)
	_build_event_log(page_container)
	_build_mobile_overlay()
	_build_confirmation_dialog()
	_build_update_banner()

func _build_update_banner() -> void:
	update_banner = PanelContainer.new()
	update_banner.name = "BrowserUpdateBanner"
	update_banner.visible = false
	update_banner.z_index = 300
	update_banner.mouse_filter = Control.MOUSE_FILTER_STOP
	update_banner.set_anchors_preset(Control.PRESET_CENTER_TOP)
	update_banner.offset_left = -280.0
	update_banner.offset_top = 10.0
	update_banner.offset_right = 280.0
	update_banner.offset_bottom = 66.0
	add_child(update_banner)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	update_banner.add_child(row)
	update_banner_label = Label.new()
	update_banner_label.text = "NEW VERSION READY"
	update_banner_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	update_banner_label.add_theme_color_override("font_color", COLOR_GOOD)
	update_banner_label.add_theme_font_size_override("font_size", 13)
	row.add_child(update_banner_label)
	update_now_button = Button.new()
	update_now_button.text = "SAVE & UPDATE"
	update_now_button.tooltip_text = "Save this run, install the newest browser build, and reload."
	update_now_button.pressed.connect(_install_browser_update)
	row.add_child(update_now_button)
	update_later_button = Button.new()
	update_later_button.text = "LATER"
	update_later_button.tooltip_text = "Hide this reminder for ten minutes."
	update_later_button.pressed.connect(_snooze_browser_update)
	row.add_child(update_later_button)

func _build_header(parent: Control) -> void:
	header_panel = PanelContainer.new()
	parent.add_child(header_panel)
	header_row = HBoxContainer.new()
	header_row.add_theme_constant_override("separation", 20)
	header_panel.add_child(header_row)
	header_title_stack = VBoxContainer.new()
	header_row.add_child(header_title_stack)
	header_title = Label.new()
	header_title.text = "ONE FOOT PER SECOND"
	header_title.add_theme_font_size_override("font_size", 27)
	header_title.add_theme_color_override("font_color", COLOR_ACCENT)
	header_title_stack.add_child(header_title)
	header_subtitle = Label.new()
	header_subtitle.text = "A BASEBALL IDLE GAME ABOUT A VERY SLOW PITCH"
	header_subtitle.add_theme_font_size_override("font_size", 13)
	header_subtitle.add_theme_color_override("font_color", COLOR_MUTED)
	header_title_stack.add_child(header_subtitle)
	header_spacer = Control.new()
	header_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(header_spacer)
	xp_label = _header_metric(header_row, "XP", "0.00")
	rate_label = _header_metric(header_row, "XP / SECOND", "0.00")
	rings_label = _header_metric(header_row, "DNA • ARCANA", "D0 • A0")
	prestige_header_stack = rings_label.get_parent() as VBoxContainer
	prestige_header_heading = prestige_header_stack.get_child(0) as Label
	save_stack = VBoxContainer.new()
	header_row.add_child(save_stack)
	save_button = Button.new()
	save_button.text = "SAVE"
	save_button.custom_minimum_size = Vector2(78.0, 34.0)
	save_button.pressed.connect(_save_now)
	save_stack.add_child(save_button)
	var transfer_row := HBoxContainer.new()
	transfer_row.add_theme_constant_override("separation", 4)
	save_stack.add_child(transfer_row)
	export_save_button = Button.new()
	export_save_button.text = "EXPORT"
	export_save_button.custom_minimum_size = Vector2(54.0, 26.0)
	export_save_button.add_theme_font_size_override("font_size", 10)
	export_save_button.tooltip_text = "Write a portable JSON backup of this run."
	export_save_button.pressed.connect(_request_export_save)
	transfer_row.add_child(export_save_button)
	load_save_button = Button.new()
	load_save_button.text = "LOAD"
	load_save_button.custom_minimum_size = Vector2(54.0, 26.0)
	load_save_button.add_theme_font_size_override("font_size", 10)
	load_save_button.tooltip_text = "Load a portable JSON backup after confirmation."
	load_save_button.pressed.connect(_request_load_save)
	transfer_row.add_child(load_save_button)
	hard_reset_button = Button.new()
	hard_reset_button.text = "RESET PROGRESS"
	hard_reset_button.custom_minimum_size = Vector2(112.0, 28.0)
	hard_reset_button.add_theme_font_size_override("font_size", 11)
	hard_reset_button.tooltip_text = "Permanently erase this save. Requires typing RESET in a confirmation window."
	hard_reset_button.pressed.connect(_request_hard_reset)
	save_stack.add_child(hard_reset_button)
	save_label = Label.new()
	save_label.text = "autosave on"
	save_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	save_label.add_theme_font_size_override("font_size", 12)
	save_label.add_theme_color_override("font_color", COLOR_MUTED)
	save_stack.add_child(save_label)

func _header_metric(parent: Control, heading: String, value: String) -> Label:
	var stack := VBoxContainer.new()
	stack.custom_minimum_size.x = 126.0
	parent.add_child(stack)
	header_metric_stacks.append(stack)
	var heading_label := Label.new()
	heading_label.text = heading
	heading_label.add_theme_font_size_override("font_size", 12)
	heading_label.add_theme_color_override("font_color", COLOR_MUTED)
	heading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	stack.add_child(heading_label)
	header_metric_headings.append(heading_label)
	var value_label := Label.new()
	value_label.text = value
	value_label.add_theme_font_size_override("font_size", 21)
	value_label.add_theme_color_override("font_color", COLOR_GOLD)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	stack.add_child(value_label)
	return value_label

func _build_mobile_navigation(parent: Control) -> void:
	mobile_nav = HBoxContainer.new()
	mobile_nav.name = "MobileNavigation"
	mobile_nav.visible = false
	mobile_nav.add_theme_constant_override("separation", 4)
	parent.add_child(mobile_nav)
	var entries := [
		["UPGRADES", "Upgrades", func() -> void: _show_mobile_overlay(upgrade_panel, "UPGRADES")],
		["LOADOUT", "Current ball, pitches, body, and facilities", func() -> void: _show_mobile_overlay(equipment_sidebar, "LOADOUT")],
		["LOG", "Recent game events", func() -> void: _show_mobile_overlay(event_log_panel, "EVENT LOG")],
		["SAVE", "Save, export, load, or reset this run", func() -> void: _show_mobile_overlay(save_stack, "SAVE & TRANSFER")],
	]
	for entry in entries:
		var button := Button.new()
		button.name = "Mobile%sButton" % str(entry[0]).capitalize()
		button.text = str(entry[0])
		button.tooltip_text = str(entry[1])
		button.custom_minimum_size.y = 44.0
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override("font_size", 10)
		button.pressed.connect(entry[2])
		mobile_nav.add_child(button)

func _build_mobile_overlay() -> void:
	mobile_overlay_panel = Control.new()
	mobile_overlay_panel.name = "MobileOverlay"
	mobile_overlay_panel.visible = false
	mobile_overlay_panel.z_index = 200
	mobile_overlay_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	mobile_overlay_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(mobile_overlay_panel)

	var dimmer := ColorRect.new()
	dimmer.color = Color(0.01, 0.02, 0.04, 0.92)
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mobile_overlay_panel.add_child(dimmer)

	mobile_overlay_surface = PanelContainer.new()
	mobile_overlay_surface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mobile_overlay_surface.offset_left = 5.0
	mobile_overlay_surface.offset_top = 5.0
	mobile_overlay_surface.offset_right = -5.0
	mobile_overlay_surface.offset_bottom = -5.0
	mobile_overlay_panel.add_child(mobile_overlay_surface)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 7)
	margin.add_theme_constant_override("margin_bottom", 7)
	mobile_overlay_surface.add_child(margin)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 7)
	margin.add_child(stack)
	var heading_row := HBoxContainer.new()
	stack.add_child(heading_row)
	mobile_overlay_title = Label.new()
	mobile_overlay_title.text = "MENU"
	mobile_overlay_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mobile_overlay_title.add_theme_font_size_override("font_size", 17)
	mobile_overlay_title.add_theme_color_override("font_color", COLOR_ACCENT)
	heading_row.add_child(mobile_overlay_title)
	var close_button := Button.new()
	close_button.name = "MobileOverlayCloseButton"
	close_button.text = "CLOSE  ×"
	close_button.custom_minimum_size = Vector2(88.0, 42.0)
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.pressed.connect(_close_mobile_overlay)
	heading_row.add_child(close_button)
	mobile_overlay_content = VBoxContainer.new()
	mobile_overlay_content.name = "MobileOverlayContent"
	mobile_overlay_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mobile_overlay_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(mobile_overlay_content)

func _show_mobile_overlay(control: Control, title: String) -> void:
	if not mobile_layout or control == null:
		return
	if mobile_overlay_control != null:
		_close_mobile_overlay()
	mobile_overlay_control = control
	mobile_overlay_home = control.get_parent() as Control
	mobile_overlay_home_index = control.get_index()
	control.reparent(mobile_overlay_content)
	control.visible = true
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	control.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if control == upgrade_panel:
		upgrade_panel.custom_minimum_size.x = 0.0
	if control == equipment_sidebar:
		equipment_sidebar.custom_minimum_size.x = 0.0
	mobile_overlay_title.text = title
	mobile_overlay_panel.visible = true
	mobile_overlay_panel.move_to_front()

func _close_mobile_overlay() -> void:
	if mobile_overlay_control != null and is_instance_valid(mobile_overlay_control):
		var control := mobile_overlay_control
		if mobile_overlay_home != null and is_instance_valid(mobile_overlay_home):
			control.reparent(mobile_overlay_home)
			mobile_overlay_home.move_child(
				control,
				clampi(mobile_overlay_home_index, 0, maxi(mobile_overlay_home.get_child_count() - 1, 0))
			)
		if control == upgrade_panel:
			control.size_flags_horizontal = Control.SIZE_FILL
		elif control == equipment_sidebar:
			control.size_flags_horizontal = Control.SIZE_FILL
		elif control == event_log_panel:
			control.size_flags_vertical = Control.SIZE_FILL
		elif control == save_stack:
			control.size_flags_horizontal = Control.SIZE_FILL
			control.size_flags_vertical = Control.SIZE_FILL
		control.visible = not mobile_layout
	mobile_overlay_control = null
	mobile_overlay_home = null
	mobile_overlay_home_index = -1
	if mobile_overlay_panel != null:
		mobile_overlay_panel.visible = false

func _on_root_resized() -> void:
	if is_web_build:
		_sync_browser_content_scale()
	call_deferred("_apply_responsive_layout")

func _sync_browser_content_scale(reported_scale := -1.0) -> void:
	if not is_web_build:
		return
	var display_scale := reported_scale
	if display_scale <= 0.0:
		display_scale = DisplayServer.screen_get_scale()
	if display_scale <= 0.0:
		var browser_ratio = JavaScriptBridge.eval("window.devicePixelRatio || 1", true)
		if browser_ratio != null:
			display_scale = float(browser_ratio)
	display_scale = _normalize_browser_content_scale(display_scale)
	if not is_equal_approx(get_window().content_scale_factor, display_scale):
		get_window().content_scale_factor = display_scale

func _normalize_browser_content_scale(reported_scale: float) -> float:
	return clampf(reported_scale, 1.0, 4.0)

func _get_responsive_viewport_size() -> Vector2:
	var viewport_size := get_viewport_rect().size
	if not is_web_build:
		return viewport_size
	var css_width = JavaScriptBridge.eval("window.innerWidth", true)
	var css_height = JavaScriptBridge.eval("window.innerHeight", true)
	if css_width != null and css_height != null:
		var browser_size := Vector2(float(css_width), float(css_height))
		if browser_size.x > 0.0 and browser_size.y > 0.0:
			return browser_size
	return viewport_size

func _apply_responsive_layout() -> void:
	if pitch_field == null:
		return
	var viewport_size := _get_responsive_viewport_size()
	var portrait := viewport_size.y > viewport_size.x * 1.08
	var should_use_mobile := is_web_build and (
		portrait or minf(viewport_size.x, viewport_size.y) < 720.0
	)
	_set_mobile_layout(should_use_mobile, portrait)

func _set_mobile_layout(enabled: bool, portrait := true) -> void:
	var layout_changed := enabled != mobile_layout
	var portrait_changed := enabled and portrait != mobile_portrait_layout
	if not layout_changed and not portrait_changed:
		return
	if not enabled:
		mobile_layout = false
		mobile_portrait_layout = false
		_close_mobile_overlay()
	else:
		mobile_layout = true
		mobile_portrait_layout = portrait
		_close_mobile_overlay()

	root_margin.add_theme_constant_override("margin_left", 5 if mobile_layout else 14)
	root_margin.add_theme_constant_override("margin_right", 5 if mobile_layout else 14)
	root_margin.add_theme_constant_override("margin_top", 5 if mobile_layout else 12)
	root_margin.add_theme_constant_override("margin_bottom", 5 if mobile_layout else 12)
	update_banner.offset_left = -185.0 if mobile_layout else -280.0
	update_banner.offset_right = 185.0 if mobile_layout else 280.0
	update_banner.offset_top = 5.0 if mobile_layout else 10.0
	update_banner.offset_bottom = 61.0 if mobile_layout else 66.0
	update_banner_label.add_theme_font_size_override("font_size", 11 if mobile_layout else 13)
	if not update_now_button.disabled:
		update_banner_label.text = "UPDATE READY" if mobile_layout else "NEW VERSION READY"
	update_now_button.text = "UPDATE" if mobile_layout else "SAVE & UPDATE"
	update_now_button.add_theme_font_size_override("font_size", 10 if mobile_layout else 16)
	update_later_button.add_theme_font_size_override("font_size", 10 if mobile_layout else 16)
	page_container.add_theme_constant_override("separation", 4 if mobile_layout else 10)
	body_container.add_theme_constant_override("separation", 0 if mobile_layout else 10)
	header_row.add_theme_constant_override("separation", 7 if mobile_layout else 20)
	header_title.add_theme_font_size_override("font_size", 17 if mobile_layout else 27)
	header_subtitle.visible = not mobile_layout
	for index in header_metric_stacks.size():
		header_metric_stacks[index].custom_minimum_size.x = 64.0 if mobile_layout else 126.0
		header_metric_headings[index].add_theme_font_size_override("font_size", 9 if mobile_layout else 12)
		var value_label := header_metric_stacks[index].get_child(1) as Label
		value_label.add_theme_font_size_override("font_size", 15 if mobile_layout else 21)
	if header_metric_headings.size() >= 3:
		header_metric_headings[1].text = "XP / S" if mobile_layout else "XP / SECOND"
		header_metric_headings[2].text = "DNA • ARCANA"
	prestige_header_stack.visible = _has_genetic_reveal() and not mobile_layout
	save_stack.visible = not mobile_layout
	mobile_nav.visible = mobile_layout
	upgrade_panel.visible = not mobile_layout
	equipment_sidebar.visible = not mobile_layout
	event_log_panel.visible = not mobile_layout
	upgrade_panel.custom_minimum_size.x = 0.0 if mobile_layout else 360.0
	equipment_sidebar.custom_minimum_size.x = 0.0 if mobile_layout else 215.0
	upgrade_tabs.get_tab_bar().add_theme_font_size_override("font_size", 11 if mobile_layout else 8)
	play_stack.add_theme_constant_override("separation", 4 if mobile_layout else 8)
	opponent_row.add_theme_constant_override("separation", 5 if mobile_layout else 12)
	previous_button.custom_minimum_size.x = 42.0 if mobile_layout else 140.0
	next_button.custom_minimum_size.x = 42.0 if mobile_layout else 140.0
	previous_button.text = "‹" if mobile_layout else "‹ PREVIOUS BATTER"
	if mobile_layout:
		next_button.text = "›"
	opponent_label.add_theme_font_size_override("font_size", 18 if mobile_layout else 25)
	quirk_label.add_theme_font_size_override("font_size", 11 if mobile_layout else 14)
	era_label.add_theme_font_size_override("font_size", 10 if mobile_layout else 13)
	distance_label.add_theme_font_size_override("font_size", 11 if mobile_layout else 13)
	field_stack.add_theme_constant_override("separation", 4 if mobile_layout else 7)
	pitch_field.custom_minimum_size = Vector2(0.0, 320.0) if mobile_layout else Vector2(450.0, 360.0)
	pitch_field.set_portrait_layout(mobile_layout and mobile_portrait_layout)
	visual_weight_label.visible = not mobile_layout
	last_result_label.add_theme_font_size_override("font_size", 12 if mobile_layout else 18)
	mastery_label.add_theme_font_size_override("font_size", 11 if mobile_layout else 13)
	outcomes_grid.columns = 4 if mobile_layout else Content.OUTCOME_NAMES.size()
	for index in outcome_panels.size():
		outcome_name_labels[index].add_theme_font_size_override("font_size", 9 if mobile_layout else 11)
		outcome_probability_labels[index].add_theme_font_size_override("font_size", 13 if mobile_layout else 16)
		outcome_delay_labels[index].add_theme_font_size_override("font_size", 9 if mobile_layout else 10)
	strikeout_payout_label.add_theme_font_size_override("font_size", 10 if mobile_layout else 11)
	field_stat_panel.offset_left = 6.0 if mobile_layout else 10.0
	field_stat_panel.offset_top = 6.0 if mobile_layout else 10.0
	# The phone readout only needs enough room for a short label and value. Keeping
	# it clear of the centered pitcher matters more than preserving desktop width.
	field_stat_panel.offset_right = 138.0 if mobile_layout else 252.0
	field_stat_panel.offset_bottom = 150.0 if mobile_layout else 176.0
	inventory_dock.offset_left = -248.0 if mobile_layout else -310.0
	inventory_dock.offset_top = -40.0 if mobile_layout else -48.0
	for slot_button_value in inventory_slot_buttons.values():
		var slot_button := slot_button_value as Button
		slot_button.custom_minimum_size = Vector2(30.0, 30.0) if mobile_layout else Vector2(38.0, 38.0)
		slot_button.add_theme_font_size_override("font_size", 12 if mobile_layout else 15)
	opponent_loadout_dock.offset_left = -40.0 if mobile_layout else -46.0
	opponent_loadout_dock.offset_top = 44.0 if mobile_layout else 54.0
	opponent_loadout_dock.offset_bottom = 300.0 if mobile_layout else 354.0
	locker_slot_grid.columns = 4 if mobile_layout else Content.LOOT_SLOTS.size()
	root_margin.queue_sort()
	_refresh_interface()

func _build_play_area(parent: Control) -> void:
	play_panel = PanelContainer.new()
	play_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	play_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	play_panel.size_flags_stretch_ratio = 1.85
	parent.add_child(play_panel)
	play_stack = VBoxContainer.new()
	play_stack.add_theme_constant_override("separation", 8)
	play_panel.add_child(play_stack)

	era_label = Label.new()
	era_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	era_label.add_theme_font_size_override("font_size", 13)
	era_label.add_theme_color_override("font_color", COLOR_ACCENT)
	play_stack.add_child(era_label)

	opponent_row = HBoxContainer.new()
	opponent_row.add_theme_constant_override("separation", 12)
	play_stack.add_child(opponent_row)
	previous_button = Button.new()
	previous_button.text = "‹ PREVIOUS BATTER"
	previous_button.custom_minimum_size.x = 140.0
	previous_button.pressed.connect(_previous_opponent)
	opponent_row.add_child(previous_button)
	opponent_stack = VBoxContainer.new()
	opponent_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	opponent_row.add_child(opponent_stack)
	opponent_label = Label.new()
	opponent_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	opponent_label.add_theme_font_size_override("font_size", 25)
	opponent_label.add_theme_color_override("font_color", Color.WHITE)
	opponent_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	opponent_stack.add_child(opponent_label)
	quirk_label = Label.new()
	quirk_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quirk_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quirk_label.add_theme_font_size_override("font_size", 14)
	quirk_label.add_theme_color_override("font_color", COLOR_MUTED)
	opponent_stack.add_child(quirk_label)
	next_button = Button.new()
	next_button.text = "NEXT BATTER ›"
	next_button.custom_minimum_size.x = 140.0
	next_button.pressed.connect(_next_opponent)
	opponent_row.add_child(next_button)

	_build_distance_status(play_stack)

	play_row = HBoxContainer.new()
	play_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	play_row.add_theme_constant_override("separation", 8)
	play_stack.add_child(play_row)
	_build_equipment_sidebar(play_row)
	field_stack = VBoxContainer.new()
	field_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	field_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	field_stack.add_theme_constant_override("separation", 7)
	play_row.add_child(field_stack)

	pitch_field = PitchFieldScript.new()
	# Let the field advance its visual clock before this parent advances the
	# authoritative simulation. Batch event offsets are relative to the end of
	# the current frame; this ordering prevents that delta from being applied to
	# newly spawned balls and batter results a second time.
	pitch_field.process_priority = -10
	pitch_field.custom_minimum_size = Vector2(450.0, 360.0)
	pitch_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pitch_field.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pitch_field.move_closer_requested.connect(_move_closer)
	pitch_field.move_farther_requested.connect(_move_farther)
	pitch_field.batter_call_displayed.connect(_on_batter_call_displayed)
	field_stack.add_child(pitch_field)
	_build_field_stat_overlay(pitch_field)
	_build_inventory_dock(pitch_field)
	_build_opponent_loadout_dock(pitch_field)

	field_footer = HBoxContainer.new()
	field_stack.add_child(field_footer)
	last_result_label = Label.new()
	last_result_label.text = "Waiting for the first pitch…"
	last_result_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	last_result_label.add_theme_color_override("font_color", COLOR_TEXT)
	field_footer.add_child(last_result_label)
	visual_weight_label = Label.new()
	visual_weight_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	visual_weight_label.add_theme_color_override("font_color", COLOR_MUTED)
	# Keep this compact status on one line. Allowing it to wrap gave the HBox a
	# near-zero minimum width, so tab-driven relayouts could collapse it into a
	# vertical column of individual letters beside the field.
	visual_weight_label.custom_minimum_size.x = 245.0
	visual_weight_label.add_theme_font_size_override("font_size", 12)
	visual_weight_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	field_footer.add_child(visual_weight_label)

	mastery_label = Label.new()
	mastery_label.add_theme_font_size_override("font_size", 13)
	mastery_label.add_theme_color_override("font_color", COLOR_MUTED)
	mastery_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	field_stack.add_child(mastery_label)
	mastery_bar = ProgressBar.new()
	mastery_bar.min_value = 0.0
	mastery_bar.max_value = 100.0
	mastery_bar.show_percentage = false
	mastery_bar.custom_minimum_size.y = 10.0
	field_stack.add_child(mastery_bar)

	outcomes_grid = GridContainer.new()
	outcomes_grid.columns = Content.OUTCOME_NAMES.size()
	outcomes_grid.add_theme_constant_override("h_separation", 5)
	outcomes_grid.add_theme_constant_override("v_separation", 5)
	field_stack.add_child(outcomes_grid)
	for index in Content.OUTCOME_NAMES.size():
		var outcome_panel := PanelContainer.new()
		outcome_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		outcomes_grid.add_child(outcome_panel)
		outcome_panels.append(outcome_panel)
		var outcome_stack := VBoxContainer.new()
		outcome_panel.add_child(outcome_stack)
		var name_label := Label.new()
		name_label.text = str(Content.OUTCOME_NAMES[index])
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size", 11)
		name_label.add_theme_color_override("font_color", Content.OUTCOME_COLORS[index])
		outcome_stack.add_child(name_label)
		outcome_name_labels.append(name_label)
		var probability_label := Label.new()
		probability_label.text = "0.00%"
		probability_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		probability_label.add_theme_font_size_override("font_size", 16)
		outcome_stack.add_child(probability_label)
		outcome_probability_labels.append(probability_label)
		var delay_label := Label.new()
		delay_label.text = "+0s"
		delay_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		delay_label.add_theme_font_size_override("font_size", 10)
		delay_label.add_theme_color_override("font_color", COLOR_MUTED)
		outcome_stack.add_child(delay_label)
		outcome_delay_labels.append(delay_label)
	strikeout_payout_label = Label.new()
	strikeout_payout_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	strikeout_payout_label.add_theme_font_size_override("font_size", 11)
	strikeout_payout_label.add_theme_color_override("font_color", COLOR_MUTED)
	field_stack.add_child(strikeout_payout_label)

func _build_distance_status(parent: Control) -> void:
	distance_label = Label.new()
	distance_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	distance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	distance_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	distance_label.add_theme_font_size_override("font_size", 13)
	distance_label.add_theme_color_override("font_color", COLOR_GOLD)
	parent.add_child(distance_label)

func _build_equipment_sidebar(parent: Control) -> void:
	equipment_sidebar = ScrollContainer.new()
	equipment_sidebar.custom_minimum_size.x = 215.0
	equipment_sidebar.size_flags_horizontal = Control.SIZE_FILL
	equipment_sidebar.size_flags_vertical = Control.SIZE_EXPAND_FILL
	equipment_sidebar.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	parent.add_child(equipment_sidebar)
	var sidebar := VBoxContainer.new()
	sidebar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sidebar.add_theme_constant_override("separation", 6)
	equipment_sidebar.add_child(sidebar)
	var heading := Label.new()
	heading.text = "CURRENT UPGRADABLE LOADOUT"
	heading.add_theme_font_size_override("font_size", 12)
	heading.add_theme_color_override("font_color", COLOR_ACCENT)
	sidebar.add_child(heading)
	_equipment_card(sidebar, "ball", "CURRENT BALL")
	_equipment_card(sidebar, "pitch", "PITCH ARSENAL")
	_equipment_card(sidebar, "body", "BODY")
	equipment_progression_heading = Label.new()
	equipment_progression_heading.text = "OWNED FACILITIES"
	equipment_progression_heading.add_theme_font_size_override("font_size", 11)
	equipment_progression_heading.add_theme_color_override("font_color", COLOR_ACCENT)
	sidebar.add_child(equipment_progression_heading)
	equipment_summary_label = Label.new()
	equipment_summary_label.add_theme_font_size_override("font_size", 12)
	equipment_summary_label.add_theme_color_override("font_color", COLOR_MUTED)
	equipment_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sidebar.add_child(equipment_summary_label)

func _build_inventory_dock(parent: Control) -> void:
	inventory_dock = HBoxContainer.new()
	inventory_dock.name = "EquipmentDock"
	inventory_dock.z_index = 40
	inventory_dock.mouse_filter = Control.MOUSE_FILTER_STOP
	inventory_dock.set_anchor(SIDE_LEFT, 1.0)
	inventory_dock.set_anchor(SIDE_TOP, 1.0)
	inventory_dock.set_anchor(SIDE_RIGHT, 1.0)
	inventory_dock.set_anchor(SIDE_BOTTOM, 1.0)
	inventory_dock.offset_left = -310.0
	inventory_dock.offset_top = -48.0
	inventory_dock.offset_right = -8.0
	inventory_dock.offset_bottom = -8.0
	inventory_dock.add_theme_constant_override("separation", 4)
	parent.add_child(inventory_dock)
	for definition in Content.LOOT_SLOTS:
		var slot := str(definition.id)
		var button := Button.new()
		button.name = "Equipment_%s" % slot
		button.custom_minimum_size = Vector2(38.0, 38.0)
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override("font_size", 15)
		button.pressed.connect(_open_locker.bind(slot))
		inventory_dock.add_child(button)
		inventory_slot_buttons[slot] = button

func _build_field_stat_overlay(parent: Control) -> void:
	field_stat_panel = PanelContainer.new()
	field_stat_panel.name = "FieldStatOverlay"
	field_stat_panel.z_index = 40
	field_stat_panel.set_anchor(SIDE_LEFT, 0.0)
	field_stat_panel.set_anchor(SIDE_TOP, 0.0)
	field_stat_panel.set_anchor(SIDE_RIGHT, 0.0)
	field_stat_panel.set_anchor(SIDE_BOTTOM, 0.0)
	field_stat_panel.offset_left = 10.0
	field_stat_panel.offset_top = 10.0
	field_stat_panel.offset_right = 252.0
	field_stat_panel.offset_bottom = 176.0
	field_stat_panel.modulate = Color(1.0, 1.0, 1.0, 0.88)
	parent.add_child(field_stat_panel)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 1)
	field_stat_panel.add_child(stack)
	var heading := Label.new()
	heading.text = "LIVE THROW PROFILE"
	heading.add_theme_font_size_override("font_size", 10)
	heading.add_theme_color_override("font_color", COLOR_ACCENT)
	stack.add_child(heading)
	var rows := [
		["speed", "SPEED"],
		["quality", "QUALITY"],
		["recovery", "RECOVERY"],
		["lineup", "LINEUP"],
		["hit_delay", "HIT DELAY"],
		["calling", "CALLING"],
		["distance", "DISTANCE"],
	]
	for row_definition in rows:
		var stat_id := str(row_definition[0])
		var row := HBoxContainer.new()
		row.tooltip_text = str(Content.STAT_HELP.get(stat_id, ""))
		row.mouse_default_cursor_shape = Control.CURSOR_HELP
		stack.add_child(row)
		var name_label := Label.new()
		name_label.text = str(row_definition[1])
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.add_theme_font_size_override("font_size", 10)
		name_label.add_theme_color_override("font_color", COLOR_MUTED)
		name_label.tooltip_text = row.tooltip_text
		row.add_child(name_label)
		var value_label := Label.new()
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		value_label.add_theme_font_size_override("font_size", 11)
		value_label.add_theme_color_override("font_color", COLOR_TEXT)
		value_label.tooltip_text = row.tooltip_text
		row.add_child(value_label)
		field_stat_labels[stat_id] = value_label

func _build_opponent_loadout_dock(parent: Control) -> void:
	opponent_loadout_dock = VBoxContainer.new()
	opponent_loadout_dock.name = "OpponentLoadoutDock"
	opponent_loadout_dock.z_index = 40
	opponent_loadout_dock.mouse_filter = Control.MOUSE_FILTER_STOP
	opponent_loadout_dock.set_anchor(SIDE_LEFT, 1.0)
	opponent_loadout_dock.set_anchor(SIDE_TOP, 0.0)
	opponent_loadout_dock.set_anchor(SIDE_RIGHT, 1.0)
	opponent_loadout_dock.set_anchor(SIDE_BOTTOM, 0.0)
	opponent_loadout_dock.offset_left = -46.0
	opponent_loadout_dock.offset_top = 54.0
	opponent_loadout_dock.offset_right = -8.0
	opponent_loadout_dock.offset_bottom = 354.0
	opponent_loadout_dock.add_theme_constant_override("separation", 3)
	parent.add_child(opponent_loadout_dock)

func _loot_square_style(color: Color, strength: float, locked := false, equipped := false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("0a101a") if locked else COLOR_PANEL_ALT.lerp(color, minf(strength + (0.14 if equipped else 0.0), 0.82))
	style.border_color = Color("253247") if locked else (Color.WHITE.lerp(color, 0.55) if equipped else color)
	style.set_border_width_all(3 if equipped else 1)
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	style.content_margin_left = 4.0
	style.content_margin_right = 4.0
	style.content_margin_top = 4.0
	style.content_margin_bottom = 4.0
	return style

func _apply_loot_square_style(button: Button, color: Color, locked := false, equipped := false) -> void:
	button.add_theme_stylebox_override("normal", _loot_square_style(color, 0.28, locked, equipped))
	button.add_theme_stylebox_override("hover", _loot_square_style(color, 0.48, locked, equipped))
	button.add_theme_stylebox_override("pressed", _loot_square_style(color, 0.62, locked, equipped))
	button.add_theme_stylebox_override("disabled", _loot_square_style(color, 0.08, true, false))
	button.add_theme_color_override("font_color", color)
	button.add_theme_color_override("font_hover_color", Color.WHITE)

func _loot_item_row_style(color: Color, equipped: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_PANEL_ALT.lerp(color, 0.22 if equipped else 0.07)
	style.border_color = Color.WHITE.lerp(color, 0.55) if equipped else Color(color, 0.55)
	style.set_border_width_all(2 if equipped else 1)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 6.0
	style.content_margin_right = 6.0
	style.content_margin_top = 3.0
	style.content_margin_bottom = 3.0
	return style

func _build_locker_dialog() -> void:
	locker_dialog = Window.new()
	locker_dialog.name = "EquipmentWindow"
	locker_dialog.title = "STRIKEOUT EQUIPMENT"
	# A newly constructed Window may inherit a visible default before it is added
	# to the tree.  Keep the equipment browser closed until the player clicks a
	# field slot; otherwise it can cover the field on a fresh launch.
	locker_dialog.visible = false
	locker_dialog.min_size = Vector2i(800, 560)
	locker_dialog.size = Vector2i(940, 700)
	locker_dialog.transient = true
	locker_dialog.close_requested.connect(_close_locker_dialog)
	add_child(locker_dialog)
	locker_dialog.hide()

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	locker_dialog.add_child(margin)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8)
	margin.add_child(stack)
	locker_dialog_status_label = Label.new()
	locker_dialog_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	locker_dialog_status_label.add_theme_font_size_override("font_size", 13)
	stack.add_child(locker_dialog_status_label)
	locker_slot_grid = GridContainer.new()
	locker_slot_grid.columns = Content.LOOT_SLOTS.size()
	locker_slot_grid.add_theme_constant_override("h_separation", 5)
	locker_slot_grid.add_theme_constant_override("v_separation", 5)
	stack.add_child(locker_slot_grid)
	for definition in Content.LOOT_SLOTS:
		var slot := str(definition.id)
		var button := Button.new()
		button.custom_minimum_size = Vector2(54.0, 40.0)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(_select_locker_slot.bind(slot))
		locker_slot_grid.add_child(button)
		locker_dialog_slot_buttons[slot] = button
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(scroll)
	locker_dialog_items = VBoxContainer.new()
	locker_dialog_items.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	locker_dialog_items.add_theme_constant_override("separation", 5)
	scroll.add_child(locker_dialog_items)

func _close_locker_dialog() -> void:
	locker_dialog.hide()

func _open_locker(slot: String) -> void:
	if not game.is_loot_slot_unlocked(slot):
		return
	selected_loot_slot = slot
	_rebuild_locker_dialog()
	if mobile_layout:
		var viewport_size := get_viewport_rect().size
		locker_dialog.min_size = Vector2i(320, 440)
		locker_dialog.popup_centered(Vector2i(
			clampi(int(viewport_size.x) - 16, 320, 620),
			clampi(int(viewport_size.y) - 24, 440, 760)
		))
	else:
		locker_dialog.min_size = Vector2i(800, 560)
		locker_dialog.popup_centered(Vector2i(940, 700))

func _select_locker_slot(slot: String) -> void:
	if not game.is_loot_slot_unlocked(slot):
		return
	selected_loot_slot = slot
	_rebuild_locker_dialog()

func _rebuild_locker_dialog() -> void:
	if locker_dialog_items == null:
		return
	var definition := Content.loot_slot_by_id(selected_loot_slot)
	if definition.is_empty():
		selected_loot_slot = "hat"
		definition = Content.loot_slot_by_id(selected_loot_slot)
	for slot_definition in Content.LOOT_SLOTS:
		var slot := str(slot_definition.id)
		var slot_button: Button = locker_dialog_slot_buttons[slot]
		var unlocked := game.is_loot_slot_unlocked(slot)
		slot_button.text = str(slot_definition.letter) if unlocked else "?"
		slot_button.disabled = not unlocked
		var equipped := game.get_equipped_loot_item(slot)
		var color := game.get_equipped_loot_rarity_color(slot, COLOR_MUTED)
		_apply_loot_square_style(slot_button, color, not unlocked, not equipped.is_empty())
		if slot == selected_loot_slot:
			slot_button.add_theme_color_override("font_color", COLOR_GOLD)

	var items := game.get_loot_items_for_slot(selected_loot_slot)
	var equipped_item := game.get_equipped_loot_item(selected_loot_slot)
	var equipped_name := "EMPTY" if equipped_item.is_empty() else str(equipped_item.name)
	var clone_note := "100% applied"
	if game.get_equipment_inheritance_factor() < 0.999:
		clone_note = "×%.3f after clone inheritance" % game.get_equipment_inheritance_factor()
	locker_dialog_status_label.text = (
		"%s  •  %d / %d KEPT  •  EQUIPPED: %s\n%s\n"
		+ "Click an item to equip it. ★ items are never auto-scrapped; the lowest-Power unstarred item is removed above capacity.  •  %s"
	) % [
		str(definition.name),
		items.size(),
		BaseballGameState.LOOT_ITEMS_PER_SLOT,
		equipped_name,
		game.get_equipment_bonus_summary(),
		clone_note,
	]
	for child in locker_dialog_items.get_children():
		locker_dialog_items.remove_child(child)
		child.queue_free()
	if items.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No %s items have dropped yet." % str(definition.name).to_lower()
		empty_label.add_theme_color_override("font_color", COLOR_MUTED)
		locker_dialog_items.add_child(empty_label)
		return
	for item in items:
		var rarity := Content.loot_rarity(int(item.rarity))
		var is_equipped := str(game.equipped_loot.get(selected_loot_slot, "")) == str(item.id)
		var row_panel := PanelContainer.new()
		row_panel.custom_minimum_size.y = 68.0
		row_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row_panel.add_theme_stylebox_override("panel", _loot_item_row_style(Color(rarity.color), is_equipped))
		locker_dialog_items.add_child(row_panel)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 5)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row_panel.add_child(row)
		var item_button := Button.new()
		item_button.custom_minimum_size = Vector2(0.0, 60.0)
		item_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		item_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		item_button.clip_text = true
		item_button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		item_button.text = "%sPOWER %d  •  %s  •  ILVL %d  •  %s\n%s" % [
			"✓ EQUIPPED  •  " if is_equipped else "",
			game.get_loot_item_power(item),
			str(rarity.name),
			int(item.item_level),
			str(item.name),
			game.get_loot_item_description(item),
		]
		item_button.tooltip_text = item_button.text
		item_button.flat = true
		item_button.add_theme_color_override("font_color", Color(rarity.color))
		item_button.pressed.connect(_toggle_loot_item.bind(str(item.id)))
		row.add_child(item_button)
		var favorite_button := Button.new()
		favorite_button.custom_minimum_size = Vector2(52.0, 60.0)
		favorite_button.size_flags_horizontal = Control.SIZE_SHRINK_END
		favorite_button.text = "★" if bool(item.get("favorite", false)) else "☆"
		favorite_button.tooltip_text = "Allow auto-scrap" if bool(item.get("favorite", false)) else "Protect from auto-scrap"
		favorite_button.add_theme_font_size_override("font_size", 23)
		favorite_button.add_theme_color_override(
			"font_color",
			COLOR_GOLD if bool(item.get("favorite", false)) else COLOR_MUTED
		)
		favorite_button.pressed.connect(_toggle_loot_favorite.bind(str(item.id)))
		row.add_child(favorite_button)

func _equipment_card(parent: Control, id: String, heading: String) -> void:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0.0, 86.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(card)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 1)
	card.add_child(stack)
	var heading_label := Label.new()
	heading_label.text = heading
	heading_label.add_theme_font_size_override("font_size", 11)
	heading_label.add_theme_color_override("font_color", COLOR_ACCENT)
	stack.add_child(heading_label)
	var value_label := Label.new()
	value_label.add_theme_font_size_override("font_size", 14)
	value_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	stack.add_child(value_label)
	var effect_label := Label.new()
	effect_label.add_theme_font_size_override("font_size", 12)
	effect_label.add_theme_color_override("font_color", COLOR_MUTED)
	effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	effect_label.custom_minimum_size.y = 30.0
	stack.add_child(effect_label)
	equipment_labels[id] = {"value": value_label, "effect": effect_label}

func _build_upgrade_area(parent: Control) -> void:
	upgrade_panel = PanelContainer.new()
	upgrade_panel.custom_minimum_size.x = 360.0
	upgrade_panel.size_flags_horizontal = Control.SIZE_FILL
	upgrade_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(upgrade_panel)
	# Every long child explicitly clips or wraps, so the TabContainer can own its
	# real panel width. Its native overflow arrows then remain usable instead of
	# being clipped by an intermediate viewport.
	upgrade_tabs = TabContainer.new()
	upgrade_tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upgrade_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	upgrade_tabs.clip_tabs = true
	upgrade_tabs.use_hidden_tabs_for_min_size = true
	upgrade_tabs.get_tab_bar().add_theme_font_size_override("font_size", 8)
	upgrade_panel.add_child(upgrade_tabs)
	_build_training_tab(upgrade_tabs)
	_build_pitch_tab(upgrade_tabs)
	_build_ball_tab(upgrade_tabs)
	_build_scale_tab(upgrade_tabs)
	_build_rebirth_tab(upgrade_tabs)
	_build_stats_tab(upgrade_tabs)
	_build_guide_tab(upgrade_tabs)

func _create_scroll_tab(tabs: TabContainer, title: String) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.name = title
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 7)
	scroll.add_child(content)
	return content

func _section_label(parent: Control, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", COLOR_ACCENT)
	parent.add_child(label)

func _build_training_tab(tabs: TabContainer) -> void:
	var content := _create_scroll_tab(tabs, "TRAIN")
	_section_label(content, "REPEATABLE FUNDAMENTALS")
	for definition in _definitions_by_unlock(Content.TRAINING):
		var button := _upgrade_button(_definition_tooltip(definition))
		button.pressed.connect(_buy_training.bind(str(definition.id)))
		content.add_child(button)
		training_buttons[definition.id] = button

func _build_pitch_tab(tabs: TabContainer) -> void:
	var content := _create_scroll_tab(tabs, "PITCH")
	_section_label(content, "AUTOMATIC ARSENAL")
	var explainer := Label.new()
	explainer.text = "Every learned pitch enters the automatic mix. Pitch Calling increasingly favors the better ones."
	explainer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explainer.add_theme_font_size_override("font_size", 13)
	explainer.add_theme_color_override("font_color", COLOR_MUTED)
	content.add_child(explainer)
	for definition in _definitions_by_unlock(Content.PITCHES):
		var button := _upgrade_button(_definition_tooltip(definition, ["quality", "speed"]))
		button.pressed.connect(_buy_pitch.bind(str(definition.id)))
		content.add_child(button)
		pitch_buttons[definition.id] = button

func _build_ball_tab(tabs: TabContainer) -> void:
	var content := _create_scroll_tab(tabs, "BALL")
	_section_label(content, "BALL UPGRADES — POWER WITHOUT PHANTOM PROJECTILES")
	var ball_explainer := Label.new()
	ball_explainer.text = "Each shell replaces the previous shell. Payload multiplies XP per result while the visual ball count stays honest."
	ball_explainer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ball_explainer.add_theme_font_size_override("font_size", 13)
	ball_explainer.add_theme_color_override("font_color", COLOR_MUTED)
	content.add_child(ball_explainer)
	for definition in _definitions_by_unlock(Content.BALL_UPGRADES):
		var button := _upgrade_button(_definition_tooltip(definition, ["payload"]))
		button.pressed.connect(_buy_ball_upgrade.bind(str(definition.id)))
		content.add_child(button)
		ball_upgrade_buttons[definition.id] = button

func _build_scale_tab(tabs: TabContainer) -> void:
	var content := _create_scroll_tab(tabs, "FACILITY")
	_section_label(content, "ONE-TIME TRAINING, FACILITIES & QUESTIONABLE DECISIONS")
	for definition in _definitions_by_unlock(Content.MILESTONES):
		var button := _upgrade_button(_definition_tooltip(definition))
		button.pressed.connect(_buy_milestone.bind(str(definition.id)))
		content.add_child(button)
		milestone_buttons[definition.id] = button
	automation_section = VBoxContainer.new()
	automation_section.add_theme_constant_override("separation", 7)
	content.add_child(automation_section)
	_section_label(automation_section, "AUTOMATION")
	var automation_definitions := [
		{
			"id": "advance",
			"name": "Auto-advance",
			"upgrade": "migratory_instinct",
			"description": "Move to a newly unlocked opponent immediately.",
		},
		{
			"id": "train",
			"name": "Auto-coach",
			"upgrade": "autonomic_coach",
			"description": "Buy the cheapest available fundamental training automatically.",
		},
		{
			"id": "farm",
			"name": "Auto-scout",
			"upgrade": "predator_scouting",
			"description": "Farm the unlocked opponent and range with the best estimated XP/sec.",
		},
	]
	for definition in automation_definitions:
		var toggle := CheckButton.new()
		toggle.clip_text = true
		toggle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		toggle.tooltip_text = definition.description
		toggle.toggled.connect(_toggle_automation.bind(str(definition.id)))
		automation_section.add_child(toggle)
		automation_toggles[definition.id] = {"button": toggle, "definition": definition}

func _build_rebirth_tab(tabs: TabContainer) -> void:
	var content := _create_scroll_tab(tabs, "RESET")
	rebirth_tab = content.get_parent() as Control
	rebirth_story_label = Label.new()
	rebirth_story_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rebirth_story_label.add_theme_color_override("font_color", COLOR_GOLD)
	rebirth_story_label.add_theme_font_size_override("font_size", 14)
	content.add_child(rebirth_story_label)
	ascension_currency_label = Label.new()
	ascension_currency_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ascension_currency_label.add_theme_color_override("font_color", COLOR_TEXT)
	content.add_child(ascension_currency_label)

	genetic_section = VBoxContainer.new()
	genetic_section.add_theme_constant_override("separation", 7)
	content.add_child(genetic_section)
	_section_label(genetic_section, "I • GENETIC REBIRTH — THE TIME MACHINE IS FOR OBSTETRICS")
	genetic_reset_button = _upgrade_button("Reset the current body for DNA based on all XP earned by that body.")
	genetic_reset_button.pressed.connect(_request_genetic_rebirth)
	genetic_section.add_child(genetic_reset_button)
	for definition in Content.GENETIC_UPGRADES:
		var button := _upgrade_button(str(definition.description))
		button.pressed.connect(_buy_genetic.bind(str(definition.id)))
		genetic_section.add_child(button)
		genetic_buttons[definition.id] = button

	eldritch_section = VBoxContainer.new()
	eldritch_section.add_theme_constant_override("separation", 7)
	content.add_child(eldritch_section)
	_section_label(eldritch_section, "II • ELDRITCH ASCENSION — DESTROY THIS REALITY RESPONSIBLY")
	eldritch_reset_button = _upgrade_button("Reset the body, DNA, and every genetic enhancement for Arcana based on total DNA earned in this reality.")
	eldritch_reset_button.pressed.connect(_request_eldritch_ascension)
	eldritch_section.add_child(eldritch_reset_button)
	for definition in Content.ELDRITCH_UPGRADES:
		var button := _upgrade_button(str(definition.description))
		button.pressed.connect(_buy_eldritch.bind(str(definition.id)))
		eldritch_section.add_child(button)
		eldritch_buttons[definition.id] = button

	divine_section = VBoxContainer.new()
	divine_section.add_theme_constant_override("separation", 7)
	content.add_child(divine_section)
	_section_label(divine_section, "III • DIVINE GRAND SLAM — ONE BLESSING PER SAVED UNIVERSE")
	for definition in Content.DIVINE_BLESSINGS:
		var button := _upgrade_button(str(definition.description))
		button.pressed.connect(_request_divine_ascension.bind(str(definition.id)))
		divine_section.add_child(button)
		divine_buttons[definition.id] = button
	divine_halo_button = _upgrade_button("After every blessing is owned, each additional Halo multiplies XP and mastery ×1.50.")
	divine_halo_button.pressed.connect(_request_divine_ascension.bind("halo"))
	divine_section.add_child(divine_halo_button)

func _build_stats_tab(tabs: TabContainer) -> void:
	var content := _create_scroll_tab(tabs, "STATS")
	_section_label(content, "CURRENT PITCHING PROFILE")
	var stat_names := {
		"quality": "Quality",
		"potency": "Ball payload",
		"opponent_difficulty": "Effective opponent threat",
		"trait_penalty": "Special counter penalty",
		"distance": "Pitching distance",
		"distance_bonus": "Distance XP multiplier",
		"distance_penalty": "Distance threat multiplier",
		"flight_time": "True flight time",
		"speed": "True velocity",
		"speed_limit": "Current body limit",
		"equipment_bonuses": "Applied equipment bonuses",
		"equipment_inheritance": "Equipment inheritance",
		"loot_inventory": "Equipment items / capacity",
		"loot_found": "Loot found (body / lifetime)",
		"loot_discarded": "Overflow items removed",
		"rate": "Physical balls / second",
		"arms": "Synchronized arms",
		"clones": "Pitcher bodies",
		"time": "Time multiplier",
		"lineup_time": "Base lineup time",
		"hit_delay": "Fair-hit delay multiplier",
		"pitch_calling": "Best-option calling bias",
		"strikes": "Strikes per batter",
		"balls": "Balls per walk",
		"strikeout_odds": "Strikeout chance / at-bat",
		"hit_protection": "Count protection",
		"strikeouts": "Strikeouts (body / lifetime)",
		"mastery": "Opponent mastery multiplier",
		"income": "Estimated XP / second",
		"simulation": "Simulation mode",
		"visuals": "Visible projectile policy",
		"lifetime_pitches": "Lifetime pitches",
		"lifetime_xp": "Lifetime XP",
		"dna": "Unspent DNA / lifetime DNA",
		"arcana": "Unspent Arcana / lifetime Arcana",
		"genetic_rebirths": "Genetic rebirths (reality / lifetime)",
		"eldritch_ascensions": "Eldritch resets (universe / lifetime)",
		"divine_ascensions": "Universes saved",
		"divine_blessings": "Divine blessings / Halos",
		"completion": "Cosmic campaign",
	}
	for id in stat_names:
		var row := VBoxContainer.new()
		row.add_theme_constant_override("separation", 0)
		content.add_child(row)
		var name_label := Label.new()
		name_label.text = stat_names[id]
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		name_label.add_theme_font_size_override("font_size", 13)
		name_label.add_theme_color_override("font_color", COLOR_MUTED)
		var help_id: String = str({
			"quality": "quality",
			"potency": "payload",
			"distance_penalty": "distance",
			"speed": "speed",
			"rate": "recovery",
			"lineup_time": "lineup",
			"hit_delay": "hit_delay",
			"pitch_calling": "calling",
		}.get(str(id), ""))
		if not str(help_id).is_empty():
			name_label.tooltip_text = str(Content.STAT_HELP.get(str(help_id), ""))
			name_label.mouse_default_cursor_shape = Control.CURSOR_HELP
		row.add_child(name_label)
		var value_label := Label.new()
		value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		value_label.custom_minimum_size.x = 0.0
		value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		value_label.add_theme_font_size_override("font_size", 15)
		value_label.add_theme_color_override("font_color", COLOR_TEXT)
		row.add_child(value_label)
		stat_labels[id] = value_label
		stat_rows[id] = row

func _build_guide_tab(tabs: TabContainer) -> void:
	var content := _create_scroll_tab(tabs, "HELP")
	_section_label(content, "HOW TO BE LESS TERRIBLE")
	guide_label = Label.new()
	guide_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	guide_label.add_theme_color_override("font_color", COLOR_TEXT)
	content.add_child(guide_label)

func _upgrade_button(description: String) -> Button:
	var button := Button.new()
	button.custom_minimum_size.y = 78.0
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.clip_text = true
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	button.add_theme_font_size_override("font_size", 16)
	button.tooltip_text = description
	return button

func _build_event_log(parent: Control) -> void:
	event_log_panel = PanelContainer.new()
	event_log_panel.custom_minimum_size.y = 72.0
	event_log_panel.size_flags_vertical = Control.SIZE_FILL
	parent.add_child(event_log_panel)
	event_log = RichTextLabel.new()
	event_log.bbcode_enabled = true
	event_log.fit_content = false
	event_log.scroll_following = true
	event_log.add_theme_font_size_override("normal_font_size", 14)
	event_log_panel.add_child(event_log)

func _build_confirmation_dialog() -> void:
	_build_locker_dialog()
	_build_hard_reset_dialog()
	_build_save_transfer_dialogs()
	body_limit_dialog = AcceptDialog.new()
	body_limit_dialog.title = "The body refuses"
	add_child(body_limit_dialog)
	genetic_confirmation = ConfirmationDialog.new()
	genetic_confirmation.title = "Be born again, but with more baseball?"
	genetic_confirmation.confirmed.connect(_confirm_genetic_rebirth)
	add_child(genetic_confirmation)
	eldritch_confirmation = ConfirmationDialog.new()
	eldritch_confirmation.title = "Destroy this reality?"
	eldritch_confirmation.confirmed.connect(_confirm_eldritch_ascension)
	add_child(eldritch_confirmation)
	divine_confirmation = ConfirmationDialog.new()
	divine_confirmation.title = "Let God restore the universe?"
	divine_confirmation.confirmed.connect(_confirm_divine_ascension)
	add_child(divine_confirmation)

func _build_save_transfer_dialogs() -> void:
	export_save_dialog = FileDialog.new()
	export_save_dialog.name = "ExportSaveDialog"
	export_save_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	export_save_dialog.access = FileDialog.ACCESS_FILESYSTEM
	export_save_dialog.use_native_dialog = true
	export_save_dialog.filters = PackedStringArray(["*.json;One Foot Per Second Save;application/json"])
	export_save_dialog.file_selected.connect(_write_export_save)
	add_child(export_save_dialog)

	load_save_dialog = FileDialog.new()
	load_save_dialog.name = "LoadSaveDialog"
	load_save_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	load_save_dialog.access = FileDialog.ACCESS_FILESYSTEM
	load_save_dialog.use_native_dialog = true
	load_save_dialog.filters = PackedStringArray(["*.json;One Foot Per Second Save;application/json"])
	load_save_dialog.file_selected.connect(_read_import_save)
	add_child(load_save_dialog)

	import_save_confirmation = ConfirmationDialog.new()
	import_save_confirmation.name = "ImportSaveConfirmation"
	import_save_confirmation.title = "Replace current progress?"
	import_save_confirmation.get_ok_button().text = "LOAD SAVE"
	import_save_confirmation.confirmed.connect(_confirm_import_save)
	import_save_confirmation.canceled.connect(_discard_pending_import)
	add_child(import_save_confirmation)

	save_transfer_message_dialog = AcceptDialog.new()
	save_transfer_message_dialog.name = "SaveTransferMessage"
	save_transfer_message_dialog.title = "Save transfer"
	add_child(save_transfer_message_dialog)

func _build_hard_reset_dialog() -> void:
	hard_reset_dialog = Window.new()
	hard_reset_dialog.name = "HardResetWindow"
	hard_reset_dialog.title = "RESET ALL PROGRESS"
	hard_reset_dialog.min_size = Vector2i(520, 250)
	hard_reset_dialog.size = Vector2i(560, 270)
	hard_reset_dialog.transient = true
	hard_reset_dialog.exclusive = true
	hard_reset_dialog.close_requested.connect(_close_hard_reset_dialog)
	add_child(hard_reset_dialog)
	hard_reset_dialog.hide()

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_bottom", 22)
	hard_reset_dialog.add_child(margin)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 14)
	margin.add_child(stack)
	var warning := Label.new()
	warning.text = (
		"This permanently erases the local save: XP, equipment, mastery, every prestige layer, "
		+ "and all lifetime statistics. This cannot be undone."
	)
	warning.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	warning.add_theme_color_override("font_color", COLOR_BAD)
	stack.add_child(warning)
	var instruction := Label.new()
	instruction.text = "Type RESET exactly to unlock the erase button."
	instruction.add_theme_color_override("font_color", COLOR_MUTED)
	stack.add_child(instruction)
	hard_reset_input = LineEdit.new()
	hard_reset_input.placeholder_text = "Type RESET"
	hard_reset_input.clear_button_enabled = true
	hard_reset_input.text_changed.connect(_update_hard_reset_confirmation)
	stack.add_child(hard_reset_input)
	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_END
	button_row.add_theme_constant_override("separation", 10)
	stack.add_child(button_row)
	var cancel_button := Button.new()
	cancel_button.text = "CANCEL"
	cancel_button.pressed.connect(_close_hard_reset_dialog)
	button_row.add_child(cancel_button)
	hard_reset_confirm_button = Button.new()
	hard_reset_confirm_button.text = "ERASE ALL PROGRESS"
	hard_reset_confirm_button.disabled = true
	hard_reset_confirm_button.add_theme_color_override("font_color", COLOR_BAD)
	hard_reset_confirm_button.pressed.connect(_confirm_hard_reset)
	button_row.add_child(hard_reset_confirm_button)

func _has_genetic_reveal() -> bool:
	return (
		game.genetic_offer_unlocked
		or game.lifetime_genetic_rebirths > 0
		or game.lifetime_dna_earned > 0.0
		or game.divine_ascensions > 0
	)

func _has_eldritch_reveal() -> bool:
	return (
		game.eldritch_offer_unlocked
		or game.lifetime_eldritch_ascensions > 0
		or game.lifetime_arcana_earned > 0.0
		or game.divine_ascensions > 0
	)

func _has_divine_reveal() -> bool:
	return (
		game.cosmos_conquered
		or game.divine_ascensions > 0
		or not game.divine_blessings.is_empty()
		or game.divine_halos > 0
	)

func _visible_campaign_level_count() -> int:
	if _has_eldritch_reveal():
		return game.opponents.size()
	if game.highest_unlocked >= Content.ELDRITCH_EXHIBITION_INDEX:
		return Content.ELDRITCH_EXHIBITION_INDEX + 1
	if _has_genetic_reveal():
		return Content.ALIEN_FINAL_INDEX + 1
	if game.highest_unlocked >= Content.ALIEN_EXHIBITION_INDEX:
		return Content.ALIEN_EXHIBITION_INDEX + 1
	return Content.HUMAN_FINAL_INDEX + 1

func _catalog_tier_for_level(required_level: int) -> int:
	if required_level <= Content.HUMAN_FINAL_INDEX:
		return 0
	if required_level <= Content.ALIEN_FINAL_INDEX:
		return 1
	return 2

func _visible_catalog_tier() -> int:
	if _has_eldritch_reveal() or game.highest_unlocked >= Content.ELDRITCH_EXHIBITION_INDEX:
		return 2
	if _has_genetic_reveal() or game.highest_unlocked >= Content.ALIEN_EXHIBITION_INDEX:
		return 1
	return 0

func _catalog_entry_is_visible(definition: Dictionary, owned: bool) -> bool:
	return owned or _catalog_tier_for_level(int(definition.required_level)) <= _visible_catalog_tier()

func _definitions_by_unlock(source: Array) -> Array:
	var result := source.duplicate()
	result.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		var left_level := int(left.get("required_level", 0))
		var right_level := int(right.get("required_level", 0))
		if left_level != right_level:
			return left_level < right_level
		var left_cost := float(left.get("cost", left.get("base_cost", 0.0)))
		var right_cost := float(right.get("cost", right.get("base_cost", 0.0)))
		if left_cost != right_cost:
			return left_cost < right_cost
		return str(left.get("name", "")) < str(right.get("name", ""))
	)
	return result

func _definition_tooltip(definition: Dictionary, fallback_stats: Array = []) -> String:
	var lines: Array[String] = [str(definition.get("description", ""))]
	var stats: Array = definition.get("stats", fallback_stats)
	for stat_value in stats:
		var help := str(Content.STAT_HELP.get(str(stat_value), ""))
		if not help.is_empty() and help not in lines:
			lines.append(help)
	return "\n\n".join(lines)

func _set_catalog_lock(button: Button, definition: Dictionary) -> void:
	var unlock_text := "REACH LEVEL %d" % (int(definition.required_level) + 1)
	_set_catalog_lock_text(button, definition, [unlock_text])

func _set_catalog_lock_text(button: Button, definition: Dictionary, requirements: Array[String]) -> void:
	var unlock_text := " • ".join(requirements)
	button.text = "%s\n🔒 %s" % [str(definition.name), "\n🔒 ".join(requirements)]
	button.tooltip_text = unlock_text
	button.disabled = true

func _refresh_reveal_visibility() -> void:
	var genetic_revealed := _has_genetic_reveal()
	var eldritch_revealed := _has_eldritch_reveal()
	var divine_revealed := _has_divine_reveal()
	var reveal_mask := int(genetic_revealed) + int(eldritch_revealed) * 2 + int(divine_revealed) * 4

	prestige_header_stack.visible = genetic_revealed and not mobile_layout
	if genetic_revealed:
		prestige_header_heading.text = "DNA • ARCANA" if eldritch_revealed else "DNA"
		rings_label.text = (
			"D%s • A%s" % [
				BaseballGameState.format_number(float(game.dna), 0),
				BaseballGameState.format_number(float(game.arcana), 0),
			]
			if eldritch_revealed
			else BaseballGameState.format_number(float(game.dna), 0)
		)

	if reveal_mask != last_reveal_mask:
		var rebirth_index := rebirth_tab.get_index()
		upgrade_tabs.set_tab_hidden(rebirth_index, not genetic_revealed)
		if not genetic_revealed and upgrade_tabs.current_tab == rebirth_index:
			upgrade_tabs.current_tab = 0
		automation_section.visible = genetic_revealed
		genetic_section.visible = genetic_revealed
		eldritch_section.visible = eldritch_revealed
		divine_section.visible = divine_revealed
		last_reveal_mask = reveal_mask

	header_subtitle.text = "A BASEBALL IDLE GAME ABOUT A VERY SLOW PITCH"
	equipment_progression_heading.text = "OWNED FACILITIES"
	if genetic_revealed:
		header_subtitle.text = "A BASEBALL IDLE GAME ABOUT QUESTIONABLE BIOLOGY"
		equipment_progression_heading.text = "FACILITIES & MUTATIONS"
	if eldritch_revealed:
		header_subtitle.text = "A BASEBALL IDLE GAME ABOUT COSMICALLY OVERQUALIFIED PITCHING"
		equipment_progression_heading.text = "FACILITIES, MUTATIONS & MAGIC"
	if divine_revealed:
		header_subtitle.text = "A BASEBALL IDLE GAME ABOUT SAVING THE UNIVERSE WITH BASEBALL"
	if is_web_build:
		header_subtitle.text += "  •  BROWSER BUILD"

	for id in ["arms", "dna", "genetic_rebirths"]:
		stat_rows[id].visible = genetic_revealed
	for id in ["equipment_inheritance", "clones", "time", "arcana", "eldritch_ascensions"]:
		stat_rows[id].visible = eldritch_revealed
	for id in ["divine_ascensions", "divine_blessings", "completion"]:
		stat_rows[id].visible = divine_revealed
	stat_rows.speed_limit.visible = game.is_velocity_body_capped()
	_refresh_guide_text(genetic_revealed, eldritch_revealed, divine_revealed)

func _refresh_guide_text(
	genetic_revealed: bool,
	eldritch_revealed: bool,
	divine_revealed: bool
) -> void:
	var sections: Array[String] = [
		(
			"Only a complete strikeout awards XP or mastery. Individual strikes and every hit award "
			+ "zero. An unprotected hit sends the batter away, clears every accumulated strike, and "
			+ "leaves the plate empty: Singles are annoying, Home Runs are long, and Grand Slams impose "
			+ "the full twelve-second humiliation. Even a clean strikeout takes three seconds for the next batter."
		),
		(
			"The three diamonds beside a human batter are the remaining strikes. Move the mound farther "
			+ "from the plate for a larger XP multiplier and a harder batter. At the opening 3-foot range, "
			+ "the 1 ft/s lob genuinely takes three seconds to arrive; extreme travel times compress only "
			+ "on screen, while Stats keeps the true physical time."
		),
		(
			"Earn opponent mastery to unlock the next batter, or move backward whenever an easier opponent "
			+ "produces more XP per second. The circle beside the pitcher fills toward the next release. While "
			+ "the plate is empty, pitching stops and the circle beside home plate fills until the next batter "
			+ "arrives. On-Deck Hurry-Up multiplies every replacement delay by 0.930 per rank. After an opponent's "
			+ "mastery target is passed, staying there adds a small logarithmic XP and loot-quality farming bonus."
		),
		(
			"Completed strikeouts can leave random clothing. The first career strikeout guarantees a hat; "
			+ "later eligible strikeouts have a 12% chance, with pity by the tenth roll and a five-second parcel "
			+ "cadence at extreme production. Common, Magic, Rare, Legendary, and Unique gear gains progressively "
			+ "more affixes. The colored letter squares at the field's lower-right open equipment; ★ protects an "
			+ "item from auto-scrap. Bonuses are capped sidegrades, and each slot keeps up to 10 items."
		),
		(
			"A released ball keeps the speed, path, color, source, and travel time it had at release. New "
			+ "upgrades affect only future throws. Every visible low-rate ball is one exact simulated pitch; "
			+ "only after more than %s would overlap on this device does a labeled dot represent several pitches."
			% BaseballGameState.format_number(float(pitch_field.get_visual_capacity()), 0)
		),
	]
	if genetic_revealed:
		sections.append(
			"Xylophax's proposal unlocks prenatal genetic editing and the Time Machine. Genetic rebirth "
			+ "resets the baseball climb and Locker for DNA: floor((body XP / 10B)^(1/3)), before multipliers. "
			+ "Mutations survive later genetic rebirths. Alien batters require four through nine strikes; new "
			+ "arms, count compression, fielding reflexes, and automation provide new ways to handle them."
		)
	if eldritch_revealed:
		sections.append(
			"N'Kthra's revelation unlocks eldritch ascension. Destroying the current reality resets XP, DNA, "
			+ "genetics, levels, and the Locker for Arcana: floor((DNA earned in this reality)^0.60), before "
			+ "multipliers. Mirror bullpens, time compression, portals, and other magic survive future destroyed "
			+ "realities. Reverse Terminator Wardrobe is the exception that can carry equipped clothing through "
			+ "ordinary genetic time travel."
		)
	if divine_revealed:
		sections.append(
			"After Octathulhu is defeated, choose one permanent divine blessing and let God restore the "
			+ "universe. Every named blessing can be earned on later victories; further wins award Halos."
		)
	guide_label.text = "\n\n".join(sections)

func _refresh_interface() -> void:
	if game == null or pitch_field == null:
		return
	var opponent := game.get_current_opponent()
	var at_bat_metrics := game.get_at_bat_metrics()
	var probabilities: Array = at_bat_metrics.probabilities
	var estimated_xp_per_second := minf(
		BaseballGameState.MAX_NUMBER,
		float(at_bat_metrics.strikeouts_per_second)
		* game.get_strikeout_base_points()
		* game.get_xp_multiplier()
	)
	_refresh_reveal_visibility()
	xp_label.text = BaseballGameState.format_number(game.xp)
	rate_label.text = BaseballGameState.format_number(estimated_xp_per_second)
	if development_session:
		save_button.disabled = true
		export_save_button.disabled = true
		load_save_button.disabled = true
		hard_reset_button.disabled = true
		save_label.text = "test session"
	else:
		save_button.disabled = false
		export_save_button.disabled = false
		load_save_button.disabled = false
		hard_reset_button.disabled = false
	era_label.text = "LEVEL %02d / %02d  •  %s" % [
		game.current_opponent + 1,
		_visible_campaign_level_count(),
		opponent.era,
	]
	previous_button.disabled = game.current_opponent <= 0
	next_button.disabled = game.current_opponent >= game.highest_unlocked
	previous_button.tooltip_text = "Select the previous unlocked batter. A released pitch keeps flying and will resolve against the selected batter."
	next_button.tooltip_text = "Select the next unlocked batter. A released pitch keeps flying and will resolve against the selected batter."
	if game.cosmos_conquered:
		next_button.text = "DIVINE OFFER READY"
	elif game.is_story_exhibition_blocked():
		next_button.text = "REBIRTH REQUIRED" if not game.get_story_status_text().contains("Offer in") and not game.get_story_status_text().contains("Revelation in") else "EXHIBITION ACTIVE"
	elif game.current_opponent < game.highest_unlocked:
		next_button.text = "NEXT BATTER ›"
	elif game.current_opponent == game.opponents.size() - 1:
		next_button.text = "FINAL BOSS ACTIVE"
	else:
		next_button.text = "NEXT BATTER LOCKED"
	if mobile_layout:
		previous_button.text = "‹"
		next_button.text = "›"
	var distance := game.get_current_distance()
	distance_label.text = (
		"%s  •  XP ×%s  •  THREAT +%.2f" % [
			str(distance.label),
			BaseballGameState.format_number(game.get_distance_xp_multiplier()),
			game.get_distance_difficulty(),
		]
		if mobile_layout
		else "%s  •  %s  •  XP ×%s  •  BATTER THREAT +%.2f" % [
			str(distance.name),
			str(distance.label),
			BaseballGameState.format_number(game.get_distance_xp_multiplier()),
			game.get_distance_difficulty(),
		]
	)
	var mastery_value := game.opponent_mastery[game.current_opponent]
	var mastery_required := float(opponent.mastery_required)
	var overmastery_summary := game.get_overmastery_summary()
	if game.is_alien_exhibition_blocked():
		mastery_label.text = game.get_story_status_text()
		mastery_bar.value = game.alien_exhibition_seconds / BaseballGameState.EXHIBITION_SECONDS * 100.0
	elif game.is_eldritch_exhibition_blocked():
		mastery_label.text = game.get_story_status_text()
		mastery_bar.value = game.eldritch_exhibition_seconds / BaseballGameState.EXHIBITION_SECONDS * 100.0
	elif game.is_speed_gate_blocked():
		mastery_label.text = game.get_speed_gate_status_text()
		mastery_bar.value = 0.0
	elif game.current_opponent == game.opponents.size() - 1:
		mastery_label.text = (
			"COSMIC DOMINION COMPLETE  •  OCTATHULHU DEFEATED%s" % (
				"  •  %s" % overmastery_summary if not overmastery_summary.is_empty() else ""
			)
			if game.cosmos_conquered
			else "FINAL BOSS MASTERY  %s / %s  •  Conquer the cosmos at 100%%" % [
				BaseballGameState.format_number(mastery_value),
				BaseballGameState.format_number(mastery_required),
			]
		)
	elif mastery_value >= mastery_required:
		var target_ratio := mastery_value / maxf(mastery_required, 0.000001)
		mastery_label.text = "OPPONENT MASTERED  •  ×%s TARGET%s" % [
			BaseballGameState.format_number(target_ratio),
			"  •  %s" % overmastery_summary if not overmastery_summary.is_empty() else "",
		]
	else:
		mastery_label.text = "OPPONENT MASTERY  %s / %s  •  Next level unlocks at 100%%" % [
			BaseballGameState.format_number(mastery_value),
			BaseballGameState.format_number(mastery_required),
		]
	if not game.is_story_exhibition_blocked() and not game.is_speed_gate_blocked():
		mastery_bar.value = game.get_mastery_ratio() * 100.0
	for index in probabilities.size():
		outcome_probability_labels[index].text = "%.2f%%" % (probabilities[index] * 100.0)
		var bonus_seconds := game.get_outcome_turnover_bonus(index)
		outcome_delay_labels[index].text = "+%s" % _format_compact_seconds(bonus_seconds)
		var detail := ""
		if index < Content.HIT_OUTCOME_COUNT:
			detail = "Ends the plate appearance unless saved. Adds %s beyond the base lineup change." % _format_compact_seconds(bonus_seconds)
		elif index == Content.FOUL_INDEX:
			detail = "Adds one strike, but cannot supply the final strike. The batter stays at the plate."
		elif index == Content.BALL_INDEX:
			detail = "Adds one Ball. %d Balls produce a walk, treated like a Single and adding %s." % [game.get_balls_required(), _format_compact_seconds(bonus_seconds)]
		else:
			detail = "Adds one strike. Strike %d completes the only XP-paying outcome." % game.get_strikes_required()
		outcome_panels[index].tooltip_text = "%s • %.2f%%\n%s\nEvery completed plate appearance includes a %s base lineup change." % [
			str(Content.OUTCOME_NAMES[index]),
			float(probabilities[index]) * 100.0,
			detail,
			_format_compact_seconds(game.get_base_batter_turnover_seconds()),
		]
	strikeout_payout_label.text = "COMPLETED STRIKEOUT: %s XP" % BaseballGameState.format_number(
		game.get_strikeout_base_points() * game.get_xp_multiplier()
	)

	pitch_field.configure_from_game(game, at_bat_metrics)
	_refresh_field_stats()
	opponent_label.text = game.get_current_batter_name()
	var trait_description := Content.trait_description(str(opponent.trait))
	var story_status := game.get_story_status_text()
	var speed_status := game.get_speed_gate_status_text()
	quirk_label.text = str(opponent.name).to_upper()
	quirk_label.tooltip_text = "%s%s%s%s" % [
		str(opponent.quirk),
		"\n%s" % trait_description if not trait_description.is_empty() else "",
		"\n%s" % story_status if not story_status.is_empty() else "",
		"\n%s" % speed_status if not speed_status.is_empty() else "",
	]
	_refresh_equipment()
	_refresh_locker()
	_refresh_opponent_loadout()
	var weight: float = float(pitch_field.get_visual_weight())
	visual_weight_label.text = (
		"1:1 PROJECTILES  •  %s IN FLIGHT" % BaseballGameState.format_number(
			float(pitch_field.get_rendered_pitch_count()), 0
		)
		if weight < 1.01
		else "EACH DOT ≈ %s PITCHES" % BaseballGameState.format_number(weight)
	)
	_refresh_purchase_buttons()
	_refresh_rebirth_buttons()
	_refresh_stats(at_bat_metrics, estimated_xp_per_second)

func _refresh_field_stats() -> void:
	if field_stat_labels.is_empty():
		return
	field_stat_labels.speed.text = BaseballGameState.format_speed(pitch_field.last_pitch_speed_fps)
	field_stat_labels.quality.text = "%.3f" % game.get_pitch_quality()
	field_stat_labels.recovery.text = "%.3f/s" % game.get_recovery_rate()
	field_stat_labels.lineup.text = "%s" % _format_compact_seconds(game.get_base_batter_turnover_seconds())
	field_stat_labels.hit_delay.text = "×%.3f" % game.get_hit_delay_factor()
	field_stat_labels.calling.text = "×%.2f" % game.get_pitch_calling_bias()
	field_stat_labels.distance.text = "×%.3f" % game.get_distance_penalty_multiplier()

func _format_compact_seconds(seconds: float) -> String:
	if absf(seconds - round(seconds)) < 0.05:
		return "%ds" % int(round(seconds))
	return "%.1fs" % seconds

func _refresh_equipment() -> void:
	var ball_entry: Dictionary = equipment_labels.ball
	var ball_value: Label = ball_entry.value
	var ball_effect: Label = ball_entry.effect
	ball_value.text = game.get_current_ball_name()
	ball_value.tooltip_text = ball_value.text
	ball_effect.text = "Payload ×%s" % BaseballGameState.format_number(game.get_pitch_potency())

	var best_pitch := game.get_best_pitch()
	var pitch_entry: Dictionary = equipment_labels.pitch
	var pitch_value: Label = pitch_entry.value
	var pitch_effect: Label = pitch_entry.effect
	pitch_value.text = "%d learned • best %s" % [game.unlocked_pitches.size(), str(best_pitch.name)]
	var selection_lines: Array[String] = []
	for entry in game.get_pitch_selection_entries():
		selection_lines.append("%s %.1f%%" % [
			str(Content.pitch_by_id(str(entry.id)).name),
			float(entry.probability) * 100.0,
		])
	pitch_value.tooltip_text = "Automatic selection\n" + "\n".join(selection_lines)
	pitch_effect.text = "Best quality %+.2f • calling bias ×%.2f" % [
		float(best_pitch.bonus),
		game.get_pitch_calling_bias(),
	]

	var body_entry: Dictionary = equipment_labels.body
	var body_value: Label = body_entry.value
	var body_effect: Label = body_entry.effect
	var arm_count := int(game.get_arm_count())
	var pitcher_count := int(game.get_clone_count())
	if _has_eldritch_reveal():
		body_value.text = "%d %s • %d %s" % [
			arm_count,
			"arm" if arm_count == 1 else "arms",
			pitcher_count,
			"pitcher" if pitcher_count == 1 else "pitchers",
		]
	elif _has_genetic_reveal():
		body_value.text = "%d-%s pitcher" % [arm_count, "arm" if arm_count == 1 else "armed"]
	else:
		body_value.text = "Pitcher"
	body_value.tooltip_text = body_value.text
	body_effect.text = "%s cooldown • %d ball%s/release\nBody size ×%.3f" % [
		BaseballGameState.format_duration(game.get_pitch_cooldown_seconds()),
		game.get_volley_size(),
		"" if game.get_volley_size() == 1 else "s",
		game.get_pitcher_size_multiplier(),
	]
	if _has_eldritch_reveal():
		body_effect.text = "%s cooldown • %d balls/release • Time ×%s\nBody size ×%.3f" % [
			BaseballGameState.format_duration(game.get_pitch_cooldown_seconds()),
			game.get_volley_size(),
			BaseballGameState.format_number(game.get_time_multiplier(), 0),
			game.get_pitcher_size_multiplier(),
		]

	equipment_summary_label.text = game.get_owned_equipment_summary()
	equipment_summary_label.tooltip_text = equipment_summary_label.text

func _refresh_locker() -> void:
	if inventory_dock == null:
		return
	var unlock_mask := 0
	for index in Content.LOOT_SLOTS.size():
		if game.is_loot_slot_unlocked(str(Content.LOOT_SLOTS[index].id)):
			unlock_mask |= 1 << index
	var signature := "%d|%d|%.4f" % [
		game.loot_revision,
		unlock_mask,
		game.get_equipment_inheritance_factor(),
	]
	if signature == last_loot_ui_signature:
		return
	last_loot_ui_signature = signature
	last_loot_revision = game.loot_revision
	for definition in Content.LOOT_SLOTS:
		var slot := str(definition.id)
		var button: Button = inventory_slot_buttons[slot]
		var unlocked := game.is_loot_slot_unlocked(slot)
		var equipped := game.get_equipped_loot_item(slot)
		# Slot color is a quick rarity read: gray Common, blue Magic, gold Rare,
		# orange Legendary, purple Unique. The item's separate cosmetic tint still
		# appears on the abstract pitcher.
		var color := game.get_equipped_loot_rarity_color(slot, COLOR_MUTED)
		button.text = ("✓%s" % str(definition.letter)) if unlocked and not equipped.is_empty() else (str(definition.letter) if unlocked else "?")
		button.disabled = not unlocked
		_apply_loot_square_style(button, color, not unlocked, not equipped.is_empty())
		if not unlocked:
			button.tooltip_text = "Finish human baseball to reveal this equipment slot."
		else:
			button.tooltip_text = "%s • %d / %d • %s" % [
				str(definition.name),
				game.get_loot_items_for_slot(slot, false).size(),
				BaseballGameState.LOOT_ITEMS_PER_SLOT,
				(
					"Empty"
					if equipped.is_empty()
					else "%s • Power %d" % [str(equipped.name), game.get_loot_item_power(equipped)]
				),
			]
	if locker_dialog != null and locker_dialog.visible:
		_rebuild_locker_dialog()

func _refresh_opponent_loadout() -> void:
	if opponent_loadout_dock == null:
		return
	var variant := game.get_current_batter_variant()
	var signature := "%d:%d" % [game.current_opponent, game.batter_generation]
	if signature == opponent_loadout_signature:
		return
	opponent_loadout_signature = signature
	for child in opponent_loadout_dock.get_children():
		opponent_loadout_dock.remove_child(child)
		child.queue_free()
	var entries: Array = variant.get("loadout", [])
	for entry_value in entries:
		var entry: Dictionary = entry_value
		var button := Button.new()
		button.custom_minimum_size = Vector2(38.0, 30.0)
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_default_cursor_shape = Control.CURSOR_HELP
		button.text = str(entry.get("letter", "?"))
		var entry_id := str(entry.get("id", ""))
		var color := Color(entry.get("color", COLOR_MUTED))
		if entry_id != "body":
			color = Color(Content.loot_rarity(int(entry.get("rarity", 0))).color)
		_apply_loot_square_style(button, color)
		var kind := "BODY" if entry_id == "body" else ("BAT" if entry_id == "bat" else entry_id.to_upper())
		var rarity_text := ""
		if entry_id != "body":
			rarity_text = " • %s" % str(Content.loot_rarity(int(entry.get("rarity", 0))).name)
		button.tooltip_text = "%s%s • %s • Batter threat %+.3f" % [
			kind,
			rarity_text,
			str(entry.get("name", "Unknown")),
			float(entry.get("difficulty_bonus", 0.0)),
		]
		opponent_loadout_dock.add_child(button)

func _refresh_purchase_buttons() -> void:
	for definition in Content.TRAINING:
		var id := str(definition.id)
		var rank := int(game.training_levels[id])
		var button: Button = training_buttons[id]
		if game.highest_unlocked < int(definition.get("required_level", 0)):
			_set_catalog_lock(button, definition)
		elif id == "velocity" and game.is_velocity_body_capped():
			button.text = "%s  •  RANK %d\nBODY LIMIT REACHED — CLICK FOR DETAILS" % [
				definition.name,
				rank,
			]
			button.disabled = false
			button.tooltip_text = str(Content.STAT_HELP.speed)
		elif definition.has("max_level") and rank >= int(definition.max_level):
			button.text = "✓ %s  •  RANK %d / %d  •  MAXED\n%s" % [
				definition.name,
				rank,
				int(definition.max_level),
				definition.description,
			]
			button.disabled = true
			button.tooltip_text = _definition_tooltip(definition)
		else:
			var cost := game.get_training_cost(id)
			button.text = "%s  •  RANK %d\n%s XP  —  %s" % [
				definition.name,
				rank,
				BaseballGameState.format_cost(cost),
				definition.description,
			]
			button.disabled = game.xp < cost
			button.tooltip_text = _definition_tooltip(definition)

	for definition in Content.PITCHES:
		var id := str(definition.id)
		var button: Button = pitch_buttons[id]
		button.visible = _catalog_entry_is_visible(definition, id in game.unlocked_pitches)
		if not button.visible:
			continue
		if id in game.unlocked_pitches:
			button.text = "✓ %s  •  LEARNED\n%s" % [definition.name, definition.description]
			button.tooltip_text = _definition_tooltip(definition, ["quality", "speed"])
			button.disabled = true
		elif game.highest_unlocked < int(definition.required_level):
			_set_catalog_lock(button, definition)
		else:
			button.text = "%s  •  %s XP\n%s" % [
				definition.name,
				BaseballGameState.format_cost(game.get_pitch_cost(id)),
				definition.description,
			]
			button.tooltip_text = _definition_tooltip(definition, ["quality", "speed"])
			button.disabled = not game.can_buy_pitch(id)

	for definition in Content.BALL_UPGRADES:
		var id := str(definition.id)
		var button: Button = ball_upgrade_buttons[id]
		button.visible = _catalog_entry_is_visible(definition, game.has_ball_upgrade(id))
		if not button.visible:
			continue
		if game.has_ball_upgrade(id):
			button.text = "✓ %s  •  INSTALLED\n%s" % [definition.name, definition.description]
			button.tooltip_text = _definition_tooltip(definition, ["payload"])
			button.disabled = true
		elif game.highest_unlocked < int(definition.required_level):
			_set_catalog_lock(button, definition)
		else:
			button.text = "%s  •  %s XP\n%s" % [
				definition.name,
				BaseballGameState.format_cost(game.get_ball_upgrade_cost(id)),
				definition.description,
			]
			button.tooltip_text = _definition_tooltip(definition, ["payload"])
			button.disabled = not game.can_buy_ball_upgrade(id)

	for definition in Content.MILESTONES:
		var id := str(definition.id)
		var button: Button = milestone_buttons[id]
		button.visible = _catalog_entry_is_visible(definition, game.has_milestone(id))
		if not button.visible:
			continue
		if game.has_milestone(id):
			button.text = "✓ %s  •  OWNED\n%s" % [definition.name, definition.description]
			button.tooltip_text = _definition_tooltip(definition)
			button.disabled = true
		elif not game.get_milestone_unmet_requirements(definition).is_empty():
			_set_catalog_lock_text(button, definition, game.get_milestone_unmet_requirements(definition))
		else:
			button.text = "%s  •  %s XP\n%s" % [
				definition.name,
				BaseballGameState.format_cost(game.get_milestone_cost(id)),
				definition.description,
			]
			button.tooltip_text = _definition_tooltip(definition)
			button.disabled = not game.can_buy_milestone(id)

	for definition in Content.SCALE_UPGRADES:
		var id := str(definition.id)
		var rank := int(game.scale_levels[id])
		var button: Button = scale_buttons[id]
		if game.highest_unlocked < int(definition.required_level):
			button.text = "🔒 %s  •  REACH LEVEL %d\n%s" % [
				definition.name,
				int(definition.required_level) + 1,
				definition.description,
			]
			button.disabled = true
		elif rank >= int(definition.max_level):
			button.text = "✓ %s  •  RANK %d / %d  •  MAXED\n%s" % [
				definition.name,
				rank,
				int(definition.max_level),
				definition.description,
			]
			button.disabled = true
		else:
			var cost := game.get_scale_cost(id)
			button.text = "%s  •  RANK %d  •  %s XP\n%s" % [
				definition.name,
				rank,
				BaseballGameState.format_cost(cost),
				definition.description,
			]
			button.disabled = not game.can_buy_scale(id)

	for id in automation_toggles:
		var entry: Dictionary = automation_toggles[id]
		var toggle: CheckButton = entry.button
		var definition: Dictionary = entry.definition
		var required_upgrade := str(definition.upgrade)
		var unlocked := game.has_genetic_upgrade(required_upgrade)
		toggle.text = "%s  •  %s\n%s" % [
			definition.name,
			"GENETICALLY UNLOCKED" if unlocked else "REQUIRES %s" % Content.genetic_by_id(required_upgrade).name,
			definition.description,
		]
		toggle.disabled = not unlocked
		var enabled := false
		match str(id):
			"advance":
				enabled = game.auto_advance_enabled
			"train":
				enabled = game.auto_train_enabled
			"farm":
				enabled = game.auto_farm_enabled
		toggle.set_pressed_no_signal(enabled)

func _refresh_rebirth_buttons() -> void:
	var story := "Beat the 30 human opponents to meet the first impossible batter."
	if game.cosmos_conquered:
		story = "GOD: ‘You saved the universe with baseball. I admit I did not have that one.’ Choose one blessing; everything else will be restored."
	elif game.is_eldritch_exhibition_blocked():
		story = "N'Kthra, Rookie of the Last Aeon hits every pitch out of reality. After one minute it explains how to move your consciousness elsewhere."
	elif game.eldritch_ascensions > 0:
		story = "Your consciousness inhabits reality %d. Octathulhu remains technically beatable under the oldest rules of baseball." % (game.eldritch_ascensions + 1)
	elif game.is_alien_exhibition_blocked():
		story = "Xylophax hits every pitch for a Grand Slam. After one minute it offers prenatal genetic editing and a Time Machine for the prenatal part."
	elif game.genetic_rebirths > 0:
		story = "Body %d is legally human in several permissive jurisdictions. Beat the alien leagues at up to Mach 12." % (game.genetic_rebirths + 1)
	if game.genetic_rebirths > 0 and not game.eldritch_offer_unlocked:
		story += " Rebirth when the quoted DNA buys a useful mutation; a shallow human loop followed by a deeper alien harvest is usually efficient."
	rebirth_story_label.text = story
	if _has_divine_reveal():
		ascension_currency_label.text = (
			"DNA %s  •  Arcana %s  •  Body XP %s  •  Reality DNA %s  •  Universes saved %d"
			% [
				BaseballGameState.format_number(float(game.dna), 0),
				BaseballGameState.format_number(float(game.arcana), 0),
				BaseballGameState.format_number(game.run_xp),
				BaseballGameState.format_number(game.reality_dna_earned, 0),
				game.divine_ascensions,
			]
		)
	elif _has_eldritch_reveal():
		ascension_currency_label.text = "DNA %s  •  Arcana %s  •  Body XP %s  •  Reality DNA %s" % [
			BaseballGameState.format_number(float(game.dna), 0),
			BaseballGameState.format_number(float(game.arcana), 0),
			BaseballGameState.format_number(game.run_xp),
			BaseballGameState.format_number(game.reality_dna_earned, 0),
		]
	else:
		ascension_currency_label.text = "DNA %s  •  Body XP %s" % [
			BaseballGameState.format_number(float(game.dna), 0),
			BaseballGameState.format_number(game.run_xp),
		]

	var potential_dna := game.get_potential_dna()
	if not game.genetic_offer_unlocked:
		genetic_reset_button.text = "🔒 GENETIC REBIRTH\nBeat human baseball, then survive Xylophax for one minute."
		genetic_reset_button.disabled = true
	elif game.highest_unlocked < Content.ALIEN_EXHIBITION_INDEX:
		genetic_reset_button.text = "GENETIC REBIRTH NOT READY\nReach Xylophax again; current body XP still determines the award."
		genetic_reset_button.disabled = true
	elif potential_dna <= 0:
		genetic_reset_button.text = "GENETIC REBIRTH NOT READY\nEarn 10B total XP with this body."
		genetic_reset_button.disabled = true
	else:
		genetic_reset_button.text = "REINCARNATE VIA TIME MACHINE  •  +%d DNA\nResets this body and all level progress; mutations survive." % potential_dna
		genetic_reset_button.disabled = false

	for definition in Content.GENETIC_UPGRADES:
		var id := str(definition.id)
		var rank := int(game.genetic_levels[id])
		var button: Button = genetic_buttons[id]
		if not game.genetic_offer_unlocked:
			button.text = "🔒 %s\n%s" % [definition.name, definition.description]
			button.disabled = true
		elif rank >= int(definition.max_level):
			button.text = "✓ %s  •  RANK %d / %d\n%s" % [definition.name, rank, int(definition.max_level), definition.description]
			button.disabled = true
		else:
			button.text = "%s  •  RANK %d  •  %d DNA\n%s" % [definition.name, rank, game.get_genetic_cost(id), definition.description]
			button.disabled = not game.can_buy_genetic(id)

	var potential_arcana := game.get_potential_arcana()
	if not game.eldritch_offer_unlocked:
		eldritch_reset_button.text = "🔒 ELDRITCH ASCENSION\nBeat the alien leagues, then survive the Last Aeon for one minute."
		eldritch_reset_button.disabled = true
	elif game.highest_unlocked < Content.ELDRITCH_EXHIBITION_INDEX:
		eldritch_reset_button.text = "ELDRITCH ASCENSION NOT READY\nReach the Last Aeon again; all DNA earned in this reality determines the award."
		eldritch_reset_button.disabled = true
	elif potential_arcana <= 0:
		eldritch_reset_button.text = "ELDRITCH ASCENSION NOT READY\nComplete at least one genetic rebirth in this reality."
		eldritch_reset_button.disabled = true
	else:
		eldritch_reset_button.text = "ABANDON THIS REALITY  •  +%d ARCANA\nResets XP, levels, DNA, and genetics; eldritch magic survives." % potential_arcana
		eldritch_reset_button.disabled = false

	for definition in Content.ELDRITCH_UPGRADES:
		var id := str(definition.id)
		var rank := int(game.eldritch_levels[id])
		var button: Button = eldritch_buttons[id]
		if not game.eldritch_offer_unlocked:
			button.text = "🔒 %s\n%s" % [definition.name, definition.description]
			button.disabled = true
		elif rank >= int(definition.max_level):
			button.text = "✓ %s  •  RANK %d / %d\n%s" % [definition.name, rank, int(definition.max_level), definition.description]
			button.disabled = true
		else:
			button.text = "%s  •  RANK %d  •  %d ARCANA\n%s" % [definition.name, rank, game.get_eldritch_cost(id), definition.description]
			button.disabled = not game.can_buy_eldritch(id)

	for definition in Content.DIVINE_BLESSINGS:
		var id := str(definition.id)
		var button: Button = divine_buttons[id]
		if game.has_divine_blessing(id):
			button.text = "✓ %s  •  ETERNALLY OWNED\n%s" % [definition.name, definition.description]
			button.disabled = true
		else:
			button.text = "%s  •  CHOOSE AFTER COSMIC VICTORY\n%s" % [definition.name, definition.description]
			button.disabled = not game.cosmos_conquered
	divine_halo_button.text = "ANOTHER HALO  •  CURRENT RANK %d\nAll XP and opponent mastery ×1.50; requires every named blessing." % game.divine_halos
	divine_halo_button.disabled = not game.cosmos_conquered or not game.all_divine_blessings_owned()

func _refresh_stats(at_bat_metrics: Dictionary, estimated_xp_per_second: float) -> void:
	var pitch_rate := game.get_pitch_rate()
	var mode := "INDIVIDUAL EVENTS"
	if pitch_rate >= 1000.0:
		mode = "BATCHED MATH"
	mode += " • 1:1 PROJECTILES" if pitch_field.is_rendering_one_to_one() else " • LABELED REPRESENTATIVES"
	stat_labels.quality.text = "%.3f" % game.get_pitch_quality()
	stat_labels.potency.text = "×%s" % BaseballGameState.format_number(game.get_pitch_potency())
	stat_labels.opponent_difficulty.text = "%.3f" % game.get_effective_opponent_difficulty()
	stat_labels.trait_penalty.text = "+%.3f" % game.get_opponent_trait_penalty()
	stat_labels.distance.text = str(game.get_current_distance().label)
	stat_labels.distance_bonus.text = "×%s" % BaseballGameState.format_number(game.get_distance_xp_multiplier())
	stat_labels.distance_penalty.text = "×%.3f" % game.get_distance_penalty_multiplier()
	stat_labels.flight_time.text = BaseballGameState.format_flight_time(game.get_physical_flight_seconds())
	stat_labels.speed.text = BaseballGameState.format_speed(game.get_velocity_fps())
	stat_labels.speed_limit.text = "%s • body %s • gear may exceed" % [
		game.get_velocity_stage_name(),
		BaseballGameState.format_speed(game.get_body_velocity_fps()),
	]
	stat_labels.equipment_bonuses.text = game.get_equipment_bonus_summary()
	stat_labels.equipment_inheritance.text = "%d / %d bodies • ×%.3f aggregate" % [
		int(game.get_clone_count()) if game.has_eldritch_upgrade("clone_dress_code") else 1,
		int(game.get_clone_count()),
		game.get_equipment_inheritance_factor(),
	]
	var unlocked_loot_slots := 0
	for definition in Content.LOOT_SLOTS:
		if game.is_loot_slot_unlocked(str(definition.id)):
			unlocked_loot_slots += 1
	stat_labels.loot_inventory.text = "%d / %d" % [
		game.loot_items.size(),
		unlocked_loot_slots * BaseballGameState.LOOT_ITEMS_PER_SLOT,
	]
	stat_labels.loot_found.text = "%s / %s" % [
		BaseballGameState.format_number(game.current_body_loot_found, 0),
		BaseballGameState.format_number(game.lifetime_loot_found, 0),
	]
	stat_labels.loot_discarded.text = BaseballGameState.format_number(game.loot_overflow_discarded, 0)
	stat_labels.rate.text = BaseballGameState.format_number(pitch_rate)
	stat_labels.arms.text = BaseballGameState.format_number(game.get_arm_count(), 0)
	stat_labels.clones.text = BaseballGameState.format_number(game.get_clone_count(), 0)
	stat_labels.time.text = "×%s" % BaseballGameState.format_number(game.get_time_multiplier())
	stat_labels.lineup_time.text = _format_compact_seconds(game.get_base_batter_turnover_seconds())
	stat_labels.hit_delay.text = "×%.3f" % game.get_hit_delay_factor()
	stat_labels.pitch_calling.text = "×%.3f" % game.get_pitch_calling_bias()
	stat_labels.strikes.text = str(game.get_strikes_per_batter())
	stat_labels.balls.text = str(game.get_balls_required())
	stat_labels.strikeout_odds.text = "%.4f%%" % (float(at_bat_metrics.strikeout_probability) * 100.0)
	stat_labels.hit_protection.text = game.get_hit_protection_summary()
	stat_labels.strikeouts.text = "%s / %s" % [BaseballGameState.format_number(game.current_body_strikeouts), BaseballGameState.format_number(game.lifetime_strikeouts)]
	stat_labels.mastery.text = "×%s" % BaseballGameState.format_number(game.get_mastery_multiplier())
	stat_labels.income.text = BaseballGameState.format_number(estimated_xp_per_second)
	stat_labels.simulation.text = mode
	stat_labels.visuals.text = "%s / %s in flight" % [
		BaseballGameState.format_number(float(pitch_field.get_rendered_pitch_count()), 0),
		BaseballGameState.format_number(float(pitch_field.get_visual_capacity()), 0),
	]
	stat_labels.lifetime_pitches.text = BaseballGameState.format_number(game.lifetime_pitches)
	stat_labels.lifetime_xp.text = BaseballGameState.format_number(game.lifetime_xp)
	stat_labels.dna.text = "%s / %s" % [BaseballGameState.format_number(float(game.dna), 0), BaseballGameState.format_number(game.lifetime_dna_earned, 0)]
	stat_labels.arcana.text = "%s / %s" % [BaseballGameState.format_number(float(game.arcana), 0), BaseballGameState.format_number(game.lifetime_arcana_earned, 0)]
	stat_labels.genetic_rebirths.text = "%d / %d" % [game.genetic_rebirths, game.lifetime_genetic_rebirths]
	stat_labels.eldritch_ascensions.text = "%d / %d" % [game.eldritch_ascensions, game.lifetime_eldritch_ascensions]
	stat_labels.divine_ascensions.text = str(game.divine_ascensions)
	stat_labels.divine_blessings.text = "%d / %d • %d Halos" % [game.divine_blessings.size(), Content.DIVINE_BLESSINGS.size(), game.divine_halos]
	stat_labels.completion.text = "AWAITING DIVINE RESET" if game.cosmos_conquered else "In progress"

func _on_batch_resolved(summary: Dictionary) -> void:
	var launched: int = pitch_field.notify_batch(summary)
	var pitch_count := float(summary.pitches)
	var earned := float(summary.earned_xp)
	var loot_found := int(summary.get("loot_found", 0))
	if loot_found > 0:
		var drops: Array = summary.get("loot_drops", [])
		var drop_text := "%d loot parcels" % loot_found
		if not drops.is_empty():
			var featured: Dictionary = drops[0]
			var rarity: Dictionary = Content.loot_rarity(int(featured.rarity))
			drop_text = "%s %s" % [rarity.name, featured.name]
			if loot_found > 1:
				drop_text += " + %d more" % (loot_found - 1)
		var discarded := int(summary.get("loot_discarded", 0))
		if discarded > 0:
			drop_text += " • %d lowest items cleared" % discarded
		_log_event("STRIKEOUT LOOT: %s." % drop_text)
	var has_impact := false
	for event_value in summary.get("pitch_events", []):
		if str((event_value as Dictionary).get("phase", "")) == "impact":
			has_impact = true
			break
	if launched == 1:
		last_result_label.text = "Pitch in flight…"
		last_result_label.add_theme_color_override("font_color", COLOR_MUTED)
	elif launched > 1:
		last_result_label.text = "%s-ball volley released…" % BaseballGameState.format_number(float(launched), 0)
		last_result_label.add_theme_color_override("font_color", COLOR_MUTED)
	elif has_impact:
		# The field signal has already written the full outcome name. Keep that
		# call instead of replacing it with a generic accounting summary.
		pass
	elif pitch_count > 0.0 and pitch_field.get_batter_status_text().contains("NEXT BATTER"):
		last_result_label.text = pitch_field.get_batter_status_text()
		last_result_label.add_theme_color_override("font_color", COLOR_MUTED)
	elif pitch_count > 0.0:
		last_result_label.text = "%s pitches resolved  •  +%s XP" % [
			BaseballGameState.format_number(pitch_count),
			BaseballGameState.format_number(earned),
		]
		last_result_label.add_theme_color_override("font_color", COLOR_TEXT)

func _on_batter_call_displayed(call_text: String, color: Color) -> void:
	last_result_label.text = call_text
	last_result_label.add_theme_color_override("font_color", color)

func _on_progression_changed(message: String) -> void:
	_log_event(message)
	_refresh_interface()

func _on_save_status_changed(message: String) -> void:
	if is_web_build and not web_storage_persistent:
		save_label.text = "temporary save"
	else:
		save_label.text = message.to_lower()

func _log_event(message: String) -> void:
	if event_log == null:
		return
	event_log.append_text("[color=#63d9ff]›[/color] %s\n" % message)

func _previous_opponent() -> void:
	game.set_current_opponent(game.current_opponent - 1)

func _next_opponent() -> void:
	game.set_current_opponent(game.current_opponent + 1)

func _move_closer() -> void:
	game.set_distance_index(game.selected_distance_index - 1)
	_refresh_interface()

func _move_farther() -> void:
	game.set_distance_index(game.selected_distance_index + 1)
	_refresh_interface()

func _buy_training(id: String) -> void:
	if id == "velocity" and game.is_velocity_body_capped():
		_show_body_limit_dialog()
		return
	game.buy_training(id)
	_refresh_interface()

func _show_body_limit_dialog() -> void:
	var stage := game.get_velocity_stage_name()
	if game.eldritch_ascensions > 0:
		body_limit_dialog.dialog_text = (
			"This reality will not permit a pitch faster than light. Velocity Training has nowhere left "
			+ "to put the extra speed."
		)
	elif game.genetic_rebirths > 0:
		body_limit_dialog.dialog_text = (
			"This engineered body has reached its Mach 12 limit. Velocity Training cannot push its tissues "
			+ "farther. If only pitching could stop obeying ordinary distance and time…"
		)
	else:
		body_limit_dialog.dialog_text = (
			"This is the limit of an ordinary human pitching body: 211.6 mph. Velocity Training cannot "
			+ "push it farther. If only there were some way to change what the body itself can handle…"
		)
	if last_body_limit_popup_stage != stage:
		last_body_limit_popup_stage = stage
	body_limit_dialog.popup_centered(Vector2i(560, 190))

func _buy_pitch(id: String) -> void:
	game.buy_pitch(id)
	_refresh_interface()

func _buy_ball_upgrade(id: String) -> void:
	game.buy_ball_upgrade(id)
	_refresh_interface()

func _buy_milestone(id: String) -> void:
	game.buy_milestone(id)
	_refresh_interface()

func _buy_scale(id: String) -> void:
	game.buy_scale(id)
	_refresh_interface()

func _buy_genetic(id: String) -> void:
	game.buy_genetic(id)
	_refresh_interface()

func _buy_eldritch(id: String) -> void:
	game.buy_eldritch(id)
	_refresh_interface()

func _toggle_loot_item(item_id: String) -> void:
	game.equip_loot(item_id)
	_rebuild_locker_dialog()
	_refresh_interface()

func _toggle_loot_favorite(item_id: String) -> void:
	game.toggle_loot_favorite(item_id)
	_rebuild_locker_dialog()
	_refresh_interface()

func _toggle_automation(enabled: bool, id: String) -> void:
	match id:
		"advance":
			game.auto_advance_enabled = enabled and game.has_genetic_upgrade("migratory_instinct")
		"train":
			game.auto_train_enabled = enabled and game.has_genetic_upgrade("autonomic_coach")
		"farm":
			game.auto_farm_enabled = enabled and game.has_genetic_upgrade("predator_scouting")
	_log_event("%s %s." % [id.capitalize(), "enabled" if enabled else "disabled"])
	_refresh_interface()

func _request_genetic_rebirth() -> void:
	if game.get_potential_dna() <= 0:
		return
	genetic_confirmation.dialog_text = (
		"This body becomes %d DNA. XP, training, pitches, facilities, opponent access, mastery, and the Locker reset. "
		+ "Reverse Terminator Wardrobe rank %d keeps that many randomly selected equipped slots. "
		+ "DNA, genetic enhancements, Arcana, eldritch magic, and divine rewards remain."
	) % [game.get_potential_dna(), int(game.eldritch_levels.get("reverse_terminator", 0))]
	genetic_confirmation.popup_centered()

func _confirm_genetic_rebirth() -> void:
	game.perform_genetic_rebirth()
	game.save_game()
	_refresh_interface()

func _request_eldritch_ascension() -> void:
	if game.get_potential_arcana() <= 0:
		return
	eldritch_confirmation.dialog_text = (
		"Destroy this reality for %d Arcana? This resets XP, levels, mastery, DNA, every genetic enhancement, "
		+ "every ordinary purchase, and every item in the Locker. Reverse Terminator only works with genetic time travel. "
		+ "Arcana, eldritch magic, and divine rewards remain."
	) % game.get_potential_arcana()
	eldritch_confirmation.popup_centered()

func _confirm_eldritch_ascension() -> void:
	game.perform_eldritch_ascension()
	game.save_game()
	_refresh_interface()

func _request_divine_ascension(id: String) -> void:
	if not game.cosmos_conquered:
		return
	if id != "halo" and game.has_divine_blessing(id):
		return
	if id == "halo" and not game.all_divine_blessings_owned():
		return
	pending_divine_id = id
	var reward_name := "Another Halo" if id == "halo" else str(Content.divine_by_id(id).name)
	divine_confirmation.dialog_text = (
		"Accept %s? God restores the original universe: XP, levels, DNA, Arcana, genetic enhancements, "
		+ "eldritch magic, story encounters, and all equipment reset. Divine blessings, Halos, and lifetime statistics remain."
	) % reward_name
	divine_confirmation.popup_centered()

func _confirm_divine_ascension() -> void:
	if pending_divine_id.is_empty():
		return
	game.perform_divine_ascension(pending_divine_id)
	pending_divine_id = ""
	game.save_game()
	_refresh_interface()

func _save_now() -> void:
	if development_session:
		return
	game.save_game()
	autosave_elapsed = 0.0

func _backup_filename() -> String:
	var now := Time.get_datetime_dict_from_system()
	return "one-foot-per-second-save-v%d-%04d%02d%02d-%02d%02d%02d.json" % [
		BaseballGameState.SAVE_VERSION,
		int(now.year),
		int(now.month),
		int(now.day),
		int(now.hour),
		int(now.minute),
		int(now.second),
	]

func _request_export_save() -> void:
	if development_session:
		return
	game.save_game()
	autosave_elapsed = 0.0
	var filename := _backup_filename()
	var save_text := game.get_save_json(true)
	if is_web_build:
		var bridge: Variant = Engine.get_singleton("JavaScriptBridge")
		if bridge == null:
			_show_save_transfer_error("The browser download bridge is unavailable.")
			return
		bridge.download_buffer(save_text.to_utf8_buffer(), filename, "application/json")
		_on_save_status_changed("Backup exported")
		_log_event("Portable save backup downloaded as %s." % filename)
		return
	var downloads := OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
	if not downloads.is_empty():
		export_save_dialog.current_dir = downloads
	export_save_dialog.current_file = filename
	export_save_dialog.popup_file_dialog()

func _write_export_save(path: String) -> void:
	var target := path if path.to_lower().ends_with(".json") else "%s.json" % path
	var file := FileAccess.open(target, FileAccess.WRITE)
	if file == null:
		_show_save_transfer_error("The backup could not be written to that location.")
		return
	file.store_string(game.get_save_json(true))
	file.close()
	_on_save_status_changed("Backup exported")
	_log_event("Portable save backup exported to %s." % target.get_file())

func _request_load_save() -> void:
	if development_session:
		return
	if is_web_build:
		_request_web_import_file()
		return
	var downloads := OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
	if not downloads.is_empty():
		load_save_dialog.current_dir = downloads
	load_save_dialog.popup_file_dialog()

func _read_import_save(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_show_save_transfer_error("The selected backup could not be opened.")
		return
	if file.get_length() > BaseballGameState.MAX_IMPORTED_SAVE_CHARACTERS:
		file.close()
		_show_save_transfer_error("The selected file is too large to be a game save.")
		return
	var text := file.get_as_text()
	file.close()
	_stage_import_save(text, path.get_file())

func _request_web_import_file() -> void:
	var bridge: Variant = Engine.get_singleton("JavaScriptBridge")
	if bridge == null:
		_show_save_transfer_error("The browser file picker is unavailable.")
		return
	var document: Variant = bridge.get_interface("document")
	if document == null:
		_show_save_transfer_error("The browser document interface is unavailable.")
		return
	web_file_selected_callback = bridge.create_callback(_on_web_file_selected)
	web_file_input = document.createElement("input")
	web_file_input.setAttribute("type", "file")
	web_file_input.setAttribute("accept", ".json,application/json")
	web_file_input.addEventListener("change", web_file_selected_callback)
	web_file_input.click()

func _on_web_file_selected(arguments: Array) -> void:
	if arguments.is_empty():
		return
	var event: Variant = arguments[0]
	var files: Variant = event.target.files
	if files == null or int(files.length) <= 0:
		return
	var selected_file: Variant = files[0]
	if int(selected_file.size) > BaseballGameState.MAX_IMPORTED_SAVE_CHARACTERS:
		_show_save_transfer_error("The selected file is too large to be a game save.")
		_clear_web_file_handles()
		return
	pending_import_name = str(selected_file.name)
	var bridge: Variant = Engine.get_singleton("JavaScriptBridge")
	web_file_loaded_callback = bridge.create_callback(_on_web_file_loaded)
	web_file_error_callback = bridge.create_callback(_on_web_file_error)
	web_file_reader = bridge.create_object("FileReader")
	web_file_reader.addEventListener("load", web_file_loaded_callback)
	web_file_reader.addEventListener("error", web_file_error_callback)
	web_file_reader.readAsArrayBuffer(selected_file)

func _on_web_file_loaded(_arguments: Array) -> void:
	var bridge: Variant = Engine.get_singleton("JavaScriptBridge")
	if bridge == null or web_file_reader == null:
		_show_save_transfer_error("The selected browser file could not be read.")
		_clear_web_file_handles()
		return
	var bytes: PackedByteArray = bridge.js_buffer_to_packed_byte_array(web_file_reader.result)
	var source_name := pending_import_name
	_stage_import_save(bytes.get_string_from_utf8(), source_name)
	_clear_web_file_handles()

func _on_web_file_error(_arguments: Array) -> void:
	_show_save_transfer_error("The browser could not read the selected backup.")
	_clear_web_file_handles()

func _clear_web_file_handles() -> void:
	web_file_input = null
	web_file_reader = null
	web_file_selected_callback = null
	web_file_loaded_callback = null
	web_file_error_callback = null

func _stage_import_save(text: String, source_name: String) -> void:
	var decoded := game.decode_save_text(text)
	if not bool(decoded.get("ok", false)):
		_show_save_transfer_error(str(decoded.get("message", "The selected save is invalid.")))
		return
	pending_import_save = (decoded.data as Dictionary).duplicate(true)
	pending_import_name = source_name
	var saved_level := clampi(
		int(pending_import_save.get("current_opponent", 0)) + 1,
		1,
		game.opponents.size()
	)
	var saved_version := int(pending_import_save.get("version", 0))
	var saved_xp := maxf(float(pending_import_save.get("xp", 0.0)), 0.0)
	import_save_confirmation.dialog_text = (
		"Load %s?\n\nSave v%d • Level %d • %s XP\n\n"
		+ "This replaces the current run, equipment, mastery, and prestige state. "
		+ "The imported state will be autosaved immediately."
	) % [
		source_name if not source_name.is_empty() else "selected backup",
		saved_version,
		saved_level,
		BaseballGameState.format_number(saved_xp),
	]
	import_save_confirmation.popup_centered(Vector2i(610, 260))

func _confirm_import_save() -> void:
	if development_session or pending_import_save.is_empty():
		return
	var imported := pending_import_save.duplicate(true)
	var imported_name := pending_import_name
	_discard_pending_import()
	game.apply_save_data(imported)
	var saved_at := float(imported.get("saved_at", Time.get_unix_time_from_system()))
	var offline_seconds := maxf(Time.get_unix_time_from_system() - saved_at, 0.0)
	var offline_summary := game.simulate_offline(offline_seconds)
	pitch_field.reset_visual_state()
	last_reveal_mask = -1
	last_loot_revision = -1
	last_loot_ui_signature = ""
	opponent_loadout_signature = ""
	event_log.clear()
	_refresh_interface()
	game.save_game()
	autosave_elapsed = 0.0
	_log_event("Loaded portable backup %s." % imported_name)
	if not offline_summary.is_empty():
		_log_offline_summary(offline_summary, "Imported-save catch-up")

func _discard_pending_import() -> void:
	pending_import_save.clear()
	pending_import_name = ""

func _show_save_transfer_error(message: String) -> void:
	save_transfer_message_dialog.dialog_text = message
	save_transfer_message_dialog.popup_centered(Vector2i(560, 180))
	_on_save_status_changed("Transfer failed")

func _request_hard_reset() -> void:
	if development_session:
		return
	hard_reset_input.clear()
	hard_reset_confirm_button.disabled = true
	hard_reset_dialog.popup_centered(Vector2i(560, 270))
	hard_reset_input.call_deferred("grab_focus")

func _close_hard_reset_dialog() -> void:
	hard_reset_input.clear()
	hard_reset_confirm_button.disabled = true
	hard_reset_dialog.hide()

func _update_hard_reset_confirmation(typed_text: String) -> void:
	hard_reset_confirm_button.disabled = typed_text != "RESET"

func _confirm_hard_reset() -> void:
	if development_session or hard_reset_input.text != "RESET":
		return
	hard_reset_dialog.hide()
	game.delete_save()
	game.reset_fresh()
	pitch_field.reset_visual_state()
	autosave_elapsed = 0.0
	ui_elapsed = 0.0
	last_reveal_mask = -1
	last_loot_revision = -1
	last_loot_ui_signature = ""
	opponent_loadout_signature = ""
	event_log.clear()
	game.save_game()
	_refresh_interface()
	_log_event("Progress reset. Little Timmy has agreed to pretend none of that happened.")
