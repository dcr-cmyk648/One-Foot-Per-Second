extends SceneTree

const MainScene = preload("res://main.tscn")
const MainScript = preload("res://scripts/main.gd")
const Content = preload("res://scripts/content.gd")

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _run() -> void:
	root.size = Vector2i(390, 844)
	var main = MainScene.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	main.set_process(false)
	main.pitch_field.set_process(false)
	main.game.reset_fresh()
	main.offline_progress_dialog.hide()
	main._refresh_interface()
	main._set_mobile_layout(true, true)
	await process_frame
	await process_frame

	print("No Hitter — portrait browser-interface audit")
	_expect(main.mobile_layout, "Phone layout did not activate")
	_expect(main.mobile_portrait_layout, "Portrait field orientation did not activate")
	_expect(is_equal_approx(main._normalize_browser_content_scale(3.0), 3.0), "A 3× phone display must retain its logical content scale")
	_expect(main.mobile_nav.visible, "Phone navigation should remain visible below the field")
	_expect(main.page_container.get_combined_minimum_size().y <= main.page_scroll.size.y + 1.0, "A fresh 390×844 phone should not require vertical scrolling")
	_expect(not main.mobile_install_button.visible, "Native sessions should not show a phone install action")
	_expect(main._mobile_install_offer_for_state(true, true, false, false), "Eligible iPhones should receive the Home Screen install pathway")
	_expect(main._mobile_install_offer_for_state(true, false, true, false), "Eligible Android phones should receive the install pathway")
	_expect(not main._mobile_install_offer_for_state(true, true, false, true), "A Home Screen launch should hide the redundant install pathway")
	_expect(not main._mobile_install_offer_for_state(true, false, false, false), "Non-mobile browsers should not receive phone-specific instructions")
	_expect(main.header_subtitle.visible, "The milestone subtitle should remain visible beneath the title on phone")
	_expect(main.header_subtitle.text == "A baseball game about a regular ol’ guy", "Phone and desktop should share the same milestone subtitle")
	_expect(main.achievement_toast_description != null, "Phone achievement toasts should include the completed condition")
	_expect(main.achievement_toast_description.get_theme_font_size("font_size") < main.achievement_toast_name.get_theme_font_size("font_size"), "Phone achievement conditions should remain visually subordinate to their names")
	_expect(main.achievement_toast.size.x <= 352.0, "The expanded achievement toast should stay inside a 390-pixel phone")
	_expect(main._should_use_compact_layout(Vector2(1279.0, 800.0)), "A resized browser just below the wide boundary should use overlay navigation")
	_expect(main._should_use_compact_layout(Vector2(1366.0, 680.0)), "A resized short browser window should use overlay navigation")
	_expect(not main._should_use_compact_layout(Vector2(1280.0, 696.0)), "The complete wide interface should fit at its declared boundary")
	_expect(not main._should_use_compact_layout(Vector2(1600.0, 720.0), true, true), "Widening a normal-height compact browser should restore the full interface")
	main._set_mobile_install_offer_visible(true)
	await process_frame
	_expect(main.mobile_install_button.visible, "An eligible iPhone should expose INSTALL directly in the phone navigation")
	_expect(main.mobile_nav.get_combined_minimum_size().x <= main.page_scroll.size.x + 1.0, "The iPhone INSTALL action should fit without widening the phone UI")
	main._configure_mobile_install_dialog("ios")
	main.mobile_install_dialog.popup_centered_clamped(Vector2i(360, 365), 0.95)
	await process_frame
	_expect(main.mobile_install_dialog.visible, "The INSTALL action should open its Home Screen guide")
	_expect(main.mobile_install_dialog.dialog_text.contains("ADD TO HOME SCREEN"), "The iPhone guide should name Apple's Add to Home Screen action")
	_expect(main.mobile_install_dialog.dialog_text.contains("EXPORT"), "The iPhone guide should protect players from browser-storage surprises")
	main.mobile_install_dialog.hide()
	main._configure_mobile_install_dialog("android")
	_expect(main.mobile_install_dialog.title == "INSTALL ON ANDROID", "The Android install guide should identify its platform")
	_expect(main.mobile_install_dialog.dialog_text.contains("INSTALL APP"), "The Android fallback should name Chrome's install action")
	_expect(main.mobile_install_dialog.dialog_text.contains("SAVE & UPDATE"), "The Android guide should explain that installed builds stay web-updated")
	main._set_mobile_install_offer_visible(false)
	_expect(not main.upgrade_panel.visible, "Upgrade panel should not squeeze the phone field")
	_expect(not main.equipment_sidebar.visible, "Loadout sidebar should not squeeze the phone field")
	_expect(not main.event_log_panel.visible, "Event log should live behind the phone menu")
	_expect(main.pitch_field.is_portrait_layout(), "The phone field should rotate into a vertical pitching lane")
	_expect(
		main.pitch_field.get_pitcher_position().y > main.pitch_field.get_batter_position().y,
		"The phone pitcher must appear below the batter"
	)
	_expect(main.outcomes_grid.columns == 4, "Phone outcomes should wrap into a readable 4-by-2 grid")
	_expect(main.previous_button.text.is_empty() and main.next_button.text.is_empty(), "Phone opponent controls should not depend on font arrow glyphs")
	_expect(main.previous_button.icon != null and main.next_button.icon != null, "Phone opponent controls should provide rasterized back/forward icons")
	_expect(main.previous_button.get_combined_minimum_size().y >= 44.0 and main.next_button.get_combined_minimum_size().y >= 44.0, "Phone opponent controls should remain touch-sized")
	_expect(not main.visual_weight_label.visible, "Secondary renderer detail should not crowd the phone footer")
	_expect(main.field_stat_panel.size.x <= 134.0, "The phone throw profile is wider than its values require")
	_expect(
		main.field_stat_panel.position.x + main.field_stat_panel.size.x
		< main.pitch_field.get_pitcher_position().x - 10.0 * main.pitch_field._get_pitcher_visual_scale(),
		"The phone throw profile overlaps the pitcher model"
	)
	var portrait_arm: Dictionary = main.pitch_field._get_throw_arm_geometry(0, 1, 0.0)
	_expect(Vector2(portrait_arm.end).x > 0.0, "A right-handed phone pitcher should rest the arm on screen-right")
	var portrait_mound: Vector2 = main.pitch_field.get_pitcher_position()
	_expect(main.pitch_field.move_closer_arrow.text.is_empty(), "Phone mound controls should use icons instead of unsupported arrow glyphs")
	_expect(main.pitch_field.move_closer_arrow.icon != null and main.pitch_field.move_farther_arrow.icon != null, "Phone mound controls should provide rasterized up/down icons")
	_expect(main.pitch_field.move_closer_arrow.size.x >= 44.0 and main.pitch_field.move_closer_arrow.size.y >= 44.0, "Phone mound controls should be touch-sized")
	_expect(main.pitch_field.move_closer_arrow.position.x > portrait_mound.x, "Both phone mound controls should sit to the pitcher's right")
	_expect(main.pitch_field.move_farther_arrow.position.x > portrait_mound.x, "The farther-mound control should not cover the cooldown meter")
	_expect(main.pitch_field.move_closer_arrow.position.y < main.pitch_field.move_farther_arrow.position.y, "Move closer should point up above Move farther")
	main.is_web_build = true
	main._on_browser_update_available()
	await process_frame
	_expect(main.update_banner.visible, "An available browser release should show the update banner")
	_expect(main.update_banner.size.x <= 370.0, "The browser update banner should fit a 390-pixel phone")
	main._snooze_browser_update()
	_expect(not main.update_banner.visible, "Choosing Later should dismiss the browser update banner")
	main.is_web_build = false

	main._show_mobile_overlay(main.upgrade_panel, "UPGRADES")
	await process_frame
	_expect(main.mobile_overlay_panel.visible, "Upgrades button should open a full phone overlay")
	_expect(main.upgrade_panel.get_parent() == main.mobile_overlay_content, "Upgrade panel should move into the overlay")
	_expect(main.upgrade_panel.visible, "Upgrade overlay content should be visible")
	_expect(main.mobile_overlay_xp_label.visible, "The Upgrades overlay should keep spendable XP visible")
	_expect(
		main.mobile_overlay_xp_label.text == "XP %s" % main.xp_label.text,
		"The Upgrades overlay XP balance should match the live game balance"
	)
	_expect(main.mobile_upgrade_stats_panel.visible, "The phone upgrade overlay should keep current stats visible")
	_expect(main.mobile_upgrade_stat_labels.size() == 9, "The phone upgrade overlay should expose every trainable base-stat axis")
	_expect(
		main.mobile_upgrade_stat_labels.speed.text == BaseballGameState.format_speed(main.game.get_representative_pitch_speed()),
		"The phone upgrade overlay should show the current effective speed"
	)
	_expect(main.mobile_upgrade_stat_labels.quality.text == "%.3f" % main.game.get_pitch_quality(), "The phone upgrade overlay should show current quality")
	_expect(main.mobile_upgrade_stat_labels.tap.text == "1.7%", "The phone upgrade overlay should show the reduced current field-tap advance")
	_expect(main.mobile_tab_navigation.visible, "The phone upgrade overlay should show tab navigation")
	_expect(
		main.mobile_tab_next_button.get_combined_minimum_size().x >= 44.0
		and main.mobile_tab_next_button.get_combined_minimum_size().y >= 44.0,
		"The phone tab-forward control should provide a 44-by-44 touch target"
	)
	_expect(
		main.mobile_tab_previous_button.get_combined_minimum_size().x >= 44.0
		and main.mobile_tab_previous_button.get_combined_minimum_size().y >= 44.0,
		"The phone tab-back control should provide a 44-by-44 touch target"
	)
	_expect(main.mobile_tab_previous_button.icon != null and main.mobile_tab_next_button.icon != null, "Phone tab traversal should not depend on font arrow glyphs")
	_expect(not main.upgrade_tabs.get_tab_bar().scrolling_enabled, "The tiny native TabBar arrows should be removed on phone layouts")
	_expect(main.upgrade_tabs.get_tab_bar().has_theme_icon_override("decrement") and main.upgrade_tabs.get_tab_bar().has_theme_icon_override("increment"), "Tiny native overflow arrows should yield to the explicit phone tab controls")
	_expect(main.mobile_tab_previous_button.disabled, "The first upgrade tab should disable Back")
	_expect(main.catalog_hide_purchased_toggles.size() == 3, "Phone upgrade catalogs should retain every per-tab Hide Purchased control")
	for catalog_toggle in main.catalog_hide_purchased_toggles.values():
		_expect((catalog_toggle as CheckButton).get_combined_minimum_size().y >= 44.0, "Phone Hide Purchased controls should remain touch-sized")
	main.upgrade_tabs.current_tab = main.achievement_tab.get_index()
	main._refresh_achievement_tab(true)
	await process_frame
	_expect(main.achievement_cards.size() == 101, "The phone achievement browser should expose all 101 slots")
	var phone_hidden_card: Dictionary = main.achievement_cards.genetic_offer
	_expect((phone_hidden_card.title as Label).text == "HIDDEN ACHIEVEMENT", "Phone hidden achievements should remain anonymous")
	_expect(not (phone_hidden_card.description as Label).text.contains("Xylophax"), "Phone hidden achievements must not leak future names")
	var phone_no_hitter_card: Dictionary = main.achievement_cards.no_hitter
	_expect((phone_no_hitter_card.title as Label).text == "HIDDEN ACHIEVEMENT", "The phone must not reveal the namesake secret achievement")
	_expect(not (phone_no_hitter_card.description as Label).text.contains("Octathulhu"), "The phone must not leak the namesake secret condition")
	main.upgrade_tabs.current_tab = 0
	main._refresh_mobile_tab_navigation()
	main.mobile_tab_next_button.pressed.emit()
	await process_frame
	_expect(main.upgrade_tabs.current_tab == 1, "The touch-sized Next control did not change upgrade tabs")
	_expect(not main.mobile_tab_previous_button.disabled, "Advancing a tab should enable Back")
	main._close_mobile_overlay()
	await process_frame
	_expect(not main.mobile_overlay_panel.visible, "Closing the phone overlay should reveal the field")
	_expect(main.upgrade_panel.get_parent() == main.body_container, "Upgrade panel should return to its desktop home")
	_expect(not main.upgrade_panel.visible, "Returned upgrade panel should stay hidden on phone")

	main._show_mobile_inspection_for_control(main.outcome_panels[0])
	await process_frame
	_expect(main.mobile_inspection_dialog.visible, "Tapping a result card should open mobile details")
	_expect(main.mobile_inspection_dialog.dialog_text.to_upper().contains("GRAND SLAM"), "Result-card details should reuse the desktop tooltip")
	_expect(
		main.mobile_inspection_dialog.get_ok_button().get_combined_minimum_size().y >= 44.0,
		"Mobile inspection should always have a touch-sized Close action, not %s"
		% str(main.mobile_inspection_dialog.get_ok_button().get_combined_minimum_size())
	)
	main.mobile_inspection_dialog.hide()
	if main.opponent_loadout_dock.get_child_count() > 0:
		var opponent_item := main.opponent_loadout_dock.get_child(0) as Control
		main._show_mobile_inspection_for_control(opponent_item)
		await process_frame
		_expect(main.mobile_inspection_dialog.visible, "Tapping enemy equipment should open mobile details")
		_expect(main.mobile_inspection_dialog.dialog_text.contains("Batter threat"), "Enemy equipment details should include its threat modifier")
		main.mobile_inspection_dialog.hide()

	main.game.opponent_mastery[0] = float(main.game.opponents[0].mastery_required) * 124.0
	main._refresh_interface()
	await process_frame
	await process_frame
	_expect(main.mastery_label.text.begins_with("MASTERED ×124"), "Phone overmastery should use its compact one-line summary")
	_expect(main.page_container.get_combined_minimum_size().y <= main.page_scroll.size.y + 1.0, "A long overmastery state should not push phone navigation below 390×844")
	main._show_mobile_inspection_for_control(main.mastery_label)
	await process_frame
	_expect(main.mobile_inspection_dialog.visible, "Phone mastery should expose its full desktop explanation on tap")
	main.mobile_inspection_dialog.hide()

	main.game._add_loot_item({
		"id": "phone_equipped_hat", "slot": "hat", "item_level": 1, "rarity": 0,
		"name": "Phone Test Cap", "stats": {"quality_bonus": 0.01},
		"roll_quality": 1.0, "color": "a9b6c5", "favorite": false,
	})
	main.game._add_loot_item({
		"id": "phone_compare_hat", "slot": "hat", "item_level": 2, "rarity": 1,
		"name": "Readable Comparison Cap", "stats": {"quality_bonus": 0.02, "speed_bonus": 0.01},
		"roll_quality": 1.0, "color": "66a6ff", "favorite": false,
	})
	main.game.equip_loot("phone_equipped_hat")
	main._open_locker("hat")
	await process_frame
	await process_frame
	_expect(main.locker_dialog.visible, "The phone equipment browser should open")
	_expect(main.locker_dialog.borderless, "The phone equipment browser should not rely on an iOS-obscured title bar")
	_expect(main.locker_dialog_close_button.visible, "The phone equipment browser needs an in-content Close button")
	_expect(main.locker_dialog_close_button.get_combined_minimum_size().y >= 44.0, "The equipment Close button should be touch-sized")
	_expect(main.locker_dialog.position.y >= 0, "The phone equipment browser should remain below the usable viewport edge")
	_expect(main.locker_dialog.position.y + main.locker_dialog.size.y <= 844, "The phone equipment browser should fit inside the usable viewport")
	var phone_compare_button: Button
	var phone_compare_label: Label
	var phone_compare_stack: VBoxContainer
	for row_index in main.locker_dialog_items.get_child_count():
		var phone_item_panel := main.locker_dialog_items.get_child(row_index) as PanelContainer
		var phone_item_stack := phone_item_panel.get_child(0) as VBoxContainer
		var phone_item_label := phone_item_stack.get_child(0) as Label
		var phone_actions := phone_item_stack.get_child(1) as HBoxContainer
		if str(phone_item_panel.get_meta("loot_item_id", "")) == "phone_compare_hat":
			phone_compare_label = phone_item_label
			phone_compare_stack = phone_item_stack
			phone_compare_button = phone_actions.get_child(1) as Button
			_expect(phone_item_label.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Phone item text should not intercept vertical scrolling")
			_expect(phone_item_label.text.begins_with("Readable Comparison Cap"), "Phone equipment rows should lead with the complete item name")
			_expect(phone_item_label.text.contains("POWER %d" % main.game.get_loot_item_power(main.game.get_loot_item("phone_compare_hat"))), "Phone equipment rows should show Power without opening Compare")
			_expect(phone_item_label.custom_minimum_size.y >= 62.0, "Phone equipment summaries should reserve visible height above their action buttons")
			_expect((phone_actions.get_child(0) as Button).text == "EQUIP", "Phone rows should expose an explicit Equip action")
	_expect(phone_compare_button != null, "The phone locker should retain the comparison item")
	_expect(phone_compare_stack.tooltip_text.is_empty(), "Phone and S-Pen layouts should not create a covering hover tooltip")
	var hold_press := InputEventScreenTouch.new()
	hold_press.pressed = true
	hold_press.position = phone_compare_label.get_global_rect().get_center()
	main._input(hold_press)
	var hold_drag := InputEventScreenDrag.new()
	hold_drag.relative = Vector2(0.0, MainScript.LOCKER_ITEM_DRAG_CANCEL_DISTANCE + 1.0)
	main._input(hold_drag)
	main._update_locker_item_hold(MainScript.LOCKER_ITEM_HOLD_SECONDS + 0.1)
	_expect(not main.loot_item_dialog.visible, "Scrolling a phone item should cancel hold-to-inspect")
	main._input(hold_press)
	main._update_locker_item_hold(MainScript.LOCKER_ITEM_HOLD_SECONDS - 0.01)
	_expect(not main.loot_item_dialog.visible, "A short phone press should not interrupt locker scrolling")
	main._update_locker_item_hold(0.02)
	await process_frame
	_expect(main.loot_item_dialog.visible, "Holding passive phone item text should open its full comparison")
	main._close_loot_item_dialog()
	phone_compare_button.pressed.emit()
	await process_frame
	await process_frame
	_expect(main.loot_item_dialog.visible, "Tapping phone equipment should open a dedicated, legible comparison")
	_expect(main.loot_item_dialog.position.y >= 0 and main.loot_item_dialog.position.y + main.loot_item_dialog.size.y <= 844, "The item comparison must remain entirely inside the phone viewport")
	_expect(main.loot_item_name_label.text == "Readable Comparison Cap", "The item comparison should show the complete item name")
	_expect(main.loot_item_equipped_label.text.contains("Phone Test Cap"), "The phone comparison should identify the equipped item")
	_expect(main.loot_item_stats.get_child_count() == Content.LOOT_STATS.size(), "The phone comparison should expose all item stats without hover")
	_expect(main.loot_item_equip_button.get_combined_minimum_size().y >= 44.0 and main.loot_item_trash_button.get_combined_minimum_size().y >= 44.0, "Phone comparison actions should be touch-sized")
	main.loot_item_trash_button.pressed.emit()
	_expect(main.loot_item_trash_button.text == "CONFIRM TRASH", "Phone Trash should require a second deliberate press")
	main._close_loot_item_dialog()
	main.locker_dialog_close_button.pressed.emit()
	await process_frame
	_expect(not main.locker_dialog.visible, "The in-content equipment Close button should dismiss the browser")

	main._show_mobile_overlay(main.equipment_sidebar, "LOADOUT")
	await process_frame
	_expect(main.equipment_sidebar.get_parent() == main.mobile_overlay_content, "Loadout should open in the same phone overlay")
	main._close_mobile_overlay()
	root.size = Vector2i(1179, 720)
	main._set_mobile_layout(true, false, true)
	await process_frame
	await process_frame
	_expect(main.outcomes_grid.columns == 8, "Compact landscape outcomes should stay on one short row")
	_expect(main.mobile_nav.custom_minimum_size.y <= 34.0, "Compact landscape navigation should not waste vertical space")
	_expect(main.page_container.get_combined_minimum_size().y <= main.page_scroll.size.y + 1.0, "A 1179×720 compact browser should keep the complete play view in-frame")
	root.size = Vector2i(1256, 696)
	main._set_mobile_layout(false, false, true)
	await process_frame
	await process_frame
	_expect(not main.mobile_layout, "Desktop layout did not restore")
	_expect(not main.pitch_field.is_portrait_layout(), "Desktop field should return to its horizontal lane")
	_expect(main.upgrade_panel.visible and main.equipment_sidebar.visible and main.event_log_panel.visible, "Desktop panels did not restore")
	_expect(main.outcomes_grid.columns == 8, "Desktop outcome row should return to one line")
	_expect(main.page_container.get_combined_minimum_size().y <= main.page_scroll.size.y + 1.0, "The narrowest hysteresis-allowed wide view should fit without page scrolling")
	_expect(main.body_container.get_combined_minimum_size().x <= main.page_scroll.size.x + 1.0, "The narrowest hysteresis-allowed wide view should not clip its right panel")
	main.game.genetic_offer_unlocked = true
	main.game.eldritch_offer_unlocked = true
	main.game.highest_unlocked = 44
	main.game.current_opponent = 44
	main.game._reset_batter_identity()
	main._refresh_interface()
	await process_frame
	await process_frame
	_expect(main.prestige_header_stack.visible, "The wide-layout audit must include its late-game prestige metric")
	_expect(main.header_row.get_combined_minimum_size().x <= main.header_panel.size.x + 1.0, "Late-game header controls should fit at the narrowest retained wide width")
	_expect(main.page_container.get_combined_minimum_size().y <= main.page_scroll.size.y + 1.0, "A long final-boss name should not reintroduce page scrolling at the wide boundary")
	var desktop_arm: Dictionary = main.pitch_field._get_throw_arm_geometry(0, 1, 0.0)
	_expect(Vector2(desktop_arm.end).y > 0.0, "A right-handed desktop pitcher should rest the arm below the throwing line")

	main.free()
	if failures.is_empty():
		print("PASS: portrait field and mobile overlays are stable")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("FAIL: %d mobile interface issue(s)" % failures.size())
		quit(1)
