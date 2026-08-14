extends Control

const Content = preload("res://scripts/content.gd")
const GameStateScript = preload("res://scripts/game_state.gd")
const PitchFieldScript = preload("res://scripts/pitch_field.gd")
const TitleArtScript = preload("res://scripts/title_art.gd")

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
const WEB_UPDATE_SAVE_FLUSH_SECONDS := 1.50
const WEB_UPDATE_RELOAD_WATCHDOG_SECONDS := 6.0
const BROWSER_SAVE_MIRROR_KEY := "no_hitter_portable_save_mirror_v1"
const BROWSER_SAVE_ROLLBACK_KEY := "no_hitter_portable_save_rollback_v1"
const BROWSER_MANUAL_SAVE_SLOT_COUNT := 3
const WEB_WIDE_MIN_WIDTH := 1280.0
const WEB_WIDE_MIN_HEIGHT := 696.0
const WEB_LAYOUT_HYSTERESIS := 24.0
const WEB_DENSE_MAX_HEIGHT := 860.0
const MOBILE_TAB_ARROW_TOUCH_SIZE := 44
const MOBILE_PORTRAIT_FIELD_MIN_HEIGHT := 270.0
const LOCKER_ITEM_HOLD_SECONDS := 0.55
const LOCKER_ITEM_DRAG_CANCEL_DISTANCE := 8.0

var game: BaseballGameState
var pitch_field
var ui_elapsed := 0.0
var expensive_ui_elapsed := 0.0
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
var previous_navigation_icon: ImageTexture
var next_navigation_icon: ImageTexture
var favorite_open_icon: ImageTexture
var favorite_kept_icon: ImageTexture
var distance_label: Label
var equipment_labels := {}
var status_stat_labels := {}
var equipment_summary_label: Label
var equipment_progression_heading: Label
var equipment_progression_list: VBoxContainer
var last_owned_upgrade_list_signature := ""
var visual_weight_label: Label
var last_result_label: Label
var outcome_panels: Array[PanelContainer] = []
var outcome_name_labels: Array[Label] = []
var outcome_probability_labels: Array[Label] = []
var outcome_delay_labels: Array[Label] = []
var strikeout_payout_label: Label
var outcome_footer: HBoxContainer
var frustration_status: HBoxContainer
var frustration_label: Label
var frustration_bar: ProgressBar
var training_buttons := {}
var pitch_buttons := {}
var ball_upgrade_buttons := {}
var milestone_buttons := {}
var catalog_hide_purchased_toggles := {}
var scale_buttons := {}
var body_growth_buttons := {}
var genetic_buttons := {}
var eldritch_buttons := {}
var divine_buttons := {}
var automation_toggles := {}
var automation_training_heading: Label
var automation_catalog_heading: Label
var stat_labels := {}
var stat_rows := {}
var upgrade_tabs: TabContainer
var rebirth_tab: Control
var achievement_tab: Control
var achievement_count_label: Label
var achievement_bonus_label: Label
var achievement_hide_achieved_toggle: CheckButton
var achievement_cards := {}
var achievement_section_headings := {}
var achievement_last_revision := -1
var achievement_last_reveal_signature := ""
var achievement_toast: PanelContainer
var achievement_toast_heading: Label
var achievement_toast_name: Label
var achievement_toast_description: Label
var achievement_toast_queue: Array[Dictionary] = []
var achievement_toast_showing := false
var achievement_toast_tween: Tween
var automation_section: VBoxContainer
var human_growth_section: VBoxContainer
var genetic_section: VBoxContainer
var eldritch_section: VBoxContainer
var divine_section: VBoxContainer
var guide_label: Label
var rebirth_story_label: Label
var ascension_currency_label: Label
var body_growth_status_label: Label
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
var locker_dialog_close_button: Button
var locker_dialog_status_label: Label
var locker_dialog_items: VBoxContainer
var locker_dialog_slot_buttons := {}
var selected_loot_slot := "hat"
var loot_item_dialog: Window
var loot_item_name_label: Label
var loot_item_meta_label: Label
var loot_item_equipped_label: Label
var loot_item_stats: VBoxContainer
var loot_item_status_label: Label
var loot_item_equip_button: Button
var loot_item_trash_button: Button
var selected_loot_item_id := ""
var armed_loot_trash_id := ""
var locker_item_hold_targets: Array[Dictionary] = []
var held_locker_item_id := ""
var held_locker_item_elapsed := 0.0
var held_locker_item_drag_distance := 0.0
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
var mobile_install_dialog: AcceptDialog
var mobile_inspection_dialog: AcceptDialog
var offline_progress_dialog: AcceptDialog
var browser_update_confirmation: ConfirmationDialog
var browser_update_export_button: Button
var alien_help_dialog: AcceptDialog
var alien_help_button: Button
var pending_import_save: Dictionary = {}
var pending_import_name := ""
var pending_import_returns_from_title := false
var pending_title_offline_summary: Dictionary = {}
var pending_title_offline_prefix := "Welcome back"
var pending_new_game_from_title := false
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
var web_lifecycle_serial := -1
var web_last_recovered_hidden_at := 0.0
var web_lifecycle_poll_elapsed := 1.0
var web_update_check_elapsed := WEB_UPDATE_CHECK_INTERVAL - 5.0
var web_update_status_elapsed := 0.0
var web_update_ready := false
var web_update_snoozed_until := 0.0
var web_update_installing := false
var web_update_attempt_serial := 0
var browser_save_recovered := false
var browser_save_regression_allowed := false
var update_banner: PanelContainer
var update_banner_label: Label
var update_now_button: Button
var update_later_button: Button
var mobile_layout := false
var mobile_portrait_layout := false
var web_dense_layout := false
var responsive_layout_initialized := false
var mobile_overlay_panel: Control
var mobile_overlay_surface: PanelContainer
var mobile_overlay_content: VBoxContainer
var mobile_overlay_title: Label
var mobile_overlay_xp_label: Label
var mobile_nav: HBoxContainer
var mobile_install_button: Button
var mobile_overlay_control: Control
var mobile_overlay_home: Control
var mobile_overlay_home_index := -1
var mobile_tab_navigation: HBoxContainer
var mobile_tab_label_card: PanelContainer
var mobile_tab_label: Label
var mobile_tab_previous_button: Button
var mobile_tab_next_button: Button
var mobile_upgrade_stats_panel: PanelContainer
var mobile_upgrade_stat_labels := {}
var root_margin: MarginContainer
var page_scroll: ScrollContainer
var page_container: VBoxContainer
var body_container: HBoxContainer
var header_panel: PanelContainer
var header_row: HBoxContainer
var header_title_stack: VBoxContainer
var header_title: Label
var header_spacer: Control
var save_stack: VBoxContainer
var save_action_row: HBoxContainer
var browser_save_slots_panel: VBoxContainer
var browser_save_slot_entries: Array[Dictionary] = []
var play_panel: PanelContainer
var play_stack: VBoxContainer
var opponent_row: HBoxContainer
var opponent_stack: VBoxContainer
var play_row: HBoxContainer
var equipment_sidebar: ScrollContainer
var equipment_sidebar_heading: Label
var equipment_stats_section: VBoxContainer
var field_stack: VBoxContainer
var field_footer: HBoxContainer
var outcomes_grid: GridContainer
var upgrade_panel: PanelContainer
var event_log_panel: PanelContainer
var field_stat_panel: PanelContainer
var locker_slot_grid: GridContainer
var header_metric_stacks: Array[VBoxContainer] = []
var header_metric_headings: Array[Label] = []
var return_to_title_button: Button
var title_screen: ColorRect
var title_panel: PanelContainer
var title_root_stack: VBoxContainer
var title_heading_label: Label
var title_layout_grid: GridContainer
var title_hero_stack: VBoxContainer
var title_action_panel: PanelContainer
var title_action_heading: Label
var title_art
var title_art_frame: PanelContainer
var title_subtitle_label: Label
var title_progress_label: Label
var title_menu_stack: VBoxContainer
var title_resume_stack: VBoxContainer
var title_autosave_label: Label
var title_autosave_button: Button
var title_manual_slot_entries: Array[Dictionary] = []
var title_screen_active := false

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
	game.achievement_unlocked.connect(_on_achievement_unlocked)
	_build_interface()
	_configure_platform_ui()
	var offline_summary := game.load_game()
	if is_web_build:
		var mirror_summary := _recover_browser_save_mirror()
		if browser_save_recovered:
			offline_summary = mirror_summary
	_apply_development_arguments()
	if not offline_summary.is_empty():
		_log_offline_summary(offline_summary, "Welcome back")
	elif not browser_save_recovered:
		_log_event("The toddler is ready. Your arm is not.")
	if is_web_build and not web_storage_persistent:
		_log_event("Browser storage is temporary here. Use EXPORT after playing if you want to keep this run.")
	_refresh_interface()
	_show_title_screen(false)
	if game.save_writes_locked:
		_log_event("An existing save could not be read and has not been overwritten. Use LOAD to recover it or RESET to deliberately start over.")
		call_deferred("_show_save_recovery_required")
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
	_update_locker_item_hold(delta)
	if is_web_build:
		_poll_browser_lifecycle(delta)
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
	expensive_ui_elapsed += delta
	autosave_elapsed += delta
	if ui_elapsed >= 0.20:
		ui_elapsed = 0.0
		var refresh_expensive := expensive_ui_elapsed >= 1.0
		if refresh_expensive:
			expensive_ui_elapsed = 0.0
		_refresh_interface(refresh_expensive)
	if autosave_elapsed >= 10.0 and not development_session and not game.save_writes_locked:
		autosave_elapsed = 0.0
		game.save_game()

func _write_browser_save_mirror() -> void:
	if not is_web_build or game == null or development_session or game.save_writes_locked:
		return
	var storage: Variant = JavaScriptBridge.get_interface("localStorage")
	if storage == null:
		browser_save_regression_allowed = false
		return
	var current_text := game.get_save_json()
	var current_decoded := game.decode_save_text(current_text)
	if not bool(current_decoded.get("ok", false)):
		browser_save_regression_allowed = false
		return
	var previous_text := str(storage.getItem(BROWSER_SAVE_MIRROR_KEY))
	var previous_decoded := game.decode_save_text(previous_text)
	if bool(previous_decoded.get("ok", false)):
		var previous_data: Dictionary = previous_decoded.data
		var current_data: Dictionary = current_decoded.data
		if (
			not browser_save_regression_allowed
			and _browser_save_has_more_progress(previous_data, current_data)
		):
			# An unexpected fresh or rolled-back runtime may write repeatedly after
			# an update. Preserve the demonstrably more advanced mirror until load
			# recovery or an explicit import/reset resolves the discrepancy.
			browser_save_regression_allowed = false
			return
		if previous_text != current_text:
			storage.setItem(BROWSER_SAVE_ROLLBACK_KEY, previous_text)
	storage.setItem(BROWSER_SAVE_MIRROR_KEY, current_text)
	browser_save_regression_allowed = false

func _recover_browser_save_mirror() -> Dictionary:
	if game.last_load_failure_reason == "future_version":
		# A mirror from an older schema is not permission to downgrade a newer
		# primary save. The cached executable must update first.
		return {}
	var storage: Variant = JavaScriptBridge.get_interface("localStorage")
	if storage == null:
		return {}
	var mirrored_data := _read_browser_recovery_data(storage, BROWSER_SAVE_MIRROR_KEY)
	if mirrored_data.is_empty() or not _browser_save_has_progress(mirrored_data):
		mirrored_data = _read_browser_recovery_data(storage, BROWSER_SAVE_ROLLBACK_KEY)
	if mirrored_data.is_empty() or not _browser_save_has_progress(mirrored_data):
		return {}
	var current_data := game.to_save_data()
	var mirror_is_newer := (
		float(mirrored_data.get("saved_at", 0.0))
		> game.last_loaded_save_timestamp + 0.5
	)
	var mirror_is_ahead := _browser_save_has_more_progress(mirrored_data, current_data)
	if game.last_load_succeeded and not mirror_is_newer and not mirror_is_ahead:
		return {}
	game.apply_save_data(mirrored_data)
	game.save_writes_locked = false
	game.last_load_succeeded = true
	game.last_load_recovered = true
	browser_save_recovered = true
	var saved_at := float(mirrored_data.get("saved_at", Time.get_unix_time_from_system()))
	var recovered_summary := game.simulate_offline(maxf(Time.get_unix_time_from_system() - saved_at, 0.0))
	game.save_game()
	_log_event("Recovered progress from the browser's secondary save mirror.")
	return recovered_summary

func _read_browser_recovery_data(storage: Variant, key: String) -> Dictionary:
	var text := str(storage.getItem(key))
	if text.is_empty() or text == "null":
		return {}
	var decoded := game.decode_save_text(text)
	return decoded.data if bool(decoded.get("ok", false)) else {}

func _browser_save_has_progress(data: Dictionary) -> bool:
	return (
		float(data.get("lifetime_pitches", 0.0)) > 0.0
		or float(data.get("lifetime_xp", 0.0)) > 0.0
		or float(data.get("lifetime_strikeouts", 0.0)) > 0.0
		or int(data.get("highest_unlocked", 0)) > 0
		or int(data.get("lifetime_genetic_rebirths", data.get("genetic_rebirths", 0))) > 0
		or int(data.get("lifetime_eldritch_ascensions", data.get("eldritch_ascensions", 0))) > 0
		or int(data.get("divine_ascensions", 0)) > 0
		or (data.get("unlocked_achievements", []) as Array).size() > 0
	)

func _browser_save_has_more_progress(candidate: Dictionary, baseline: Dictionary) -> bool:
	var numeric_fields := [
		"lifetime_pitches", "lifetime_xp", "lifetime_strikeouts", "lifetime_loot_found",
		"lifetime_field_taps", "lifetime_genetic_rebirths", "lifetime_eldritch_ascensions",
		"divine_ascensions", "divine_halos", "body_growth_level",
	]
	for field in numeric_fields:
		var candidate_value := float(candidate.get(field, 0.0))
		var baseline_value := float(baseline.get(field, 0.0))
		if candidate_value > baseline_value + maxf(absf(baseline_value) * 0.000000001, 0.000001):
			return true
	if (
		bool(candidate.get("human_league_completed_as_toddler", false))
		and not bool(baseline.get("human_league_completed_as_toddler", false))
	):
		return true
	return (candidate.get("unlocked_achievements", []) as Array).size() > (baseline.get("unlocked_achievements", []) as Array).size()

func _clear_browser_recovery_mirrors() -> void:
	if not is_web_build:
		return
	var storage: Variant = JavaScriptBridge.get_interface("localStorage")
	if storage != null:
		storage.removeItem(BROWSER_SAVE_MIRROR_KEY)
		storage.removeItem(BROWSER_SAVE_ROLLBACK_KEY)

func _browser_save_slot_key(slot_index: int) -> String:
	return "no_hitter_manual_save_slot_%d" % (clampi(slot_index, 0, BROWSER_MANUAL_SAVE_SLOT_COUNT - 1) + 1)

func _manual_save_slot_path(slot_index: int) -> String:
	return "user://no_hitter_manual_save_slot_%d.json" % (
		clampi(slot_index, 0, BROWSER_MANUAL_SAVE_SLOT_COUNT - 1) + 1
	)

func _read_browser_save_slot(slot_index: int) -> Dictionary:
	var slot_text := ""
	var slot_path := _manual_save_slot_path(slot_index)
	if FileAccess.file_exists(slot_path):
		var file := FileAccess.open(slot_path, FileAccess.READ)
		if file != null and file.get_length() <= BaseballGameState.MAX_IMPORTED_SAVE_CHARACTERS:
			slot_text = file.get_as_text()
		if file != null:
			file.close()
	# Existing phone installations stored these slots synchronously in
	# localStorage. Keep reading that generation as a migration and redundancy
	# path so the new cross-platform picker never strands it after an update.
	if slot_text.is_empty() and is_web_build:
		var storage: Variant = JavaScriptBridge.get_interface("localStorage")
		if storage != null:
			slot_text = str(storage.getItem(_browser_save_slot_key(slot_index)))
	var decoded := game.decode_save_text(slot_text)
	return decoded.data if bool(decoded.get("ok", false)) else {}

func _format_browser_save_slot(slot_index: int, data: Dictionary) -> String:
	return _format_named_save("SLOT %d" % (slot_index + 1), data)

func _refresh_browser_save_slots() -> void:
	if browser_save_slots_panel == null:
		return
	for slot_index in browser_save_slot_entries.size():
		var entry: Dictionary = browser_save_slot_entries[slot_index]
		var data := _read_browser_save_slot(slot_index)
		(entry.label as Label).text = _format_browser_save_slot(slot_index, data)
		(entry.load_button as Button).disabled = data.is_empty()

func _save_browser_slot(slot_index: int) -> void:
	if game == null or development_session:
		return
	if game.save_writes_locked:
		_show_save_recovery_required()
		return
	if not game.save_game():
		return
	var save_text := game.get_save_json()
	var file := FileAccess.open(_manual_save_slot_path(slot_index), FileAccess.WRITE)
	if file == null:
		_show_save_transfer_error("This device is not allowing a manual save slot.")
		return
	file.store_string(save_text)
	file.close()
	if is_web_build:
		var storage: Variant = JavaScriptBridge.get_interface("localStorage")
		if storage != null:
			storage.setItem(_browser_save_slot_key(slot_index), save_text)
		JavaScriptBridge.force_fs_sync()
	_refresh_browser_save_slots()
	if title_screen_active and title_resume_stack.visible:
		_refresh_title_save_picker()
	_on_save_status_changed("Saved to slot %d" % (slot_index + 1))
	_log_event("Manual save written to Slot %d." % (slot_index + 1))

func _load_browser_slot(slot_index: int) -> void:
	var data := _read_browser_save_slot(slot_index)
	if data.is_empty():
		return
	_stage_import_save(JSON.stringify(data), "Phone Slot %d" % (slot_index + 1))

func _input(event: InputEvent) -> void:
	# Observe without consuming the event. The embedded ScrollContainer keeps its
	# native drag behavior while a stationary touch can become an inspection.
	if not mobile_layout or locker_dialog == null or not locker_dialog.visible:
		_cancel_locker_item_hold()
		return
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_begin_locker_item_hold_at(touch.position)
		else:
			_cancel_locker_item_hold()
	elif event is InputEventScreenDrag and not held_locker_item_id.is_empty():
		held_locker_item_drag_distance += (event as InputEventScreenDrag).relative.length()
		if held_locker_item_drag_distance > LOCKER_ITEM_DRAG_CANCEL_DISTANCE:
			_cancel_locker_item_hold()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and game != null:
		if not development_session and not game.save_writes_locked:
			game.save_game()
		get_tree().quit()
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_web_build and game != null:
		_mark_browser_background(Time.get_unix_time_from_system())
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN and is_web_build and game != null:
		var now := Time.get_unix_time_from_system()
		# Returning to a long-running idle tab is the most useful time to ask the
		# service worker whether a newer release has landed.
		web_update_check_elapsed = WEB_UPDATE_CHECK_INTERVAL
		_resume_browser_background(web_backgrounded_at, now)
		_refresh_mobile_install_offer()

func _configure_platform_ui() -> void:
	if not is_web_build:
		return
	web_storage_persistent = OS.is_userfs_persistent()
	if not JavaScriptBridge.pwa_update_available.is_connected(_on_browser_update_available):
		JavaScriptBridge.pwa_update_available.connect(_on_browser_update_available)
	if JavaScriptBridge.pwa_needs_update():
		_on_browser_update_available()
	var storage_note := (
		"Progress is stored in this browser. EXPORT creates a portable backup."
		if web_storage_persistent
		else "This browser is not providing persistent storage. EXPORT a backup before leaving."
	)
	save_button.tooltip_text = storage_note
	export_save_button.tooltip_text = "Download a portable JSON backup of this run."
	load_save_button.tooltip_text = "Choose a portable JSON backup to replace the current run. On mobile, use Browse / Locations to select an enabled Google Drive provider directly."
	save_label.tooltip_text = storage_note
	_refresh_mobile_install_offer()

func _mobile_install_offer_for_state(
	web_build: bool,
	ios_device: bool,
	android_device: bool,
	standalone: bool,
	already_installed := false
) -> bool:
	return (
		web_build
		and (ios_device or android_device)
		and not standalone
		and not already_installed
	)

func _get_mobile_install_platform() -> String:
	if not is_web_build:
		return ""
	var ios_result = JavaScriptBridge.eval(
		"(/iPhone|iPad|iPod/.test(navigator.userAgent) || (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1))",
		true
	)
	if bool(ios_result):
		return "ios"
	var android_result = JavaScriptBridge.eval("/Android/i.test(navigator.userAgent)", true)
	return "android" if bool(android_result) else ""

func _should_offer_mobile_install() -> bool:
	if not is_web_build:
		return false
	var platform := _get_mobile_install_platform()
	var standalone_result = JavaScriptBridge.eval(
		"(window.matchMedia('(display-mode: standalone)').matches || window.navigator.standalone === true)",
		true
	)
	var installed_result = JavaScriptBridge.eval(
		"Boolean(window.OFPS_PWA && window.OFPS_PWA.isInstalled())",
		true
	)
	return _mobile_install_offer_for_state(
		true,
		platform == "ios",
		platform == "android",
		bool(standalone_result),
		bool(installed_result)
	)

func _set_mobile_install_offer_visible(visible: bool) -> void:
	if mobile_install_button == null:
		return
	mobile_install_button.visible = visible
	if mobile_nav != null:
		mobile_nav.queue_sort()

func _refresh_mobile_install_offer() -> void:
	var platform := _get_mobile_install_platform()
	mobile_install_button.tooltip_text = (
		"Install No Hitter on this Android device."
		if platform == "android"
		else "Add No Hitter to this iPhone's Home Screen."
	)
	_set_mobile_install_offer_visible(_should_offer_mobile_install())

func _configure_mobile_install_dialog(platform: String) -> void:
	if mobile_install_dialog == null:
		return
	if platform == "android":
		mobile_install_dialog.title = "INSTALL ON ANDROID"
		mobile_install_dialog.dialog_text = (
			"1. Open this game in Chrome.\n\n"
			+ "2. Tap Chrome's ⋮ menu, then tap INSTALL APP or ADD TO HOME SCREEN.\n\n"
			+ "3. Confirm Install, then launch the game from its new app icon.\n\n"
			+ "The installed game stays on the browser update channel and will offer REVIEW UPDATE when a new build is ready. Export a portable backup before accepting an update."
		)
	else:
		mobile_install_dialog.title = "INSTALL ON IPHONE"
		mobile_install_dialog.dialog_text = (
			"1. Tap Safari's SHARE button (the square with an up arrow).\n\n"
			+ "2. Scroll down and tap ADD TO HOME SCREEN.\n\n"
			+ "3. Tap ADD, then launch the game from its new Home Screen icon.\n\n"
			+ "EXPORT a backup first. If iOS starts the installed game with a fresh save, use IMPORT to bring your run across. IMPORT can browse Google Drive when Drive is enabled under Files > Browse > Locations. If Add to Home Screen is missing, open this page in Safari."
		)

func _show_mobile_install() -> void:
	if mobile_install_dialog == null:
		return
	var platform := _get_mobile_install_platform()
	if platform == "android":
		var prompted = JavaScriptBridge.eval(
			"Boolean(window.OFPS_PWA && window.OFPS_PWA.promptInstall())",
			true
		)
		if bool(prompted):
			return
	_configure_mobile_install_dialog(platform)
	mobile_install_dialog.popup_centered_clamped(Vector2i(360, 365), 0.95)

func _enable_mobile_inspection(control: Control, title: String) -> void:
	control.set_meta("mobile_inspection_title", title)
	control.mouse_default_cursor_shape = Control.CURSOR_HELP
	if control is BaseButton:
		(control as BaseButton).pressed.connect(_show_mobile_inspection_for_control.bind(control))
	else:
		control.gui_input.connect(_on_mobile_inspection_input.bind(control))

func _on_mobile_inspection_input(event: InputEvent, control: Control) -> void:
	if not mobile_layout:
		return
	var activated := (
		(event is InputEventScreenTouch and (event as InputEventScreenTouch).pressed)
		or (
			event is InputEventMouseButton
			and (event as InputEventMouseButton).pressed
			and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT
		)
	)
	if activated:
		_show_mobile_inspection_for_control(control)

func _show_mobile_inspection_for_control(control: Control) -> void:
	if not mobile_layout or mobile_inspection_dialog == null or control == null:
		return
	var details := control.tooltip_text.strip_edges()
	if details.is_empty():
		return
	mobile_inspection_dialog.title = str(
		control.get_meta("mobile_inspection_title", "DETAILS")
	).to_upper()
	mobile_inspection_dialog.dialog_text = details
	mobile_inspection_dialog.popup_centered_clamped(Vector2i(360, 245), 0.94)
	mobile_inspection_dialog.get_ok_button().set_deferred(
		"custom_minimum_size",
		Vector2(100.0, 44.0)
	)

func _update_browser_release_status(delta: float) -> void:
	web_update_status_elapsed += delta
	web_update_check_elapsed += delta
	if web_update_status_elapsed >= 1.0:
		web_update_status_elapsed = 0.0
		_refresh_mobile_install_offer()
		if JavaScriptBridge.pwa_needs_update():
			_on_browser_update_available()
		elif web_update_ready:
			web_update_ready = false
			update_banner.visible = false
			if title_screen_active:
				_refresh_title_layout()
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
		if title_screen_active:
			_refresh_title_layout()

