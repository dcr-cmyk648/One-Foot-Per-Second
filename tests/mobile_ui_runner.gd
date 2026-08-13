extends SceneTree

const MainScene = preload("res://main.tscn")

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
	main._refresh_interface()
	main._set_mobile_layout(true, true)
	await process_frame
	await process_frame

	print("One Foot Per Second — portrait browser-interface audit")
	_expect(main.mobile_layout, "Phone layout did not activate")
	_expect(main.mobile_portrait_layout, "Portrait field orientation did not activate")
	_expect(is_equal_approx(main._normalize_browser_content_scale(3.0), 3.0), "A 3× phone display must retain its logical content scale")
	_expect(main.mobile_nav.visible, "Phone navigation should remain visible below the field")
	_expect(main.header_subtitle.visible, "The milestone subtitle should remain visible beneath the title on phone")
	_expect(main.header_subtitle.text == "A baseball game about a regular ol’ guy", "Phone and desktop should share the same milestone subtitle")
	_expect(main._should_use_compact_layout(Vector2(1279.0, 800.0)), "A resized browser just below the wide boundary should use overlay navigation")
	_expect(main._should_use_compact_layout(Vector2(1366.0, 680.0)), "A resized short browser window should use overlay navigation")
	_expect(not main._should_use_compact_layout(Vector2(1280.0, 720.0)), "The complete wide interface should fit at its declared boundary")
	_expect(not main.upgrade_panel.visible, "Upgrade panel should not squeeze the phone field")
	_expect(not main.equipment_sidebar.visible, "Loadout sidebar should not squeeze the phone field")
	_expect(not main.event_log_panel.visible, "Event log should live behind the phone menu")
	_expect(main.pitch_field.is_portrait_layout(), "The phone field should rotate into a vertical pitching lane")
	_expect(
		main.pitch_field.get_pitcher_position().y > main.pitch_field.get_batter_position().y,
		"The phone pitcher must appear below the batter"
	)
	_expect(main.outcomes_grid.columns == 4, "Phone outcomes should wrap into a readable 4-by-2 grid")
	_expect(main.previous_button.text == "‹" and main.next_button.text == "›", "Phone opponent controls should use compact arrows")
	_expect(not main.visual_weight_label.visible, "Secondary renderer detail should not crowd the phone footer")
	_expect(main.field_stat_panel.size.x <= 134.0, "The phone throw profile is wider than its values require")
	_expect(
		main.field_stat_panel.position.x + main.field_stat_panel.size.x
		< main.pitch_field.get_pitcher_position().x - 10.0 * main.pitch_field._get_pitcher_visual_scale(),
		"The phone throw profile overlaps the pitcher model"
	)
	var portrait_arm: Dictionary = main.pitch_field._get_throw_arm_geometry(0, 1, 0.0)
	_expect(Vector2(portrait_arm.end).x > 0.0, "A right-handed phone pitcher should rest the arm on screen-right")
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
	main._close_mobile_overlay()
	await process_frame
	_expect(not main.mobile_overlay_panel.visible, "Closing the phone overlay should reveal the field")
	_expect(main.upgrade_panel.get_parent() == main.body_container, "Upgrade panel should return to its desktop home")
	_expect(not main.upgrade_panel.visible, "Returned upgrade panel should stay hidden on phone")

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
