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
	_expect(main.mobile_nav.visible, "Phone navigation should remain visible below the field")
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
	main._set_mobile_layout(false, false)
	await process_frame
	_expect(not main.mobile_layout, "Desktop layout did not restore")
	_expect(not main.pitch_field.is_portrait_layout(), "Desktop field should return to its horizontal lane")
	_expect(main.upgrade_panel.visible and main.equipment_sidebar.visible and main.event_log_panel.visible, "Desktop panels did not restore")
	_expect(main.outcomes_grid.columns == 8, "Desktop outcome row should return to one line")

	main.free()
	if failures.is_empty():
		print("PASS: portrait field and mobile overlays are stable")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("FAIL: %d mobile interface issue(s)" % failures.size())
		quit(1)