func _snooze_browser_update() -> void:
	# LATER also cancels the short pre-activation save window. Once the worker is
	# activating this button is disabled so it never promises to cancel a reload
	# that the browser has already accepted.
	web_update_attempt_serial += 1
	_reset_browser_update_attempt()
	web_update_snoozed_until = Time.get_unix_time_from_system() + WEB_UPDATE_SNOOZE_SECONDS
	update_banner.visible = false
	if title_screen_active:
		_refresh_title_layout()

func _request_browser_update() -> void:
	if web_update_installing or not is_web_build or not JavaScriptBridge.pwa_needs_update():
		return
	_show_browser_update_confirmation()

func _reset_browser_update_attempt(message := "") -> void:
	web_update_installing = false
	if update_now_button == null or update_later_button == null:
		return
	update_now_button.disabled = false
	update_later_button.disabled = false
	update_now_button.text = "REVIEW" if mobile_layout else "REVIEW UPDATE"
	update_banner_label.text = (
		message
		if not message.is_empty()
		else ("UPDATE • BACK UP FIRST" if mobile_layout else "UPDATE READY • EXPORT BACKUP FIRST")
	)

func _show_browser_update_confirmation() -> void:
	# Restore any reparented mobile menu before opening a Window. In particular,
	# this keeps an update requested from SAVES from fighting that full-screen
	# overlay for focus and ensures the save controls have a valid home at reload.
	if mobile_overlay_control != null:
		_close_mobile_overlay()
	var viewport_size := _get_responsive_viewport_size()
	var compact := (
		mobile_layout
		or _is_portrait_viewport(viewport_size)
		or viewport_size.x < 600.0
	)
	_configure_browser_update_confirmation(compact)
	var requested_size := Vector2i(320, 210) if compact else Vector2i(440, 210)
	var clamp_ratio := 0.88 if compact else 0.94
	browser_update_confirmation.popup_centered_clamped(requested_size, clamp_ratio)

func _configure_browser_update_confirmation(for_mobile: bool) -> void:
	browser_update_confirmation.title = "BACK UP YOUR SAVE"
	browser_update_confirmation.dialog_text = (
		"Choose EXPORT for a portable backup, or install the update now.\n\n"
		+ "Progress should be preserved, but browser storage can still be cleared."
	)
	browser_update_confirmation.ok_button_text = "UPDATE"
	browser_update_confirmation.cancel_button_text = "LATER"
	browser_update_confirmation.min_size = (
		Vector2i(260, 170) if for_mobile else Vector2i(360, 180)
	)

func _handle_browser_update_custom_action(action: StringName) -> void:
	if action != &"export_backup":
		return
	# Defer the shared export flow until the confirmation has released its modal
	# focus. Closing the window or choosing LATER remains a true cancel action.
	browser_update_confirmation.hide()
	call_deferred("_request_export_save")

func _install_browser_update() -> void:
	if web_update_installing or not is_web_build or not JavaScriptBridge.pwa_needs_update():
		return
	if game != null and game.save_writes_locked:
		_show_save_recovery_required()
		return
	web_update_installing = true
	web_update_attempt_serial += 1
	var attempt_serial := web_update_attempt_serial
	update_now_button.disabled = true
	update_later_button.disabled = false
	update_banner_label.text = "SAVING YOUR RUN…"
	if game != null and not development_session:
		if not game.save_game():
			_reset_browser_update_attempt("SAVE FAILED • EXPORT OR RETRY")
			_show_save_transfer_error(
				"The update was not installed because the automatic save could not be verified. Export a backup or try again."
			)
			return
		_write_browser_save_mirror()
	# Web saves live in IndexedDB. Flush them before asking the service worker to
	# activate the new release and reload every open game tab.
	JavaScriptBridge.force_fs_sync()
	# Godot's Web filesystem flush is asynchronous. The synchronous localStorage
	# mirror is already complete; this window gives IndexedDB time to catch up.
	await get_tree().create_timer(WEB_UPDATE_SAVE_FLUSH_SECONDS, true, false, true).timeout
	if attempt_serial != web_update_attempt_serial or not web_update_installing:
		return
	update_banner_label.text = "INSTALLING UPDATE…"
	update_later_button.disabled = true
	# The stock Godot worker uses Client.navigate(), which iOS Home Screen apps can
	# silently ignore after activation. The page bridge listens for controllerchange
	# and guarantees a bounded location.reload() fallback instead.
	var bridge_started = JavaScriptBridge.eval(
		"Boolean(window.OFPS_PWA && window.OFPS_PWA.activateWaitingUpdate && window.OFPS_PWA.activateWaitingUpdate())",
		true
	)
	var update_error := OK if bool(bridge_started) else JavaScriptBridge.pwa_update()
	if update_error != OK:
		_reset_browser_update_attempt("UPDATE READY • RELOAD OR RETRY")
		_log_event("The browser could not activate the update automatically. Reload this page or tap Review to try again.")
		return
	await get_tree().create_timer(WEB_UPDATE_RELOAD_WATCHDOG_SECONDS, true, false, true).timeout
	if attempt_serial != web_update_attempt_serial or not web_update_installing:
		return
	# This normally never returns because navigation destroys the old page. Keep a
	# second independent reload request in case an older cached bridge was partial.
	JavaScriptBridge.eval(
		"Boolean(window.OFPS_PWA && window.OFPS_PWA.forceUpdateReload ? window.OFPS_PWA.forceUpdateReload() : (window.location.reload(), true))",
		true
	)
	await get_tree().create_timer(1.50, true, false, true).timeout
	if attempt_serial == web_update_attempt_serial and web_update_installing:
		_reset_browser_update_attempt("UPDATE READY • CLOSE AND REOPEN")
		_log_event("The update was saved, but this browser declined the automatic reload. Close and reopen the app to finish.")

func _poll_browser_lifecycle(delta: float) -> void:
	if not is_web_build or game == null:
		return
	web_lifecycle_poll_elapsed += maxf(delta, 0.0)
	if web_lifecycle_poll_elapsed < 0.25:
		return
	web_lifecycle_poll_elapsed = 0.0
	var raw_snapshot: Variant = JavaScriptBridge.eval(
		"window.OFPS_PWA && window.OFPS_PWA.lifecycleSnapshot ? window.OFPS_PWA.lifecycleSnapshot() : ''",
		true
	)
	var parsed: Variant = JSON.parse_string(str(raw_snapshot))
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var snapshot: Dictionary = parsed
	var serial := int(snapshot.get("serial", -1))
	if serial <= web_lifecycle_serial:
		return
	web_lifecycle_serial = serial
	var lifecycle_state := str(snapshot.get("state", "visible"))
	var hidden_at := maxf(float(snapshot.get("hiddenAt", 0.0)), 0.0)
	if lifecycle_state == "hidden":
		_mark_browser_background(hidden_at)
	else:
		_resume_browser_background(hidden_at, Time.get_unix_time_from_system())

func _mark_browser_background(hidden_at: float) -> void:
	if not is_web_build or game == null:
		return
	var bounded_hidden_at := hidden_at if hidden_at > 0.0 else Time.get_unix_time_from_system()
	if web_backgrounded_at > 0.0:
		web_backgrounded_at = minf(web_backgrounded_at, bounded_hidden_at)
		return
	web_backgrounded_at = bounded_hidden_at
	if not development_session and not game.save_writes_locked:
		game.save_game()
		_write_browser_save_mirror()
		JavaScriptBridge.force_fs_sync()

func _resume_browser_background(hidden_at: float, now: float) -> void:
	if not is_web_build:
		return
	var effective_hidden_at := hidden_at
	if web_backgrounded_at > 0.0:
		effective_hidden_at = (
			minf(effective_hidden_at, web_backgrounded_at)
			if effective_hidden_at > 0.0
			else web_backgrounded_at
		)
	if (
		effective_hidden_at > 0.0
		and effective_hidden_at > web_last_recovered_hidden_at + 1.0
	):
		_apply_browser_offline_catchup(maxf(now - effective_hidden_at, 0.0))
		web_last_recovered_hidden_at = effective_hidden_at
	web_backgrounded_at = 0.0
	web_last_wall_clock = now

func _consume_browser_wall_clock(delta: float) -> float:
	if not is_web_build:
		return delta
	var now := Time.get_unix_time_from_system()
	if web_last_wall_clock <= 0.0:
		web_last_wall_clock = now
		return delta
	var wall_seconds := maxf(now - web_last_wall_clock, 0.0)
	web_last_wall_clock = now
	var split := _split_browser_elapsed(wall_seconds, delta)
	_apply_browser_offline_catchup(float(split.offline))
	return float(split.live)

func _split_browser_elapsed(wall_seconds: float, delta: float) -> Dictionary:
	# Safari may resume a frozen Home Screen app with one enormous frame delta,
	# so comparing wall time to delta loses the entire away period. Treat any
	# wall gap over one second as suspended time except for a small live frame.
	if wall_seconds <= 1.0:
		# A lifecycle resume may already have consumed the wall-clock gap and reset
		# the reference clock before this same giant frame reaches us. Never replay
		# that giant delta as foreground simulation a second time.
		return {"live": minf(maxf(delta, 0.0), 0.25) if delta > 1.0 else delta, "offline": 0.0}
	var live_seconds := minf(maxf(delta, 0.0), 0.25)
	return {
		"live": live_seconds,
		"offline": maxf(wall_seconds - live_seconds, 0.0),
	}

func _apply_browser_offline_catchup(seconds: float) -> void:
	if seconds < 1.0 or game == null:
		return
	var summary := game.simulate_offline(seconds)
	if pitch_field != null:
		pitch_field.reset_visual_state()
	if not summary.is_empty():
		_log_offline_summary(summary, "Browser catch-up")
	_refresh_interface()
	if not development_session and not game.save_writes_locked:
		game.save_game()

func _log_offline_summary(summary: Dictionary, prefix: String) -> void:
	var loot_note := ""
	if int(summary.get("loot_found", 0)) > 0:
		loot_note = " Locker parcels: %d found, %d kept, %d cleared by slot limits." % [
			int(summary.get("loot_found", 0)),
			int(summary.get("loot_kept", 0)),
			int(summary.get("loot_discarded", 0)),
		]
		var scrap_gained := float(summary.get("loot_scrap_gained", 0.0))
		if scrap_gained > 0.0:
			loot_note += " Scrap recovered: %s." % BaseballGameState.format_number(scrap_gained, 0)
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
	_show_offline_progress(summary, prefix)

func _show_offline_progress(summary: Dictionary, prefix: String) -> void:
	var earned_xp := float(summary.get("earned_xp", 0.0))
	if earned_xp <= 0.0 or offline_progress_dialog == null:
		return
	if title_screen_active:
		pending_title_offline_summary = summary.duplicate(true)
		pending_title_offline_prefix = prefix
		return
	var detail_lines: Array[String] = [
		"Away for %s" % BaseballGameState.format_duration(float(summary.get("offline_seconds", 0.0))),
		"Offline efficiency: %.0f%%" % (float(summary.get("offline_xp_efficiency", 0.0)) * 100.0),
	]
	var strikeouts := float(summary.get("strikeouts", 0.0))
	if strikeouts > 0.0:
		detail_lines.append("Strikeouts completed: %s" % BaseballGameState.format_number(strikeouts))
	var loot_found := int(summary.get("loot_found", 0))
	if loot_found > 0:
		detail_lines.append("Locker parcels found: %d" % loot_found)
	var scrap_gained := float(summary.get("loot_scrap_gained", 0.0))
	if scrap_gained > 0.0:
		detail_lines.append("Scrap recovered: %s" % BaseballGameState.format_number(scrap_gained, 0))
	offline_progress_dialog.title = prefix.to_upper()
	offline_progress_dialog.dialog_text = (
		"+%s XP\n\n%s"
		% [BaseballGameState.format_number(earned_xp, 3), "\n".join(detail_lines)]
	)
	offline_progress_dialog.popup_centered_clamped(Vector2i(440, 270), 0.92)

func _apply_development_arguments() -> void:
	var arguments := OS.get_cmdline_user_args()
	if "--fresh" in arguments:
		development_session = true
		game.reset_fresh()
		_clear_achievement_toasts()
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
	_clear_achievement_toasts()
	game.highest_unlocked = 34 if preview == "alien" else (43 if preview == "eldritch" else 44)
	game.current_opponent = 33 if preview == "alien" else game.highest_unlocked
	game._sync_distance_to_current_opponent()
	game._reset_batter_identity()
	game.genetic_offer_unlocked = true
	game.genetic_rebirths = 1
	game.eldritch_offer_unlocked = preview != "alien"
	game.eldritch_ascensions = 1 if preview != "alien" else 0
	game.training_levels = {
		"velocity": 180 if preview == "alien" else 315,
		"command": 385 if preview == "alien" else 730,
		"field_hustle": BaseballGameState.FIELD_TAP_MAX_RANK,
		"recovery": 26,
		"turnover": 10,
		"hit_recovery": 8,
		"pitch_calling": 12,
		"distance_control": 20,
		"offline_efficiency": 24,
	}
	for definition in Content.GENETIC_UPGRADES:
		game.genetic_levels[definition.id] = mini(int(definition.max_level), 2) if preview == "alien" else int(definition.max_level)
	if preview != "alien":
		for definition in Content.ELDRITCH_UPGRADES:
			game.eldritch_levels[definition.id] = mini(int(definition.max_level), 3) if preview == "eldritch" else int(definition.max_level)
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

func _compact_panel_style(horizontal_margin: float, vertical_margin: float, radius := 8) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_PANEL
	style.border_color = Color("263750")
	style.set_border_width_all(1)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = horizontal_margin
	style.content_margin_right = horizontal_margin
	style.content_margin_top = vertical_margin
	style.content_margin_bottom = vertical_margin
	return style

func _scroll_content_gutter(scroll: ScrollContainer, right_margin := 14) -> MarginContainer:
	# Godot places the vertical bar over the ScrollContainer's content width. A
	# real layout gutter keeps text, stars, and BUY buttons clear at every scale.
	var gutter := MarginContainer.new()
	gutter.name = "ScrollContentGutter"
	gutter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gutter.size_flags_vertical = Control.SIZE_EXPAND_FILL
	gutter.add_theme_constant_override("margin_right", right_margin)
	scroll.add_child(gutter)
	return gutter

func _create_navigation_icon(direction: String) -> ImageTexture:
	var image := Image.create(28, 28, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	var points: Array[Vector2i] = []
	for step in 10:
		points.append(Vector2i(19 - step, 5 + step))
		points.append(Vector2i(10 + step, 14 + step))
	for source in points:
		var target := source
		match direction:
			"right":
				target.x = 27 - source.x
			"up":
				target = Vector2i(source.y, source.x)
			"down":
				target = Vector2i(source.y, 27 - source.x)
		for offset_x in range(-1, 2):
			for offset_y in range(-1, 2):
				var pixel := target + Vector2i(offset_x, offset_y)
				if pixel.x >= 0 and pixel.x < 28 and pixel.y >= 0 and pixel.y < 28:
					image.set_pixelv(pixel, COLOR_TEXT)
	return ImageTexture.create_from_image(image)

func _ensure_navigation_icons() -> void:
	if previous_navigation_icon == null:
		previous_navigation_icon = _create_navigation_icon("left")
	if next_navigation_icon == null:
		next_navigation_icon = _create_navigation_icon("right")

func _create_favorite_icon(filled: bool) -> ImageTexture:
	var image := Image.create(28, 28, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	var polygon := PackedVector2Array()
	for point_index in 10:
		var radius := 10.5 if point_index % 2 == 0 else 4.6
		var angle := -PI * 0.5 + float(point_index) * PI / 5.0
		polygon.append(Vector2(14.0, 14.0) + Vector2(cos(angle), sin(angle)) * radius)
	for y in range(2, 26):
		for x in range(2, 26):
			var point := Vector2(float(x) + 0.5, float(y) + 0.5)
			if not Geometry2D.is_point_in_polygon(point, polygon):
				continue
			var edge := false
			if not filled:
				for offset in [Vector2(-1.5, 0.0), Vector2(1.5, 0.0), Vector2(0.0, -1.5), Vector2(0.0, 1.5)]:
					if not Geometry2D.is_point_in_polygon(point + offset, polygon):
						edge = true
						break
			if filled or edge:
				image.set_pixel(x, y, COLOR_GOLD if filled else COLOR_MUTED)
	return ImageTexture.create_from_image(image)

func _ensure_favorite_icons() -> void:
	if favorite_open_icon == null:
		favorite_open_icon = _create_favorite_icon(false)
	if favorite_kept_icon == null:
		favorite_kept_icon = _create_favorite_icon(true)

func _configure_tab_overflow_controls(for_mobile: bool) -> void:
	if upgrade_tabs == null or mobile_tab_navigation == null:
		return
	# The native TabBar grows a tiny, scrollbar-adjacent overflow pair as soon as
	# the catalog no longer fits. Those controls are hard to read on desktop and
	# nearly impossible to tap on a phone, so every layout uses one explicit
	# previous/current/next navigator instead.
	mobile_tab_navigation.visible = true
	var tab_bar := upgrade_tabs.get_tab_bar()
	tab_bar.visible = false
	tab_bar.scrolling_enabled = false
	var arrow_size := float(MOBILE_TAB_ARROW_TOUCH_SIZE if for_mobile else 38)
	mobile_tab_previous_button.custom_minimum_size = Vector2(arrow_size, arrow_size)
	mobile_tab_next_button.custom_minimum_size = Vector2(arrow_size, arrow_size)
	mobile_tab_label_card.custom_minimum_size.y = 48.0 if for_mobile else 38.0
	mobile_tab_label.add_theme_font_size_override("font_size", 18 if for_mobile else 14)
	mobile_tab_navigation.add_theme_constant_override("separation", 8 if for_mobile else 6)
	_refresh_mobile_tab_navigation()

func _visible_upgrade_tab_indices() -> Array[int]:
	var visible_indices: Array[int] = []
	for tab_index in upgrade_tabs.get_tab_count():
		if not upgrade_tabs.is_tab_hidden(tab_index):
			visible_indices.append(tab_index)
	return visible_indices

func _move_mobile_upgrade_tab(direction: int) -> void:
	var visible_indices := _visible_upgrade_tab_indices()
	var visible_position := visible_indices.find(upgrade_tabs.current_tab)
	if visible_position < 0:
		return
	var target_position := visible_position + direction
	if target_position < 0 or target_position >= visible_indices.size():
		return
	upgrade_tabs.current_tab = visible_indices[target_position]
	_refresh_mobile_tab_navigation()

func _refresh_mobile_tab_navigation(_tab_index := -1) -> void:
	if mobile_tab_previous_button == null or mobile_tab_next_button == null:
		return
	var visible_indices := _visible_upgrade_tab_indices()
	var visible_position := visible_indices.find(upgrade_tabs.current_tab)
	if mobile_tab_label != null and visible_position >= 0:
		mobile_tab_label.text = "%s  •  %d / %d" % [
			upgrade_tabs.get_tab_title(upgrade_tabs.current_tab),
			visible_position + 1,
			visible_indices.size(),
		]
	mobile_tab_previous_button.disabled = visible_position <= 0
	mobile_tab_next_button.disabled = (
		visible_position < 0 or visible_position >= visible_indices.size() - 1
	)

func _on_upgrade_tab_changed(tab_index: int) -> void:
	_refresh_mobile_tab_navigation(tab_index)
	_refresh_achievement_tab(true)

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

	page_scroll = ScrollContainer.new()
	page_scroll.name = "PageScroll"
	page_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	page_scroll.follow_focus = true
	root_margin.add_child(page_scroll)

	page_container = VBoxContainer.new()
	page_container.name = "Page"
	page_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page_container.add_theme_constant_override("separation", 10)
	page_scroll.add_child(page_container)
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
	_build_achievement_toast()
	_build_title_screen()

func _build_title_screen() -> void:
	title_screen = ColorRect.new()
	title_screen.name = "TitleScreen"
	title_screen.color = COLOR_BG
	title_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title_screen.mouse_filter = Control.MOUSE_FILTER_STOP
	title_screen.z_index = 350
	title_screen_active = true
	add_child(title_screen)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title_screen.add_child(center)
	title_panel = PanelContainer.new()
	title_panel.name = "TitlePanel"
	var title_surface := _compact_panel_style(22.0, 18.0, 14)
	title_surface.bg_color = Color("0d1727")
	title_surface.border_color = Color("2a4260")
	title_surface.set_border_width_all(2)
	title_panel.add_theme_stylebox_override("panel", title_surface)
	center.add_child(title_panel)

	title_root_stack = VBoxContainer.new()
	title_root_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_root_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	title_root_stack.add_theme_constant_override("separation", 12)
	title_panel.add_child(title_root_stack)

	title_heading_label = Label.new()
	title_heading_label.text = "NO HITTER"
	title_heading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_heading_label.add_theme_font_size_override("font_size", 46)
	title_heading_label.add_theme_color_override("font_color", COLOR_ACCENT)
	title_root_stack.add_child(title_heading_label)
	title_subtitle_label = Label.new()
	title_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_subtitle_label.add_theme_font_size_override("font_size", 15)
	title_subtitle_label.add_theme_color_override("font_color", COLOR_MUTED)
	title_root_stack.add_child(title_subtitle_label)

	title_layout_grid = GridContainer.new()
	title_layout_grid.name = "TitleLayout"
	title_layout_grid.columns = 2
	title_layout_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_layout_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	title_layout_grid.add_theme_constant_override("h_separation", 18)
	title_layout_grid.add_theme_constant_override("v_separation", 12)
	title_root_stack.add_child(title_layout_grid)

	title_hero_stack = VBoxContainer.new()
	title_hero_stack.name = "TitleHero"
	title_hero_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_hero_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	title_hero_stack.size_flags_stretch_ratio = 1.7
	title_hero_stack.add_theme_constant_override("separation", 7)
	title_layout_grid.add_child(title_hero_stack)

	title_art_frame = PanelContainer.new()
	title_art_frame.name = "TitleArtFrame"
	title_art_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_art_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var art_frame_style := _compact_panel_style(4.0, 4.0, 10)
	art_frame_style.bg_color = Color("07101b")
	art_frame_style.border_color = Color("355371")
	art_frame_style.set_border_width_all(2)
	title_art_frame.add_theme_stylebox_override("panel", art_frame_style)
	title_hero_stack.add_child(title_art_frame)
	title_art = TitleArtScript.new()
	title_art.name = "ProgressiveTitleArt"
	title_art.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_art.size_flags_vertical = Control.SIZE_EXPAND_FILL
	title_art.custom_minimum_size.y = 320.0
	title_art_frame.add_child(title_art)

	title_progress_label = Label.new()
	title_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_progress_label.add_theme_font_size_override("font_size", 12)
	title_progress_label.add_theme_color_override("font_color", COLOR_GOLD)
	title_hero_stack.add_child(title_progress_label)

	title_action_panel = PanelContainer.new()
	title_action_panel.name = "TitleActions"
	title_action_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_action_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	title_action_panel.size_flags_stretch_ratio = 0.9
	var action_style := _compact_panel_style(15.0, 14.0, 10)
	action_style.bg_color = Color("111e31")
	action_style.border_color = Color("2b4462")
	title_action_panel.add_theme_stylebox_override("panel", action_style)
	title_layout_grid.add_child(title_action_panel)
	var action_stack := VBoxContainer.new()
	action_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	action_stack.add_theme_constant_override("separation", 10)
	title_action_panel.add_child(action_stack)
	title_action_heading = Label.new()
	title_action_heading.text = "YOUR RUN AWAITS"
	title_action_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_action_heading.add_theme_font_size_override("font_size", 13)
	title_action_heading.add_theme_color_override("font_color", COLOR_GOLD)
	action_stack.add_child(title_action_heading)
	var action_spacer := Control.new()
	action_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	action_stack.add_child(action_spacer)

	title_menu_stack = VBoxContainer.new()
	title_menu_stack.add_theme_constant_override("separation", 9)
	action_stack.add_child(title_menu_stack)
	var resume_button := _title_menu_button("RESUME GAME", true)
	resume_button.pressed.connect(_open_title_resume_picker)
	title_menu_stack.add_child(resume_button)
	var new_game_button := _title_menu_button("START NEW GAME")
	new_game_button.tooltip_text = "Begin from the backyard. Existing progress requires a typed RESET; manual slots and exported backups remain."
	new_game_button.pressed.connect(_request_new_game_from_title)
	title_menu_stack.add_child(new_game_button)
	var import_button := _title_menu_button("IMPORT SAVE")
	import_button.tooltip_text = "Choose a portable No Hitter JSON backup. Mobile system pickers can browse Files and an enabled Google Drive provider directly."
	import_button.pressed.connect(_request_load_save)
	title_menu_stack.add_child(import_button)

	title_resume_stack = VBoxContainer.new()
	title_resume_stack.visible = false
	title_resume_stack.add_theme_constant_override("separation", 6)
	action_stack.add_child(title_resume_stack)
	var resume_heading := Label.new()
	resume_heading.text = "CHOOSE A SAVE"
	resume_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	resume_heading.add_theme_font_size_override("font_size", 15)
	resume_heading.add_theme_color_override("font_color", COLOR_ACCENT)
	title_resume_stack.add_child(resume_heading)
	var autosave_row := _title_save_row("AUTOSAVE")
	title_resume_stack.add_child(autosave_row.container)
	title_autosave_label = autosave_row.label
	title_autosave_button = autosave_row.button
	title_autosave_button.pressed.connect(_resume_loaded_autosave)
	for slot_index in BROWSER_MANUAL_SAVE_SLOT_COUNT:
		var slot_row := _title_save_row("SLOT %d" % (slot_index + 1))
		title_resume_stack.add_child(slot_row.container)
		(slot_row.button as Button).pressed.connect(_load_browser_slot.bind(slot_index))
		title_manual_slot_entries.append(slot_row)
	var back_button := _title_menu_button("BACK")
	back_button.pressed.connect(_close_title_resume_picker)
	title_resume_stack.add_child(back_button)
	var action_bottom_spacer := Control.new()
	action_bottom_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	action_stack.add_child(action_bottom_spacer)
	var transfer_hint := Label.new()
	transfer_hint.text = "AUTOSAVE ON  •  BACKUPS ARE PORTABLE JSON"
	transfer_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	transfer_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	transfer_hint.add_theme_font_size_override("font_size", 10)
	transfer_hint.add_theme_color_override("font_color", COLOR_MUTED)
	action_stack.add_child(transfer_hint)

func _title_menu_button(text_value: String, primary := false) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size.y = 52.0
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 16)
	if primary:
		var normal := _compact_panel_style(12.0, 8.0, 8)
		normal.bg_color = Color("1f617b")
		normal.border_color = COLOR_ACCENT
		normal.set_border_width_all(2)
		var hover := normal.duplicate() as StyleBoxFlat
		hover.bg_color = Color("287c9d")
		var pressed := normal.duplicate() as StyleBoxFlat
		pressed.bg_color = Color("174a60")
		button.add_theme_stylebox_override("normal", normal)
		button.add_theme_stylebox_override("hover", hover)
		button.add_theme_stylebox_override("pressed", pressed)
		button.add_theme_color_override("font_color", Color.WHITE)
	return button

func _title_save_row(default_text: String) -> Dictionary:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _compact_panel_style(8.0, 5.0, 7))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	panel.add_child(row)
	var label := Label.new()
	label.text = "%s\nEMPTY" % default_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", COLOR_TEXT)
	row.add_child(label)
	var button := Button.new()
	button.text = "LOAD"
	button.custom_minimum_size = Vector2(72.0, 44.0)
	button.focus_mode = Control.FOCUS_ALL
	row.add_child(button)
	return {"container": panel, "label": label, "button": button}

