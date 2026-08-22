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

func _rect_inside(inner: Rect2, outer: Rect2) -> bool:
	return (
		inner.position.x >= outer.position.x - 1.0
		and inner.position.y >= outer.position.y - 1.0
		and inner.end.x <= outer.end.x + 1.0
		and inner.end.y <= outer.end.y + 1.0
	)

func _run() -> void:
	root.size = Vector2i(390, 844)
	var main = MainScene.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	main.set_process(false)
	main.pitch_field.set_process(false)
	main.game.reset_fresh()
	main.pitch_field.reset_visual_state()
	main.game.pending_story_dialogs.clear()
	main.story_dialog.hide()
	main.offline_progress_dialog.hide()
	main._refresh_interface()
	main._set_mobile_layout(true, true)
	main._configure_title_layout(Vector2(390.0, 844.0))
	await process_frame
	await process_frame

	print("No Hitter — portrait browser-interface audit")
	_expect(main.title_screen_active and main.title_screen.visible, "Phone launches should begin on the title screen")
	_expect(main.title_panel.size.x <= 366.0 and main.title_panel.position.x >= 0.0 and main.title_panel.position.x + main.title_panel.size.x <= main.title_screen.size.x, "The phone title panel should fit horizontally: %s at %s" % [str(main.title_panel.size), str(main.title_panel.position)])
	_expect(main.title_panel.size.y <= 820.0 and main.title_panel.position.y >= 0.0 and main.title_panel.position.y + main.title_panel.size.y <= main.title_screen.size.y, "The phone title panel should fit vertically: %s at %s" % [str(main.title_panel.size), str(main.title_panel.position)])
	main.is_web_build = true
	main.update_banner.visible = true
	main._configure_title_layout(Vector2(390.0, 844.0))
	await process_frame
	_expect(not main.update_banner.get_global_rect().intersects(main.title_heading_label.get_global_rect()), "A phone update banner must not overlap the NO HITTER title")
	main.update_banner.visible = false
	main.is_web_build = false
	main._configure_title_layout(Vector2(390.0, 844.0))
	_expect(main.title_art._visible_era() == 0, "Fresh phone title art must remain spoiler-free")
	_expect(main.title_art.get_animation_state(0.0).phase == "windup", "Phone title art should retain the deterministic windup phase")
	_expect(main.title_art.get_animation_state(main.title_art.WINDUP_SECONDS + main.title_art.OUTBOUND_SECONDS + main.title_art.CONTACT_SECONDS + 0.01).phase == "batted_return", "Phone title art should retain the visible batted-return phase")
	var phone_title_stage: Rect2 = main.title_art._stage_rect(Vector2(340.0, 420.0))
	_expect(absf(phone_title_stage.size.x / phone_title_stage.size.y - 0.92) < 0.02 and phone_title_stage.size.x > 310.0, "Phone title art should enlarge the icon-style matchup in a portrait frame")
	if "--capture-title" in OS.get_cmdline_user_args():
		var title_image := root.get_texture().get_image()
		var title_error := title_image.save_png("/private/tmp/no-hitter-title-phone.png")
		_expect(title_error == OK, "Could not capture the phone title screen")
	main._open_title_resume_picker()
	main._configure_title_layout(Vector2(390.0, 844.0))
	await process_frame
	_expect(main.title_resume_stack.visible and not main.title_art_frame.visible, "The phone save picker should replace the art instead of overflowing beneath it")
	main._close_title_resume_picker()
	main._request_new_game_from_title()
	main._configure_title_layout(Vector2(390.0, 844.0))
	await process_frame
	_expect(main.title_new_game_stack.visible and not main.hard_reset_dialog.visible, "Phone Start New Game should present slots instead of a typed global reset")
	_expect(main.title_panel.position.y + main.title_panel.size.y <= main.title_screen.size.y, "The phone new-game slot picker should keep every title action in frame")
	for new_slot_entry in main.title_new_game_slot_entries:
		_expect(_rect_inside((new_slot_entry.button as Control).get_global_rect(), main.title_action_panel.get_global_rect()), "Every phone BEGIN/REPLACE action must stay visibly inside the title action panel")
	var phone_new_game_back := main.title_new_game_stack.get_child(main.title_new_game_stack.get_child_count() - 1) as Control
	_expect(_rect_inside(phone_new_game_back.get_global_rect(), main.title_action_panel.get_global_rect()), "The phone new-campaign Back action must remain reachable")
	main._close_title_new_game_picker()
	main.development_session = true
	main._start_fresh_title_game(0)
	await process_frame
	await process_frame
	_expect(main.story_dialog.visible, "A fresh phone slot must visibly present the opening story")
	_expect(main.story_dialog.position.y + main.story_dialog.size.y <= root.size.y + 1.0, "The opening phone story dialog must remain fully reachable at 390×844")
	_expect(main.story_dialog.dialog_text.contains("one foot per second"), "The opening phone story must explain the slow first pitch")
	main._accept_story_dialog()
	main.story_dialog.hide()
	main.game.pending_story_dialogs.clear()
	main._return_to_title_screen()
	main._leave_title_screen(false)
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
	_expect(main.header_subtitle.text == "A baseball game about a regular ol’ toddler", "Phone and desktop should share the current toddler-body subtitle")
	if "--capture-ui" in OS.get_cmdline_user_args():
		await process_frame
		var phone_play_image := root.get_texture().get_image()
		var phone_play_error := phone_play_image.save_png("/private/tmp/no-hitter-play-phone.png")
		_expect(phone_play_error == OK, "Could not capture the portrait phone play screen")
	_expect(not main.era_label.text.contains("/"), "Phone campaign chrome should show only the current level")
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
	main.development_session = false
	main._request_hard_reset()
	await process_frame
	_expect(main.hard_reset_dialog.visible and main.hard_reset_dialog.borderless, "Phone reset confirmation should use the game modal instead of gray window chrome")
	_expect(main.hard_reset_dialog.position.x >= 0.0 and main.hard_reset_dialog.position.x + main.hard_reset_dialog.size.x <= root.size.x, "Phone reset confirmation should fit horizontally")
	_expect(main.hard_reset_dialog.position.y >= 0.0 and main.hard_reset_dialog.position.y + main.hard_reset_dialog.size.y <= root.size.y, "Phone reset confirmation actions should remain reachable")
	main._close_hard_reset_dialog()
	main.development_session = true
	main._configure_mobile_install_dialog("android")
	_expect(main.mobile_install_dialog.title == "INSTALL ON ANDROID", "The Android install guide should identify its platform")
	_expect(main.mobile_install_dialog.dialog_text.contains("INSTALL APP"), "The Android fallback should name Chrome's install action")
	_expect(main.mobile_install_dialog.dialog_text.contains("REVIEW UPDATE"), "The Android guide should explain that installed builds stay web-updated")
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
	_expect(main.frustration_status.get_parent() == main.outcome_footer, "The phone Determination meter should occupy the strip directly beneath the outcome cards")
	_expect(main.outcome_footer.get_index() == main.outcomes_grid.get_index() + 1, "The Determination strip should immediately follow the outcome grid")
	_expect(main.frustration_bar.get_combined_minimum_size().x >= 55.0, "The phone Determination meter should remain legible")
	_expect(main.frustration_label.tooltip_text.contains("no cap") and main.frustration_label.tooltip_text.contains("Grand Slam +12,000"), "Phone inspection should explain the uncapped whole-number Determination bonus")
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
	_expect(not main.pitch_field.move_closer_arrow.visible and not main.pitch_field.move_farther_arrow.visible, "Level-assigned phone ranges should not leave obsolete mound arrows on the field")
	main.is_web_build = true
	main._set_mobile_layout(false, false)
	main._set_mobile_layout(true, true)
	_expect(main.browser_save_slots_panel.visible, "The phone Web save overlay should expose manual save slots")
	_expect(main.browser_save_slot_entries.size() == 3, "Installed phone builds should provide three visible manual save slots")
	_expect(main._format_browser_save_slot(0, {}).contains("SLOT 1\nEMPTY"), "An unused phone save slot should identify itself as empty")
	var slot_summary: String = main._format_browser_save_slot(1, {"current_opponent": 4, "xp": 123.0, "saved_at": 1_700_000_000})
	_expect(slot_summary.contains("SLOT 2") and slot_summary.contains("LEVEL 5") and slot_summary.contains("123 XP"), "Occupied phone save slots should show level and XP at a glance")
	_expect(not slot_summary.contains("DNA") and not slot_summary.contains("ARCANA") and not slot_summary.contains("HALOS"), "Pre-prestige save rows must remain spoiler-free")
	var genetic_slot: String = main._format_browser_save_slot(0, {
		"current_opponent": 0,
		"xp": 8.0,
		"saved_at": 1_700_000_000,
		"genetic_offer_unlocked": true,
		"dna": 12,
		"lifetime_dna_earned": 26,
	})
	_expect(genetic_slot.contains("DNA 12 (26 earned)") and not genetic_slot.contains("ARCANA"), "A genetic save row should show current and lifetime DNA without revealing later layers")
	var eldritch_slot: String = main._format_browser_save_slot(0, {
		"current_opponent": 2,
		"xp": 9.0,
		"saved_at": 1_700_000_000,
		"eldritch_offer_unlocked": true,
		"dna": 0,
		"lifetime_dna_earned": 41000000,
		"arcana": 3,
		"lifetime_arcana_earned": 63,
	})
	_expect(eldritch_slot.contains("DNA 0 (41M earned)") and eldritch_slot.contains("ARCANA 3 (63 earned)"), "An eldritch save row should retain genetic history and show both prestige currencies")
	var divine_slot: String = main._format_browser_save_slot(0, {
		"current_opponent": 1,
		"xp": 10.0,
		"saved_at": 1_700_000_000,
		"divine_ascensions": 2,
		"divine_blessings": ["one", "two"],
		"divine_halos": 1,
	})
	_expect(divine_slot.contains("DNA 0 (0 earned)") and divine_slot.contains("ARCANA 0 (0 earned)") and divine_slot.contains("BLESSINGS 2/%d • HALOS 1" % Content.DIVINE_BLESSINGS.size()), "A divine save row should show all revealed prestige layers even immediately after a full reset")
	main._show_mobile_overlay(main.save_stack, "SAVES & TRANSFER")
	await process_frame
	_expect(main.return_to_title_button.text == "RETURN TO TITLE" and main.return_to_title_button.get_combined_minimum_size().y >= 44.0, "The phone Saves menu should provide a touch-sized return to title action")
	main.return_to_title_button.pressed.emit()
	await process_frame
	_expect(main.title_screen_active and main.title_screen.visible and not main.mobile_overlay_panel.visible, "Return to Title should close the phone Saves overlay and reveal the title screen")
	main._leave_title_screen(false)
	main._on_browser_update_available()
	await process_frame
	_expect(main.update_banner.visible, "An available browser release should show the update banner")
	_expect(main.update_banner.size.x <= 370.0, "The browser update banner should fit a 390-pixel phone")
	_expect(main.update_banner_label.text == "UPDATE READY", "The phone update banner should stay concise")
	_expect(main.update_now_button.text == "REVIEW", "A phone update should open a warning instead of updating immediately")
	main._show_browser_update_confirmation()
	await process_frame
	_expect(main.browser_update_confirmation.dialog_text.contains("recovery checkpoint") and main.browser_update_confirmation.title == "INSTALL UPDATE", "The phone update confirmation should explain automatic save preservation")
	_expect(main.browser_update_confirmation.dialog_autowrap and main.browser_update_confirmation.min_size.x <= 360, "The update warning should wrap inside a 390-pixel phone viewport")
	_expect(
		main.browser_update_confirmation.size.x <= 350 and main.browser_update_confirmation.size.y <= 760,
		"The complete phone update warning should fit inside a 390-by-844 display, not %s" % str(main.browser_update_confirmation.size)
	)
	_expect(main.browser_update_export_button != null and main.browser_update_export_button.text == "EXPORT", "The phone update warning should provide a direct portable-backup action")
	var update_cancel: Button = main.browser_update_confirmation.get_cancel_button()
	_expect(update_cancel.text == "LATER" and update_cancel.position.y + update_cancel.size.y <= main.browser_update_confirmation.size.y, "The phone update warning's safe Later action should remain inside the dialog")
	main.browser_update_confirmation.hide()
	main._snooze_browser_update()
	_expect(not main.update_banner.visible, "Choosing Later should dismiss the browser update banner")
	main.is_web_build = false
	main.browser_save_slots_panel.visible = false

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
	main.game.xp = 12.6
	main._refresh_interface()
	_expect(main.xp_label.text == "13", "Phone XP should become a rounded whole number above one")
	_expect(main.mobile_overlay_xp_label.text == "XP 13", "The phone Upgrades balance should share whole-XP formatting")
	_expect(main.mobile_upgrade_stats_panel.visible, "The phone upgrade overlay should keep current stats visible")
	_expect(main.mobile_upgrade_stat_labels.size() == 15, "The phone upgrade overlay should expose every trainable base-stat axis")
	_expect(
		main.mobile_upgrade_stat_labels.speed.text == BaseballGameState.format_speed(main.game.get_representative_pitch_speed()),
		"The phone upgrade overlay should show the current effective speed"
	)
	_expect(main.mobile_upgrade_stat_labels.quality.text == BaseballGameState.format_rating(main.game.get_pitch_quality()), "The phone upgrade overlay should show current whole-number Quality")
	_expect(main.mobile_upgrade_stat_labels.tap.text == "1.7–5.7%", "The phone upgrade overlay should show both short- and long-timer field-tap limits")
	var phone_training_row: Dictionary = main.training_buttons.velocity
	_expect((phone_training_row.label as Label).mouse_filter == Control.MOUSE_FILTER_IGNORE, "Phone upgrade descriptions should remain draggable scroll regions")
	_expect((phone_training_row.label as Label).text.contains("+0.75 ft/s Speed"), "Phone Training cards should show a succinct, exact next-rank gain")
	_expect(not (phone_training_row.label as Label).text.contains("approaches"), "Phone Training cards should not show eventual asymptotic targets")
	_expect(not (phone_training_row.label as Label).text.contains("•  1 XP"), "The Training card should not repeat a price already shown on its action button")
	_expect((phone_training_row.button as Button).text.ends_with("XP"), "Phone purchases should put the actual XP price on the action control")
	_expect((phone_training_row.button as Button).get_combined_minimum_size().y >= 44.0, "Phone upgrade price controls should be touch-sized")
	_expect(not str(Content.TRAINING[2].description).contains("Remaining"), "Compact Training copy should not lead with opaque remaining-gap language")
	_expect(str(Content.TRAINING[2].details).contains("Each rank removes 8%"), "The full Field Hustle formula should remain available after its spoiler-safe lock opens")
	var training_hold_press := InputEventScreenTouch.new()
	training_hold_press.pressed = true
	training_hold_press.position = (phone_training_row.label as Label).get_global_rect().get_center()
	main._input(training_hold_press)
	var training_hold_drag := InputEventScreenDrag.new()
	training_hold_drag.relative = Vector2(0.0, MainScript.UPGRADE_ROW_DRAG_CANCEL_DISTANCE + 1.0)
	main._input(training_hold_drag)
	main._update_upgrade_row_hold(MainScript.UPGRADE_ROW_HOLD_SECONDS + 0.1)
	_expect(not main.mobile_inspection_dialog.visible, "Scrolling a phone upgrade should cancel hold-to-inspect")
	main._input(training_hold_press)
	main._update_upgrade_row_hold(MainScript.UPGRADE_ROW_HOLD_SECONDS + 0.01)
	await process_frame
	_expect(main.mobile_inspection_dialog.visible, "Holding passive phone upgrade text should open its full explanation")
	_expect(main.mobile_inspection_body_label.text.contains("raw 0.75 ft/s"), "The phone upgrade explanation should show the unabridged effect")
	main.mobile_inspection_dialog.hide()
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
	_expect(not main.upgrade_tabs.get_tab_bar().visible, "The native TabBar and its tiny overflow arrows should be absent on phone layouts")
	_expect(main.mobile_tab_label.text.begins_with("TRAIN") and not main.mobile_tab_label.text.contains("TAB"), "The large phone navigation should identify the current section without repetitive TAB copy")
	_expect(main.mobile_tab_label_card.visible and main.mobile_tab_label.get_theme_font_size("font_size") >= 18, "The current phone upgrade section should use a readable card")
	var phone_purchase_tabs: Array[String] = []
	for tab_index in main._visible_upgrade_tab_indices():
		phone_purchase_tabs.append(main.upgrade_tabs.get_tab_title(tab_index))
	_expect(phone_purchase_tabs == ["TRAIN", "FACILITY", "BALL", "BODY"], "Phone UPGRADES must expose purchases only in TRAIN → FACILITY → BALL → BODY order")
	_expect(main.mobile_tab_next_button.get_combined_minimum_size().y >= 44.0, "Purchase navigator must remain touch-sized")
	main._close_mobile_overlay()
	main._show_mobile_overlay(main.equipment_sidebar, "LOADOUT")
	(main.equipment_labels.pitch.inspect_button as Button).pressed.emit()
	await process_frame
	_expect(main.pitch_arsenal_dialog.visible and main.pitch_arsenal_dialog.title == "PITCH ARSENAL", "Phone Loadout Arsenal must open the read-only pitch inspector")
	_expect(main.pitch_arsenal_dialog.borderless and main.pitch_arsenal_dialog.has_theme_stylebox_override("panel"), "Phone Pitch Arsenal must use the opaque app-owned modal surface without native chrome")
	_expect(main.pitch_arsenal_dialog.position.y + main.pitch_arsenal_dialog.size.y <= root.size.y + 1.0, "Phone Pitch Arsenal inspector must remain in frame")
	for definition in Content.PITCHES:
		var id := str(definition.id)
		if id not in main.game.unlocked_pitches:
			main.game.unlocked_pitches.append(id)
		main.game.pitch_levels[id] = 2
		main.game.pitch_draft_power[id] = 0.25
	main._open_pitch_arsenal()
	await process_frame
	var final_pitch_card := main.pitch_arsenal_entries.get_child(main.pitch_arsenal_entries.get_child_count() - 1) as PanelContainer
	var final_pitch_copy := final_pitch_card.get_child(0) as Label
	_expect(final_pitch_copy.text.contains(str(Content.PITCHES.back().name)), "Phone Arsenal must retain the final learned pitch after a many-pitch scroll")
	_expect(main.pitch_arsenal_close_button.get_combined_minimum_size().y >= 44.0, "Phone Arsenal Close must stay touch-sized")
	if "--capture-ui" in OS.get_cmdline_user_args():
		var arsenal_image := root.get_texture().get_image()
		var arsenal_error := arsenal_image.save_png("/private/tmp/no-hitter-arsenal-phone.png")
		_expect(arsenal_error == OK, "Could not capture the phone Pitch Arsenal")
	main._close_pitch_arsenal()
	_expect(not main.pitch_arsenal_dialog.visible, "Phone Arsenal Close must not trap the player")
	main._close_mobile_overlay()
	main._open_mobile_log_hub()
	await process_frame
	_expect(main.mobile_overlay_control == main.mobile_log_hub and main.mobile_overlay_title.text == "LOG", "Phone LOG must open its touch-sized hub")
	if "--capture-ui" in OS.get_cmdline_user_args():
		var log_hub_image := root.get_texture().get_image()
		var log_hub_error := log_hub_image.save_png("/private/tmp/no-hitter-log-phone.png")
		_expect(log_hub_error == OK, "Could not capture the phone Log hub")
	for child in main.mobile_log_hub.get_child(0).get_children():
		if child is Button:
			_expect((child as Button).get_combined_minimum_size().y >= 44.0, "Every LOG destination must be touch-sized")
	for destination in [
		[main.event_log_panel, "EVENTS"], [main.achievement_tab, "ACHIEVEMENTS"], [main.story_tab, "STORY"], [main.stats_tab, "STATS"], [main.guide_tab, "HELP"],
	]:
		main._open_mobile_log_destination(destination[0], destination[1])
		await process_frame
		_expect(main.mobile_overlay_control == destination[0] and main.mobile_overlay_title.text.contains(destination[1]), "LOG destination %s must open through the reusable overlay" % destination[1])
		_expect(main.mobile_overlay_surface.get_global_rect().encloses((destination[0] as Control).get_global_rect()), "LOG destination %s must remain in-frame" % destination[1])
		main._close_mobile_overlay()
		await process_frame
		_expect(not main.mobile_overlay_panel.visible and main.mobile_overlay_control == null, "Closing a LOG destination must return to play without a trap")
	main._show_mobile_overlay(main.upgrade_panel, "UPGRADES")
	main.pitch_field.batter_phase = "leaving"
	main.pitch_field.batter_phase_age = 0.5
	main.pitch_field.batter_phase_duration = 1.0
	main.pitch_field.batter_exit_outcome = 1
	var portrait_exit: Dictionary = main.pitch_field._get_batter_transition_visual()
	_expect(Vector2(portrait_exit.offset).x < 0.0 and Vector2(portrait_exit.offset).y < 0.0, "A portrait hit exit should rotate toward the phone field's upper-left foul side")
	main.pitch_field.batter_phase = "entering"
	main.pitch_field.batter_phase_age = 0.0
	main.pitch_field.batter_phase_duration = 1.0
	var portrait_entrance: Dictionary = main.pitch_field._get_batter_transition_visual()
	_expect(Vector2(portrait_entrance.offset).x > 0.0 and Vector2(portrait_entrance.offset).y > 0.0, "A portrait replacement should enter from the opposite lower-right side")
	main.pitch_field.batter_phase = "active"
	_expect(main.mobile_tab_previous_button.disabled, "The first upgrade tab should disable Back")
	_expect(main.catalog_hide_purchased_toggles.size() == 2 and not main.catalog_hide_purchased_toggles.has("body"), "Phone BODY removes the invisible Hide Purchased state while Ball and Facility retain controls")
	for catalog_toggle in main.catalog_hide_purchased_toggles.values():
		_expect((catalog_toggle as CheckButton).get_combined_minimum_size().y >= 44.0, "Phone Hide Purchased controls should remain touch-sized")
	_expect(main.body_section_buttons.run.visible, "Phone BODY should expose its drafted RUN subtab")
	for body_section_button_value in main.body_section_buttons.values():
		var body_section_button := body_section_button_value as Button
		_expect(body_section_button.get_combined_minimum_size().y >= 44.0, "Every BODY subtab should provide a 44-pixel touch target")
	_expect(main.achievement_cards.size() == Content.ACHIEVEMENTS.size(), "The phone Log achievement browser should expose every catalog slot")
	_expect(main.achievement_hide_achieved_toggle.get_combined_minimum_size().y >= 44.0, "Phone achievements should provide a touch-sized Hide Achieved filter")
	var phone_first_card: Dictionary = main.achievement_cards.first_pitch
	_expect((phone_first_card.panel as PanelContainer).mouse_filter == Control.MOUSE_FILTER_PASS, "Phone achievement copy should remain a passive scrolling surface")
	_expect((phone_first_card.title as Label).mouse_filter == Control.MOUSE_FILTER_IGNORE, "Phone achievement labels should never steal a swipe")
	_expect((phone_first_card.details_button as Button).get_combined_minimum_size().y >= 44.0, "Phone achievement inspection should use a clearly bounded Details button")
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
	_expect(main.mobile_inspection_body_label.text.to_upper().contains("GRAND SLAM"), "Result-card details should reuse the desktop tooltip")
	_expect(main.mobile_inspection_body_label.text.contains("cannot be saved"), "Phone Grand Slam details should state that no save mechanic applies")
	var mobile_close := main.mobile_inspection_dialog.find_child("MobileInspectionCloseButton", true, false) as Button
	_expect(mobile_close != null and mobile_close.get_combined_minimum_size().y >= 44.0, "Mobile inspection should always have a touch-sized Close action")
	main.mobile_inspection_dialog.hide()
	if main.opponent_loadout_dock.get_child_count() > 0:
		var opponent_item := main.opponent_loadout_dock.get_child(0) as Control
		main._show_mobile_inspection_for_control(opponent_item)
		await process_frame
		_expect(main.mobile_inspection_dialog.visible, "Tapping enemy equipment should open mobile details")
		_expect(main.mobile_inspection_body_label.text.contains("Batter threat"), "Enemy equipment details should include its threat modifier")
		main.mobile_inspection_dialog.hide()
	_expect(main.power_comparison_panel.size.x <= 64.0, "The label-only phone Power gauge should remain narrow beside enemy equipment")
	_expect(main.power_comparison_panel.size.y > main.power_comparison_panel.size.x * 2.0, "The phone Power gauge should be vertical")
	_expect(main.power_comparison_panel.position.x + main.power_comparison_panel.size.x <= main.opponent_loadout_dock.position.x + 1.0, "The phone Power gauge must not cover the enemy equipment strip")
	main._show_mobile_inspection_for_control(main.power_comparison_panel)
	await process_frame
	_expect(main.mobile_inspection_dialog.visible, "Tapping Power should expose the same detailed odds available on desktop")
	_expect(main.mobile_inspection_body_label.text.contains("called-Strike matchup"), "Phone Power details should explain the probability calibration")
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
	main._open_mobile_inspection("LONG DETAILS", "This deliberately oversized explanation must scroll without moving the Close control. ".repeat(40))
	await process_frame
	var long_close := main.mobile_inspection_dialog.find_child("MobileInspectionCloseButton", true, false) as Button
	_expect(main.mobile_inspection_body_scroll.has_meta("bounded_detail_body") and main.mobile_inspection_body_label.get_combined_minimum_size().y > main.mobile_inspection_body_scroll.size.y, "At 390×844 long mobile details use a genuinely scrollable bounded body")
	_expect(long_close != null and not main.mobile_inspection_body_scroll.is_ancestor_of(long_close) and long_close.get_global_rect().end.y <= root.size.y + 1.0, "At 390×844 long mobile details keep Close fixed and in frame")
	main.mobile_inspection_dialog.hide()
	root.size = Vector2i(360, 700)
	main._set_mobile_layout(true, true)
	await process_frame
	main._open_mobile_inspection("LONG DETAILS", "This deliberately oversized explanation must scroll without moving the Close control. ".repeat(40))
	await process_frame
	_expect(main.mobile_inspection_dialog.position.y >= 0 and main.mobile_inspection_dialog.position.y + main.mobile_inspection_dialog.size.y <= 700 and long_close.get_global_rect().end.y <= 700, "At 360×700 long mobile details keep title and Close in frame")
	_expect(main.mobile_inspection_body_label.get_combined_minimum_size().y > main.mobile_inspection_body_scroll.size.y, "At 360×700 the oversized mobile detail body still scrolls")
	main.mobile_inspection_dialog.hide()
	root.size = Vector2i(390, 844)
	main._set_mobile_layout(true, true)
	await process_frame

	main.game._add_loot_item({
		"id": "phone_equipped_hat", "slot": "hat", "item_level": 1, "rarity": 0,
		"name": "Phone Test Cap", "stats": {"quality_bonus": 0.01},
		"roll_quality": 1.0, "color": "a9b6c5", "favorite": false,
	})
	var phone_comparison_stats := {}
	for stat_definition in Content.LOOT_STATS:
		phone_comparison_stats[str(stat_definition.id)] = 0.02
	main.game._add_loot_item({
		"id": "phone_compare_hat", "slot": "hat", "item_level": 2, "rarity": 1,
		"name": "Readable Comparison Cap", "stats": phone_comparison_stats,
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
		var phone_info_stack := phone_item_stack.get_child(0) as VBoxContainer
		var phone_identity_row := phone_info_stack.get_child(0) as HBoxContainer
		var phone_item_label := phone_identity_row.get_child(0) as Label
		var phone_power_label := phone_identity_row.get_child(1) as Label
		var phone_actions := phone_item_stack.get_child(1) as HBoxContainer
		if str(phone_item_panel.get_meta("loot_item_id", "")) == "phone_compare_hat":
			phone_compare_label = phone_item_label
			phone_compare_stack = phone_info_stack
			phone_compare_button = phone_actions.get_child(1) as Button
			_expect(phone_item_label.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Phone item text should not intercept vertical scrolling")
			_expect(phone_item_label.text.begins_with("Readable Comparison Cap"), "Phone equipment rows should lead with the complete item name")
			_expect(phone_power_label.text == "POWER %d" % main.game.get_loot_item_power(main.game.get_loot_item("phone_compare_hat")), "Phone equipment rows should show Power without opening Compare")
			_expect(not (phone_info_stack.get_child(2) as Label).text.is_empty(), "Phone equipment rows should show their rolled stats before opening Compare")
			_expect(phone_item_panel.custom_minimum_size.y >= 140.0, "Phone equipment summaries should reserve visible height above their action buttons")
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
	_expect(main.loot_item_stats.get_child_count() == Content.LOOT_STATS.size(), "The phone comparison should expose every changed effective stat without hover")
	_expect(main.loot_item_stats_scroll.has_meta("bounded_detail_body") and bool(main.loot_item_stats_scroll.get_meta("bounded_detail_body")), "Tall equipment details must use the reusable bounded-scroll contract")
	_expect(main.loot_item_stats.get_combined_minimum_size().y > main.loot_item_stats_scroll.size.y, "The equipment detail body must genuinely scroll when every stat differs")
	var phone_close_button := main.loot_item_dialog.find_child("EquipmentComparisonCloseButton", true, false) as Button
	_expect(phone_close_button != null and not main.loot_item_stats_scroll.is_ancestor_of(phone_close_button) and phone_close_button.get_parent().get_parent() == main.loot_item_stats_scroll.get_parent(), "At 390×844 the bounded detail body must be a sibling of the persistent Close header")
	_expect(main.loot_item_equip_button.get_combined_minimum_size().y >= 44.0 and main.loot_item_trash_button.get_combined_minimum_size().y >= 44.0, "Phone comparison actions should be touch-sized")
	main.loot_item_trash_button.pressed.emit()
	_expect(main.loot_item_trash_button.text == "CONFIRM TRASH", "Phone Trash should require a second deliberate press")
	main._close_loot_item_dialog()
	main.locker_dialog_close_button.pressed.emit()
	await process_frame
	_expect(not main.locker_dialog.visible, "The in-content equipment Close button should dismiss the browser")
	var narrow_geometry: Rect2i = main._loot_item_popup_geometry(Vector2(360.0, 700.0))
	_expect(narrow_geometry.position.x >= 0 and narrow_geometry.position.y >= 0 and narrow_geometry.end.x <= 360 and narrow_geometry.end.y <= 700, "The narrower 360×700 comparison geometry must remain entirely in frame")
	_expect(main.loot_item_stats.get_combined_minimum_size().y > narrow_geometry.size.y - 180, "The narrower portrait comparison contract must retain a real scrollable body")
	main._close_loot_item_dialog()
	main._close_locker_dialog()

	main._show_mobile_overlay(main.equipment_sidebar, "LOADOUT")
	await process_frame
	_expect(main.equipment_sidebar.get_parent() == main.mobile_overlay_content, "Loadout should open in the same phone overlay")
	_expect(main.status_stat_labels.size() == 15 and not (main.status_stat_labels.speed as Label).text.is_empty(), "Phone Loadout should show every trainable effective progression stat")
	_expect(main.equipment_progression_heading.text == "OWNED FACILITIES", "Fresh Loadout should not imply unrevealed prestige systems")
	main._close_mobile_overlay()
	root.size = Vector2i(1179, 720)
	main._set_mobile_layout(true, false, true)
	await process_frame
	await process_frame
	_expect(main.outcomes_grid.columns == 8, "Compact landscape outcomes should stay on one short row")
	_expect(main.mobile_nav.custom_minimum_size.y <= 34.0, "Compact landscape navigation should not waste vertical space")
	_expect(main.page_container.get_combined_minimum_size().y <= main.page_scroll.size.y + 1.0, "A 1179×720 compact browser should keep the complete play view in-frame")
	if "--capture-ui" in OS.get_cmdline_user_args():
		var compact_play_image := root.get_texture().get_image()
		var compact_play_error := compact_play_image.save_png("/private/tmp/no-hitter-play-compact.png")
		_expect(compact_play_error == OK, "Could not capture the compact play screen")
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
	if "--capture-ui" in OS.get_cmdline_user_args():
		var desktop_edge_image := root.get_texture().get_image()
		var desktop_edge_error := desktop_edge_image.save_png("/private/tmp/no-hitter-play-desktop-edge.png")
		_expect(desktop_edge_error == OK, "Could not capture the desktop edge play screen")
	main.game.genetic_offer_unlocked = true
	main.game.eldritch_offer_unlocked = true
	main.game.highest_unlocked = Content.FINAL_BOSS_INDEX
	main.game.current_opponent = Content.FINAL_BOSS_INDEX
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