func _show_title_screen(save_current := true) -> void:
	if title_screen == null:
		return
	if mobile_overlay_control != null:
		_close_mobile_overlay()
	if save_current and not development_session and not game.save_writes_locked:
		game.save_game()
		autosave_elapsed = 0.0
	title_screen_active = true
	title_menu_stack.visible = true
	title_resume_stack.visible = false
	title_action_heading.text = "YOUR RUN AWAITS"
	_refresh_title_screen()
	_refresh_title_layout()
	title_screen.visible = true
	title_screen.move_to_front()

func _return_to_title_screen() -> void:
	_show_title_screen(true)

func _leave_title_screen(show_pending_offline := true) -> void:
	if title_screen == null:
		return
	title_screen_active = false
	title_screen.visible = false
	title_menu_stack.visible = true
	title_resume_stack.visible = false
	title_action_heading.text = "YOUR RUN AWAITS"
	if show_pending_offline and not pending_title_offline_summary.is_empty():
		var summary := pending_title_offline_summary.duplicate(true)
		var prefix := pending_title_offline_prefix
		pending_title_offline_summary.clear()
		_show_offline_progress(summary, prefix)
	_refresh_interface()

func _refresh_title_screen() -> void:
	if title_screen == null or game == null:
		return
	title_subtitle_label.text = _get_game_subtitle()
	var highest := game.get_historical_highest_opponent()
	var has_progress := _browser_save_has_progress(game.to_save_data())
	if has_progress:
		var era_index := clampi(int(highest / 5), 0, Content.ERA_NAMES.size() - 1)
		title_progress_label.text = "FARTHEST REACHED • LEVEL %02d • %s" % [
			highest + 1,
			str(Content.ERA_NAMES[era_index]),
		]
	else:
		title_progress_label.text = "THE BACKYARD IS WAITING"
	title_art.configure(
		highest,
		_has_genetic_reveal(),
		_has_eldritch_reveal(),
		_has_divine_reveal()
	)

func _refresh_title_layout() -> void:
	if title_panel == null:
		return
	_configure_title_layout(_get_responsive_viewport_size())

func _configure_title_layout(viewport_size: Vector2) -> void:
	if title_panel == null:
		return
	var portrait := _is_portrait_viewport(viewport_size)
	var compact_title := portrait or viewport_size.x < 760.0
	var choosing_save := title_resume_stack != null and title_resume_stack.visible
	var panel_width := (
		clampf(viewport_size.x - 24.0, 300.0, 620.0)
		if compact_title
		else clampf(viewport_size.x - 64.0, 760.0, 1120.0)
	)
	var panel_height := (
		clampf(viewport_size.y - 24.0, 460.0, 820.0)
		if compact_title
		else clampf(viewport_size.y - 64.0, 520.0, 680.0)
	)
	title_panel.custom_minimum_size = Vector2(panel_width, panel_height)
	title_layout_grid.columns = 1 if compact_title else 2
	title_layout_grid.add_theme_constant_override("h_separation", 12 if compact_title else 18)
	title_layout_grid.add_theme_constant_override("v_separation", 10 if compact_title else 12)
	title_heading_label.add_theme_font_size_override("font_size", 38 if compact_title else 52)
	title_heading_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	var reserve_update_banner := (
		is_web_build and update_banner != null and update_banner.visible
	)
	title_heading_label.custom_minimum_size.y = (
		(66.0 if compact_title else 86.0) if reserve_update_banner else 0.0
	)
	title_subtitle_label.add_theme_font_size_override("font_size", 14 if compact_title else 16)
	title_subtitle_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART if compact_title else TextServer.AUTOWRAP_OFF
	)
	title_root_stack.add_theme_constant_override("separation", 9 if compact_title else 12)
	title_action_panel.custom_minimum_size.x = 0.0 if compact_title else 330.0
	title_action_panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL if choosing_save or not compact_title else Control.SIZE_FILL
	)
	# The art gives way to the save list only on a narrow portrait screen. A wide
	# title keeps its matchup tableau visible, so desktop no longer looks like a
	# stretched phone menu.
	title_hero_stack.visible = not (compact_title and choosing_save)
	title_art_frame.visible = title_hero_stack.visible
	title_progress_label.visible = title_hero_stack.visible
	title_art.custom_minimum_size.y = (
		clampf(panel_height - 420.0, 180.0, 360.0)
		if compact_title
		else clampf(panel_height - 150.0, 360.0, 520.0)
	)

func _open_title_resume_picker() -> void:
	_refresh_title_save_picker()
	title_menu_stack.visible = false
	title_resume_stack.visible = true
	title_action_heading.text = "CHOOSE A SAVE"
	_refresh_title_layout()

func _close_title_resume_picker() -> void:
	title_resume_stack.visible = false
	title_menu_stack.visible = true
	title_action_heading.text = "YOUR RUN AWAITS"
	_refresh_title_layout()

func _refresh_title_save_picker() -> void:
	var autosave_data := game.to_save_data()
	var autosave_available := (
		game.last_load_succeeded
		or _browser_save_has_progress(autosave_data)
		or FileAccess.file_exists(BaseballGameState.SAVE_PATH)
		or FileAccess.file_exists(BaseballGameState.SAVE_BACKUP_PATH)
	)
	title_autosave_label.text = (
		_format_named_save("AUTOSAVE", autosave_data)
		if autosave_available
		else "AUTOSAVE\nEMPTY"
	)
	title_autosave_button.disabled = not autosave_available
	for slot_index in title_manual_slot_entries.size():
		var entry: Dictionary = title_manual_slot_entries[slot_index]
		var data := _read_browser_save_slot(slot_index)
		(entry.label as Label).text = _format_browser_save_slot(slot_index, data)
		(entry.button as Button).disabled = data.is_empty()

func _format_named_save(name: String, data: Dictionary) -> String:
	if data.is_empty():
		return "%s\nEMPTY" % name
	var timestamp := Time.get_datetime_dict_from_unix_time(int(data.get("saved_at", 0)))
	return "%s\nLEVEL %d • %s XP • %02d/%02d %02d:%02d" % [
		name,
		clampi(int(data.get("current_opponent", 0)) + 1, 1, Content.OPPONENT_NAMES.size()),
		BaseballGameState.format_xp_total(maxf(float(data.get("xp", 0.0)), 0.0)),
		int(timestamp.get("month", 0)),
		int(timestamp.get("day", 0)),
		int(timestamp.get("hour", 0)),
		int(timestamp.get("minute", 0)),
	]

func _resume_loaded_autosave() -> void:
	_leave_title_screen()

func _request_new_game_from_title() -> void:
	var has_current_progress := (
		game.save_writes_locked
		or game.last_load_succeeded
		or _browser_save_has_progress(game.to_save_data())
		or FileAccess.file_exists(BaseballGameState.SAVE_PATH)
		or FileAccess.file_exists(BaseballGameState.SAVE_BACKUP_PATH)
	)
	if not has_current_progress:
		_start_fresh_title_game()
		return
	pending_new_game_from_title = true
	_request_hard_reset()

func _start_fresh_title_game() -> void:
	pending_title_offline_summary.clear()
	game.reset_fresh()
	game.save_writes_locked = false
	browser_save_regression_allowed = true
	pitch_field.reset_visual_state()
	last_reveal_mask = -1
	last_loot_revision = -1
	last_loot_ui_signature = ""
	last_owned_upgrade_list_signature = ""
	opponent_loadout_signature = ""
	event_log.clear()
	if not development_session:
		game.save_game()
	_leave_title_screen(false)
	_log_event("A new backyard career begins at one foot per second.")

func _build_update_banner() -> void:
	update_banner = PanelContainer.new()
	update_banner.name = "BrowserUpdateBanner"
	update_banner.visible = false
	update_banner.z_index = 400
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
	update_banner_label.text = "UPDATE READY • EXPORT BACKUP FIRST"
	update_banner_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	update_banner_label.add_theme_color_override("font_color", COLOR_GOOD)
	update_banner_label.add_theme_font_size_override("font_size", 13)
	row.add_child(update_banner_label)
	update_now_button = Button.new()
	update_now_button.text = "REVIEW UPDATE"
	update_now_button.tooltip_text = "Review the save-backup warning before installing the browser update."
	update_now_button.pressed.connect(_request_browser_update)
	row.add_child(update_now_button)
	update_later_button = Button.new()
	update_later_button.text = "LATER"
	update_later_button.tooltip_text = "Hide this reminder for ten minutes."
	update_later_button.pressed.connect(_snooze_browser_update)
	row.add_child(update_later_button)

func _build_achievement_toast() -> void:
	achievement_toast = PanelContainer.new()
	achievement_toast.name = "AchievementToast"
	achievement_toast.visible = false
	achievement_toast.z_index = 290
	achievement_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	achievement_toast.set_anchors_preset(Control.PRESET_CENTER_TOP)
	achievement_toast.offset_left = -225.0
	achievement_toast.offset_top = 76.0
	achievement_toast.offset_right = 225.0
	achievement_toast.offset_bottom = 174.0
	var toast_style := _compact_panel_style(14.0, 9.0, 9)
	toast_style.bg_color = Color("162234")
	toast_style.border_color = COLOR_GOLD
	toast_style.set_border_width_all(2)
	achievement_toast.add_theme_stylebox_override("panel", toast_style)
	add_child(achievement_toast)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 2)
	achievement_toast.add_child(stack)
	achievement_toast_heading = Label.new()
	achievement_toast_heading.text = "ACHIEVEMENT UNLOCKED  •  +1% XP"
	achievement_toast_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	achievement_toast_heading.add_theme_font_size_override("font_size", 11)
	achievement_toast_heading.add_theme_color_override("font_color", COLOR_GOLD)
	stack.add_child(achievement_toast_heading)
	achievement_toast_name = Label.new()
	achievement_toast_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	achievement_toast_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	achievement_toast_name.add_theme_font_size_override("font_size", 17)
	achievement_toast_name.add_theme_color_override("font_color", COLOR_TEXT)
	stack.add_child(achievement_toast_name)
	achievement_toast_description = Label.new()
	achievement_toast_description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	achievement_toast_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	achievement_toast_description.max_lines_visible = 2
	achievement_toast_description.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	achievement_toast_description.add_theme_font_size_override("font_size", 11)
	achievement_toast_description.add_theme_color_override("font_color", COLOR_MUTED)
	stack.add_child(achievement_toast_description)

func _build_header(parent: Control) -> void:
	header_panel = PanelContainer.new()
	header_panel.add_theme_stylebox_override("panel", _compact_panel_style(10.0, 6.0))
	parent.add_child(header_panel)
	header_row = HBoxContainer.new()
	header_row.add_theme_constant_override("separation", 20)
	header_panel.add_child(header_row)
	header_title_stack = VBoxContainer.new()
	header_row.add_child(header_title_stack)
	header_title = Label.new()
	header_title.text = "NO HITTER"
	header_title.add_theme_font_size_override("font_size", 27)
	header_title.add_theme_color_override("font_color", COLOR_ACCENT)
	header_title_stack.add_child(header_title)
	header_subtitle = Label.new()
	header_subtitle.text = "A baseball game about a regular ol’ toddler"
	header_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
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
	save_stack.add_theme_constant_override("separation", 1)
	header_row.add_child(save_stack)
	save_action_row = HBoxContainer.new()
	save_action_row.add_theme_constant_override("separation", 3)
	save_stack.add_child(save_action_row)
	save_button = Button.new()
	save_button.text = "SAVES"
	save_button.custom_minimum_size = Vector2(54.0, 32.0)
	save_button.add_theme_font_size_override("font_size", 11)
	save_button.tooltip_text = "Open autosave, manual save slots, export, import, and title-screen controls."
	save_button.pressed.connect(_open_saves_menu)
	save_action_row.add_child(save_button)
	export_save_button = Button.new()
	export_save_button.text = "EXPORT"
	export_save_button.custom_minimum_size = Vector2(58.0, 32.0)
	export_save_button.add_theme_font_size_override("font_size", 10)
	export_save_button.tooltip_text = "Write a portable JSON backup of this run."
	export_save_button.pressed.connect(_request_export_save)
	save_action_row.add_child(export_save_button)
	load_save_button = Button.new()
	load_save_button.text = "IMPORT"
	load_save_button.custom_minimum_size = Vector2(60.0, 32.0)
	load_save_button.add_theme_font_size_override("font_size", 10)
	load_save_button.tooltip_text = "Import a portable JSON backup after confirmation. Mobile file pickers can browse an enabled Google Drive provider directly."
	load_save_button.pressed.connect(_request_load_save)
	save_action_row.add_child(load_save_button)
	hard_reset_button = Button.new()
	hard_reset_button.text = "RESET PROGRESS"
	hard_reset_button.custom_minimum_size = Vector2(104.0, 32.0)
	hard_reset_button.add_theme_font_size_override("font_size", 9)
	hard_reset_button.tooltip_text = "Permanently erase this save. Requires typing RESET in a confirmation window."
	hard_reset_button.pressed.connect(_request_hard_reset)
	save_action_row.add_child(hard_reset_button)
	var save_status_row := HBoxContainer.new()
	save_status_row.add_theme_constant_override("separation", 4)
	save_stack.add_child(save_status_row)
	save_label = Label.new()
	save_label.text = "autosave on"
	save_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	save_label.add_theme_font_size_override("font_size", 10)
	save_label.add_theme_color_override("font_color", COLOR_MUTED)
	save_status_row.add_child(save_label)
	return_to_title_button = Button.new()
	return_to_title_button.text = "TITLE"
	return_to_title_button.custom_minimum_size = Vector2(48.0, 24.0)
	return_to_title_button.add_theme_font_size_override("font_size", 9)
	return_to_title_button.tooltip_text = "Save the current run and return to the title screen."
	return_to_title_button.pressed.connect(_return_to_title_screen)
	save_status_row.add_child(return_to_title_button)
	_build_browser_save_slots(save_stack)

func _build_browser_save_slots(parent: Control) -> void:
	browser_save_slots_panel = VBoxContainer.new()
	browser_save_slots_panel.name = "BrowserManualSaveSlots"
	browser_save_slots_panel.visible = false
	browser_save_slots_panel.add_theme_constant_override("separation", 5)
	parent.add_child(browser_save_slots_panel)
	var heading := Label.new()
	heading.text = "MANUAL SAVE SLOTS"
	heading.add_theme_font_size_override("font_size", 12)
	heading.add_theme_color_override("font_color", COLOR_ACCENT)
	browser_save_slots_panel.add_child(heading)
	var note := Label.new()
	note.text = "Stored on this device. EXPORT is portable; IMPORT can browse Files, iCloud, or an enabled Drive provider."
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_font_size_override("font_size", 10)
	note.add_theme_color_override("font_color", COLOR_MUTED)
	browser_save_slots_panel.add_child(note)
	for slot_index in BROWSER_MANUAL_SAVE_SLOT_COUNT:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 5)
		browser_save_slots_panel.add_child(row)
		var summary_label := Label.new()
		summary_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		summary_label.add_theme_font_size_override("font_size", 11)
		summary_label.add_theme_color_override("font_color", COLOR_TEXT)
		row.add_child(summary_label)
		var save_slot_button := Button.new()
		save_slot_button.text = "SAVE"
		save_slot_button.custom_minimum_size = Vector2(58.0, 44.0)
		save_slot_button.focus_mode = Control.FOCUS_NONE
		save_slot_button.pressed.connect(_save_browser_slot.bind(slot_index))
		row.add_child(save_slot_button)
		var load_slot_button := Button.new()
		load_slot_button.text = "LOAD"
		load_slot_button.custom_minimum_size = Vector2(58.0, 44.0)
		load_slot_button.focus_mode = Control.FOCUS_NONE
		load_slot_button.pressed.connect(_load_browser_slot.bind(slot_index))
		row.add_child(load_slot_button)
		browser_save_slot_entries.append({
			"label": summary_label,
			"save_button": save_slot_button,
			"load_button": load_slot_button,
		})

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
		["STATUS", "Stats, ball, pitches, body, and owned upgrades", func() -> void: _show_mobile_overlay(equipment_sidebar, "STATUS")],
		["LOG", "Recent game events", func() -> void: _show_mobile_overlay(event_log_panel, "EVENT LOG")],
		["SAVES", "Save, export, load, or reset this run", func() -> void: _show_mobile_overlay(save_stack, "SAVES & TRANSFER")],
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
	mobile_install_button = Button.new()
	mobile_install_button.name = "MobileInstallButton"
	mobile_install_button.text = "INSTALL"
	mobile_install_button.tooltip_text = "Install No Hitter on this phone."
	mobile_install_button.custom_minimum_size.y = 44.0
	mobile_install_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mobile_install_button.focus_mode = Control.FOCUS_NONE
	mobile_install_button.add_theme_font_size_override("font_size", 10)
	mobile_install_button.add_theme_color_override("font_color", COLOR_GOLD)
	mobile_install_button.pressed.connect(_show_mobile_install)
	mobile_install_button.visible = false
	mobile_nav.add_child(mobile_install_button)

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
	mobile_overlay_xp_label = Label.new()
	mobile_overlay_xp_label.name = "MobileOverlayXP"
	mobile_overlay_xp_label.visible = false
	mobile_overlay_xp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	mobile_overlay_xp_label.add_theme_font_size_override("font_size", 13)
	mobile_overlay_xp_label.add_theme_color_override("font_color", COLOR_GOLD)
	mobile_overlay_xp_label.tooltip_text = "XP available to spend"
	heading_row.add_child(mobile_overlay_xp_label)
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
	if control == null or (not mobile_layout and control != save_stack):
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
	if control == save_stack:
		_refresh_browser_save_slots()
		browser_save_slots_panel.visible = true
		save_button.text = "SAVE AUTOSAVE NOW"
	mobile_overlay_title.text = title
	mobile_overlay_xp_label.visible = control == upgrade_panel
	mobile_overlay_xp_label.text = "XP %s" % BaseballGameState.format_xp_total(game.xp)
	mobile_overlay_panel.visible = true
	mobile_overlay_panel.move_to_front()
	_configure_menu_overlay_geometry()

func _configure_menu_overlay_geometry() -> void:
	if mobile_overlay_surface == null:
		return
	if mobile_layout:
		mobile_overlay_surface.set_anchors_preset(Control.PRESET_FULL_RECT)
		mobile_overlay_surface.offset_left = 5.0
		mobile_overlay_surface.offset_top = 5.0
		mobile_overlay_surface.offset_right = -5.0
		mobile_overlay_surface.offset_bottom = -5.0
	else:
		mobile_overlay_surface.set_anchors_preset(Control.PRESET_CENTER)
		mobile_overlay_surface.offset_left = -360.0
		mobile_overlay_surface.offset_top = -310.0
		mobile_overlay_surface.offset_right = 360.0
		mobile_overlay_surface.offset_bottom = 310.0

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
			browser_save_slots_panel.visible = mobile_layout
			save_button.text = "SAVES"
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
	var portrait := _is_portrait_viewport(viewport_size)
	var should_use_mobile := is_web_build and _should_use_compact_layout(
		viewport_size,
		mobile_layout,
		responsive_layout_initialized
	)
	var should_use_dense := is_web_build and viewport_size.y < WEB_DENSE_MAX_HEIGHT
	responsive_layout_initialized = true
	_set_mobile_layout(should_use_mobile, portrait, should_use_dense)
	_refresh_title_layout()

func _is_portrait_viewport(viewport_size: Vector2) -> bool:
	return viewport_size.y > viewport_size.x * 1.08

func _should_use_compact_layout(
	viewport_size: Vector2,
	current_compact := false,
	apply_hysteresis := false
) -> bool:
	if _is_portrait_viewport(viewport_size):
		return true
	var minimum_width := WEB_WIDE_MIN_WIDTH
	var minimum_height := WEB_WIDE_MIN_HEIGHT
	# Hysteresis is deliberately one-sided: an already-wide layout may shrink a
	# little before collapsing, but compact mode returns to wide at the declared
	# safe boundary. Applying the buffer to compact-mode re-entry used to require
	# 1304×744, so an ordinary 720 px-tall browser could remain compact forever
	# no matter how wide the window became.
	if apply_hysteresis and not current_compact:
		minimum_width -= WEB_LAYOUT_HYSTERESIS
	return viewport_size.x < minimum_width or viewport_size.y < minimum_height

func _set_mobile_layout(enabled: bool, portrait := true, dense := false) -> void:
	var layout_changed := enabled != mobile_layout
	var portrait_changed := enabled and portrait != mobile_portrait_layout
	var density_changed := dense != web_dense_layout
	if not layout_changed and not portrait_changed and not density_changed:
		return
	web_dense_layout = dense
	if not enabled:
		mobile_layout = false
		mobile_portrait_layout = false
		_close_mobile_overlay()
	else:
		mobile_layout = true
		mobile_portrait_layout = portrait
		_close_mobile_overlay()

	var dense_wide := web_dense_layout and not mobile_layout
	root_margin.add_theme_constant_override("margin_left", 5 if mobile_layout else (10 if dense_wide else 14))
	root_margin.add_theme_constant_override("margin_right", 5 if mobile_layout else (10 if dense_wide else 14))
	root_margin.add_theme_constant_override("margin_top", 5 if mobile_layout else (6 if dense_wide else 12))
	root_margin.add_theme_constant_override("margin_bottom", 5 if mobile_layout else (6 if dense_wide else 12))
	update_banner.offset_left = -176.0 if mobile_layout else -280.0
	update_banner.offset_right = 176.0 if mobile_layout else 280.0
	update_banner.offset_top = 5.0 if mobile_layout else 10.0
	update_banner.offset_bottom = 61.0 if mobile_layout else 66.0
	update_banner_label.add_theme_font_size_override("font_size", 11 if mobile_layout else 13)
	if not update_now_button.disabled:
		update_banner_label.text = "UPDATE • BACK UP FIRST" if mobile_layout else "UPDATE READY • EXPORT BACKUP FIRST"
	update_now_button.text = "REVIEW" if mobile_layout else "REVIEW UPDATE"
	update_now_button.custom_minimum_size.x = 66.0 if mobile_layout else 0.0
	update_now_button.add_theme_font_size_override("font_size", 10 if mobile_layout else 16)
	update_later_button.custom_minimum_size.x = 50.0 if mobile_layout else 0.0
	update_later_button.add_theme_font_size_override("font_size", 10 if mobile_layout else 16)
	if achievement_toast != null:
		achievement_toast.offset_left = -176.0 if mobile_layout else -225.0
		achievement_toast.offset_right = 176.0 if mobile_layout else 225.0
		achievement_toast.offset_top = 62.0 if mobile_layout else 76.0
		achievement_toast.offset_bottom = 158.0 if mobile_layout else 174.0
		achievement_toast_heading.add_theme_font_size_override("font_size", 10 if mobile_layout else 11)
		achievement_toast_name.add_theme_font_size_override("font_size", 14 if mobile_layout else 17)
		achievement_toast_description.add_theme_font_size_override("font_size", 10 if mobile_layout else 11)
	page_container.add_theme_constant_override("separation", 4 if mobile_layout else (6 if dense_wide else 10))
	body_container.add_theme_constant_override("separation", 0 if mobile_layout else (8 if dense_wide else 10))
	header_row.add_theme_constant_override("separation", 7 if mobile_layout else (12 if dense_wide else 20))
	header_title.add_theme_font_size_override("font_size", 18 if mobile_layout else (21 if dense_wide else 24))
	header_title_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL if mobile_layout else Control.SIZE_FILL
	header_title_stack.custom_minimum_size.x = 175.0 if mobile_layout else (280.0 if dense_wide else 360.0)
	header_spacer.visible = not mobile_layout
	header_subtitle.visible = true
	header_subtitle.custom_minimum_size.x = 175.0 if mobile_layout else 0.0
	header_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if mobile_layout else TextServer.AUTOWRAP_OFF
	header_subtitle.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	header_subtitle.add_theme_font_size_override("font_size", 10 if mobile_layout else (11 if dense_wide else 12))
	for index in header_metric_stacks.size():
		header_metric_stacks[index].custom_minimum_size.x = 64.0 if mobile_layout else (84.0 if dense_wide else 108.0)
		header_metric_headings[index].add_theme_font_size_override("font_size", 9 if mobile_layout else (10 if dense_wide else 11))
		var value_label := header_metric_stacks[index].get_child(1) as Label
		value_label.add_theme_font_size_override("font_size", 16 if mobile_layout else (18 if dense_wide else 20))
	if header_metric_headings.size() >= 3:
		header_metric_headings[1].text = "XP / S" if mobile_layout else "XP / SECOND"
		header_metric_headings[2].text = "DNA • ARCANA"
	prestige_header_stack.visible = _has_genetic_reveal() and not mobile_layout
	save_stack.visible = not mobile_layout
	browser_save_slots_panel.visible = mobile_layout or mobile_overlay_control == save_stack
	return_to_title_button.text = "RETURN TO TITLE" if mobile_layout else "TITLE"
	return_to_title_button.custom_minimum_size = (
		Vector2(132.0, 44.0) if mobile_layout else Vector2(48.0, 24.0)
	)
	return_to_title_button.add_theme_font_size_override("font_size", 11 if mobile_layout else 9)
	mobile_nav.visible = mobile_layout
	upgrade_panel.visible = not mobile_layout
	equipment_sidebar.visible = not mobile_layout
	event_log_panel.visible = not mobile_layout
	upgrade_panel.custom_minimum_size.x = 0.0 if mobile_layout else (350.0 if dense_wide else 370.0)
	equipment_sidebar.custom_minimum_size.x = 0.0 if mobile_layout else (220.0 if dense_wide else 250.0)
	equipment_sidebar_heading.text = "STATUS & LOADOUT" if mobile_layout else "LOADOUT"
	equipment_stats_section.visible = mobile_layout
	mobile_upgrade_stats_panel.visible = mobile_layout
	for catalog_toggle in catalog_hide_purchased_toggles.values():
		(catalog_toggle as CheckButton).custom_minimum_size.y = 44.0 if mobile_layout else 0.0
	if achievement_hide_achieved_toggle != null:
		achievement_hide_achieved_toggle.custom_minimum_size.y = 44.0 if mobile_layout else 0.0
	for achievement_entry_value in achievement_cards.values():
		var achievement_entry: Dictionary = achievement_entry_value
		(achievement_entry.details_button as Button).custom_minimum_size = Vector2(
			78.0,
			44.0 if mobile_layout else 36.0
		)
	for collection in [training_buttons, pitch_buttons, ball_upgrade_buttons, milestone_buttons, body_growth_buttons, genetic_buttons, eldritch_buttons, divine_buttons]:
		for entry_value in collection.values():
			var entry: Dictionary = entry_value
			(entry.container as PanelContainer).custom_minimum_size.y = 88.0 if mobile_layout else 82.0
			(entry.label as Label).add_theme_font_size_override("font_size", 15 if mobile_layout else 15)
			(entry.button as Button).custom_minimum_size = Vector2(76.0, 44.0)
			(entry.button as Button).add_theme_font_size_override("font_size", 12)
	_configure_tab_overflow_controls(mobile_layout)
	play_stack.add_theme_constant_override("separation", 4 if mobile_layout else (5 if dense_wide else 8))
	opponent_row.add_theme_constant_override("separation", 5 if mobile_layout else (8 if dense_wide else 12))
	previous_button.custom_minimum_size.x = 44.0 if mobile_layout else (116.0 if dense_wide else 140.0)
	next_button.custom_minimum_size.x = 44.0 if mobile_layout else (116.0 if dense_wide else 140.0)
	previous_button.custom_minimum_size.y = 44.0 if mobile_layout else 0.0
	next_button.custom_minimum_size.y = 44.0 if mobile_layout else 0.0
	if mobile_layout:
		_ensure_navigation_icons()
		previous_button.text = ""
		next_button.text = ""
		previous_button.icon = previous_navigation_icon
		next_button.icon = next_navigation_icon
		previous_button.expand_icon = true
		next_button.expand_icon = true
	else:
		previous_button.icon = null
		next_button.icon = null
		previous_button.text = "< PREVIOUS BATTER"
		next_button.text = "NEXT BATTER >"
	opponent_label.add_theme_font_size_override("font_size", 18 if mobile_layout else (21 if dense_wide else 25))
	quirk_label.add_theme_font_size_override("font_size", 11 if mobile_layout else (12 if dense_wide else 14))
	era_label.add_theme_font_size_override("font_size", 10 if mobile_layout else (11 if dense_wide else 13))
	distance_label.add_theme_font_size_override("font_size", 11 if mobile_layout else (12 if dense_wide else 13))
	field_stack.add_theme_constant_override("separation", 3 if mobile_layout or dense_wide else 7)
	if mobile_layout:
		pitch_field.custom_minimum_size = Vector2(
			0.0,
			MOBILE_PORTRAIT_FIELD_MIN_HEIGHT if mobile_portrait_layout else 220.0
		)
	elif dense_wide:
		pitch_field.custom_minimum_size = Vector2(400.0, 250.0)
	else:
		pitch_field.custom_minimum_size = Vector2(450.0, 360.0)
	pitch_field.set_portrait_layout(mobile_layout and mobile_portrait_layout)
	visual_weight_label.visible = not mobile_layout
	visual_weight_label.custom_minimum_size.x = 190.0 if dense_wide else 245.0
	last_result_label.add_theme_font_size_override("font_size", 12 if mobile_layout else (14 if dense_wide else 18))
	mastery_label.add_theme_font_size_override("font_size", 11 if mobile_layout or dense_wide else 13)
	outcomes_grid.columns = 4 if mobile_layout and mobile_portrait_layout else Content.OUTCOME_NAMES.size()
	for index in outcome_panels.size():
		outcome_name_labels[index].add_theme_font_size_override("font_size", 9 if mobile_layout and mobile_portrait_layout else (10 if web_dense_layout else 11))
		outcome_probability_labels[index].add_theme_font_size_override("font_size", 12 if mobile_layout else (15 if dense_wide else 16))
		outcome_delay_labels[index].add_theme_font_size_override("font_size", 8 if mobile_layout else (9 if dense_wide else 10))
	frustration_label.add_theme_font_size_override("font_size", 8 if mobile_layout else (9 if dense_wide else 10))
	frustration_bar.custom_minimum_size = Vector2(55.0 if mobile_layout else 90.0, 6.0 if mobile_layout else 7.0)
	strikeout_payout_label.add_theme_font_size_override("font_size", 9 if mobile_layout else (10 if dense_wide else 11))
	mobile_nav.custom_minimum_size.y = 44.0 if mobile_portrait_layout else 34.0
	for mobile_button in mobile_nav.get_children():
		(mobile_button as Button).custom_minimum_size.y = 44.0 if mobile_portrait_layout else 34.0
	event_log_panel.custom_minimum_size.y = 44.0 if dense_wide else 72.0
	event_log.add_theme_font_size_override("normal_font_size", 12 if dense_wide else 14)
	field_stat_panel.offset_left = 6.0 if mobile_layout else 10.0
	field_stat_panel.offset_top = 6.0 if mobile_layout else 10.0
	# The phone readout only needs enough room for a short label and value. Keeping
	# it clear of the centered pitcher matters more than preserving desktop width.
	field_stat_panel.offset_right = 138.0 if mobile_layout else 210.0
	field_stat_panel.offset_bottom = 154.0 if mobile_layout else 172.0
	for field_value_value in field_stat_labels.values():
		var field_value := field_value_value as Label
		field_value.custom_minimum_size.x = 0.0
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
	_configure_menu_overlay_geometry()
	root_margin.queue_sort()
	_refresh_interface()

func _build_play_area(parent: Control) -> void:
	play_panel = PanelContainer.new()
	play_panel.add_theme_stylebox_override("panel", _compact_panel_style(10.0, 7.0))
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
	previous_button.text = "< PREVIOUS BATTER"
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
	_enable_mobile_inspection(quirk_label, "Batter details")
	next_button = Button.new()
	next_button.text = "NEXT BATTER >"
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
	pitch_field.field_tapped.connect(_on_field_tapped)
	pitch_field.batter_call_displayed.connect(_on_batter_call_displayed)
	field_stack.add_child(pitch_field)
	_build_field_stat_overlay(pitch_field)
	_build_inventory_dock(pitch_field)
	_build_opponent_loadout_dock(pitch_field)
	_build_alien_help_button(pitch_field)

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
	_enable_mobile_inspection(mastery_label, "Opponent mastery")
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
		outcome_panel.add_theme_stylebox_override("panel", _compact_panel_style(5.0, 3.0, 6))
		outcomes_grid.add_child(outcome_panel)
		outcome_panels.append(outcome_panel)
		_enable_mobile_inspection(outcome_panel, str(Content.OUTCOME_NAMES[index]))
		var outcome_stack := VBoxContainer.new()
		outcome_stack.add_theme_constant_override("separation", 0)
		outcome_panel.add_child(outcome_stack)
		var outcome_heading := HBoxContainer.new()
		outcome_heading.add_theme_constant_override("separation", 2)
		outcome_stack.add_child(outcome_heading)
		var name_label := Label.new()
		name_label.text = str(Content.OUTCOME_NAMES[index])
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size", 11)
		name_label.add_theme_color_override("font_color", Content.OUTCOME_COLORS[index])
		outcome_heading.add_child(name_label)
		outcome_name_labels.append(name_label)
		var delay_label := Label.new()
		delay_label.text = "+0s"
		delay_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		delay_label.add_theme_font_size_override("font_size", 10)
		delay_label.add_theme_color_override("font_color", COLOR_MUTED)
		outcome_heading.add_child(delay_label)
		outcome_delay_labels.append(delay_label)
		var probability_label := Label.new()
		probability_label.text = "0.00%"
		probability_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		probability_label.add_theme_font_size_override("font_size", 16)
		outcome_stack.add_child(probability_label)
		outcome_probability_labels.append(probability_label)
	outcome_footer = HBoxContainer.new()
	outcome_footer.add_theme_constant_override("separation", 8)
	field_stack.add_child(outcome_footer)
	frustration_status = HBoxContainer.new()
	frustration_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frustration_status.add_theme_constant_override("separation", 5)
	outcome_footer.add_child(frustration_status)
	frustration_label = Label.new()
	frustration_label.add_theme_font_size_override("font_size", 10)
	frustration_label.add_theme_color_override("font_color", COLOR_GOLD)
	frustration_label.mouse_default_cursor_shape = Control.CURSOR_HELP
	_enable_mobile_inspection(frustration_label, "Frustration")
	frustration_status.add_child(frustration_label)
	frustration_bar = ProgressBar.new()
	frustration_bar.min_value = 0.0
	frustration_bar.max_value = 100.0
	frustration_bar.show_percentage = false
	frustration_bar.custom_minimum_size = Vector2(75.0, 7.0)
	frustration_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frustration_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frustration_status.add_child(frustration_bar)
	strikeout_payout_label = Label.new()
	strikeout_payout_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	strikeout_payout_label.add_theme_font_size_override("font_size", 11)
	strikeout_payout_label.add_theme_color_override("font_color", COLOR_MUTED)
	outcome_footer.add_child(strikeout_payout_label)

func _build_distance_status(parent: Control) -> void:
	distance_label = Label.new()
	distance_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	distance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	distance_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	distance_label.add_theme_font_size_override("font_size", 13)
	distance_label.add_theme_color_override("font_color", COLOR_GOLD)
	distance_label.tooltip_text = "This opponent level sets the active range. Distance Control reduces its added threat; released balls keep their original range."
	distance_label.mouse_default_cursor_shape = Control.CURSOR_HELP
	_enable_mobile_inspection(distance_label, "Level range")
	parent.add_child(distance_label)

func _build_equipment_sidebar(parent: Control) -> void:
	equipment_sidebar = ScrollContainer.new()
	equipment_sidebar.custom_minimum_size.x = 250.0
	equipment_sidebar.size_flags_horizontal = Control.SIZE_FILL
	equipment_sidebar.size_flags_vertical = Control.SIZE_EXPAND_FILL
	equipment_sidebar.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	parent.add_child(equipment_sidebar)
	var sidebar_gutter := _scroll_content_gutter(equipment_sidebar, 12)
	var sidebar := VBoxContainer.new()
	sidebar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sidebar.add_theme_constant_override("separation", 6)
	sidebar_gutter.add_child(sidebar)
	equipment_sidebar_heading = Label.new()
	equipment_sidebar_heading.text = "LOADOUT"
	equipment_sidebar_heading.add_theme_font_size_override("font_size", 13)
	equipment_sidebar_heading.add_theme_color_override("font_color", COLOR_ACCENT)
	sidebar.add_child(equipment_sidebar_heading)
	equipment_stats_section = VBoxContainer.new()
	equipment_stats_section.name = "StatusStatSection"
	equipment_stats_section.visible = false
	equipment_stats_section.add_theme_constant_override("separation", 2)
	sidebar.add_child(equipment_stats_section)
	var stats_heading := Label.new()
	stats_heading.text = "CURRENT STATS"
	stats_heading.add_theme_font_size_override("font_size", 11)
	stats_heading.add_theme_color_override("font_color", COLOR_ACCENT)
	equipment_stats_section.add_child(stats_heading)
	_build_status_stat_list(equipment_stats_section)
	_equipment_card(sidebar, "ball", "CURRENT BALL")
	_equipment_card(sidebar, "pitch", "PITCH ARSENAL")
	_equipment_card(sidebar, "body", "BODY")
	equipment_progression_heading = Label.new()
	equipment_progression_heading.text = "OWNED FACILITIES"
	equipment_progression_heading.add_theme_font_size_override("font_size", 11)
	equipment_progression_heading.add_theme_color_override("font_color", COLOR_ACCENT)
	sidebar.add_child(equipment_progression_heading)
	equipment_progression_list = VBoxContainer.new()
	equipment_progression_list.name = "OwnedUpgradeList"
	equipment_progression_list.add_theme_constant_override("separation", 4)
	sidebar.add_child(equipment_progression_list)
	equipment_summary_label = Label.new()
	equipment_summary_label.text = "No facilities owned yet"
	equipment_summary_label.add_theme_font_size_override("font_size", 12)
	equipment_summary_label.add_theme_color_override("font_color", COLOR_MUTED)
	equipment_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	equipment_progression_list.add_child(equipment_summary_label)

func _build_status_stat_list(parent: Control) -> void:
	var rows := [
		["speed", "SPEED"],
		["quality", "QUALITY"],
		["recovery", "RECOVERY"],
		["lineup", "LINEUP"],
		["hit_delay", "HIT DELAY"],
		["calling", "CALLING"],
		["distance", "DISTANCE"],
		["tap", "FIELD TAP"],
		["offline", "OFFLINE"],
	]
	for row_definition in rows:
		var stat_id := str(row_definition[0])
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		row.tooltip_text = str(Content.STAT_HELP.get(stat_id, ""))
		row.mouse_default_cursor_shape = Control.CURSOR_HELP
		_enable_mobile_inspection(row, str(row_definition[1]))
		parent.add_child(row)
		var name_label := Label.new()
		name_label.text = str(row_definition[1])
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.add_theme_font_size_override("font_size", 11)
		name_label.add_theme_color_override("font_color", COLOR_MUTED)
		name_label.tooltip_text = row.tooltip_text
		row.add_child(name_label)
		var value_label := Label.new()
		value_label.custom_minimum_size.x = 82.0
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		value_label.add_theme_font_size_override("font_size", 12)
		value_label.add_theme_color_override("font_color", COLOR_TEXT)
		value_label.tooltip_text = row.tooltip_text
		row.add_child(value_label)
		status_stat_labels[stat_id] = value_label

func _build_alien_help_button(parent: Control) -> void:
	alien_help_button = Button.new()
	alien_help_button.name = "AlienHelpButton"
	alien_help_button.text = "HELP"
	alien_help_button.visible = false
	alien_help_button.focus_mode = Control.FOCUS_NONE
	alien_help_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	alien_help_button.tooltip_text = "Something impossible has noticed you."
	alien_help_button.set_anchors_preset(Control.PRESET_CENTER_TOP)
	alien_help_button.offset_left = -58.0
	alien_help_button.offset_right = 58.0
	alien_help_button.offset_top = 10.0
	alien_help_button.offset_bottom = 54.0
	alien_help_button.add_theme_color_override("font_color", Color.WHITE)
	alien_help_button.add_theme_color_override("font_hover_color", Color.WHITE)
	alien_help_button.add_theme_font_size_override("font_size", 16)
	var normal_style := _compact_panel_style(15.0, 8.0, 7)
	normal_style.bg_color = Color("9f1f35")
	normal_style.border_color = COLOR_BAD
	var hover_style := normal_style.duplicate() as StyleBoxFlat
	hover_style.bg_color = Color("c52d46")
	var pressed_style := normal_style.duplicate() as StyleBoxFlat
	pressed_style.bg_color = Color("721426")
	alien_help_button.add_theme_stylebox_override("normal", normal_style)
	alien_help_button.add_theme_stylebox_override("hover", hover_style)
	alien_help_button.add_theme_stylebox_override("pressed", pressed_style)
	alien_help_button.pressed.connect(_accept_alien_help)
	parent.add_child(alien_help_button)

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
	field_stat_panel.offset_right = 210.0
	field_stat_panel.offset_bottom = 170.0
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
		["pitch", "PITCH", "The pitch type selected for this immutable throw."],
		["release", "RELEASE", "Ball speed at the instant it leaves the hand."],
		["plate", "AT PLATE", "Ball speed when it reaches the plate after air drag."],
		["drag", "AIR DRAG", "Percentage of release speed lost before the plate. Space leagues play in vacuum."],
		["travel", "TRAVEL", "The throw's complete release-to-plate flight time."],
		["quality", "QUALITY", str(Content.STAT_HELP.quality)],
		["distance", "RANGE", "The level-assigned release distance captured when this throw began."],
	]
	for row_definition in rows:
		var stat_id := str(row_definition[0])
		var value_label := Label.new()
		value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		value_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		value_label.clip_text = true
		value_label.custom_minimum_size.x = 0.0
		value_label.add_theme_font_size_override("font_size", 10)
		value_label.add_theme_color_override("font_color", COLOR_TEXT)
		value_label.tooltip_text = str(row_definition[2])
		value_label.mouse_default_cursor_shape = Control.CURSOR_HELP
		_enable_mobile_inspection(value_label, str(row_definition[1]))
		value_label.set_meta("stat_prefix", str(row_definition[1]))
		stack.add_child(value_label)
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
	var locker_heading := HBoxContainer.new()
	locker_heading.add_theme_constant_override("separation", 8)
	stack.add_child(locker_heading)
	var locker_title := Label.new()
	locker_title.text = "STRIKEOUT EQUIPMENT"
	locker_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	locker_title.add_theme_font_size_override("font_size", 16)
	locker_title.add_theme_color_override("font_color", COLOR_ACCENT)
	locker_heading.add_child(locker_title)
	locker_dialog_close_button = Button.new()
	locker_dialog_close_button.name = "EquipmentCloseButton"
	locker_dialog_close_button.text = "CLOSE  X"
	locker_dialog_close_button.custom_minimum_size = Vector2(96.0, 44.0)
	locker_dialog_close_button.focus_mode = Control.FOCUS_NONE
	locker_dialog_close_button.pressed.connect(_close_locker_dialog)
	locker_heading.add_child(locker_dialog_close_button)
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
	var locker_gutter := _scroll_content_gutter(scroll, 14)
	locker_dialog_items = VBoxContainer.new()
	locker_dialog_items.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	locker_dialog_items.add_theme_constant_override("separation", 5)
	locker_gutter.add_child(locker_dialog_items)

func _build_loot_item_dialog() -> void:
	loot_item_dialog = Window.new()
	loot_item_dialog.name = "EquipmentItemWindow"
	loot_item_dialog.title = "EQUIPMENT COMPARISON"
	loot_item_dialog.visible = false
	loot_item_dialog.borderless = true
	loot_item_dialog.unresizable = true
	loot_item_dialog.transient = true
	loot_item_dialog.min_size = Vector2i(330, 520)
	loot_item_dialog.size = Vector2i(650, 650)
	loot_item_dialog.close_requested.connect(_close_loot_item_dialog)
	add_child(loot_item_dialog)
	loot_item_dialog.hide()

	var surface := PanelContainer.new()
	surface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	surface.add_theme_stylebox_override("panel", _compact_panel_style(14.0, 12.0))
	loot_item_dialog.add_child(surface)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 9)
	surface.add_child(stack)

	var heading_row := HBoxContainer.new()
	heading_row.add_theme_constant_override("separation", 8)
	stack.add_child(heading_row)
	var heading := Label.new()
	heading.text = "ITEM COMPARISON"
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_theme_font_size_override("font_size", 17)
	heading.add_theme_color_override("font_color", COLOR_ACCENT)
	heading_row.add_child(heading)
	var close_button := Button.new()
	close_button.text = "CLOSE  X"
	close_button.custom_minimum_size = Vector2(110.0, 48.0)
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.pressed.connect(_close_loot_item_dialog)
	heading_row.add_child(close_button)

	loot_item_name_label = Label.new()
	loot_item_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	loot_item_name_label.add_theme_font_size_override("font_size", 20)
	stack.add_child(loot_item_name_label)
	loot_item_meta_label = Label.new()
	loot_item_meta_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	loot_item_meta_label.add_theme_font_size_override("font_size", 14)
	stack.add_child(loot_item_meta_label)
	loot_item_equipped_label = Label.new()
	loot_item_equipped_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	loot_item_equipped_label.add_theme_font_size_override("font_size", 14)
	loot_item_equipped_label.add_theme_color_override("font_color", COLOR_MUTED)
	stack.add_child(loot_item_equipped_label)

	var stats_heading := Label.new()
	stats_heading.text = "THIS ITEM  vs  CURRENTLY EQUIPPED"
	stats_heading.add_theme_font_size_override("font_size", 12)
	stats_heading.add_theme_color_override("font_color", COLOR_ACCENT)
	stack.add_child(stats_heading)
	var stats_scroll := ScrollContainer.new()
	stats_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	stats_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(stats_scroll)
	var stats_gutter := _scroll_content_gutter(stats_scroll, 14)
	loot_item_stats = VBoxContainer.new()
	loot_item_stats.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	loot_item_stats.add_theme_constant_override("separation", 5)
	stats_gutter.add_child(loot_item_stats)

	loot_item_status_label = Label.new()
	loot_item_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	loot_item_status_label.custom_minimum_size.y = 40.0
	loot_item_status_label.add_theme_font_size_override("font_size", 13)
	loot_item_status_label.add_theme_color_override("font_color", COLOR_MUTED)
	stack.add_child(loot_item_status_label)

	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 8)
	stack.add_child(action_row)
	loot_item_equip_button = Button.new()
	loot_item_equip_button.custom_minimum_size = Vector2(100.0, 50.0)
	loot_item_equip_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	loot_item_equip_button.focus_mode = Control.FOCUS_NONE
	loot_item_equip_button.pressed.connect(_equip_selected_loot_item)
	action_row.add_child(loot_item_equip_button)
	loot_item_trash_button = Button.new()
	loot_item_trash_button.text = "TRASH"
	loot_item_trash_button.custom_minimum_size = Vector2(100.0, 50.0)
	loot_item_trash_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	loot_item_trash_button.focus_mode = Control.FOCUS_NONE
	loot_item_trash_button.add_theme_color_override("font_color", COLOR_BAD)
	loot_item_trash_button.pressed.connect(_trash_selected_loot_item)
	action_row.add_child(loot_item_trash_button)
	var keep_button := Button.new()
	keep_button.text = "KEEP"
	keep_button.custom_minimum_size = Vector2(100.0, 50.0)
	keep_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	keep_button.focus_mode = Control.FOCUS_NONE
	keep_button.pressed.connect(_close_loot_item_dialog)
	action_row.add_child(keep_button)

func _close_locker_dialog() -> void:
	_cancel_locker_item_hold()
	_close_loot_item_dialog()
	locker_dialog.hide()

func _open_locker(slot: String) -> void:
	if not game.is_loot_slot_unlocked(slot):
		return
	selected_loot_slot = slot
	_rebuild_locker_dialog()
	locker_dialog_close_button.visible = mobile_layout
	if mobile_layout:
		var viewport_size := _get_responsive_viewport_size()
		var popup_size := Vector2i(
			clampi(int(viewport_size.x) - 16, 300, 620),
			clampi(int(viewport_size.y) - 24, 420, 760)
		)
		locker_dialog.borderless = true
		locker_dialog.min_size = Vector2i(300, 420)
		locker_dialog.popup_centered(popup_size)
		locker_dialog.position = Vector2i(
			maxi((int(viewport_size.x) - popup_size.x) / 2, 0),
			maxi((int(viewport_size.y) - popup_size.y) / 2, 0)
		)
	else:
		locker_dialog.borderless = false
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
	_cancel_locker_item_hold()
	locker_item_hold_targets.clear()
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
		"%s  •  %d / %d KEPT  •  SCRAP %s\n"
		+ "EQUIPPED ITEM: %s\n"
		+ "TOTAL LOADOUT BONUSES: %s\n"
		+ "Use EQUIP directly or COMPARE for every stat and explicit swap/trash choices. Filled stars prevent automatic clearing.  •  %s"
	) % [
		str(definition.name),
		items.size(),
		BaseballGameState.LOOT_ITEMS_PER_SLOT,
		BaseballGameState.format_number(game.scrap, 0),
		equipped_name,
		game.get_equipment_bonus_summary(),
		clone_note,
	]
	locker_dialog_status_label.tooltip_text = (
		"Overflow Scrap equals item level × rarity value: Common ×1, Magic ×3, Rare ×8, Legendary ×20, Unique ×50. Scrap has no use yet."
	)
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
		row_panel.custom_minimum_size.y = 142.0 if mobile_layout else 132.0
		row_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row_panel.mouse_filter = Control.MOUSE_FILTER_PASS
		row_panel.add_theme_stylebox_override("panel", _loot_item_row_style(Color(rarity.color), is_equipped))
		row_panel.set_meta("loot_item_id", str(item.id))
		locker_dialog_items.add_child(row_panel)
		var row_stack := VBoxContainer.new()
		row_stack.add_theme_constant_override("separation", 4)
		row_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row_stack.mouse_filter = Control.MOUSE_FILTER_PASS
		row_panel.add_child(row_stack)
		var inspection_text := _get_loot_item_inspection_text(item)
		# Both pointer and touch layouts show the essential identity before any
		# interaction. Desktop hover and mobile hold expose the same full comparison.
		var info_stack := VBoxContainer.new()
		info_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_stack.add_theme_constant_override("separation", 1)
		info_stack.mouse_filter = Control.MOUSE_FILTER_PASS
		info_stack.tooltip_text = "" if mobile_layout else inspection_text
		row_stack.add_child(info_stack)
		var identity_row := HBoxContainer.new()
		identity_row.add_theme_constant_override("separation", 8)
		identity_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		info_stack.add_child(identity_row)
		var item_name_label := Label.new()
		item_name_label.text = "%s%s" % ["EQUIPPED  •  " if is_equipped else "", str(item.name)]
		item_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		item_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		item_name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		item_name_label.max_lines_visible = 2
		item_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		item_name_label.add_theme_font_size_override("font_size", 15 if mobile_layout else 14)
		item_name_label.add_theme_color_override("font_color", Color(rarity.color))
		identity_row.add_child(item_name_label)
		var power_label := Label.new()
		power_label.text = "POWER %d" % game.get_loot_item_power(item)
		power_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		power_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		power_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		power_label.add_theme_font_size_override("font_size", 14 if mobile_layout else 13)
		power_label.add_theme_color_override("font_color", COLOR_GOLD)
		identity_row.add_child(power_label)
		var item_meta_label := Label.new()
		item_meta_label.text = "%s  •  ITEM LEVEL %d" % [str(rarity.name).to_upper(), int(item.item_level)]
		item_meta_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		item_meta_label.add_theme_font_size_override("font_size", 10 if mobile_layout else 11)
		item_meta_label.add_theme_color_override("font_color", COLOR_MUTED)
		info_stack.add_child(item_meta_label)
		var item_effect_label := Label.new()
		item_effect_label.text = game.get_loot_item_description(item)
		item_effect_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		item_effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		item_effect_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		item_effect_label.max_lines_visible = 1 if mobile_layout else 2
		item_effect_label.add_theme_font_size_override("font_size", 11 if mobile_layout else 12)
		item_effect_label.add_theme_color_override("font_color", COLOR_TEXT)
		info_stack.add_child(item_effect_label)
		locker_item_hold_targets.append({"control": info_stack, "item_id": str(item.id)})
		var actions := HBoxContainer.new()
		actions.add_theme_constant_override("separation", 6)
		row_stack.add_child(actions)
		var equip_button := Button.new()
		equip_button.text = "UNEQUIP" if is_equipped else "EQUIP"
		equip_button.custom_minimum_size = Vector2(92.0, 44.0)
		equip_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		equip_button.focus_mode = Control.FOCUS_NONE
		equip_button.set_meta("loot_action", "equip")
		equip_button.set_meta("loot_item_id", str(item.id))
		equip_button.pressed.connect(_toggle_loot_item.bind(str(item.id)))
		actions.add_child(equip_button)
		var compare_button := Button.new()
		compare_button.text = "COMPARE"
		compare_button.custom_minimum_size = Vector2(110.0, 44.0)
		compare_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		compare_button.focus_mode = Control.FOCUS_NONE
		compare_button.set_meta("loot_action", "compare")
		compare_button.set_meta("loot_item_id", str(item.id))
		compare_button.pressed.connect(_open_loot_item_dialog.bind(str(item.id)))
		actions.add_child(compare_button)
		var favorite_button := Button.new()
		favorite_button.custom_minimum_size = Vector2(52.0, 44.0)
		favorite_button.size_flags_horizontal = Control.SIZE_SHRINK_END
		_ensure_favorite_icons()
		favorite_button.text = ""
		favorite_button.icon = favorite_kept_icon if bool(item.get("favorite", false)) else favorite_open_icon
		favorite_button.expand_icon = false
		favorite_button.tooltip_text = "Allow auto-scrap" if bool(item.get("favorite", false)) else "Protect from auto-scrap"
		favorite_button.add_theme_color_override(
			"font_color",
			COLOR_GOLD if bool(item.get("favorite", false)) else COLOR_MUTED
		)
		favorite_button.set_meta("loot_action", "favorite")
		favorite_button.set_meta("loot_item_id", str(item.id))
		favorite_button.pressed.connect(_toggle_loot_favorite.bind(str(item.id)))
		actions.add_child(favorite_button)

func _get_loot_item_inspection_text(item: Dictionary) -> String:
	if item.is_empty():
		return ""
	var rarity := Content.loot_rarity(int(item.get("rarity", 0)))
	var equipped := game.get_equipped_loot_item(str(item.get("slot", "")))
	var same_item := not equipped.is_empty() and str(equipped.get("id", "")) == str(item.get("id", ""))
	var candidate_power := game.get_loot_item_power(item)
	var equipped_power := 0 if equipped.is_empty() else game.get_loot_item_power(equipped)
	var lines: Array[String] = [
		str(item.get("name", "Unnamed equipment")),
		"Power %d • %s • Item level %d" % [candidate_power, str(rarity.name), int(item.get("item_level", 1))],
	]
	if same_item:
		lines.append("Currently equipped")
	elif equipped.is_empty():
		lines.append("Compared with empty slot • Power change +%d" % candidate_power)
	else:
		lines.append("Compared with %s • Power %d • Change %s%d" % [
			str(equipped.name), equipped_power,
			"+" if candidate_power - equipped_power >= 0 else "",
			candidate_power - equipped_power,
		])
	var item_stats: Dictionary = item.get("stats", {})
	var equipped_stats: Dictionary = equipped.get("stats", {}) if not equipped.is_empty() else {}
	var effectiveness := game.get_equipment_effectiveness_multiplier()
	for stat_definition in Content.LOOT_STATS:
		var stat_id := str(stat_definition.id)
		var candidate_value := float(item_stats.get(stat_id, 0.0)) * effectiveness
		var equipped_value := float(equipped_stats.get(stat_id, 0.0)) * effectiveness
		var delta := candidate_value - equipped_value
		if str(stat_definition.format) == "additive":
			lines.append("%s: +%.3f vs +%.3f (%+.3f)" % [str(stat_definition.name), candidate_value, equipped_value, delta])
		else:
			lines.append("%s: ×%.3f vs ×%.3f (%+.3f)" % [str(stat_definition.name), 1.0 + candidate_value, 1.0 + equipped_value, delta])
	lines.append("Use COMPARE for equip and trash actions")
	return "\n".join(lines)

func _begin_locker_item_hold_at(position: Vector2) -> void:
	_cancel_locker_item_hold()
	for index in range(locker_item_hold_targets.size() - 1, -1, -1):
		var entry: Dictionary = locker_item_hold_targets[index]
		var target := entry.get("control") as Control
		if target == null or not is_instance_valid(target) or not target.is_visible_in_tree():
			continue
		if not target.get_global_rect().has_point(position):
			continue
		var item_id := str(entry.get("item_id", ""))
		if game.get_loot_item(item_id).is_empty():
			return
		held_locker_item_id = item_id
		held_locker_item_elapsed = 0.0
		held_locker_item_drag_distance = 0.0
		return

func _cancel_locker_item_hold() -> void:
	held_locker_item_id = ""
	held_locker_item_elapsed = 0.0
	held_locker_item_drag_distance = 0.0

func _update_locker_item_hold(delta: float) -> void:
	if held_locker_item_id.is_empty():
		return
	if not mobile_layout or not locker_dialog.visible:
		_cancel_locker_item_hold()
		return
	held_locker_item_elapsed += delta
	if held_locker_item_elapsed < LOCKER_ITEM_HOLD_SECONDS:
		return
	var item_id := held_locker_item_id
	_cancel_locker_item_hold()
	_open_loot_item_dialog(item_id)

func _open_loot_item_dialog(item_id: String) -> void:
	if game.get_loot_item(item_id).is_empty():
		return
	selected_loot_item_id = item_id
	armed_loot_trash_id = ""
	_rebuild_loot_item_dialog()
	var viewport_size := _get_responsive_viewport_size()
	var popup_size := (
		Vector2i(
			clampi(int(viewport_size.x) - 20, 330, 620),
			clampi(int(viewport_size.y) - 28, 520, 690)
		)
		if mobile_layout
		else Vector2i(650, 650)
	)
	loot_item_dialog.popup_centered(popup_size)
	if mobile_layout:
		loot_item_dialog.position = Vector2i(
			maxi((int(viewport_size.x) - popup_size.x) / 2, 0),
			maxi((int(viewport_size.y) - popup_size.y) / 2, 0)
		)

func _close_loot_item_dialog() -> void:
	selected_loot_item_id = ""
	armed_loot_trash_id = ""
	if loot_item_dialog != null:
		loot_item_dialog.hide()

func _rebuild_loot_item_dialog() -> void:
	if loot_item_dialog == null:
		return
	var item := game.get_loot_item(selected_loot_item_id)
	if item.is_empty():
		_close_loot_item_dialog()
		return
	var rarity := Content.loot_rarity(int(item.get("rarity", 0)))
	var equipped := game.get_equipped_loot_item(str(item.get("slot", "")))
	var same_item := (
		not equipped.is_empty()
		and str(equipped.get("id", "")) == selected_loot_item_id
	)
	var candidate_power := game.get_loot_item_power(item)
	var equipped_power := 0 if equipped.is_empty() else game.get_loot_item_power(equipped)
	var power_delta := candidate_power - equipped_power
	loot_item_name_label.text = str(item.get("name", "Unnamed equipment"))
	loot_item_name_label.add_theme_color_override("font_color", Color(rarity.color))
	loot_item_meta_label.text = "THIS ITEM  •  POWER %d  •  %s  •  ITEM LEVEL %d  •  POWER CHANGE %s%d" % [
		candidate_power,
		str(rarity.name),
		int(item.get("item_level", 1)),
		"+" if power_delta >= 0 else "",
		power_delta,
	]
	if same_item:
		loot_item_equipped_label.text = "CURRENTLY EQUIPPED: this item"
	elif equipped.is_empty():
		loot_item_equipped_label.text = "CURRENTLY EQUIPPED: EMPTY"
	else:
		loot_item_equipped_label.text = "CURRENTLY EQUIPPED: %s  •  POWER %d" % [
			str(equipped.name), equipped_power,
		]
	for child in loot_item_stats.get_children():
		loot_item_stats.remove_child(child)
		child.queue_free()
	var item_stats: Dictionary = item.get("stats", {})
	var equipped_stats: Dictionary = equipped.get("stats", {}) if not equipped.is_empty() else {}
	var effectiveness := game.get_equipment_effectiveness_multiplier()
	for stat_definition in Content.LOOT_STATS:
		var stat_id := str(stat_definition.id)
		var candidate_value := float(item_stats.get(stat_id, 0.0)) * effectiveness
		var equipped_value := float(equipped_stats.get(stat_id, 0.0)) * effectiveness
		var delta := candidate_value - equipped_value
		var row_panel := PanelContainer.new()
		row_panel.add_theme_stylebox_override("panel", _compact_panel_style(7.0, 5.0))
		loot_item_stats.add_child(row_panel)
		var row_stack := VBoxContainer.new()
		row_stack.add_theme_constant_override("separation", 1)
		row_panel.add_child(row_stack)
		var name_label := Label.new()
		name_label.text = str(stat_definition.name).to_upper()
		name_label.add_theme_font_size_override("font_size", 11)
		name_label.add_theme_color_override("font_color", COLOR_ACCENT)
		row_stack.add_child(name_label)
		var value_label := Label.new()
		value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		value_label.add_theme_font_size_override("font_size", 14)
		if str(stat_definition.format) == "additive":
			value_label.text = "THIS +%.3f   •   EQUIPPED +%.3f   •   CHANGE %+.3f" % [
				candidate_value, equipped_value, delta,
			]
		else:
			value_label.text = "THIS ×%.3f   •   EQUIPPED ×%.3f   •   CHANGE %+.3f" % [
				1.0 + candidate_value, 1.0 + equipped_value, delta,
			]
		value_label.add_theme_color_override(
			"font_color",
			COLOR_GOOD if delta > 0.000001 else (COLOR_BAD if delta < -0.000001 else COLOR_MUTED)
		)
		row_stack.add_child(value_label)
	var effectiveness_note := ""
	if effectiveness > 1.000001:
		effectiveness_note = " Post-human item effectiveness ×%.3f is included." % effectiveness
	loot_item_status_label.text = "Trash value: %s Scrap.%s Total-loadout caps apply after item bonuses.%s" % [
		BaseballGameState.format_number(game.get_loot_scrap_value(item), 0),
		" This item is star-protected from automatic clearing." if bool(item.get("favorite", false)) else "",
		effectiveness_note,
	]
	loot_item_status_label.add_theme_color_override("font_color", COLOR_MUTED)
	loot_item_equip_button.text = (
		"UNEQUIP" if same_item else ("EQUIP" if equipped.is_empty() else "SWAP")
	)
	loot_item_trash_button.text = "CONFIRM TRASH" if armed_loot_trash_id == selected_loot_item_id else "TRASH"

func _equip_selected_loot_item() -> void:
	if selected_loot_item_id.is_empty():
		return
	game.equip_loot(selected_loot_item_id)
	_close_loot_item_dialog()
	_rebuild_locker_dialog()
	_refresh_interface()

func _trash_selected_loot_item() -> void:
	var item := game.get_loot_item(selected_loot_item_id)
	if item.is_empty():
		_close_loot_item_dialog()
		return
	if armed_loot_trash_id != selected_loot_item_id:
		armed_loot_trash_id = selected_loot_item_id
		loot_item_trash_button.text = "CONFIRM TRASH"
		loot_item_status_label.text = "This permanently destroys %s for %s Scrap%s. Press CONFIRM TRASH to continue." % [
			str(item.name),
			BaseballGameState.format_number(game.get_loot_scrap_value(item), 0),
			"; it is currently equipped" if str(game.equipped_loot.get(str(item.slot), "")) == selected_loot_item_id else ("; it is star-protected" if bool(item.get("favorite", false)) else ""),
		]
		loot_item_status_label.add_theme_color_override("font_color", COLOR_BAD)
		return
	game.trash_loot_item(selected_loot_item_id)
	_close_loot_item_dialog()
	_rebuild_locker_dialog()
	_refresh_interface()

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
	_enable_mobile_inspection(value_label, heading)
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
	var upgrade_stack := VBoxContainer.new()
	upgrade_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upgrade_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	upgrade_stack.add_theme_constant_override("separation", 4)
	upgrade_panel.add_child(upgrade_stack)
	_build_mobile_upgrade_stats(upgrade_stack)
	mobile_tab_navigation = HBoxContainer.new()
	mobile_tab_navigation.name = "MobileTabNavigation"
	mobile_tab_navigation.visible = false
	mobile_tab_navigation.add_theme_constant_override("separation", 8)
	upgrade_stack.add_child(mobile_tab_navigation)
	mobile_tab_label_card = PanelContainer.new()
	mobile_tab_label_card.name = "CurrentUpgradeTabCard"
	mobile_tab_label_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mobile_tab_label_card.custom_minimum_size.y = 44.0
	var tab_card_style := _compact_panel_style(10.0, 5.0, 8)
	tab_card_style.bg_color = Color("17263b")
	tab_card_style.border_color = Color("3b5b7e")
	mobile_tab_label_card.add_theme_stylebox_override("panel", tab_card_style)
	mobile_tab_navigation.add_child(mobile_tab_label_card)
	mobile_tab_label = Label.new()
	mobile_tab_label.text = "TRAIN"
	mobile_tab_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mobile_tab_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mobile_tab_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	mobile_tab_label.add_theme_font_size_override("font_size", 18)
	mobile_tab_label.add_theme_color_override("font_color", COLOR_ACCENT)
	mobile_tab_label_card.add_child(mobile_tab_label)
	mobile_tab_previous_button = Button.new()
	mobile_tab_previous_button.name = "PreviousUpgradeTab"
	_ensure_navigation_icons()
	mobile_tab_previous_button.text = ""
	mobile_tab_previous_button.icon = previous_navigation_icon
	mobile_tab_previous_button.expand_icon = true
	mobile_tab_previous_button.tooltip_text = "Previous upgrade tab"
	mobile_tab_previous_button.custom_minimum_size = Vector2(
		MOBILE_TAB_ARROW_TOUCH_SIZE,
		MOBILE_TAB_ARROW_TOUCH_SIZE
	)
	mobile_tab_previous_button.add_theme_font_size_override("font_size", 28)
	mobile_tab_previous_button.focus_mode = Control.FOCUS_NONE
	mobile_tab_previous_button.pressed.connect(_move_mobile_upgrade_tab.bind(-1))
	mobile_tab_navigation.add_child(mobile_tab_previous_button)
	mobile_tab_next_button = Button.new()
	mobile_tab_next_button.name = "NextUpgradeTab"
	mobile_tab_next_button.text = ""
	mobile_tab_next_button.icon = next_navigation_icon
	mobile_tab_next_button.expand_icon = true
	mobile_tab_next_button.tooltip_text = "Next upgrade tab"
	mobile_tab_next_button.custom_minimum_size = Vector2(
		MOBILE_TAB_ARROW_TOUCH_SIZE,
		MOBILE_TAB_ARROW_TOUCH_SIZE
	)
	mobile_tab_next_button.add_theme_font_size_override("font_size", 28)
	mobile_tab_next_button.focus_mode = Control.FOCUS_NONE
	mobile_tab_next_button.pressed.connect(_move_mobile_upgrade_tab.bind(1))
	mobile_tab_navigation.add_child(mobile_tab_next_button)
	# Previous • current section • next is easier to scan than parking both arrows
	# at the far edge of the strip.
	mobile_tab_navigation.move_child(mobile_tab_previous_button, 0)
	upgrade_tabs = TabContainer.new()
	upgrade_tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upgrade_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	upgrade_tabs.clip_tabs = true
	upgrade_tabs.use_hidden_tabs_for_min_size = true
	upgrade_tabs.get_tab_bar().add_theme_font_size_override("font_size", 8)
	upgrade_tabs.tab_changed.connect(_on_upgrade_tab_changed)
	upgrade_stack.add_child(upgrade_tabs)
	_build_training_tab(upgrade_tabs)
	_build_pitch_tab(upgrade_tabs)
	_build_ball_tab(upgrade_tabs)
	_build_scale_tab(upgrade_tabs)
	_build_rebirth_tab(upgrade_tabs)
	_build_achievement_tab(upgrade_tabs)
	_build_stats_tab(upgrade_tabs)
	_build_guide_tab(upgrade_tabs)
	_configure_tab_overflow_controls(false)

func _build_mobile_upgrade_stats(parent: Control) -> void:
	mobile_upgrade_stats_panel = PanelContainer.new()
	mobile_upgrade_stats_panel.name = "MobileUpgradeStats"
	mobile_upgrade_stats_panel.visible = false
	mobile_upgrade_stats_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mobile_upgrade_stats_panel.add_theme_stylebox_override("panel", _compact_panel_style(7.0, 5.0, 6))
	parent.add_child(mobile_upgrade_stats_panel)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 3)
	mobile_upgrade_stats_panel.add_child(stack)
	var heading := Label.new()
	heading.text = "CURRENT STATS"
	heading.add_theme_font_size_override("font_size", 10)
	heading.add_theme_color_override("font_color", COLOR_ACCENT)
	stack.add_child(heading)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 1)
	stack.add_child(grid)
	var rows := [
		["speed", "SPEED"],
		["quality", "QUALITY"],
		["recovery", "RECOVERY"],
		["lineup", "LINEUP"],
		["hit_delay", "HIT DELAY"],
		["calling", "CALLING"],
		["distance", "DISTANCE"],
		["tap", "FIELD TAP"],
		["offline", "OFFLINE"],
	]
	for row_definition in rows:
		var stat_id := str(row_definition[0])
		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.tooltip_text = str(Content.STAT_HELP.get(stat_id, ""))
		row.mouse_default_cursor_shape = Control.CURSOR_HELP
		_enable_mobile_inspection(row, str(row_definition[1]))
		grid.add_child(row)
		var name_label := Label.new()
		name_label.text = str(row_definition[1])
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.add_theme_font_size_override("font_size", 9)
		name_label.add_theme_color_override("font_color", COLOR_MUTED)
		name_label.tooltip_text = row.tooltip_text
		row.add_child(name_label)
		var value_label := Label.new()
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		value_label.add_theme_font_size_override("font_size", 10)
		value_label.add_theme_color_override("font_color", COLOR_TEXT)
		value_label.tooltip_text = row.tooltip_text
		row.add_child(value_label)
		mobile_upgrade_stat_labels[stat_id] = value_label

func _create_scroll_tab(tabs: TabContainer, title: String) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.name = title
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.add_child(scroll)
	var gutter := _scroll_content_gutter(scroll, 14)
	var content := VBoxContainer.new()
	content.name = "Content"
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 7)
	gutter.add_child(content)
	return content

func _section_label(parent: Control, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", COLOR_ACCENT)
	parent.add_child(label)

func _build_catalog_hide_toggle(parent: Control, catalog_id: String) -> void:
	var toggle := CheckButton.new()
	toggle.name = "HidePurchased%s" % catalog_id.capitalize()
	toggle.text = "HIDE PURCHASED"
	toggle.tooltip_text = "Hide one-time upgrades already bought in this tab. Locked and available upgrades remain visible."
	toggle.add_theme_font_size_override("font_size", 12)
	toggle.add_theme_color_override("font_color", COLOR_MUTED)
	toggle.toggled.connect(_toggle_catalog_hide_purchased.bind(catalog_id))
	parent.add_child(toggle)
	catalog_hide_purchased_toggles[catalog_id] = toggle

func _build_training_tab(tabs: TabContainer) -> void:
	var content := _create_scroll_tab(tabs, "TRAIN")
	_section_label(content, "REPEATABLE FUNDAMENTALS")
	for definition in _definitions_by_unlock(Content.TRAINING):
		var entry := _upgrade_row(_definition_tooltip(definition))
		(entry.button as Button).pressed.connect(_buy_training.bind(str(definition.id)))
		content.add_child(entry.container)
		training_buttons[definition.id] = entry

func _build_pitch_tab(tabs: TabContainer) -> void:
	var content := _create_scroll_tab(tabs, "PITCH")
	_section_label(content, "AUTOMATIC ARSENAL")
	var explainer := Label.new()
	explainer.text = "Every learned pitch enters the automatic mix. Pitch Calling increasingly favors the better ones."
	explainer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explainer.add_theme_font_size_override("font_size", 13)
	explainer.add_theme_color_override("font_color", COLOR_MUTED)
	content.add_child(explainer)
	_build_catalog_hide_toggle(content, "pitch")
	for definition in _definitions_by_unlock(Content.PITCHES):
		var entry := _upgrade_row(_definition_tooltip(definition, ["quality", "speed"]))
		(entry.button as Button).pressed.connect(_buy_pitch.bind(str(definition.id)))
		content.add_child(entry.container)
		pitch_buttons[definition.id] = entry

func _build_ball_tab(tabs: TabContainer) -> void:
	var content := _create_scroll_tab(tabs, "BALL")
	_section_label(content, "BALL UPGRADES — POWER WITHOUT PHANTOM PROJECTILES")
	var ball_explainer := Label.new()
	ball_explainer.text = "Each shell replaces the previous shell. Payload multiplies XP per result while the visual ball count stays honest."
	ball_explainer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ball_explainer.add_theme_font_size_override("font_size", 13)
	ball_explainer.add_theme_color_override("font_color", COLOR_MUTED)
	content.add_child(ball_explainer)
	_build_catalog_hide_toggle(content, "ball")
	for definition in _definitions_by_unlock(Content.BALL_UPGRADES):
		var entry := _upgrade_row(_definition_tooltip(definition, ["payload"]))
		(entry.button as Button).pressed.connect(_buy_ball_upgrade.bind(str(definition.id)))
		content.add_child(entry.container)
		ball_upgrade_buttons[definition.id] = entry

func _build_scale_tab(tabs: TabContainer) -> void:
	var content := _create_scroll_tab(tabs, "FACILITY")
	_section_label(content, "ONE-TIME TRAINING, FACILITIES & QUESTIONABLE DECISIONS")
	_build_catalog_hide_toggle(content, "facility")
	for definition in _definitions_by_unlock(Content.MILESTONES):
		var entry := _upgrade_row(_definition_tooltip(definition))
		(entry.button as Button).pressed.connect(_buy_milestone.bind(str(definition.id)))
		content.add_child(entry.container)
		milestone_buttons[definition.id] = entry
	automation_section = VBoxContainer.new()
	automation_section.add_theme_constant_override("separation", 7)
	content.add_child(automation_section)
	_section_label(automation_section, "AUTOMATION")
	var automation_definitions := [
		{
			"id": "advance",
			"name": "Auto-advance",
			"upgrade": "migratory_instinct",
			"description": "Move immediately only when that destination level has a prestige license.",
		},
		{
			"id": "farm",
			"name": "Auto-scout",
			"upgrade": "predator_scouting",
			"description": "Farm the unlocked opponent with the best estimated XP/sec at that level's assigned range.",
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

	automation_training_heading = Label.new()
	automation_training_heading.text = "LICENSED AUTOMATIC TRAINING"
	automation_training_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	automation_training_heading.add_theme_font_size_override("font_size", 12)
	automation_training_heading.add_theme_color_override("font_color", COLOR_GOLD)
	automation_section.add_child(automation_training_heading)
	for training_value in Content.TRAINING:
		var training: Dictionary = training_value
		var id := "training_%s" % str(training.id)
		var definition := {
			"id": id,
			"kind": "training",
			"stat_id": str(training.id),
			"name": "Auto-buy %s" % str(training.name),
			"upgrade": "autonomic_coach",
			"description": "Automatically buy this one additive Training stat when affordable.",
		}
		var toggle := CheckButton.new()
		toggle.clip_text = true
		toggle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		toggle.tooltip_text = str(definition.description)
		toggle.toggled.connect(_toggle_automation.bind(id))
		automation_section.add_child(toggle)
		automation_toggles[id] = {"button": toggle, "definition": definition}

	automation_catalog_heading = Label.new()
	automation_catalog_heading.text = "ONE-TIME CATALOG AUTOMATION"
	automation_catalog_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	automation_catalog_heading.add_theme_font_size_override("font_size", 12)
	automation_catalog_heading.add_theme_color_override("font_color", COLOR_GOLD)
	automation_section.add_child(automation_catalog_heading)
	var catalog_automation_definitions := [
		{"id": "catalog_pitch", "catalog_id": "pitch", "name": "Auto-learn Pitches"},
		{"id": "catalog_ball", "catalog_id": "ball", "name": "Auto-install Balls"},
		{"id": "catalog_facility", "catalog_id": "facility", "name": "Auto-buy Facilities"},
		{"id": "catalog_growth", "catalog_id": "growth", "name": "Auto-buy Grow Up"},
	]
	for catalog_value in catalog_automation_definitions:
		var catalog: Dictionary = catalog_value
		var definition := {
			"id": str(catalog.id),
			"kind": "catalog",
			"catalog_id": str(catalog.catalog_id),
			"name": str(catalog.name),
			"upgrade": "front_office_outside_time",
			"description": "Automatically buy affordable unlocked one-time upgrades in this catalog.",
		}
		var toggle := CheckButton.new()
		toggle.clip_text = true
		toggle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		toggle.tooltip_text = str(definition.description)
		toggle.toggled.connect(_toggle_automation.bind(str(catalog.id)))
		automation_section.add_child(toggle)
		automation_toggles[str(catalog.id)] = {"button": toggle, "definition": definition}

func _build_rebirth_tab(tabs: TabContainer) -> void:
	var content := _create_scroll_tab(tabs, "GROW UP")
	rebirth_tab = content.get_parent().get_parent() as Control
	rebirth_story_label = Label.new()
	rebirth_story_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rebirth_story_label.add_theme_color_override("font_color", COLOR_GOLD)
	rebirth_story_label.add_theme_font_size_override("font_size", 14)
	content.add_child(rebirth_story_label)
	ascension_currency_label = Label.new()
	ascension_currency_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ascension_currency_label.add_theme_color_override("font_color", COLOR_TEXT)
	content.add_child(ascension_currency_label)

	human_growth_section = VBoxContainer.new()
	human_growth_section.add_theme_constant_override("separation", 7)
	content.add_child(human_growth_section)
	_section_label(human_growth_section, "I • ORDINARY BIOLOGICAL DEVELOPMENT")
	body_growth_status_label = Label.new()
	body_growth_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_growth_status_label.add_theme_font_size_override("font_size", 12)
	body_growth_status_label.add_theme_color_override("font_color", COLOR_MUTED)
	human_growth_section.add_child(body_growth_status_label)
	for stage_index in range(1, Content.BODY_GROWTH_STAGES.size()):
		var definition: Dictionary = Content.BODY_GROWTH_STAGES[stage_index]
		var entry := _upgrade_row(_definition_tooltip(definition, ["speed", "quality", "recovery"]))
		(entry.button as Button).pressed.connect(_buy_body_growth.bind(str(definition.id)))
		human_growth_section.add_child(entry.container)
		body_growth_buttons[definition.id] = entry

	genetic_section = VBoxContainer.new()
	genetic_section.add_theme_constant_override("separation", 7)
	content.add_child(genetic_section)
	_section_label(genetic_section, "II • GENETIC REBIRTH — THE TIME MACHINE IS FOR OBSTETRICS")
	genetic_reset_button = _upgrade_button("Reset the current body for DNA based on all XP earned by that body.")
	genetic_reset_button.pressed.connect(_request_genetic_rebirth)
	genetic_section.add_child(genetic_reset_button)
	for definition in Content.GENETIC_UPGRADES:
		var entry := _upgrade_row(str(definition.description))
		(entry.button as Button).pressed.connect(_buy_genetic.bind(str(definition.id)))
		genetic_section.add_child(entry.container)
		genetic_buttons[definition.id] = entry

	eldritch_section = VBoxContainer.new()
	eldritch_section.add_theme_constant_override("separation", 7)
	content.add_child(eldritch_section)
	_section_label(eldritch_section, "III • ELDRITCH ASCENSION — DESTROY THIS REALITY RESPONSIBLY")
	eldritch_reset_button = _upgrade_button("Reset the body, DNA, and every genetic enhancement for Arcana based on total DNA earned in this reality.")
	eldritch_reset_button.pressed.connect(_request_eldritch_ascension)
	eldritch_section.add_child(eldritch_reset_button)
	for definition in Content.ELDRITCH_UPGRADES:
		var entry := _upgrade_row(str(definition.description))
		(entry.button as Button).pressed.connect(_buy_eldritch.bind(str(definition.id)))
		eldritch_section.add_child(entry.container)
		eldritch_buttons[definition.id] = entry

	divine_section = VBoxContainer.new()
	divine_section.add_theme_constant_override("separation", 7)
	content.add_child(divine_section)
	_section_label(divine_section, "IV • GOD PRESTIGE — SAVE IT, THEN DO IT ALL AGAIN")
	for definition in Content.DIVINE_BLESSINGS:
		var entry := _upgrade_row(str(definition.description))
		(entry.button as Button).pressed.connect(_request_divine_ascension.bind(str(definition.id)))
		divine_section.add_child(entry.container)
		divine_buttons[definition.id] = entry
	divine_halo_button = _upgrade_button("After every blessing is owned, each additional Halo multiplies XP and mastery ×1.50.")
	divine_halo_button.pressed.connect(_request_divine_ascension.bind("halo"))
	divine_section.add_child(divine_halo_button)

func _build_achievement_tab(tabs: TabContainer) -> void:
	var content := _create_scroll_tab(tabs, "ACHIEVE")
	achievement_tab = content.get_parent().get_parent() as Control
	_section_label(content, "ACHIEVEMENTS")
	achievement_count_label = Label.new()
	achievement_count_label.add_theme_font_size_override("font_size", 18)
	achievement_count_label.add_theme_color_override("font_color", COLOR_TEXT)
	content.add_child(achievement_count_label)
	achievement_bonus_label = Label.new()
	achievement_bonus_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	achievement_bonus_label.add_theme_font_size_override("font_size", 12)
	achievement_bonus_label.add_theme_color_override("font_color", COLOR_GOLD)
	content.add_child(achievement_bonus_label)
	var explainer := Label.new()
	explainer.text = "Every achievement permanently adds +1% XP. Hidden achievements disclose nothing until their subject has been encountered."
	explainer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explainer.add_theme_font_size_override("font_size", 12)
	explainer.add_theme_color_override("font_color", COLOR_MUTED)
	content.add_child(explainer)
	achievement_hide_achieved_toggle = CheckButton.new()
	achievement_hide_achieved_toggle.name = "HideAchieved"
	achievement_hide_achieved_toggle.text = "HIDE ACHIEVED"
	achievement_hide_achieved_toggle.tooltip_text = "Hide completed achievements while leaving every unfinished and hidden slot visible."
	achievement_hide_achieved_toggle.add_theme_font_size_override("font_size", 12)
	achievement_hide_achieved_toggle.add_theme_color_override("font_color", COLOR_MUTED)
	achievement_hide_achieved_toggle.toggled.connect(_toggle_hide_achieved)
	content.add_child(achievement_hide_achieved_toggle)

	for tier_value in Content.ACHIEVEMENT_TIER_ORDER:
		var tier := str(tier_value)
		var tier_heading := Label.new()
		tier_heading.add_theme_font_size_override("font_size", 13)
		tier_heading.add_theme_color_override("font_color", COLOR_ACCENT)
		content.add_child(tier_heading)
		achievement_section_headings[tier] = tier_heading
		for definition_value in Content.ACHIEVEMENTS:
			var definition: Dictionary = definition_value
			if str(definition.tier) != tier:
				continue
			var panel := PanelContainer.new()
			panel.custom_minimum_size.y = 104.0
			# Achievement copy is passive so swipes reach the ScrollContainer. The
			# one bounded Details button below is the card's only tap target.
			panel.mouse_filter = Control.MOUSE_FILTER_PASS
			panel.add_theme_stylebox_override("panel", _achievement_card_style("hidden"))
			content.add_child(panel)
			var row := HBoxContainer.new()
			row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_theme_constant_override("separation", 8)
			row.mouse_filter = Control.MOUSE_FILTER_PASS
			panel.add_child(row)
			var stack := VBoxContainer.new()
			stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			stack.add_theme_constant_override("separation", 2)
			stack.mouse_filter = Control.MOUSE_FILTER_PASS
			row.add_child(stack)
			var title := Label.new()
			title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			title.add_theme_font_size_override("font_size", 15)
			title.mouse_filter = Control.MOUSE_FILTER_IGNORE
			stack.add_child(title)
			var description := Label.new()
			description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			description.add_theme_font_size_override("font_size", 12)
			description.add_theme_color_override("font_color", COLOR_MUTED)
			description.mouse_filter = Control.MOUSE_FILTER_IGNORE
			stack.add_child(description)
			var progress := ProgressBar.new()
			progress.show_percentage = false
			progress.custom_minimum_size.y = 6.0
			progress.mouse_filter = Control.MOUSE_FILTER_IGNORE
			stack.add_child(progress)
			var footer := Label.new()
			footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			footer.add_theme_font_size_override("font_size", 11)
			footer.add_theme_color_override("font_color", COLOR_GOLD)
			footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
			stack.add_child(footer)
			var details_button := Button.new()
			details_button.text = "DETAILS"
			details_button.custom_minimum_size = Vector2(78.0, 44.0)
			details_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			details_button.focus_mode = Control.FOCUS_NONE
			details_button.add_theme_font_size_override("font_size", 11)
			details_button.pressed.connect(_show_achievement_details.bind(str(definition.id)))
			row.add_child(details_button)
			achievement_cards[str(definition.id)] = {
				"panel": panel,
				"title": title,
				"description": description,
				"progress": progress,
				"footer": footer,
				"details_button": details_button,
			}

func _show_achievement_details(id: String) -> void:
	if mobile_inspection_dialog == null:
		return
	var definition := Content.achievement_by_id(id)
	if definition.is_empty():
		return
	var revealed := game.is_achievement_information_revealed(definition)
	mobile_inspection_dialog.title = (
		str(definition.name).to_upper() if revealed else "HIDDEN ACHIEVEMENT"
	)
	if not revealed:
		mobile_inspection_dialog.dialog_text = "No details are available yet."
	else:
		var progress := game.get_achievement_progress(definition)
		mobile_inspection_dialog.dialog_text = "%s\n\n%s  •  PERMANENT XP +1%%" % [
			str(definition.description),
			"COMPLETE" if game.has_achievement(id) else str(progress.text),
		]
	mobile_inspection_dialog.popup_centered_clamped(Vector2i(360, 245), 0.94)
	mobile_inspection_dialog.get_ok_button().set_deferred(
		"custom_minimum_size",
		Vector2(100.0, 44.0)
	)

func _achievement_card_style(state: String) -> StyleBoxFlat:
	var style := _compact_panel_style(10.0, 7.0, 6)
	match state:
		"complete":
			style.bg_color = Color("12251f")
			style.border_color = COLOR_GOOD
		"revealed":
			style.bg_color = Color("111c2c")
			style.border_color = Color("315170")
		_:
			style.bg_color = Color("090e17")
			style.border_color = Color("1b2737")
	return style

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
		"field_tap": "Field tap advance",
		"offline_xp": "Offline XP efficiency",
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
		"achievements": "Achievements / permanent XP bonus",
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
			"field_tap": "tap",
			"offline_xp": "offline",
		}.get(str(id), ""))
		if not str(help_id).is_empty():
			name_label.tooltip_text = str(Content.STAT_HELP.get(str(help_id), ""))
			name_label.mouse_default_cursor_shape = Control.CURSOR_HELP
			_enable_mobile_inspection(name_label, str(stat_names[id]))
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
	_section_label(content, "HOW NO HITTER WORKS")
	guide_label = Label.new()
	guide_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	guide_label.add_theme_font_size_override("font_size", 13)
	guide_label.add_theme_color_override("font_color", COLOR_TEXT)
	content.add_child(guide_label)

func _upgrade_row(description: String) -> Dictionary:
	var container := PanelContainer.new()
	container.custom_minimum_size.y = 82.0
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.mouse_filter = Control.MOUSE_FILTER_PASS
	container.tooltip_text = description
	container.add_theme_stylebox_override("panel", _compact_panel_style(8.0, 5.0, 7))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 7)
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	container.add_child(row)
	var label := Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.max_lines_visible = 3
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", COLOR_TEXT)
	# Passive copy is the draggable region. It deliberately ignores pointer input
	# so a finger swipe reaches the surrounding ScrollContainer.
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.tooltip_text = description
	row.add_child(label)
	var action := Button.new()
	action.text = "BUY"
	action.custom_minimum_size = Vector2(76.0, 44.0)
	action.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	action.focus_mode = Control.FOCUS_NONE
	action.add_theme_font_size_override("font_size", 12)
	action.tooltip_text = description
	row.add_child(action)
	return {
		"container": container,
		"label": label,
		"button": action,
	}

func _set_upgrade_row(
	entry: Dictionary,
	text: String,
	disabled: bool,
	tooltip: String,
	action_text := "BUY"
) -> void:
	var container := entry.container as PanelContainer
	var label := entry.label as Label
	var button := entry.button as Button
	var signature := "%s\u001f%s\u001f%s\u001f%s" % [
		text,
		str(disabled),
		tooltip,
		action_text,
	]
	if str(container.get_meta("upgrade_row_signature", "")) == signature:
		return
	container.set_meta("upgrade_row_signature", signature)
	label.text = text
	label.tooltip_text = tooltip
	container.tooltip_text = tooltip
	button.text = action_text
	button.disabled = disabled
	button.tooltip_text = tooltip

func _set_upgrade_row_visible(entry: Dictionary, visible: bool) -> void:
	var container := entry.container as Control
	if container.visible != visible:
		container.visible = visible

func _upgrade_row_is_visible(entry: Dictionary) -> bool:
	return (entry.container as Control).visible

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
	event_log_panel.add_theme_stylebox_override("panel", _compact_panel_style(8.0, 5.0))
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
	_build_loot_item_dialog()
	_build_hard_reset_dialog()
	_build_save_transfer_dialogs()
	_build_mobile_install_dialog()
	_build_mobile_inspection_dialog()
	_build_offline_progress_dialog()
	_build_browser_update_confirmation()
	_build_alien_help_dialog()
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
	divine_confirmation.title = "Do it all again?"
	divine_confirmation.confirmed.connect(_confirm_divine_ascension)
	add_child(divine_confirmation)

func _build_browser_update_confirmation() -> void:
	browser_update_confirmation = ConfirmationDialog.new()
	browser_update_confirmation.dialog_autowrap = true
	_configure_browser_update_confirmation(false)
	browser_update_confirmation.confirmed.connect(_install_browser_update)
	browser_update_confirmation.custom_action.connect(_handle_browser_update_custom_action)
	browser_update_export_button = browser_update_confirmation.add_button(
		"EXPORT",
		true,
		"export_backup"
	)
	browser_update_export_button.custom_minimum_size = Vector2(60.0, 36.0)
	add_child(browser_update_confirmation)

func _build_alien_help_dialog() -> void:
	alien_help_dialog = AcceptDialog.new()
	alien_help_dialog.name = "AlienHelpDialog"
	alien_help_dialog.title = "A MAN STEPS OUT OF A PORTAL"
	alien_help_dialog.dialog_autowrap = true
	alien_help_dialog.min_size = Vector2i(320, 260)
	alien_help_dialog.dialog_text = (
		"He watches Xylophax turn another perfect pitch into an unavoidable Grand Slam. "
		+ "Then he lowers his sunglasses.\n\n"
		+ "‘Come with me if you want to… be really good at baseball.’\n\n"
		+ "He has a Time Machine and an alarming prenatal genetics waiver. Time Travel is now "
		+ "permanently available in GROW UP whenever this body has earned enough XP."
	)
	alien_help_dialog.get_ok_button().text = "GET IN THE PORTAL"
	add_child(alien_help_dialog)

func _build_offline_progress_dialog() -> void:
	offline_progress_dialog = AcceptDialog.new()
	offline_progress_dialog.name = "OfflineProgressDialog"
	offline_progress_dialog.title = "WELCOME BACK"
	offline_progress_dialog.dialog_autowrap = true
	offline_progress_dialog.min_size = Vector2i(360, 220)
	offline_progress_dialog.get_ok_button().text = "BACK TO THE MOUND"
	add_child(offline_progress_dialog)

func _build_mobile_install_dialog() -> void:
	mobile_install_dialog = AcceptDialog.new()
	mobile_install_dialog.name = "MobileInstallGuide"
	mobile_install_dialog.dialog_autowrap = true
	mobile_install_dialog.min_size = Vector2i(340, 325)
	mobile_install_dialog.get_ok_button().text = "GOT IT"
	add_child(mobile_install_dialog)
	_configure_mobile_install_dialog("ios")

func _build_mobile_inspection_dialog() -> void:
	mobile_inspection_dialog = AcceptDialog.new()
	mobile_inspection_dialog.name = "MobileInspectionDialog"
	mobile_inspection_dialog.title = "DETAILS"
	mobile_inspection_dialog.dialog_autowrap = true
	mobile_inspection_dialog.min_size = Vector2i(330, 190)
	mobile_inspection_dialog.get_ok_button().text = "CLOSE"
	mobile_inspection_dialog.get_ok_button().add_theme_font_size_override("font_size", 22)
	add_child(mobile_inspection_dialog)

func _build_save_transfer_dialogs() -> void:
	export_save_dialog = FileDialog.new()
	export_save_dialog.name = "ExportSaveDialog"
	export_save_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	export_save_dialog.access = FileDialog.ACCESS_FILESYSTEM
	export_save_dialog.use_native_dialog = true
	export_save_dialog.filters = PackedStringArray(["*.json;No Hitter Save;application/json"])
	export_save_dialog.file_selected.connect(_write_export_save)
	add_child(export_save_dialog)

	load_save_dialog = FileDialog.new()
	load_save_dialog.name = "LoadSaveDialog"
	load_save_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	load_save_dialog.access = FileDialog.ACCESS_FILESYSTEM
	load_save_dialog.use_native_dialog = true
	load_save_dialog.filters = PackedStringArray(["*.json;No Hitter Save;application/json"])
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
		+ "and all lifetime statistics. Manual save slots and exported backups remain. This cannot be undone."
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

func _set_catalog_lock(entry: Dictionary, definition: Dictionary) -> void:
	var unlock_text := "REACH LEVEL %d" % (int(definition.required_level) + 1)
	_set_catalog_lock_text(entry, definition, [unlock_text])

func _set_catalog_lock_text(entry: Dictionary, definition: Dictionary, requirements: Array[String]) -> void:
	var unlock_text := " • ".join(requirements)
	_set_upgrade_row(
		entry,
		"%s\n%s" % [str(definition.name), "\n".join(requirements)],
		true,
		unlock_text,
		"LOCKED"
	)

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
		automation_section.visible = genetic_revealed
		last_reveal_mask = reveal_mask
	genetic_section.visible = genetic_revealed
	eldritch_section.visible = eldritch_revealed
	divine_section.visible = divine_revealed
	ascension_currency_label.visible = genetic_revealed

	header_subtitle.text = _get_game_subtitle()
	header_subtitle.tooltip_text = header_subtitle.text
	equipment_progression_heading.text = "OWNED FACILITIES"
	if genetic_revealed:
		equipment_progression_heading.text = "FACILITIES & MUTATIONS"
	if eldritch_revealed:
		equipment_progression_heading.text = "FACILITIES, MUTATIONS & MAGIC"

	for id in ["arms", "dna", "genetic_rebirths"]:
		stat_rows[id].visible = genetic_revealed
	for id in ["equipment_inheritance", "clones", "time", "arcana", "eldritch_ascensions"]:
		stat_rows[id].visible = eldritch_revealed
	for id in ["divine_ascensions", "divine_blessings", "completion"]:
		stat_rows[id].visible = divine_revealed
	stat_rows.speed_limit.visible = game.is_velocity_body_capped()
	_refresh_guide_text(genetic_revealed, eldritch_revealed, divine_revealed)

func _get_game_subtitle() -> String:
	# Each line describes only a milestone the player has already discovered.
	# Keeping this separate from reveal headings avoids advertising future layers.
	if game.cosmos_conquered or game.divine_ascensions > 0:
		return "A baseball game about saving the universe, somehow"
	if game.eldritch_ascensions > 0 or game.lifetime_eldritch_ascensions > 0:
		return "A baseball game about several versions of one guy"
	if game.eldritch_offer_unlocked or game.highest_unlocked >= Content.ELDRITCH_EXHIBITION_INDEX:
		return "A baseball game about one guy versus the void"
	if game.genetic_rebirths > 0 or game.lifetime_genetic_rebirths > 0:
		return "A baseball game about a genetically modified %s" % game.get_body_growth_noun()
	if game.genetic_offer_unlocked or game.highest_unlocked >= Content.ALIEN_EXHIBITION_INDEX:
		return "A baseball game about a %s who found aliens" % game.get_body_growth_noun()
	if game.has_milestone("steroids"):
		return "A baseball game about a big boi"
	return "A baseball game about a regular ol’ %s" % game.get_body_growth_noun()

func _refresh_guide_text(
	genetic_revealed: bool,
	eldritch_revealed: bool,
	divine_revealed: bool
) -> void:
	var sections: Array[String] = [
		(
			"SCORING\n"
			+ "• Only a completed strikeout awards XP. Every Strike also adds a little mastery against that opponent.\n"
			+ "• Hits award nothing, clear the count, and replace the batter. Bigger hits mean a longer wait. A Grand Slam cannot be saved.\n"
			+ "• Human baseball uses three Strikes for an out and four Balls for a walk; a walk behaves like a Single."
		),
		(
			"PROGRESSION\n"
			+ "• Mastery unlocks the next level and permanently improves your odds against that opponent. Extra mastery adds small logarithmic XP and loot bonuses.\n"
			+ "• Each level sets its own opponent, range, threat, and XP multiplier. PREVIOUS and NEXT choose the level; distance is automatic."
		),
		(
			"PITCH FLOW\n"
			+ "• During human play, one pitch must resolve before recovery begins. The pitcher dial shows recovery; the plate dial shows the next batter.\n"
			+ "• Tap open field to advance the active recovery, flight, or lineup timer by Field Tap %. Tapping can provide at most half of one timer.\n"
			+ "• Bad outcomes add Frustration: Grand Slams add most; Balls and Fouls barely add any. Its uncapped logarithmic quality bonus resets on a strikeout."
		),
		(
			"GETTING STRONGER\n"
			+ "• TRAIN is an incremental additive XP sink. PITCH, BALL, FACILITY, and GROW UP contain the larger, expensive one-time power jumps. Locked cards reveal only their requirement.\n"
			+ "• The field shows actual throw telemetry, including release speed, drag, plate speed, and travel time. General stats live in STATUS. Hover on desktop or tap on phone for definitions."
		),
		(
			"GEAR & ACHIEVEMENTS\n"
			+ "• Strikeouts can drop minor sidegrade gear. Power is a quick comparison; hover on desktop or hold on phone for every stat. Stars protect items from auto-scrap. Each slot keeps 10.\n"
			+ "• All %d achievement slots are visible. Each completed achievement permanently adds 1%% XP; unrevealed secret entries stay anonymous."
			% Content.ACHIEVEMENTS.size()
		),
		(
			"AWAY PLAY & SAVES\n"
			+ "• Closing or suspending the game simulates up to seven days at the displayed Offline %. Your return popup shows the exact deposit.\n"
			+ "• Autosave runs every 10 seconds. SAVES opens the same manual slots on every platform, plus EXPORT, IMPORT, and title return. Mobile file pickers can use an enabled Drive provider. Export before browser updates."
		),
		(
			"VISUALS\n"
			+ "• A released ball keeps its pitch, release speed, drag, path, color, source, target, and travel time. New upgrades affect only later throws.\n"
			+ "• Every low-rate ball is exact. Only after more than %s would overlap does one labeled dot represent several pitches."
			% BaseballGameState.format_number(float(pitch_field.get_visual_capacity()), 0)
		),
	]
	if genetic_revealed:
		sections.append(
			"TIME TRAVEL\n"
			+ "• The portal stranger unlocks genetic rebirth. It resets XP, levels, and gear for DNA based on total body XP; mutations persist.\n"
			+ "• Each Autonomic Coaching Lobe rank licenses one chosen Training auto-buy. Alien counts can require more Strikes; extra arms, hit protection, and count compression make those at-bats possible."
		)
	if eldritch_revealed:
		sections.append(
			"REALITY ASCENSION\n"
			+ "• Abandoning a reality resets XP, levels, gear, DNA, and genetics for Arcana based on DNA earned in that reality. Eldritch upgrades persist.\n"
			+ "• Front Office Outside Time can automate one-time catalogs. Clones, portals, time compression, and wardrobe preservation turn later campaigns into multi-ball baseball."
		)
	if divine_revealed:
		sections.append(
			"THE END, AGAIN\n"
			+ "• After the final victory, choose one permanent divine blessing and restore the universe. Later wins can earn every blessing, then Halos."
		)
	guide_label.text = "\n\n".join(sections)

func _achievement_reveal_signature() -> String:
	return "%d:%d:%d:%d:%d" % [
		game.get_historical_highest_opponent(),
		int(game.is_achievement_tier_revealed("genetic")),
		int(game.is_achievement_tier_revealed("eldritch")),
		int(game.is_achievement_tier_revealed("divine")),
		game.unlocked_achievements.size(),
	]

func _refresh_achievement_tab(force := false) -> void:
	if achievement_tab == null or achievement_count_label == null:
		return
	var reveal_signature := _achievement_reveal_signature()
	var tab_is_open := upgrade_tabs != null and upgrade_tabs.current_tab == achievement_tab.get_index()
	if (
		not force
		and not tab_is_open
		and achievement_last_revision == game.achievement_revision
		and achievement_last_reveal_signature == reveal_signature
	):
		return
	achievement_last_revision = game.achievement_revision
	achievement_last_reveal_signature = reveal_signature
	achievement_count_label.text = "%d / %d UNLOCKED" % [
		game.unlocked_achievements.size(),
		Content.ACHIEVEMENTS.size(),
	]
	achievement_bonus_label.text = "PERMANENT XP BONUS  +%d%%  •  XP ×%.2f" % [
		int(round(game.get_achievement_xp_bonus() * 100.0)),
		game.get_achievement_xp_multiplier(),
	]
	achievement_hide_achieved_toggle.set_pressed_no_signal(game.achievement_hide_achieved)
	for tier_value in Content.ACHIEVEMENT_TIER_ORDER:
		var tier := str(tier_value)
		var heading: Label = achievement_section_headings[tier]
		var tier_revealed := game.is_achievement_tier_revealed(tier)
		heading.visible = tier_revealed
		if tier_revealed:
			var tier_total := 0
			var tier_complete := 0
			for definition_value in Content.ACHIEVEMENTS:
				var tier_definition: Dictionary = definition_value
				if str(tier_definition.tier) == tier:
					tier_total += 1
					if game.has_achievement(str(tier_definition.id)):
						tier_complete += 1
			heading.text = "%s  •  %d / %d" % [
				str(Content.ACHIEVEMENT_TIER_NAMES[tier]),
				tier_complete,
				tier_total,
			]
	for definition_value in Content.ACHIEVEMENTS:
		var definition: Dictionary = definition_value
		var id := str(definition.id)
		var entry: Dictionary = achievement_cards[id]
		var panel: PanelContainer = entry.panel
		var title: Label = entry.title
		var description: Label = entry.description
		var progress_bar: ProgressBar = entry.progress
		var footer: Label = entry.footer
		var details_button: Button = entry.details_button
		var unlocked := game.has_achievement(id)
		var revealed := game.is_achievement_information_revealed(definition)
		panel.visible = not (unlocked and game.achievement_hide_achieved)
		if not panel.visible:
			continue
		var state := "complete" if unlocked else ("revealed" if revealed else "hidden")
		if str(panel.get_meta("achievement_state", "")) != state:
			panel.set_meta("achievement_state", state)
			panel.add_theme_stylebox_override("panel", _achievement_card_style(state))
		if not revealed:
			title.text = "HIDDEN ACHIEVEMENT"
			title.add_theme_color_override("font_color", COLOR_MUTED)
			description.text = "This achievement remains hidden."
			progress_bar.visible = false
			footer.text = "???"
			panel.tooltip_text = "Hidden Achievement\nNo details are available yet."
			details_button.tooltip_text = panel.tooltip_text
			continue
		var achievement_progress := game.get_achievement_progress(definition)
		title.text = "%s%s" % ["✓  " if unlocked else "", str(definition.name)]
		title.add_theme_color_override("font_color", COLOR_GOOD if unlocked else COLOR_TEXT)
		description.text = str(definition.description)
		progress_bar.visible = true
		progress_bar.value = float(achievement_progress.ratio) * 100.0
		footer.text = "%s  •  %s" % [
			"COMPLETE" if unlocked else str(achievement_progress.text),
			"PERMANENT XP +1%",
		]
		panel.tooltip_text = "%s\n%s\n%s" % [
			str(definition.name),
			str(definition.description),
			footer.text,
		]
		details_button.tooltip_text = panel.tooltip_text

func _refresh_interface(refresh_expensive := true) -> void:
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
	xp_label.text = BaseballGameState.format_xp_total(game.xp)
	if mobile_overlay_xp_label != null:
		mobile_overlay_xp_label.text = "XP %s" % BaseballGameState.format_xp_total(game.xp)
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
	era_label.text = "LEVEL %02d  •  %s" % [
		game.current_opponent + 1,
		opponent.era,
	]
	alien_help_button.visible = game.is_alien_help_available()
	if alien_help_button.visible:
		alien_help_button.move_to_front()
	previous_button.disabled = game.current_opponent <= 0
	next_button.disabled = game.current_opponent >= game.highest_unlocked
	previous_button.tooltip_text = "Select the previous unlocked batter. A released pitch keeps flying and will resolve against the selected batter."
	next_button.tooltip_text = "Select the next unlocked batter. A released pitch keeps flying and will resolve against the selected batter."
	if mobile_layout:
		previous_button.text = ""
		next_button.text = ""
	else:
		previous_button.text = "< PREVIOUS BATTER"
		if game.cosmos_conquered:
			next_button.text = "DIVINE OFFER READY"
		elif game.is_story_exhibition_blocked():
			next_button.text = "REBIRTH REQUIRED" if game.is_story_offer_ready() else "EXHIBITION ACTIVE"
		elif game.current_opponent < game.highest_unlocked:
			next_button.text = "NEXT BATTER >"
		elif game.current_opponent == game.opponents.size() - 1:
			next_button.text = "FINAL BOSS ACTIVE"
		else:
			next_button.text = "NEXT BATTER LOCKED"
	var distance := game.get_current_distance()
	distance_label.text = (
		"LEVEL RANGE  •  %s  •  XP ×%s  •  THREAT +%.2f" % [
			str(distance.label),
			BaseballGameState.format_number(game.get_distance_xp_multiplier()),
			game.get_distance_difficulty(),
		]
		if mobile_layout
		else "LEVEL RANGE  •  %s  •  %s  •  XP ×%s  •  BATTER THREAT +%.2f" % [
			str(distance.name),
			str(distance.label),
			BaseballGameState.format_number(game.get_distance_xp_multiplier()),
			game.get_distance_difficulty(),
		]
	)
	var mastery_value := game.opponent_mastery[game.current_opponent]
	var mastery_required := game.get_mastery_requirement()
	var mastery_quality_bonus := game.get_opponent_mastery_quality_bonus()
	var overmastery_summary := game.get_overmastery_summary()
	mastery_label.tooltip_text = (
		"Every called Strike builds mastery against this batter. Current mastery adds +%.3f quality to this matchup. "
		+ "The advantage is uncapped and logarithmic; reaching 100%% unlocks progression, while excess mastery also improves XP and loot."
	) % mastery_quality_bonus
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
			else "FINAL BOSS MASTERY  %s / %s  •  ODDS +%.3f" % [
				BaseballGameState.format_number(mastery_value),
				BaseballGameState.format_number(mastery_required),
				mastery_quality_bonus,
			]
		)
	elif mastery_value >= mastery_required:
		var target_ratio := mastery_value / maxf(mastery_required, 0.000001)
		var full_mastery_text := "OPPONENT MASTERED  •  ×%s TARGET  •  ODDS +%.3f%s" % [
			BaseballGameState.format_number(target_ratio),
			mastery_quality_bonus,
			"  •  %s" % overmastery_summary if not overmastery_summary.is_empty() else "",
		]
		if mobile_layout and not overmastery_summary.is_empty():
			mastery_label.text = "MASTERED ×%s  •  ODDS +%.3f  •  XP ×%.3f  •  LOOT +%.1f%%" % [
				BaseballGameState.format_number(target_ratio),
				mastery_quality_bonus,
				game.get_opponent_farm_xp_multiplier(),
				game.get_opponent_loot_luck() * 100.0,
			]
		else:
			mastery_label.text = full_mastery_text
			mastery_label.tooltip_text = (
				full_mastery_text
				+ "\nEvery called Strike still increases the uncapped logarithmic matchup advantage, XP bonus, and loot rolls."
			)
	else:
		mastery_label.text = "OPPONENT MASTERY  %s / %s  •  ODDS +%.3f" % [
			BaseballGameState.format_number(mastery_value),
			BaseballGameState.format_number(mastery_required),
			mastery_quality_bonus,
		]
		mastery_label.tooltip_text = (
			"Every called Strike builds mastery and immediately improves the called-Strike rate against this batter. Reach 100% to unlock the next batter; every point beyond it still helps logarithmically."
		)
	if not game.is_story_exhibition_blocked() and not game.is_speed_gate_blocked():
		mastery_bar.value = game.get_mastery_ratio() * 100.0
	for index in probabilities.size():
		outcome_probability_labels[index].text = "%.2f%%" % (probabilities[index] * 100.0)
		var bonus_seconds := game.get_outcome_turnover_bonus(index)
		outcome_delay_labels[index].text = "+%s" % _format_compact_seconds(bonus_seconds)
		var detail := ""
		if index == Content.GRAND_SLAM_INDEX:
			detail = "Always ends the plate appearance and cannot be saved by any fielder, clone, portal, or blessing. Adds %s beyond the base lineup change." % _format_compact_seconds(bonus_seconds)
		elif index < Content.HIT_OUTCOME_COUNT:
			detail = "Ends the plate appearance unless saved. Adds %s beyond the base lineup change." % _format_compact_seconds(bonus_seconds)
		elif index == Content.FOUL_INDEX:
			detail = "Adds one strike, but cannot supply the final strike. The batter stays at the plate."
		elif index == Content.BALL_INDEX:
			detail = "Adds one Ball. %d Balls produce a walk, treated like a Single and adding %s." % [game.get_balls_required(), _format_compact_seconds(bonus_seconds)]
		else:
			detail = "Adds one strike. Strike %d completes the only XP-paying outcome." % game.get_strikes_required()
		var frustration_cost := game.get_outcome_frustration_points(index)
		var frustration_note := (
			"Frustration +%s per resolved volley." % BaseballGameState.format_number(frustration_cost, 2)
			if frustration_cost > 0.0
			else "Frustration +0; a completed strikeout resets the entire score."
		)
		outcome_panels[index].tooltip_text = "%s • %.2f%%\n%s\n%s\nEvery completed plate appearance includes a %s base lineup change." % [
			str(Content.OUTCOME_NAMES[index]),
			float(probabilities[index]) * 100.0,
			detail,
			frustration_note,
			_format_compact_seconds(game.get_base_batter_turnover_seconds()),
		]
	strikeout_payout_label.text = "COMPLETED STRIKEOUT: %s XP" % BaseballGameState.format_number(
		game.get_strikeout_base_points() * game.get_xp_multiplier()
	)
	var frustration_bonus := game.get_frustration_quality_bonus()
	frustration_label.text = "FRUSTRATION +%.3f" % frustration_bonus
	frustration_bar.value = game.get_frustration_meter_ratio() * 100.0
	frustration_label.tooltip_text = (
		"%s Frustration • +%.3f quality against the active batter. "
		+ "Grand Slam +12, Home Run +8, Triple +5, Double +3, Single +1, Ball +0.20, Foul +0.10, Strike +0. "
		+ "The bonus has no cap but grows logarithmically, and a completed strikeout resets it."
	) % [BaseballGameState.format_number(game.frustration_points, 2), frustration_bonus]

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
	if refresh_expensive:
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
	if refresh_expensive:
		_refresh_purchase_buttons()
		_refresh_rebirth_buttons()
		_refresh_achievement_tab()
		_refresh_stats(at_bat_metrics, estimated_xp_per_second)
		if title_screen_active:
			_refresh_title_screen()

func _refresh_field_stats() -> void:
	if not field_stat_labels.is_empty():
		var in_flight := game.is_pitch_in_flight()
		var pitch_id := game.pending_volley_pitch_id if in_flight else ""
		var pitch_definition := Content.pitch_by_id(pitch_id)
		var release_speed := (
			game.pending_volley_speed_fps
			if in_flight
			else game.get_representative_pitch_speed()
		)
		var plate_speed := (
			game.pending_volley_plate_speed_fps
			if in_flight
			else game.get_representative_plate_speed()
		)
		var drag_loss := clampf(1.0 - plate_speed / maxf(release_speed, 0.000001), 0.0, 1.0)
		var distance_index := game.pending_volley_distance_index if in_flight else game.selected_distance_index
		var distance: Dictionary = Content.DISTANCE_TIERS[clampi(distance_index, 0, Content.DISTANCE_TIERS.size() - 1)]
		var quality := (
			game.get_pitch_quality_for_pitch(pitch_id, release_speed)
			if in_flight and not pitch_definition.is_empty()
			else game.get_pitch_quality()
		)
		_set_field_stat_text("pitch", (
			str(pitch_definition.name)
			if in_flight and not pitch_definition.is_empty()
			else "AUTOMATIC MIX"
		))
		_set_field_stat_text("release", BaseballGameState.format_speed(release_speed))
		_set_field_stat_text("plate", BaseballGameState.format_speed(plate_speed))
		_set_field_stat_text(
			"drag",
			"NONE" if drag_loss <= 0.00005 else "−%.1f%%" % (drag_loss * 100.0)
		)
		_set_field_stat_text("travel", BaseballGameState.format_flight_time(
			game.pending_volley_flight_duration if in_flight else game.get_resolved_flight_seconds()
		))
		_set_field_stat_text("quality", "%.3f" % quality)
		_set_field_stat_text("distance", str(distance.label))
	_refresh_mobile_upgrade_stats()

func _set_field_stat_text(stat_id: String, value: String) -> void:
	var label := field_stat_labels.get(stat_id) as Label
	if label == null:
		return
	label.text = "%s  %s" % [str(label.get_meta("stat_prefix", stat_id.to_upper())), value]

func _refresh_mobile_upgrade_stats() -> void:
	_refresh_effective_stat_labels(
		mobile_upgrade_stat_labels,
		game.get_representative_pitch_speed()
	)

func _refresh_status_stats() -> void:
	_refresh_effective_stat_labels(
		status_stat_labels,
		game.get_representative_pitch_speed()
	)

func _refresh_effective_stat_labels(labels: Dictionary, speed_fps: float) -> void:
	if labels.is_empty():
		return
	labels.speed.text = BaseballGameState.format_speed(speed_fps)
	labels.quality.text = "%.3f" % game.get_pitch_quality()
	labels.recovery.text = "%.3f/s" % game.get_recovery_rate()
	labels.lineup.text = _format_compact_seconds(game.get_base_batter_turnover_seconds())
	labels.hit_delay.text = "×%.3f" % game.get_hit_delay_factor()
	labels.calling.text = "×%.2f" % game.get_pitch_calling_bias()
	labels.distance.text = "×%.3f" % game.get_distance_penalty_multiplier()
	labels.tap.text = "%.1f%%" % (game.get_field_tap_fraction() * 100.0)
	labels.offline.text = "%.0f%%" % (game.get_offline_xp_efficiency() * 100.0)

func _format_compact_seconds(seconds: float) -> String:
	if absf(seconds - round(seconds)) < 0.05:
		return "%ds" % int(round(seconds))
	return "%.1fs" % seconds

func _refresh_equipment() -> void:
	_refresh_status_stats()
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
		body_value.text = "%s • %d %s • %d %s" % [
			game.get_body_growth_name(),
			arm_count,
			"arm" if arm_count == 1 else "arms",
			pitcher_count,
			"pitcher" if pitcher_count == 1 else "pitchers",
		]
	elif _has_genetic_reveal():
		body_value.text = "%s • %d-%s pitcher" % [
			game.get_body_growth_name(),
			arm_count,
			"arm" if arm_count == 1 else "armed",
		]
	else:
		body_value.text = game.get_body_growth_name()
	body_value.tooltip_text = "%s\n%s\nCurrent growth: speed ×%.3f • quality +%.3f • recovery ×%.3f" % [
		body_value.text,
		str(game.get_body_growth_stage().get("description", "")),
		game.get_body_growth_effect_multiplier("speed"),
		game.get_body_growth_quality_bonus(),
		game.get_body_growth_effect_multiplier("recovery"),
	]
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

	_refresh_owned_upgrade_list()

func _get_owned_upgrade_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for definition_value in Content.MILESTONES:
		var definition: Dictionary = definition_value
		if str(definition.id) in game.purchased_milestones:
			entries.append({
				"kind": "FACILITY",
				"name": str(definition.name),
				"detail": str(definition.description),
			})
	if _has_genetic_reveal():
		for definition_value in Content.GENETIC_UPGRADES:
			var definition: Dictionary = definition_value
			var rank := int(game.genetic_levels.get(str(definition.id), 0))
			if rank > 0:
				entries.append({
					"kind": "MUTATION R%d" % rank,
					"name": str(definition.name),
					"detail": str(definition.description),
				})
	if _has_eldritch_reveal():
		for definition_value in Content.ELDRITCH_UPGRADES:
			var definition: Dictionary = definition_value
			var rank := int(game.eldritch_levels.get(str(definition.id), 0))
			if rank > 0:
				entries.append({
					"kind": "MAGIC R%d" % rank,
					"name": str(definition.name),
					"detail": str(definition.description),
				})
	if _has_divine_reveal():
		for id_value in game.divine_blessings:
			var definition := Content.divine_by_id(str(id_value))
			if not definition.is_empty():
				entries.append({
					"kind": "BLESSING",
					"name": str(definition.name),
					"detail": str(definition.description),
				})
		if game.divine_halos > 0:
			entries.append({
				"kind": "DIVINE R%d" % game.divine_halos,
				"name": "Halo",
				"detail": "XP and opponent mastery ×1.50 per Halo.",
			})
	return entries

func _refresh_owned_upgrade_list() -> void:
	if equipment_progression_list == null:
		return
	var entries := _get_owned_upgrade_entries()
	var signature_parts: Array[String] = []
	for entry in entries:
		signature_parts.append("%s:%s:%s" % [entry.kind, entry.name, entry.detail])
	var signature := "|".join(signature_parts) if not signature_parts.is_empty() else "none"
	if signature == last_owned_upgrade_list_signature:
		return
	last_owned_upgrade_list_signature = signature
	for child in equipment_progression_list.get_children():
		if child == equipment_summary_label:
			continue
		equipment_progression_list.remove_child(child)
		child.queue_free()
	var has_prestige_entry := false
	for entry in entries:
		if str(entry.kind) != "FACILITY":
			has_prestige_entry = true
			break
	equipment_progression_heading.text = (
		"OWNED UPGRADES" if has_prestige_entry else "OWNED FACILITIES"
	)
	equipment_summary_label.text = (
		"No facilities owned yet"
		if entries.is_empty()
		else "%d owned" % entries.size()
	)
	equipment_summary_label.tooltip_text = game.get_owned_equipment_summary()
	for entry in entries:
		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", _compact_panel_style(5.0, 3.0, 5))
		panel.tooltip_text = "%s • %s\n%s" % [entry.kind, entry.name, entry.detail]
		panel.mouse_default_cursor_shape = Control.CURSOR_HELP
		_enable_mobile_inspection(panel, str(entry.name))
		equipment_progression_list.add_child(panel)
		var stack := VBoxContainer.new()
		stack.add_theme_constant_override("separation", 0)
		panel.add_child(stack)
		var title := Label.new()
		title.text = "%s • %s" % [entry.kind, entry.name]
		title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title.add_theme_font_size_override("font_size", 11)
		title.add_theme_color_override("font_color", COLOR_TEXT)
		title.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stack.add_child(title)
		var detail := Label.new()
		detail.text = str(entry.detail)
		detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		detail.add_theme_font_size_override("font_size", 10)
		detail.add_theme_color_override("font_color", COLOR_MUTED)
		detail.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stack.add_child(detail)

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
		button.text = str(definition.letter) if unlocked else "?"
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
		_enable_mobile_inspection(button, "Enemy %s" % kind)
		opponent_loadout_dock.add_child(button)

func _refresh_purchase_buttons() -> void:
	for catalog_id in catalog_hide_purchased_toggles:
		var filter_toggle: CheckButton = catalog_hide_purchased_toggles[catalog_id]
		filter_toggle.set_pressed_no_signal(bool(game.catalog_hide_purchased.get(catalog_id, false)))
	for definition in Content.TRAINING:
		var id := str(definition.id)
		var rank := int(game.training_levels[id])
		var entry: Dictionary = training_buttons[id]
		if game.highest_unlocked < int(definition.get("required_level", 0)):
			_set_catalog_lock(entry, definition)
		elif id == "velocity" and game.is_velocity_body_capped():
			_set_upgrade_row(
				entry,
				"%s  •  RANK %d\nBODY LIMIT REACHED" % [definition.name, rank],
				false,
				str(Content.STAT_HELP.speed),
				"DETAILS"
			)
		elif definition.has("max_level") and rank >= int(definition.max_level):
			_set_upgrade_row(
				entry,
				"%s  •  RANK %d / %d\n%s" % [definition.name, rank, int(definition.max_level), definition.description],
				true,
				_definition_tooltip(definition),
				"MAXED"
			)
		else:
			var cost := game.get_training_cost(id)
			_set_upgrade_row(
				entry,
				"%s  •  RANK %d  •  %s XP\n%s" % [definition.name, rank, BaseballGameState.format_cost(cost), definition.description],
				game.xp < cost,
				_definition_tooltip(definition)
			)

	for definition in Content.PITCHES:
		var id := str(definition.id)
		var entry: Dictionary = pitch_buttons[id]
		var pitch_owned := id in game.unlocked_pitches
		_set_upgrade_row_visible(entry, (
			_catalog_entry_is_visible(definition, pitch_owned)
			and not (pitch_owned and bool(game.catalog_hide_purchased.pitch))
		))
		if not _upgrade_row_is_visible(entry):
			continue
		if id in game.unlocked_pitches:
			_set_upgrade_row(entry, "%s\n%s" % [definition.name, definition.description], true, _definition_tooltip(definition, ["quality", "speed"]), "LEARNED")
		elif game.highest_unlocked < int(definition.required_level):
			_set_catalog_lock(entry, definition)
		else:
			_set_upgrade_row(
				entry,
				"%s  •  %s XP\n%s" % [definition.name, BaseballGameState.format_cost(game.get_pitch_cost(id)), definition.description],
				not game.can_buy_pitch(id),
				_definition_tooltip(definition, ["quality", "speed"])
			)

	for definition in Content.BALL_UPGRADES:
		var id := str(definition.id)
		var entry: Dictionary = ball_upgrade_buttons[id]
		var ball_owned := game.has_ball_upgrade(id)
		_set_upgrade_row_visible(entry, (
			_catalog_entry_is_visible(definition, ball_owned)
			and not (ball_owned and bool(game.catalog_hide_purchased.ball))
		))
		if not _upgrade_row_is_visible(entry):
			continue
		if game.has_ball_upgrade(id):
			_set_upgrade_row(entry, "%s\n%s" % [definition.name, definition.description], true, _definition_tooltip(definition, ["payload"]), "INSTALLED")
		elif game.highest_unlocked < int(definition.required_level):
			_set_catalog_lock(entry, definition)
		else:
			_set_upgrade_row(
				entry,
				"%s  •  %s XP\n%s" % [definition.name, BaseballGameState.format_cost(game.get_ball_upgrade_cost(id)), definition.description],
				not game.can_buy_ball_upgrade(id),
				_definition_tooltip(definition, ["payload"])
			)

	for definition in Content.MILESTONES:
		var id := str(definition.id)
		var entry: Dictionary = milestone_buttons[id]
		var milestone_owned := game.has_milestone(id)
		_set_upgrade_row_visible(entry, (
			_catalog_entry_is_visible(definition, milestone_owned)
			and not (milestone_owned and bool(game.catalog_hide_purchased.facility))
		))
		if not _upgrade_row_is_visible(entry):
			continue
		if game.has_milestone(id):
			_set_upgrade_row(entry, "%s\n%s" % [definition.name, definition.description], true, _definition_tooltip(definition), "OWNED")
		elif not game.get_milestone_unmet_requirements(definition).is_empty():
			_set_catalog_lock_text(entry, definition, game.get_milestone_unmet_requirements(definition))
		else:
			_set_upgrade_row(
				entry,
				"%s  •  %s XP\n%s" % [definition.name, BaseballGameState.format_cost(game.get_milestone_cost(id)), definition.description],
				not game.can_buy_milestone(id),
				_definition_tooltip(definition)
			)

	for definition in Content.SCALE_UPGRADES:
		var id := str(definition.id)
		var rank := int(game.scale_levels[id])
		var button: Button = scale_buttons[id]
		if game.highest_unlocked < int(definition.required_level):
			button.text = "%s  •  REACH LEVEL %d\n%s" % [
				definition.name,
				int(definition.required_level) + 1,
				definition.description,
			]
			button.disabled = true
		elif rank >= int(definition.max_level):
			button.text = "%s  •  RANK %d / %d  •  MAXED\n%s" % [
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

	var training_license_count := game.get_auto_training_license_count()
	var training_selection_count := game.get_auto_training_selection_count()
	if automation_training_heading != null:
		automation_training_heading.text = "LICENSED AUTOMATIC TRAINING  •  %d / %d SELECTED" % [
			training_selection_count,
			training_license_count,
		]
	if automation_catalog_heading != null:
		automation_catalog_heading.visible = _has_eldritch_reveal()
	for id in automation_toggles:
		var entry: Dictionary = automation_toggles[id]
		var toggle: CheckButton = entry.button
		var definition: Dictionary = entry.definition
		var kind := str(definition.get("kind", "utility"))
		var required_upgrade := str(definition.upgrade)
		if kind == "training":
			var stat_id := str(definition.stat_id)
			var enabled := game.is_auto_training_stat_selected(stat_id)
			var has_open_license := training_selection_count < training_license_count
			toggle.visible = true
			toggle.text = "%s  •  %s" % [
				definition.name,
				"SELECTED" if enabled else (
					"AVAILABLE" if has_open_license else "NEEDS ANOTHER COACHING LOBE RANK"
				),
			]
			toggle.tooltip_text = "%s\n%d stat license%s available; %d selected." % [
				definition.description,
				training_license_count,
				"" if training_license_count == 1 else "s",
				training_selection_count,
			]
			toggle.disabled = not enabled and not has_open_license
			toggle.set_pressed_no_signal(enabled)
		elif kind == "catalog":
			toggle.visible = _has_eldritch_reveal()
			var unlocked := game.has_eldritch_upgrade(required_upgrade)
			var enabled := game.is_auto_catalog_selected(str(definition.catalog_id))
			toggle.text = "%s  •  %s" % [
				definition.name,
				"ACTIVE" if enabled else (
					"READY" if unlocked else "REQUIRES %s" % Content.eldritch_by_id(required_upgrade).name
				),
			]
			toggle.tooltip_text = str(definition.description)
			toggle.disabled = not unlocked
			toggle.set_pressed_no_signal(enabled)
		elif str(id) == "advance":
			var unlocked := game.has_auto_advance_capacity()
			var capacity := game.get_auto_advance_capacity_text()
			toggle.visible = true
			toggle.text = "AUTO-ADVANCE  •  %s\n%s" % [
				"ACTIVE" if game.auto_advance_enabled else ("READY" if unlocked else "NO LICENSES"),
				capacity,
			]
			toggle.tooltip_text = "%s\n%s. Genetic ranks cover human destinations; eldritch ranks cover alien destinations." % [
				definition.description,
				capacity,
			]
			toggle.disabled = not unlocked
			toggle.set_pressed_no_signal(game.auto_advance_enabled)
		else:
			var unlocked := game.has_genetic_upgrade(required_upgrade)
			toggle.visible = true
			toggle.text = "%s  •  %s\n%s" % [
				definition.name,
				"GENETICALLY UNLOCKED" if unlocked else "REQUIRES %s" % Content.genetic_by_id(required_upgrade).name,
				definition.description,
			]
			toggle.disabled = not unlocked
			var enabled := game.auto_advance_enabled if str(id) == "advance" else game.auto_farm_enabled
			toggle.set_pressed_no_signal(enabled)

func _refresh_rebirth_buttons() -> void:
	var story := "%s. Growing up is optional; every ordinary age remains within human limits." % game.get_body_growth_name()
	if game.cosmos_conquered:
		story = "GOD: ‘Thanks for saving the universe. Wouldn’t the best reward be doing it all again?’ Choose one blessing, then let God restore everything."
	elif game.is_eldritch_exhibition_blocked():
		story = "N'Kthra, Rookie of the Last Aeon hits every pitch out of reality. After one minute it explains how to move your consciousness elsewhere."
	elif game.eldritch_ascensions > 0:
		story = "Your consciousness inhabits reality %d. Octathulhu remains technically beatable under the oldest rules of baseball." % (game.eldritch_ascensions + 1)
	elif game.is_alien_exhibition_blocked():
		if game.genetic_offer_unlocked:
			story = "The portal stranger’s Time Machine can restart this life with prenatal baseball modifications."
		elif game.is_alien_help_available():
			story = "Xylophax cannot miss. Nothing you own changes the odds. Something red has appeared on the field."
		else:
			story = "Xylophax turns every pitch into an unavoidable Grand Slam. Nothing you own changes the odds. Keep watching."
	elif game.genetic_rebirths > 0:
		story = "Body %d is legally human in several permissive jurisdictions. Beat the alien leagues at up to Mach 12." % (game.genetic_rebirths + 1)
	if game.genetic_rebirths > 0 and not game.eldritch_offer_unlocked:
		story += " Rebirth when the quoted DNA buys a useful mutation; a shallow human loop followed by a deeper alien harvest is usually efficient."
	rebirth_story_label.text = story
	var cumulative_speed := game.get_body_growth_effect_multiplier("speed")
	var cumulative_recovery := game.get_body_growth_effect_multiplier("recovery")
	body_growth_status_label.text = "%s  •  SIZE ×%.2f  •  SPEED ×%.3f  •  QUALITY +%.3f  •  RECOVERY ×%.3f" % [
		game.get_body_growth_name(),
		game.get_body_growth_visual_size(),
		cumulative_speed,
		game.get_body_growth_quality_bonus(),
		cumulative_recovery,
	]
	if game.body_growth_level == 0:
		body_growth_status_label.text += "\n%s" % str(game.get_body_growth_stage().description)
	for stage_index in range(1, Content.BODY_GROWTH_STAGES.size()):
		var definition: Dictionary = Content.BODY_GROWTH_STAGES[stage_index]
		var id := str(definition.id)
		var entry: Dictionary = body_growth_buttons[id]
		var tooltip := _definition_tooltip(definition, ["speed", "quality", "recovery"])
		if stage_index <= game.body_growth_level:
			_set_upgrade_row(
				entry,
				"%s\n%s" % [definition.name, definition.description],
				true,
				tooltip,
				"GROWN"
			)
		elif stage_index > game.body_growth_level + 1:
			var previous_stage: Dictionary = Content.BODY_GROWTH_STAGES[stage_index - 1]
			_set_catalog_lock_text(entry, definition, ["GROW THROUGH %s" % str(previous_stage.get("body_name", previous_stage.name)).to_upper()])
		elif game.highest_unlocked < int(definition.required_level):
			_set_catalog_lock(entry, definition)
		else:
			var growth_cost := game.get_body_growth_cost(id)
			_set_upgrade_row(
				entry,
				"%s  •  %s XP\n%s" % [definition.name, BaseballGameState.format_cost(growth_cost), definition.description],
				not game.can_buy_body_growth(id),
				tooltip
			)
	if _has_divine_reveal():
		ascension_currency_label.text = (
			"DNA %s  •  Arcana %s  •  Body XP %s  •  Reality DNA %s  •  Universes saved %d"
			% [
				BaseballGameState.format_number(float(game.dna), 0),
				BaseballGameState.format_number(float(game.arcana), 0),
				BaseballGameState.format_xp_total(game.run_xp),
				BaseballGameState.format_number(game.reality_dna_earned, 0),
				game.divine_ascensions,
			]
		)
	elif _has_eldritch_reveal():
		ascension_currency_label.text = "DNA %s  •  Arcana %s  •  Body XP %s  •  Reality DNA %s" % [
			BaseballGameState.format_number(float(game.dna), 0),
			BaseballGameState.format_number(float(game.arcana), 0),
			BaseballGameState.format_xp_total(game.run_xp),
			BaseballGameState.format_number(game.reality_dna_earned, 0),
		]
	else:
		ascension_currency_label.text = "DNA %s  •  Body XP %s" % [
			BaseballGameState.format_number(float(game.dna), 0),
			BaseballGameState.format_xp_total(game.run_xp),
		]

	var potential_dna := game.get_potential_dna()
	if not game.genetic_offer_unlocked:
		genetic_reset_button.text = "GENETIC REBIRTH LOCKED\nReach Xylophax, witness one impossible minute, and find help."
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
		var entry: Dictionary = genetic_buttons[id]
		if not game.genetic_offer_unlocked:
			_set_upgrade_row(entry, "%s\n%s" % [definition.name, definition.description], true, str(definition.description), "LOCKED")
		elif rank >= int(definition.max_level):
			_set_upgrade_row(entry, "%s  •  RANK %d / %d\n%s" % [definition.name, rank, int(definition.max_level), definition.description], true, str(definition.description), "MAXED")
		else:
			_set_upgrade_row(entry, "%s  •  RANK %d  •  %d DNA\n%s" % [definition.name, rank, game.get_genetic_cost(id), definition.description], not game.can_buy_genetic(id), str(definition.description))

	var potential_arcana := game.get_potential_arcana()
	if not game.eldritch_offer_unlocked:
		eldritch_reset_button.text = "ELDRITCH ASCENSION LOCKED\nBeat the alien leagues, then survive the Last Aeon for one minute."
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
		var entry: Dictionary = eldritch_buttons[id]
		if not game.eldritch_offer_unlocked:
			_set_upgrade_row(entry, "%s\n%s" % [definition.name, definition.description], true, str(definition.description), "LOCKED")
		elif rank >= int(definition.max_level):
			_set_upgrade_row(entry, "%s  •  RANK %d / %d\n%s" % [definition.name, rank, int(definition.max_level), definition.description], true, str(definition.description), "MAXED")
		else:
			_set_upgrade_row(entry, "%s  •  RANK %d  •  %d ARCANA\n%s" % [definition.name, rank, game.get_eldritch_cost(id), definition.description], not game.can_buy_eldritch(id), str(definition.description))

	for definition in Content.DIVINE_BLESSINGS:
		var id := str(definition.id)
		var entry: Dictionary = divine_buttons[id]
		if game.has_divine_blessing(id):
			_set_upgrade_row(entry, "%s\n%s" % [definition.name, definition.description], true, str(definition.description), "OWNED")
		else:
			_set_upgrade_row(entry, "%s\n%s" % [definition.name, definition.description], not game.cosmos_conquered, str(definition.description), "DO IT AGAIN")
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
	stat_labels.field_tap.text = "%.1f%% per tap • %.0f%% maximum contribution per timer" % [
		game.get_field_tap_fraction() * 100.0,
		game.get_field_tap_phase_cap() * 100.0,
	]
	stat_labels.offline_xp.text = "%.0f%%" % (game.get_offline_xp_efficiency() * 100.0)
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
	stat_labels.lifetime_xp.text = BaseballGameState.format_xp_total(game.lifetime_xp)
	stat_labels.achievements.text = "%d / %d • +%d%% • XP ×%.2f" % [
		game.unlocked_achievements.size(),
		Content.ACHIEVEMENTS.size(),
		int(round(game.get_achievement_xp_bonus() * 100.0)),
		game.get_achievement_xp_multiplier(),
	]
	stat_labels.dna.text = "%s / %s" % [BaseballGameState.format_number(float(game.dna), 0), BaseballGameState.format_number(game.lifetime_dna_earned, 0)]
	stat_labels.arcana.text = "%s / %s" % [BaseballGameState.format_number(float(game.arcana), 0), BaseballGameState.format_number(game.lifetime_arcana_earned, 0)]
	stat_labels.genetic_rebirths.text = "%d / %d" % [game.genetic_rebirths, game.lifetime_genetic_rebirths]
	stat_labels.eldritch_ascensions.text = "%d / %d" % [game.eldritch_ascensions, game.lifetime_eldritch_ascensions]
	stat_labels.divine_ascensions.text = str(game.divine_ascensions)
	stat_labels.divine_blessings.text = "%d / %d • %d Halos" % [game.divine_blessings.size(), Content.DIVINE_BLESSINGS.size(), game.divine_halos]
	stat_labels.completion.text = "AWAITING DIVINE RESET" if game.cosmos_conquered else "In progress"

func _on_achievement_unlocked(definition: Dictionary, total_unlocked: int) -> void:
	achievement_toast_queue.append(definition)
	_log_event("ACHIEVEMENT: %s • +1%% XP (%d/%d)." % [
		str(definition.name),
		total_unlocked,
		Content.ACHIEVEMENTS.size(),
	])
	_refresh_achievement_tab(true)
	if not achievement_toast_showing:
		_show_next_achievement_toast()

func _show_next_achievement_toast() -> void:
	if achievement_toast_queue.is_empty():
		achievement_toast_showing = false
		if achievement_toast != null:
			achievement_toast.visible = false
		return
	achievement_toast_showing = true
	var definition: Dictionary = achievement_toast_queue.pop_front()
	achievement_toast_name.text = str(definition.name)
	achievement_toast_description.text = str(definition.get("description", "Achievement completed."))
	achievement_toast.modulate = Color(1.0, 1.0, 1.0, 0.0)
	achievement_toast.visible = true
	achievement_toast.move_to_front()
	achievement_toast_tween = create_tween()
	achievement_toast_tween.tween_property(achievement_toast, "modulate:a", 1.0, 0.16)
	achievement_toast_tween.tween_interval(2.35)
	achievement_toast_tween.tween_property(achievement_toast, "modulate:a", 0.0, 0.30)
	achievement_toast_tween.tween_callback(_finish_achievement_toast)

func _clear_achievement_toasts() -> void:
	if achievement_toast_tween != null and achievement_toast_tween.is_valid():
		achievement_toast_tween.kill()
	achievement_toast_tween = null
	achievement_toast_queue.clear()
	achievement_toast_showing = false
	if achievement_toast != null:
		achievement_toast.visible = false

func _finish_achievement_toast() -> void:
	achievement_toast_tween = null
	achievement_toast.visible = false
	achievement_toast_showing = false
	_show_next_achievement_toast()

func _on_batch_resolved(summary: Dictionary) -> void:
	var launched: int = pitch_field.notify_batch(summary)
	var pitch_count := float(summary.pitches)
	var earned := float(summary.earned_xp)
	var loot_found := int(summary.get("loot_found", 0))
	if loot_found > 0:
		var drops: Array = summary.get("loot_drops", [])
		var drop_text := "%d loot parcels" % loot_found
		var popup_heading := "LOOT AUTO-SCRAPPED"
		var popup_detail := "%d PARCEL%s" % [loot_found, "" if loot_found == 1 else "S"]
		var popup_color := COLOR_GOLD
		if not drops.is_empty():
			var featured: Dictionary = drops[0]
			var rarity: Dictionary = Content.loot_rarity(int(featured.rarity))
			drop_text = "%s %s" % [rarity.name, featured.name]
			var slot_definition := Content.loot_slot_by_id(str(featured.slot))
			popup_heading = "%s %s DROP" % [
				str(rarity.name),
				str(slot_definition.get("name", "ITEM")),
			]
			var popup_name := str(featured.name)
			if popup_name.length() > 30:
				popup_name = popup_name.left(29) + "…"
			popup_detail = "%s • POWER %d" % [popup_name, game.get_loot_item_power(featured)]
			popup_color = Color(rarity.color)
			if loot_found > 1:
				drop_text += " + %d more" % (loot_found - 1)
				popup_detail += " • +%d MORE" % (loot_found - 1)
		var discarded := int(summary.get("loot_discarded", 0))
		if discarded > 0:
			drop_text += " • %d lowest items cleared" % discarded
		var scrap_gained := float(summary.get("loot_scrap_gained", 0.0))
		if scrap_gained > 0.0:
			drop_text += " • +%s Scrap" % BaseballGameState.format_number(scrap_gained, 0)
			popup_detail += " • +%s SCRAP" % BaseballGameState.format_number(scrap_gained, 0)
		pitch_field.show_loot_popup(popup_heading, popup_detail, popup_color)
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

func _on_field_tapped(field_position: Vector2) -> void:
	if game == null or pitch_field == null:
		return
	var result := game.apply_field_tap()
	if bool(result.get("applied", false)):
		pitch_field.apply_field_timer_advance(
			str(result.get("phase", "")),
			float(result.get("seconds", 0.0))
		)
	pitch_field.show_field_tap(field_position, result)

func _on_progression_changed(message: String) -> void:
	_log_event(message)
	_refresh_interface()

func _on_save_status_changed(message: String) -> void:
	if message == "Saved":
		_write_browser_save_mirror()
	if is_web_build and not web_storage_persistent:
		save_label.text = "temporary save"
	else:
		save_label.text = message.to_lower()

func _log_event(message: String) -> void:
	if event_log == null:
		return
	event_log.append_text("[color=#63d9ff]>[/color] %s\n" % message)

func _previous_opponent() -> void:
	game.set_current_opponent(game.current_opponent - 1)

func _next_opponent() -> void:
	game.set_current_opponent(game.current_opponent + 1)

func _accept_alien_help() -> void:
	if not game.accept_alien_help():
		return
	if not development_session and not game.save_writes_locked:
		game.save_game()
	var popup_size := Vector2i(350, 350) if mobile_layout else Vector2i(560, 300)
	alien_help_dialog.popup_centered_clamped(popup_size, 0.92)
	_refresh_interface()

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

func _buy_body_growth(id: String) -> void:
	if game.buy_body_growth(id) and not development_session and not game.save_writes_locked:
		game.save_game()
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
	var changed := true
	if id.begins_with("training_"):
		changed = game.set_auto_training_stat(id.trim_prefix("training_"), enabled)
	elif id.begins_with("catalog_"):
		changed = game.set_auto_catalog_setting(id.trim_prefix("catalog_"), enabled)
	else:
		match id:
			"advance":
				game.auto_advance_enabled = enabled and game.has_auto_advance_capacity()
			"farm":
				game.auto_farm_enabled = enabled and game.has_genetic_upgrade("predator_scouting")
	if changed:
		_log_event("%s %s." % [id.replace("_", " ").capitalize(), "enabled" if enabled else "disabled"])
	_refresh_interface()

func _toggle_catalog_hide_purchased(hidden: bool, catalog_id: String) -> void:
	if game.set_catalog_hide_purchased(catalog_id, hidden):
		_refresh_purchase_buttons()

func _toggle_hide_achieved(hidden: bool) -> void:
	game.achievement_hide_achieved = hidden
	_refresh_achievement_tab(true)

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
		"GOD: ‘Thanks for saving the universe. Wouldn’t the best reward be doing it all again?’\n\nAccept %s? God restores the original universe: XP, levels, DNA, Arcana, genetic enhancements, "
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

func _open_saves_menu() -> void:
	if mobile_overlay_control == save_stack:
		_save_now()
		return
	_save_now()
	_show_mobile_overlay(save_stack, "SAVES & TRANSFER")

func _save_now() -> void:
	if development_session:
		return
	if game.save_writes_locked:
		_show_save_recovery_required()
		return
	game.save_game()
	autosave_elapsed = 0.0

func _backup_filename() -> String:
	var now := Time.get_datetime_dict_from_system()
	return "no-hitter-save-v%d-%04d%02d%02d-%02d%02d%02d.json" % [
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
	if game.save_writes_locked:
		_show_save_recovery_required()
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
	pending_import_returns_from_title = title_screen_active
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
		BaseballGameState.format_xp_total(saved_xp),
	]
	import_save_confirmation.popup_centered(Vector2i(610, 260))

func _confirm_import_save() -> void:
	if development_session or pending_import_save.is_empty():
		return
	var imported := pending_import_save.duplicate(true)
	var imported_name := pending_import_name
	var should_resume_from_title := pending_import_returns_from_title
	_discard_pending_import()
	# The replacement confirmation is the explicit authority to retire every
	# automatic generation. Without it, unreadable/newer saves stay protected.
	game.delete_save()
	game.apply_save_data(imported)
	var saved_at := float(imported.get("saved_at", Time.get_unix_time_from_system()))
	var offline_seconds := maxf(Time.get_unix_time_from_system() - saved_at, 0.0)
	var offline_summary := game.simulate_offline(offline_seconds)
	pitch_field.reset_visual_state()
	last_reveal_mask = -1
	last_loot_revision = -1
	last_loot_ui_signature = ""
	last_owned_upgrade_list_signature = ""
	opponent_loadout_signature = ""
	event_log.clear()
	_refresh_interface()
	game.save_writes_locked = false
	browser_save_regression_allowed = true
	game.save_game()
	autosave_elapsed = 0.0
	_log_event("Loaded portable backup %s." % imported_name)
	if should_resume_from_title:
		pending_title_offline_summary.clear()
		_leave_title_screen(false)
	if not offline_summary.is_empty():
		_log_offline_summary(offline_summary, "Imported-save catch-up")

func _discard_pending_import() -> void:
	pending_import_save.clear()
	pending_import_name = ""
	pending_import_returns_from_title = false

func _show_save_transfer_error(message: String) -> void:
	save_transfer_message_dialog.dialog_text = message
	save_transfer_message_dialog.popup_centered(Vector2i(560, 180))
	_on_save_status_changed("Transfer failed")

func _show_save_recovery_required() -> void:
	if save_transfer_message_dialog == null:
		return
	var detail := game.last_load_message.strip_edges() if game != null else ""
	if detail.is_empty():
		detail = "The existing automatic save could not be read."
	save_transfer_message_dialog.dialog_text = (
		detail
		+ "\n\nIt has not been overwritten. Use LOAD to restore an exported backup or a phone save slot. "
		+ "Use RESET only if you deliberately want to discard the protected save and begin again."
	)
	save_transfer_message_dialog.popup_centered_clamped(Vector2i(600, 250), 0.94)
	_on_save_status_changed("Save recovery required")

func _request_hard_reset() -> void:
	if development_session:
		pending_new_game_from_title = false
		return
	hard_reset_input.clear()
	hard_reset_confirm_button.disabled = true
	hard_reset_dialog.popup_centered(Vector2i(560, 270))
	hard_reset_input.call_deferred("grab_focus")

func _close_hard_reset_dialog() -> void:
	pending_new_game_from_title = false
	hard_reset_input.clear()
	hard_reset_confirm_button.disabled = true
	hard_reset_dialog.hide()

func _update_hard_reset_confirmation(typed_text: String) -> void:
	hard_reset_confirm_button.disabled = typed_text != "RESET"

func _confirm_hard_reset() -> void:
	if development_session or hard_reset_input.text != "RESET":
		return
	var should_start_from_title := pending_new_game_from_title
	pending_new_game_from_title = false
	hard_reset_dialog.hide()
	_clear_browser_recovery_mirrors()
	game.delete_save()
	game.reset_fresh()
	game.save_writes_locked = false
	browser_save_regression_allowed = true
	pitch_field.reset_visual_state()
	autosave_elapsed = 0.0
	ui_elapsed = 0.0
	last_reveal_mask = -1
	last_loot_revision = -1
	last_loot_ui_signature = ""
	last_owned_upgrade_list_signature = ""
	opponent_loadout_signature = ""
	event_log.clear()
	game.save_game()
	_refresh_interface()
	_log_event("Progress reset. Little Timmy has agreed to pretend none of that happened.")
	if should_start_from_title:
		pending_title_offline_summary.clear()
		_leave_title_screen(false)
