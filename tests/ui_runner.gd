extends SceneTree

const MainScene = preload("res://main.tscn")
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
	var main = MainScene.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	main.set_process(false)
	main.pitch_field.set_process(false)
	main.game.reset_fresh()
	main.pitch_field.reset_visual_state()
	# This audit inspects the persistent Story catalog separately. Clear the two
	# opening modal presentations so they cannot mask unrelated dialog tests.
	main.game.pending_story_dialogs.clear()
	main.story_dialog.hide()
	main._clear_achievement_toasts()
	main.offline_progress_dialog.hide()
	main._refresh_interface()
	await process_frame

	print("No Hitter — progressive-interface audit")
	_expect(main.title_screen_active and main.title_screen.visible, "The game should open on its title screen instead of pitching behind an unexplained UI")
	_expect(main.title_subtitle_label.text == "A baseball game about a regular ol’ toddler", "The fresh title should remain spoiler-free")
	_expect(main.title_art._visible_era() == 0, "Fresh title art must not reveal alien or cosmic imagery")
	var title_phase_samples := [
		{"time": 0.0, "phase": "windup"},
		{"time": main.title_art.WINDUP_SECONDS + 0.01, "phase": "outbound_pitch"},
		{"time": main.title_art.WINDUP_SECONDS + main.title_art.OUTBOUND_SECONDS + 0.01, "phase": "contact"},
		{"time": main.title_art.WINDUP_SECONDS + main.title_art.OUTBOUND_SECONDS + main.title_art.CONTACT_SECONDS + 0.01, "phase": "batted_return"},
		{"time": main.title_art.WINDUP_SECONDS + main.title_art.OUTBOUND_SECONDS + main.title_art.CONTACT_SECONDS + main.title_art.RETURN_SECONDS + 0.01, "phase": "reset_rest"},
	]
	for sample in title_phase_samples:
		var phase_state: Dictionary = main.title_art.get_animation_state(float(sample.time))
		_expect(str(phase_state.phase) == str(sample.phase), "Title animation must expose deterministic %s phase" % str(sample.phase))
	_expect(float(main.title_art.get_animation_state(0.0).pitcher_arm) != float(main.title_art.get_animation_state(main.title_art.WINDUP_SECONDS + 0.5).pitcher_arm), "Pitcher arm should derive from the shared pitch phase")
	_expect(float(main.title_art.get_animation_state(0.0).pitcher_arm) != float(main.title_art.get_animation_state(main.title_art.WINDUP_SECONDS - 0.01).pitcher_arm), "Windup should visibly move the pitcher arm from rest into the cocked pose")
	_expect(float(main.title_art.get_animation_state(0.0).batter_bat) != float(main.title_art.get_animation_state(main.title_art.WINDUP_SECONDS + main.title_art.OUTBOUND_SECONDS + 0.1).batter_bat), "Batter bat should derive from the shared contact phase")
	_expect(main.title_art.get_batted_return_direction_multiplier() < 0.0, "Batted returns must travel back into the field, opposite the pitcher-to-batter pitch direction")
	for title_era in range(4):
		var title_contract: Dictionary = main.title_art.get_outbound_pitch_arm_contract(Vector2(700.0, 440.0), title_era)
		_expect(title_contract.sources == title_contract.endpoints, "Every title outbound source must equal its corresponding forward arm endpoint")
	main.native_update_test_session = true
	main.development_session = true
	main.game.save_writes_locked = true
	_expect(main._native_update_current_version() == main.NATIVE_UPDATE_TEST_VERSION, "Update test mode must use its fixed forced-outdated version")
	_expect(not main.game.save_game(), "Update test mode must keep persistent save writes locked")
	main._on_native_update_manifest_received(
		HTTPRequest.RESULT_SUCCESS,
		200,
		PackedStringArray(),
		JSON.stringify({"version": "99.0.0", "downloads": {"macos": "https://github.com/dcr-cmyk648/One-Foot-Per-Second/releases/download/v99.0.0/No-Hitter.dmg"}}).to_utf8_buffer()
	)
	_expect(main.native_update_confirmation.visible, "Forced update-test mode should immediately show an official candidate")
	_expect(main.native_update_confirmation.title.contains("UPDATE TEST") and main.native_update_confirmation.dialog_text.contains("Test version") and main.native_update_confirmation.dialog_text.contains("Official candidate") and main.native_update_confirmation.dialog_text.contains("not saved"), "Update-test copy must identify the test session, both versions, and volatile play")
	_expect(not main.native_update_export_button.visible, "Update-test mode must hide backup export because test sessions cannot export persistent state")
	_expect(main.native_update_download_url.begins_with(main.OFFICIAL_RELEASE_URL_PREFIX), "Update-test mode must retain the official release URL allowlist")
	main.native_update_confirmation.hide()
	main.native_update_test_session = false
	main.game.save_writes_locked = false
	_expect(main.title_menu_stack.get_child_count() == 3, "The title should expose Resume, New Game, and Import Save")
	main._configure_title_layout(Vector2(1600.0, 900.0))
	await process_frame
	_expect(main.title_layout_grid.columns == 2 and main.title_panel.size.x >= 900.0, "A desktop title should use a wide two-column composition instead of a stretched phone card")
	_expect(main.title_action_panel.position.x > main.title_art_frame.position.x, "Desktop title actions should sit beside the matchup art")
	main.is_web_build = true
	main.update_banner.visible = true
	main._configure_title_layout(Vector2(1280.0, 720.0))
	await process_frame
	_expect(not main.update_banner.get_global_rect().intersects(main.title_heading_label.get_global_rect()), "A desktop update banner must not overlap the NO HITTER title")
	main.update_banner.visible = false
	main.is_web_build = false
	main._configure_title_layout(Vector2(1600.0, 900.0))
	var desktop_title_stage: Rect2 = main.title_art._stage_rect(Vector2(700.0, 440.0))
	_expect(absf(desktop_title_stage.size.x / desktop_title_stage.size.y - 1.52) < 0.02 and desktop_title_stage.size.x > 620.0, "Desktop title art should enlarge the icon-style matchup in a landscape frame")
	if "--capture-title" in OS.get_cmdline_user_args():
		var title_image := root.get_texture().get_image()
		var title_error := title_image.save_png("/private/tmp/no-hitter-title-desktop.png")
		_expect(title_error == OK, "Could not capture the desktop title screen")
	main._open_title_resume_picker()
	_expect(main.title_resume_stack.visible and not main.title_menu_stack.visible, "Resume should open the save-slot picker")
	_expect(main.title_manual_slot_entries.size() == 3, "The title picker should expose all three manual save slots")
	var title_prestige_summary: String = main._format_named_save("AUTOSAVE", {
		"current_opponent": 0,
		"xp": 4.0,
		"saved_at": 1_700_000_000,
		"genetic_offer_unlocked": true,
		"dna": 7,
		"lifetime_dna_earned": 19,
	})
	_expect(title_prestige_summary.contains("DNA 7 (19 earned)"), "The title-screen save picker should expose revealed prestige point history")
	main._close_title_resume_picker()
	main._request_new_game_from_title()
	main._configure_title_layout(Vector2(1280.0, 720.0))
	await process_frame
	_expect(main.title_new_game_stack.visible and not main.title_menu_stack.visible, "Start New Game should open a slot picker rather than the global reset dialog")
	_expect(not main.hard_reset_dialog.visible, "Title Start New Game must never route through typed RESET")
	_expect(main.title_hero_stack.visible and main.title_art_frame.get_global_rect().get_area() > 1000.0, "The desktop title matchup art should remain laid out while choosing a new campaign")
	_expect(main.title_new_game_slot_entries.size() == 3, "New campaigns should offer the same three named slots as loading")
	for new_slot_entry in main.title_new_game_slot_entries:
		_expect(_rect_inside((new_slot_entry.button as Control).get_global_rect(), main.title_action_panel.get_global_rect()), "Every desktop BEGIN/REPLACE action must stay visibly inside the title action panel")
	var new_game_back := main.title_new_game_stack.get_child(main.title_new_game_stack.get_child_count() - 1) as Control
	_expect(_rect_inside(new_game_back.get_global_rect(), main.title_action_panel.get_global_rect()), "The desktop new-campaign Back action must remain reachable")
	main._close_title_new_game_picker()
	main.development_session = true
	main._start_fresh_title_game(0)
	await process_frame
	await process_frame
	_expect(main.story_dialog.visible, "Starting a fresh title slot must visibly present the queued prologue")
	_expect(main.story_dialog.dialog_text.contains("one foot per second"), "The visible fresh-slot prologue must establish the opening pitch")
	_expect(main.game.story_journal.any(func(entry: Dictionary) -> bool: return str(entry.get("id", "")) == "prologue_little_timmy"), "The fresh-slot prologue must remain recorded in STORY")
	main._accept_story_dialog()
	main.story_dialog.hide()
	main.game.pending_story_dialogs.clear()
	main._refresh_story_tab()
	var first_story_stack := (main.story_entries_stack.get_child(0) as PanelContainer).get_child(0) as VBoxContainer
	var first_story_meta := first_story_stack.get_child(1) as Label
	_expect(first_story_meta.text.begins_with("ENTRY ") and first_story_meta.text.contains(" - ") and not first_story_meta.text.contains("•"), "Rendered Story metadata should use the ASCII separator")
	var ball_scroll := main.upgrade_tabs.get_tab_control(2) as ScrollContainer
	var ball_content := ((ball_scroll.get_child(0) as MarginContainer).get_child(0) as VBoxContainer)
	_expect((ball_content.get_child(0) as Label).text == "BALL UPGRADES - POWER WITHOUT PHANTOM PROJECTILES", "Rendered Ball heading should use the ASCII dash")
	main._return_to_title_screen()
	var slot_metadata: Dictionary = main.game.to_save_data()
	slot_metadata["active_campaign_slot"] = 2
	var slot_round_trip = main.game.get_script().new()
	root.add_child(slot_round_trip)
	slot_round_trip.apply_save_data(slot_metadata)
	_expect(slot_round_trip.active_campaign_slot == 2, "The selected campaign slot should survive autosave serialization and loading")
	slot_round_trip.queue_free()
	main._leave_title_screen(false)
	_expect(not main.title_screen.visible and main.return_to_title_button.text == "TITLE", "Desktop play should retain a path back to the title screen")
	main.return_to_title_button.pressed.emit()
	await process_frame
	_expect(main.title_screen_active and main.title_screen.visible, "The in-game TITLE button should save and return to the title screen")
	main._leave_title_screen(false)
	# Clearing a level may queue deterministic draft cards, but farming the cleared
	# batter must not summon a modal until the player asks to advance.
	main.game.pending_run_choices.clear()
	main.game.pending_story_dialogs.clear()
	main.game.highest_unlocked = 1
	main.game.current_opponent = 0
	main.game.create_perk_choice(0, false, false, true)
	main._maybe_show_pending_overlay()
	_expect(not main.run_choice_dialog.visible, "Queued rewards must not passively interrupt a cleared-level farm")
	main._next_opponent()
	_expect(main.run_choice_dialog.visible, "NEXT LEVEL should present the queued mandatory reward")
	var queued_choice: Dictionary = main.game.get_next_pending_run_choice()
	main._select_run_choice_option(str(queued_choice.id), 0)
	_expect(main.game.current_opponent == 1, "Choosing the queued reward should enter the requested next level")
	main.game.reset_fresh()
	main.game.pending_story_dialogs.clear()
	# This fixture intentionally suppresses the fresh prologue modal. Remove its
	# recorded discovery too, so a later field tap cannot be credited for reading
	# a story that this synthetic player never saw.
	main.game.story_seen.erase("prologue_little_timmy")
	main.run_choice_dialog.hide()
	# The preceding synthetic draft used the real resolver so it intentionally
	# queued an achievement toast. A fresh-game fixture must clear that UI-only
	# deferred queue alongside the reset game state before asserting the first
	# active field-tap toast.
	main._clear_achievement_toasts()
	main._refresh_interface()
	var pitch_choice_text: String = main._run_choice_option_text(
		{"type": "pitch"},
		{"name": "Test Ball", "rarity_name": "COMMON", "next_level": 1, "quality_gain": 0.1, "description": "Quality +0.2."}
	)
	_expect(pitch_choice_text.contains("DRAFT BONUS") and pitch_choice_text.contains("BASE PROFILE"), "Pitch drafts must label their randomized bonus separately from the base profile")
	var age_choice_text: String = main._run_choice_option_text(
		{"type": "perk", "source_level_number": 1},
		{"name": "Become a Little Kid", "rarity_name": "COMMON", "level": 1, "effect": {"stat": "body_age", "operation": "body", "age_order": 1}}
	)
	_expect(age_choice_text.contains("AGE BONUS") and age_choice_text.contains("Speed") and age_choice_text.contains("Quality") and age_choice_text.contains("Recovery") and age_choice_text.contains("Size"), "Age draft cards must state their exact four-part body bonus")
	var margin: MarginContainer
	for child in main.get_children():
		if child is MarginContainer:
			margin = child
			break
	var page_scroll: ScrollContainer = margin.get_child(0)
	var page: VBoxContainer = page_scroll.get_child(0)
	var body: HBoxContainer = page.get_child(1)
	_expect(page_scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED, "The page must never hide content behind horizontal scrolling")
	_expect(page_scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO, "Short browser windows need vertical access to every control")
	_expect(main._should_use_compact_layout(Vector2(1279.0, 800.0)), "A browser one pixel below the wide boundary should move sidebars into overlays")
	_expect(main._should_use_compact_layout(Vector2(1366.0, 680.0)), "A short landscape browser should move tall panels into overlays")
	_expect(not main._should_use_compact_layout(Vector2(1280.0, 696.0)), "The complete wide interface should fit at its declared boundary")
	_expect(not main._should_use_compact_layout(Vector2(1256.0, 696.0), false, true), "Wide-mode hysteresis must remain safe at its smallest allowed viewport")
	_expect(main._should_use_compact_layout(Vector2(1279.0, 900.0), true, true), "Compact mode should stay compact until the safe width is restored")
	_expect(not main._should_use_compact_layout(Vector2(1280.0, 696.0), true, true), "A resized compact browser must return to wide at the safe boundary")
	_expect(not main._should_use_compact_layout(Vector2(1600.0, 720.0), true, true), "A normal-height browser must not remain locked in compact mode regardless of width")
	_expect(main._should_use_compact_layout(Vector2(1600.0, 695.0), true, true), "A browser below the measured safe height should remain compact")
	_expect(body.size.x <= main.size.x + 1.0, "Primary interface width %.1f exceeds the %.1f px canvas" % [body.size.x, main.size.x])
	for child in body.get_children():
		_expect(
			child.position.x + child.size.x <= body.size.x + 1.0,
			"Primary panel %s overflows the body viewport" % child.name
		)
	var play_panel: Control = body.get_child(0)
	var upgrade_panel: Control = body.get_child(1)
	_expect(upgrade_panel.size.x <= 380.0, "The upgrade panel should stay compact instead of squeezing the field (got %.1f px)" % upgrade_panel.size.x)
	_expect(play_panel.size.x > upgrade_panel.size.x * 2.0, "The field should receive most of the horizontal canvas")
	_expect(main.pitch_field.process_priority < main.process_priority, "The field clock must advance before the simulation clock to prevent catch-up bursts")
	_expect(not main.prestige_header_stack.visible, "Fresh UI reveals a prestige currency")
	_expect(not main.upgrade_tabs.is_tab_hidden(main.rebirth_tab.get_index()), "The run-build BODY tab should be visible from the first pitch")
	_expect(main.rebirth_tab.name == "BODY" and main.human_growth_section.visible, "The drafted run build should open in a plainly named BODY tab")
	_expect(main.body_section_buttons.size() == 4, "BODY should provide RUN, DNA, ARCANA, and DIVINE sections")
	_expect(main.body_section_buttons.run.visible, "Fresh BODY should expose its run-scoped draft section")
	_expect(not main.body_section_buttons.genetic.visible and not main.body_section_buttons.eldritch.visible and not main.body_section_buttons.divine.visible, "Fresh BODY tabs must not reveal future prestige layers")
	_expect(not main.genetic_section.visible, "Fresh BODY content must not reveal genetic enhancements")
	_expect(main.body_growth_buttons.is_empty() and main.body_modifier_buttons.is_empty(), "Retired XP Grow/Build rows must not compete with run drafts")
	_expect(not main.automation_section.visible, "Fresh UI reveals future automation")
	_expect(not main.stat_rows.arms.visible, "Fresh Stats reveal extra arms")
	_expect(not main.stat_rows.clones.visible, "Fresh Stats reveal clone bodies")
	_expect(not main.stat_rows.dna.visible, "Fresh Stats reveal DNA")
	_expect(not main.stat_rows.arcana.visible, "Fresh Stats reveal Arcana")
	_expect(not main.stat_rows.completion.visible, "Fresh Stats reveal the cosmic ending")
	_expect(not main.guide_label.text.contains("DNA"), "Fresh Guide implies the first prestige currency")
	_expect(not main.guide_label.text.contains("clone"), "Fresh Guide implies clones")
	_expect(not main.guide_label.text.contains("eldritch"), "Fresh Guide implies eldritch magic")
	_expect(not main.guide_label.text.contains("God"), "Fresh Guide implies the divine layer")
	_expect(main.era_label.text.begins_with("LEVEL 01") and not main.era_label.text.contains("/"), "The campaign header should show only the current level")
	_expect(main.upgrade_tabs.find_child("LOCKER", false, false) == null, "The full-width Locker tab should be removed")
	var purchase_tab_titles: Array[String] = []
	for tab_index in main._visible_upgrade_tab_indices():
		purchase_tab_titles.append(main.upgrade_tabs.get_tab_title(tab_index))
	_expect(purchase_tab_titles.slice(0, 4) == ["TRAIN", "FACILITY", "BALL", "BODY"], "Purchasable navigation must begin TRAIN → FACILITY → BALL → BODY")
	_expect(main.upgrade_tabs.find_child("PITCH", false, false) == null, "PITCH must not be an upgrade tab")
	_expect(main.upgrade_tabs.find_child("BALL", false, false) != null, "Ball upgrades should have their own tab")
	_expect(main.upgrade_tabs.find_child("FACILITY", false, false) != null, "Facilities should have their own tab")
	_expect(main.upgrade_tabs.find_child("ACHIEVE", false, false) != null, "Achievements should have their own tab")
	_expect(main.header_title.text == "NO HITTER", "The visible game title should use the new name")
	_expect(main.header_title_stack.size_flags_horizontal == Control.SIZE_EXPAND_FILL, "The browser title copy should receive unused header width")
	_expect(main.header_subtitle.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART and main.header_subtitle.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING, "The browser subtitle should wrap instead of truncating milestone copy")
	_expect(main.header_subtitle.get_theme_font_size("font_size") >= 13, "The browser subtitle should remain comfortably readable")
	_expect(main.achievement_cards.size() == Content.ACHIEVEMENTS.size(), "The achievement tab should render every catalog slot")
	_expect(main.achievement_hide_achieved_toggle != null, "Achievements should provide their own Hide Achieved filter")
	var first_achievement_card: Dictionary = main.achievement_cards.first_pitch
	_expect((first_achievement_card.details_button as Button).text == "DETAILS", "Achievement cards should delimit their only inspection action")
	_expect((first_achievement_card.panel as PanelContainer).mouse_filter == Control.MOUSE_FILTER_PASS, "Passive achievement cards should pass drag input through for scrolling")
	_expect(main.achievement_count_label.text == "0 / %d UNLOCKED" % Content.ACHIEVEMENTS.size(), "The fresh achievement summary should disclose the complete catalog count")
	var hidden_genetic_card: Dictionary = main.achievement_cards.genetic_offer
	_expect((hidden_genetic_card.title as Label).text == "HIDDEN ACHIEVEMENT", "Future achievements should use anonymous placeholder titles")
	_expect(not (hidden_genetic_card.description as Label).text.contains("Commissioner"), "A hidden achievement must not leak its true condition")
	var hidden_no_hitter_card: Dictionary = main.achievement_cards.no_hitter
	_expect((hidden_no_hitter_card.title as Label).text == "HIDDEN ACHIEVEMENT", "The namesake secret achievement must remain anonymous before completion")
	_expect(not (hidden_no_hitter_card.description as Label).text.contains("Octathulhu"), "The namesake secret achievement must not leak its campaign condition")
	_expect(not (main.achievement_section_headings.genetic as Label).visible, "A hidden achievement group must not leak its tier heading")
	main.game.unlocked_achievements.append("first_pitch")
	main.game.achievement_revision += 1
	main._toggle_hide_achieved(true)
	_expect(not (first_achievement_card.panel as Control).visible, "Hide Achieved should remove completed cards without hiding unfinished slots")
	main._toggle_hide_achieved(false)
	main.game.unlocked_achievements.erase("first_pitch")
	main.game.achievement_revision += 1
	main._refresh_achievement_tab(true)
	_expect(main.catalog_hide_purchased_toggles.size() == 2 and not main.catalog_hide_purchased_toggles.has("body"), "Only Ball and Facility retain Hide Purchased; BODY always shows its coherent history")
	_expect(main.equipment_labels.pitch.has("inspect_button"), "Loadout must expose a dedicated Pitch Arsenal inspector")
	main._open_pitch_arsenal()
	_expect(main.pitch_arsenal_dialog.visible and main.pitch_arsenal_dialog.title == "PITCH ARSENAL", "Loadout Arsenal should open a reusable scrollable inspector")
	_expect(main.pitch_arsenal_dialog.borderless and main.pitch_arsenal_dialog.has_theme_stylebox_override("panel"), "Desktop Pitch Arsenal must use the opaque app-owned modal surface without native chrome")
	_expect(main.pitch_arsenal_entries.get_child_count() == 2, "Fresh Pitch Arsenal should show only its explainer and learned opening pitch")
	var first_pitch_copy := (main.pitch_arsenal_entries.get_child(1) as PanelContainer).get_child(0) as Label
	_expect(first_pitch_copy.text.contains("Dead-Fish") and first_pitch_copy.text.contains("LEVEL 1") and first_pitch_copy.text.contains("USE") and first_pitch_copy.text.contains("Base profile"), "Pitch Arsenal must show learned pitch identity, level, profile, and automatic selection behavior")
	_expect(main.pitch_arsenal_close_button.get_combined_minimum_size().y >= 44.0, "Pitch Arsenal Close must be touch-sized")
	main._close_pitch_arsenal()
	main.pitch_field.snapshot.pitch_cycle_progress = 0.0
	main.pitch_field.pitch_cycle_sample_time = main.pitch_field.total_time
	var arm_rest: float = main.pitch_field.get_throw_arm_motion()
	main.pitch_field.snapshot.pitch_cycle_progress = 0.60
	main.pitch_field.pitch_cycle_sample_time = main.pitch_field.total_time
	var arm_cocked: float = main.pitch_field.get_throw_arm_motion()
	main.pitch_field.snapshot.pitch_cycle_progress = 0.99
	main.pitch_field.pitch_cycle_sample_time = main.pitch_field.total_time
	var arm_release: float = main.pitch_field.get_throw_arm_motion()
	_expect(arm_rest <= 0.0 and arm_cocked < arm_rest and arm_release > arm_cocked, "Live arm must slowly cock through recovery then whip forward at release")
	main.pitch_field.volley_in_flight = true
	main.pitch_field.throw_animation = 1.0
	_expect(is_equal_approx(main.pitch_field.get_throw_arm_motion(), 1.0), "A live released volley must begin at the exact forward release pose")
	main.pitch_field.throw_animation = 0.35
	_expect(main.pitch_field.get_throw_arm_motion() < 1.0, "A live released volley must visibly retract after release")
	main.pitch_field.volley_in_flight = false
	main.game.selected_run_perks.append({
		"definition_id": "age_little_kid", "name": "Become a Little Kid", "level": 1,
		"rarity_name": "COMMON", "color": "a9b6c5",
		"effect": {"stat": "body_age", "operation": "body", "age_order": 1},
	})
	main._refresh_interface()
	_expect(main.run_perk_list.get_child_count() == 1, "Selected run perks should be inspectable in BODY")
	_expect(main.run_perk_list.get_child_count() == 1, "BODY preserves readable drafted-body history without a hidden-row filter")
	main.game.selected_run_perks.clear()
	main._refresh_interface()
	_expect(not main.equipment_labels.has("bat"), "The batter's bat must not appear in the player's left-side loadout")
	_expect(main.inventory_slot_buttons.size() == 7, "The field should show seven compact equipment squares")
	_expect(main.field_stat_labels.size() == 7, "The live throw profile should contain only facts about the current or next pitch")
	_expect(str(main.field_stat_labels.release.text).contains("1.00 ft/s"), "The field overlay should begin with the game's literal one-foot-per-second release speed")
	_expect(str(main.field_stat_labels.plate.text).contains("0.99 ft/s"), "The untouched Wiffle Ball should lose a small real amount of atmospheric speed")
	_expect(not main.field_stat_labels.drag.text.ends_with("NONE"), "The untouched opening Wiffle Ball should disclose its small atmospheric drag")
	_expect(main.field_stat_labels.distance.text.contains("3 ft"), "The live profile should show the immutable release distance")
	_expect(main.field_stat_labels.pitch.text == "AUTOMATIC MIX", "The live throw profile should show the pitch name without a redundant PITCH prefix")
	for stat_id in main.field_stat_labels:
		_expect(not (main.field_stat_labels[stat_id] as Label).tooltip_text.is_empty(), "Field stat %s needs a hover explanation" % stat_id)
		_expect((main.field_stat_labels[stat_id] as Label).size.x >= 58.0, "Field stat %s needs actual rendered width inside the field profile" % stat_id)
		if str(stat_id) != "pitch":
			_expect((main.field_stat_labels[stat_id] as Label).text.contains("  "), "Field stat %s should paint its name and value in one browser-safe label" % stat_id)
	var field_click := InputEventMouseButton.new()
	field_click.button_index = MOUSE_BUTTON_LEFT
	field_click.pressed = true
	field_click.position = Vector2(310.0, 210.0)
	main.pitch_field._on_field_gui_input(field_click)
	_expect(main.game.get_live_tap_rate() > 0.0, "Clicking unobstructed field space should feed the rolling tap-rate signal")
	_expect(is_zero_approx(main.game.pitch_credit), "A field click should accelerate the clock smoothly instead of teleporting the pitch timer")
	_expect(main.pitch_field.field_tap_effects.size() == 1, "A field click should create its local feedback ring")
	_expect(main.game.has_achievement("first_field_tap"), "The first active field tap should unlock its achievement")
	_expect(main.achievement_toast.visible and main.achievement_toast_name.text == "This Is Supposed to Be Idle", "An achievement should produce its named unlock toast (got %s)" % main.achievement_toast_name.text)
	_expect(main.achievement_toast_description.text == "Hurry an active timer with a field tap.", "An achievement toast should state the completed condition (got %s)" % main.achievement_toast_description.text)
	_expect(main.achievement_toast_description.get_theme_font_size("font_size") < main.achievement_toast_name.get_theme_font_size("font_size"), "The completed condition should use deliberately smaller toast text")
	_expect(main.achievement_count_label.text == "1 / %d UNLOCKED" % Content.ACHIEVEMENTS.size(), "The achievement summary should update immediately after an unlock")
	main.game._clear_pitch_cycle()
	main.pitch_field.field_tap_effects.clear()
	main.game.batter_cooldown_remaining = 3.0
	main.game.batter_replacement_pending = true
	main.pitch_field.batter_phase = "waiting"
	main.pitch_field.batter_phase_age = 0.0
	main.pitch_field.batter_phase_duration = 3.0
	main.pitch_field._on_field_gui_input(field_click)
	_expect(is_equal_approx(main.game.batter_cooldown_remaining, 3.0), "A field click should not jump the authoritative next-batter timer")
	_expect(is_zero_approx(main.pitch_field.batter_phase_age), "A field click should not jump the visible next-batter meter")
	_expect(main.game.get_live_tap_timer_speed_multiplier(3.0) > 1.0, "The rolling tap signal should accelerate an active lineup clock")
	main.game.batter_cooldown_remaining = 0.0
	main.game.batter_replacement_pending = false
	main.pitch_field.batter_phase = "active"
	main.pitch_field.batter_phase_age = 0.0
	main.pitch_field.batter_phase_duration = 0.0
	main._refresh_interface()
	_expect(main.opponent_loadout_dock.get_child_count() == 3, "The opening opponent side should show body, bat, and the droppable tutorial cap")
	var opening_strike_chance := float(main.game.get_outcome_probabilities()[Content.STRIKE_INDEX])
	_expect(is_equal_approx(main.power_comparison_gauge.you_ratio, opening_strike_chance), "Power YOU must be calibrated directly to the current called-Strike probability")
	_expect(is_equal_approx(main.power_comparison_gauge.them_ratio, 1.0 - opening_strike_chance), "Power THEM must show the batter's complementary resistance")
	_expect(main.power_comparison_panel.size.y > main.power_comparison_panel.size.x * 2.0, "Power should be a compact vertical gauge, not the former horizontal bar")
	_expect(main.power_comparison_panel.position.x + main.power_comparison_panel.size.x <= main.opponent_loadout_dock.position.x + 1.0, "Power should sit directly beside, not over, enemy equipment")
	_expect(main.power_comparison_panel.tooltip_text.contains("Completed strikeout chance"), "Power details should explain both called-Strike calibration and completed-strikeout odds")
	_expect(not main.locker_dialog.visible, "The equipment popup should start closed")
	for definition in Content.LOOT_SLOTS:
		var slot_button: Button = main.inventory_slot_buttons[str(definition.id)]
		if str(definition.id) == "relic":
			_expect(slot_button.disabled and slot_button.text == "?", "The post-human equipment square should begin anonymous and locked")
		else:
			_expect(not slot_button.disabled and slot_button.text == str(definition.letter), "%s should be an available letter square" % definition.name)
	var outcome_row: GridContainer
	for child in main.pitch_field.get_parent().get_children():
		if child is GridContainer and child.get_child_count() == Content.OUTCOME_NAMES.size():
			var all_panels := true
			for outcome_child in child.get_children():
				all_panels = all_panels and outcome_child is PanelContainer
			if all_panels:
				outcome_row = child
				break
	_expect(outcome_row != null, "The compact outcome row should exist")
	if outcome_row != null:
		for outcome_panel in outcome_row.get_children():
			var outcome_stack: VBoxContainer = outcome_panel.get_child(0)
			_expect(outcome_stack.get_child_count() == 2, "Outcome cards should use a two-line name/timer and probability layout")
			var outcome_heading: HBoxContainer = outcome_stack.get_child(0)
			_expect(outcome_heading.get_child_count() == 2, "Outcome names and lineup-delay bonuses should share one compact row")
			_expect(str((outcome_heading.get_child(1) as Label).text).begins_with("+"), "Every outcome card should expose its compact lineup-delay bonus beside its name")
			_expect(not outcome_panel.tooltip_text.is_empty(), "Detailed outcome rules should live in hover text")
	_expect(main.outcome_panels[Content.GRAND_SLAM_INDEX].tooltip_text.contains("cannot be saved"), "The Grand Slam tooltip should explicitly distinguish its absolute terminal rule from a Home Run")
	_expect(main.outcome_panels[Content.GRAND_SLAM_INDEX].tooltip_text.contains("Determination +12000"), "The Grand Slam tooltip should expose its retuned whole-number Determination severity")
	_expect(main.outcome_panels[Content.BALL_INDEX].tooltip_text.contains("Determination +200"), "The Ball tooltip should expose its retuned whole-number Determination nudge")
	_expect(main.outcome_panels[1].tooltip_text.contains("unless saved"), "The Home Run tooltip should retain ordinary hit-save behavior")
	_expect(not main.strikeout_payout_label.text.begins_with("0 XP"), "The separate strikeout payout should not repeat zero-XP clutter")
	_expect(main.strikeout_payout_label.text.begins_with("COMPLETED STRIKEOUT:"), "Strikeout XP should appear in one small separate readout")
	_expect(main.frustration_status.get_parent() == main.outcome_footer, "Determination and strikeout payout should share the compact outcome footer")
	_expect(main.frustration_label.text.begins_with("DETERMINATION ") and not "." in main.frustration_label.text, "The field should expose the current outcome-weighted bonus as a whole-number rating")
	_expect(main.frustration_label.tooltip_text.contains("Grand Slam +12,000") and not main.frustration_label.tooltip_text.contains("since the last"), "Determination inspection should explain whole-number severity rather than elapsed time")
	_expect(main.hard_reset_button != null and main.hard_reset_button.text == "RESET PROGRESS", "A visible progress-reset control should exist")
	_expect(main.export_save_button != null and main.export_save_button.text == "EXPORT", "A visible portable-save export control should exist")
	_expect(main.load_save_button != null and main.load_save_button.text == "IMPORT", "A visible portable-save import control should exist")
	_expect(main.browser_save_slot_entries.size() == 3, "The shared interface should build three phone manual-save slots")
	main._open_saves_menu()
	await process_frame
	_expect(main.mobile_overlay_panel.visible and main.browser_save_slots_panel.visible, "Desktop and browser SAVES should open the same complete save-slot overlay as mobile")
	_expect(main.mobile_overlay_title.text == "SAVES & TRANSFER", "The shared save overlay should identify manual slots and transfer tools")
	main._close_mobile_overlay()
	await process_frame
	_expect(not main.mobile_overlay_panel.visible and main.save_stack.visible, "Closing desktop SAVES should restore its header controls")
	_expect(main.browser_update_confirmation.dialog_text.contains("EXPORT") and main.browser_update_confirmation.get_ok_button().text == "UPDATE", "Browser updates should require an explicit backup-aware confirmation")
	_expect(main.native_update_confirmation != null and main.native_update_export_button.text == "EXPORT BACKUP", "Native builds should include a backup-aware update prompt")
	_expect(main._is_newer_release("0.16.0", "0.15.9") and not main._is_newer_release("0.15.2", "0.15.2"), "Native updater version comparison should use semantic components")
	var native_manifest := JSON.stringify({
		"version": "999.0.0",
		"release_page": "https://github.com/dcr-cmyk648/One-Foot-Per-Second/releases/tag/v999.0.0",
		"downloads": {"macos": "https://github.com/dcr-cmyk648/One-Foot-Per-Second/releases/download/v999.0.0/No%20Hitter.dmg"},
	}).to_utf8_buffer()
	main._on_native_update_manifest_received(HTTPRequest.RESULT_SUCCESS, 200, PackedStringArray(), native_manifest)
	await process_frame
	_expect(main.native_update_confirmation.visible and main.native_update_confirmation.dialog_text.contains("remain in place"), "A newer native release should explain save preservation before download")
	_expect(main.native_update_download_url.begins_with("https://github.com/dcr-cmyk648/One-Foot-Per-Second/releases/"), "The native updater should select only an official platform download")
	main.native_update_confirmation.hide()
	_expect(main._browser_save_has_more_progress({"lifetime_pitches": 100.0}, {"lifetime_pitches": 1.0}), "Browser recovery should recognize a demonstrably more advanced mirror")
	var normal_elapsed: Dictionary = main._split_browser_elapsed(0.20, 0.20)
	_expect(is_equal_approx(float(normal_elapsed.live), 0.20) and is_zero_approx(float(normal_elapsed.offline)), "Normal browser frames should remain live simulation time")
	var resumed_elapsed: Dictionary = main._split_browser_elapsed(600.0, 600.0)
	_expect(is_equal_approx(float(resumed_elapsed.live), 0.25) and is_equal_approx(float(resumed_elapsed.offline), 599.75), "A huge Safari resume delta should become offline catch-up instead of disappearing")
	var lifecycle_consumed_elapsed: Dictionary = main._split_browser_elapsed(0.01, 600.0)
	_expect(is_equal_approx(float(lifecycle_consumed_elapsed.live), 0.25) and is_zero_approx(float(lifecycle_consumed_elapsed.offline)), "A lifecycle-consumed resume frame must not replay its giant delta as active time")
	main.game.last_load_message = "Synthetic unreadable save."
	main.game.save_writes_locked = true
	main._show_save_recovery_required()
	await process_frame
	_expect(main.save_transfer_message_dialog.visible and main.save_transfer_message_dialog.dialog_text.contains("has not been overwritten"), "Unreadable saves should block writes and expose LOAD/RESET recovery instead of silently starting over")
	main.save_transfer_message_dialog.hide()
	main.game.save_writes_locked = false
	_expect(main.browser_update_confirmation.dialog_autowrap, "The browser-update warning must wrap instead of overflowing a resized window")
	_expect(not main.import_save_confirmation.visible, "The load-save replacement confirmation should begin closed")
	_expect(not main.offline_progress_dialog.visible, "The offline-XP return popup should begin closed")
	main._show_offline_progress({
		"earned_xp": 12.5,
		"mastery_gained": 2.75,
		"offline_seconds": 3600.0,
		"offline_reward_efficiency": 0.01,
		"strikeouts": 3.0,
	}, "Welcome back")
	await process_frame
	_expect(main.offline_progress_dialog.visible, "Returning with offline XP should open a summary popup")
	_expect(main.offline_progress_dialog.dialog_text.contains("+12.5 XP"), "The return popup should lead with the exact XP deposited")
	_expect(main.offline_progress_dialog.dialog_text.contains("XP & mastery efficiency: 1%"), "The return popup should explain the shared reward multiplier")
	_expect(main.offline_progress_dialog.dialog_text.contains("Opponent mastery gained: 2.75"), "The return popup should disclose reduced offline mastery")
	main.offline_progress_dialog.hide()
	_expect(not main.hard_reset_dialog.visible and main.hard_reset_confirm_button.disabled, "The destructive reset window should begin closed and locked")
	_expect(main.header_subtitle.text == "A baseball game about a regular ol’ toddler", "Fresh human baseball needs the toddler subtitle")
	_expect((main.equipment_labels.body.value as Label).text == "Regular Ol’ Toddler", "The default loadout should identify the player's current body")
	_expect((main.equipment_labels.body.value as Label).tooltip_text.contains("One foot per second"), "The opening body inspection should explain why the toddler is so weak")
	_expect(main.status_stat_labels.size() == 15 and not (main.status_stat_labels.speed as Label).text.is_empty(), "Desktop Status should populate every trainable effective progression stat")
	_expect(main.equipment_summary_label.text == "No facilities owned yet", "Fresh Status should not imply an owned or unrevealed upgrade")
	_expect(not main.rate_label.get_parent().visible and not main.stat_rows.income.visible, "Fresh UI must hide both XP/second estimator surfaces")
	main.game.genetic_offer_unlocked = true
	main._refresh_interface()
	_expect(not main.rate_label.get_parent().visible and not main.stat_rows.income.visible, "Discovered-but-unbought estimator remains hidden from header and Status")
	_expect(main.genetic_section.visible and (main.genetic_buttons.scoreboard_calculus.container as Control).visible, "Genetic discovery exposes the locked estimator upgrade row")
	main.game.dna = 1
	_expect(main.game.buy_genetic("scoreboard_calculus"), "The displayed estimator upgrade is purchasable for one DNA")
	main._refresh_interface()
	_expect(main.rate_label.get_parent().visible and main.stat_rows.income.visible and not main.rate_label.text.is_empty() and not (main.stat_labels.income as Label).text.is_empty(), "Buying the estimator reveals numeric header and Status estimates")
	var estimator_legacy_save: Dictionary = main.game.to_save_data()
	estimator_legacy_save.version = 31
	estimator_legacy_save.genetic_levels.erase("scoreboard_calculus")
	main.game.apply_save_data(estimator_legacy_save)
	main._refresh_interface()
	_expect(main.rate_label.get_parent().visible and main.stat_rows.income.visible, "Migrated progressed v31 UI retains estimator visibility")
	main.game.reset_fresh()
	main.game.pending_story_dialogs.clear()
	main._refresh_interface()
	main.game.purchased_milestones.append("regulation_ball")
	main._refresh_interface()
	_expect(main.equipment_progression_list.get_child_count() == 2, "An owned facility should receive its own inspectable Status row")
	_expect((main.equipment_progression_list.get_child(1) as Control).tooltip_text.contains("A Regulation Baseball"), "Owned Status rows should identify their upgrade")
	main.game.purchased_milestones.erase("regulation_ball")
	main._refresh_interface()
	main.game.selected_run_perks.append({
		"definition_id": "age_little_kid", "name": "Become a Little Kid", "level": 1,
		"rarity_name": "COMMON", "color": "a9b6c5",
		"effect": {"stat": "body_age", "operation": "body", "age_order": 1},
	})
	main._refresh_interface()
	_expect(main.header_subtitle.text == main._get_game_subtitle(), "A drafted age should immediately update the milestone subtitle")
	_expect((main.equipment_labels.body.value as Label).text == main.game.get_body_growth_name(), "A drafted age should immediately update the body loadout")
	main.game.selected_run_perks.clear()
	main._refresh_interface()
	main.game.selected_run_perks.append({
		"definition_id": "build_roided", "name": "Extremely Obvious Steroids", "level": 28,
		"rarity_name": "RARE", "color": "ffd45c",
		"effect": {"stat": "body_build", "operation": "body", "adjective": "roided-out"},
	})
	main._refresh_interface()
	_expect(main.header_subtitle.text == "A baseball game about a roided-out toddler", "The first steroid use should update the compact body subtitle")
	main.game.selected_run_perks.append({
		"definition_id": "build_toned", "name": "Running Laps", "level": 1,
		"rarity_name": "COMMON", "color": "a9b6c5",
		"effect": {"stat": "body_build", "operation": "body", "adjective": "toned"},
	})
	main.game.eldritch_levels.mirror_clones = 1
	_expect(main.game.get_compact_body_descriptor(true) == "roided-out, toned toddlers", "Subtitle composition should keep one build class, one conditioning adjective, and clone pluralization")
	_expect(main.game.get_body_growth_name().contains("Roid") or main.game.get_body_growth_name().contains("roid"), "Detailed BODY text should retain the complete modifier chain")
	main.game.eldritch_levels.mirror_clones = 0
	main.game.selected_run_perks.clear()
	main._refresh_interface()
	main.development_session = false
	main._request_hard_reset()
	await process_frame
	_expect(main.hard_reset_dialog.visible, "Reset Progress should open a hard-stop confirmation window")
	_expect(main.hard_reset_dialog.borderless and main.hard_reset_dialog.has_theme_stylebox_override("panel"), "The destructive reset window should use the borderless game modal treatment")
	_expect(main.hard_reset_dialog.find_child("HardResetHeading", true, false) != null, "Borderless custom windows must retain an in-content heading")
	var offline_heading_parent: Node = main.offline_progress_dialog.get_label().get_parent()
	var offline_heading := offline_heading_parent.get_node_or_null("AppDialogHeading") as Control
	main._close_hard_reset_dialog()
	main.offline_progress_dialog.title = "WELCOME BACK"
	main.offline_progress_dialog.dialog_text = "A small test return."
	main.offline_progress_dialog.popup_centered_clamped(Vector2i(420, 220), 0.94)
	await process_frame
	var offline_dialog_rect := Rect2(Vector2(main.offline_progress_dialog.position), Vector2(main.offline_progress_dialog.size))
	var offline_heading_global := Rect2()
	if offline_heading != null:
		# Window-internal Controls report coordinates inside their own dialog tree;
		# translate them to the root canvas before comparing to the popup rect.
		offline_heading_global = Rect2(offline_heading.get_global_rect().position + Vector2(main.offline_progress_dialog.position), offline_heading.get_global_rect().size)
	_expect(offline_heading != null and offline_heading.text == "WELCOME BACK" and offline_heading.visible and offline_heading_global.get_area() > 1.0 and _rect_inside(offline_heading_global, offline_dialog_rect) and main.offline_progress_dialog.dialog_text.begins_with("WELCOME BACK\n\n"), "Borderless accept dialogs must render their current title as a visible in-content heading")
	var dialog_surface := main.offline_progress_dialog.get_theme_stylebox("panel") as StyleBoxFlat
	_expect(dialog_surface != null and dialog_surface.bg_color.a > 0.95 and dialog_surface.bg_color.b < 0.25, "App-owned dialog surfaces should be opaque navy rather than native gray")
	main.offline_progress_dialog.hide()
	main._request_hard_reset()
	main.hard_reset_input.text = "reset"
	main._update_hard_reset_confirmation(main.hard_reset_input.text)
	_expect(main.hard_reset_confirm_button.disabled, "The reset button should reject the wrong capitalization")
	main.hard_reset_input.text = "RESET"
	main._update_hard_reset_confirmation(main.hard_reset_input.text)
	_expect(not main.hard_reset_confirm_button.disabled, "Typing RESET exactly should unlock the erase button")
	main._close_hard_reset_dialog()
	_expect(not main.hard_reset_dialog.visible and main.hard_reset_confirm_button.disabled, "Closing reset confirmation should relock it")
	main.development_session = true
	_audit_catalog_visibility(main, 0, "fresh")
	_expect(not str(main.training_buttons.velocity.label.text).contains("REACH LEVEL"), "Speed Training should be the only fundamental available from the opening level")
	for training_id in ["command", "field_hustle", "recovery", "offline_efficiency", "distance_control", "turnover", "hit_recovery", "pitch_calling"]:
		_expect(str(main.training_buttons[training_id].label.text).contains("REACH LEVEL"), "%s should begin level-gated" % training_id)
	var opening_training: Dictionary = main.training_buttons.velocity
	_expect(opening_training.container is PanelContainer and not (opening_training.container is BaseButton), "Upgrade descriptions should live in passive scrollable cards")
	_expect((opening_training.label as Label).mouse_filter == Control.MOUSE_FILTER_IGNORE, "Dragging an upgrade description should reach the ScrollContainer")
	_expect((opening_training.container as Control).tooltip_text.contains("raw 0.75 ft/s"), "Desktop hover should expose the same unabridged Training explanation as mobile hold")
	_expect((opening_training.label as Label).text.contains("+0.75 ft/s Speed"), "Training cards should show the exact effect of the next rank")
	_expect((opening_training.container as Control).tooltip_text.contains("Next rank: +0.75 ft/s Speed."), "Desktop hover should include the same live next-rank calculation")
	_expect(main._format_training_delta_number(0.00000000000012) == "1.2e-13", "Tiny nonzero Training gains should use compact scientific notation instead of displaying zero")
	_expect(not (opening_training.label as Label).text.contains("•  1 XP"), "Training copy should not repeat a price already shown on its action button")
	_expect((opening_training.button as Button).text.ends_with("XP") and (opening_training.button as Button).custom_minimum_size.y >= 44.0, "Each purchasable upgrade needs a separate touch-sized price control")
	main.game.highest_unlocked = 3
	main.game.training_levels.recovery = 8
	main._refresh_interface()
	var recovery_summary: String = main._training_batch_summary("recovery", 1)
	_expect((main.training_buttons.recovery.label as Label).text.contains(recovery_summary), "A diminishing Training card should recalculate the exact next-rank gain")
	_expect(not (main.training_buttons.recovery.label as Label).text.contains("approaches"), "Visible Training cards should not substitute an eventual target for the next purchase")
	main.game.training_levels.velocity = 100000
	main._refresh_interface()
	var vanishing_speed_summary: String = main._training_batch_summary("velocity", 1)
	_expect(vanishing_speed_summary.contains("e-") and not vanishing_speed_summary.begins_with("0"), "A vanishing asymptotic Speed rank should use 1eN notation instead of saying zero")
	_expect((main.training_buttons.velocity.button as Button).tooltip_text.contains("DIMINISHING RETURN"), "A rank below ten percent of fresh efficacy should turn its price into an explicit yellow warning")
	main.game.highest_unlocked = 0
	main.game.training_levels.velocity = 0
	main.game.training_levels.recovery = 0
	main._refresh_interface()
	_audit_upgrade_order(main)
	main.game._add_loot_item({
		"id": "ui_rare_hat",
		"slot": "hat",
		"item_level": 1,
		"rarity": 2,
		"name": "Golden Test Cap",
		"stats": {"quality_bonus": 0.02},
		"roll_quality": 1.0,
		"color": "33ff88",
		"favorite": false,
	})
	main._refresh_interface()
	_expect(str(main.game.equipped_loot.hat).is_empty(), "A field loot drop should never auto-equip without Autonomic Wardrobe")
	var unequipped_hat_style := main.inventory_slot_buttons.hat.get_theme_stylebox("normal") as StyleBoxFlat
	_expect(unequipped_hat_style.border_width_left == 1, "An owned but unequipped slot should remain visually empty")
	main.game.equip_loot("ui_rare_hat")
	main.game._add_loot_item({
		"id": "ui_compare_hat",
		"slot": "hat",
		"item_level": 2,
		"rarity": 1,
		"name": "Comparative Test Cap",
		"stats": {"quality_bonus": 0.03, "speed_bonus": 0.01},
		"roll_quality": 1.0,
		"color": "66a6ff",
		"favorite": false,
	})
	main._refresh_interface()
	var hat_style := main.inventory_slot_buttons.hat.get_theme_stylebox("normal") as StyleBoxFlat
	var expected_equipped_border := Color.WHITE.lerp(Color(Content.LOOT_RARITIES[2].color), 0.55)
	_expect(hat_style.border_color.is_equal_approx(expected_equipped_border) and hat_style.border_width_left == 3, "An equipped slot should use a thick, bright version of its rarity color")
	_expect(main.inventory_slot_buttons.hat.text == "H", "An equipped field slot should rely on rarity color without a redundant icon")
	main._open_locker("hat")
	await process_frame
	_expect(main.locker_dialog.visible, "Clicking a field equipment square should open the equipment popup")
	_expect(main.locker_dialog_slot_buttons.size() == 7, "The equipment popup should preserve every slot selector")
	var equipped_item_label: Label
	var comparison_item_label: Label
	var comparison_item_panel: PanelContainer
	var comparison_item_stack: VBoxContainer
	var comparison_item_button: Button
	var first_star_button: Button
	var first_action_row: HBoxContainer
	for row_index in main.locker_dialog_items.get_child_count():
		var item_panel := main.locker_dialog_items.get_child(row_index) as PanelContainer
		var item_stack := item_panel.get_child(0) as VBoxContainer
		var info_stack := item_stack.get_child(0) as VBoxContainer
		var identity_row := info_stack.get_child(0) as HBoxContainer
		var item_label := identity_row.get_child(0) as Label
		var power_label := identity_row.get_child(1) as Label
		var action_row := item_stack.get_child(1) as HBoxContainer
		var compare_button := action_row.get_child(1) as Button
		if row_index == 0:
			first_action_row = action_row
			first_star_button = action_row.get_child(2) as Button
		_expect(power_label.text.begins_with("POWER "), "Every equipment row should expose its Power before interaction")
		if item_label.text.contains("EQUIPPED"):
			equipped_item_label = item_label
		else:
			comparison_item_label = item_label
			comparison_item_panel = item_panel
			comparison_item_stack = info_stack
			comparison_item_button = compare_button
	_expect(equipped_item_label != null, "Locker rows should make the equipped item unmistakable")
	_expect(comparison_item_button != null and comparison_item_button.text == "COMPARE", "Each item should expose an explicit Compare action")
	_expect(comparison_item_panel != null and comparison_item_stack.tooltip_text.contains("Compared with Golden Test Cap"), "Desktop browser item hover should expose the complete equipped-item comparison")
	_expect(comparison_item_stack.tooltip_text.contains("(+0.010)"), "Desktop browser item hover should include signed stat deltas")
	_expect(not (comparison_item_stack.get_child(2) as Label).text.is_empty(), "Each row should show its own stat summary without requiring a click")
	_expect(comparison_item_label.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Passive item text should leave touch drags available for scrolling")
	_expect(not equipped_item_label.text.contains("✓") and first_star_button.text.is_empty() and first_star_button.icon != null, "Equipment controls should use browser-safe drawn icons instead of unsupported font glyphs")
	_expect(first_star_button.position.x + first_star_button.size.x <= first_action_row.size.x + 1.0, "The favorite star must remain inside the item row")
	_expect(main.locker_dialog_status_label.text.contains("SCRAP 0"), "The equipment browser should display the saved Scrap bank")
	_expect(main.locker_dialog_status_label.text.contains("TOTAL LOADOUT BONUSES:"), "Aggregate bonuses should be explicitly labeled instead of appearing to belong to the equipped item")
	_expect(main.locker_dialog.min_size.x >= 800 and main.locker_dialog.min_size.y >= 560, "The equipment popup should enforce enough room for complete item rows")
	comparison_item_button.pressed.emit()
	await process_frame
	_expect(main.loot_item_dialog.visible, "Clicking an item should open the explicit comparison window instead of equipping immediately")
	_expect(str(main.game.equipped_loot.hat) == "ui_rare_hat", "Opening a comparison must not alter the equipped item")
	_expect(main.loot_item_equipped_label.text.contains("Golden Test Cap"), "The comparison should name the currently equipped item")
	_expect(main.loot_item_meta_label.text.contains("CANDIDATE") and main.loot_item_meta_label.text.contains("SLOT HAT") and main.loot_item_meta_label.text.contains("POWER"), "The comparison must retain candidate identity, slot, rarity, and Power")
	_expect(main.loot_item_stats.get_child_count() == 2, "The comparison should show only the two effective stat differences, omitting matching and absent defaults")
	_expect(not comparison_item_stack.tooltip_text.contains("Recovery:"), "Desktop comparison hover should omit unchanged effective stats")
	_expect(main.loot_item_equip_button.text == "SWAP", "An unequipped item should offer an explicit Swap action")
	_expect(main._run_effect_text({"stat": "offline", "operation": "add", "value": 0.01}) == "Offline +1%", "A 0.01 Offline effect must render as +1%, never rating-scaled")
	_expect(main._run_effect_text({"stat": "loot", "operation": "add", "value": 0.01}) == "Loot +1%", "A 0.01 Loot effect must render as +1%, never rating-scaled")
	_expect(main._format_run_percent(0.000000001).contains("e") and main._format_run_percent(0.000000001) != "0%", "A tiny nonzero perk effect must use scientific notation instead of collapsing to zero")
	var upgrade_card := {
		"card_type": "upgrade", "name": "UPGRADE: Exact Offline", "rarity_name": "RARE",
		"before_effect": {"stat": "offline", "operation": "add", "value": 0.01},
		"after_effect": {"stat": "offline", "operation": "add", "value": 0.0125},
		"secondary_effects": [{"stat": "loot", "operation": "add", "value": 0.01}],
	}
	var upgrade_card_text: String = main._run_choice_option_text({"type": "perk"}, upgrade_card)
	_expect(upgrade_card_text.contains("UPGRADE: RARE") and upgrade_card_text.contains("TARGET: Exact Offline") and upgrade_card_text.contains("Offline +1% -> Offline +1.25%") and upgrade_card_text.contains("SECONDARY: Loot +1%") and not upgrade_card_text.contains("•"), "Upgrade cards must retain exact fractional effects with ASCII-only labels")
	main.game.pending_run_choices.clear()
	main.game.pending_run_choices.append({
		"id": "ui_offline_choice", "type": "perk", "source_level_number": 1,
		"options": [{"id": "ui_offline_perk", "name": "Exact Offline", "rarity_name": "COMMON", "color": "a9b6c5", "level": 1, "effect": {"stat": "offline", "operation": "add", "value": 0.01}, "penalty": {}, "secondary_effects": []}],
	})
	main._show_run_choice(main.game.pending_run_choices[0])
	main._select_run_choice_option("ui_offline_choice", 0)
	_expect((main.status_stat_labels.offline as Label).text == "2%", "Selecting a +1% Offline perk must immediately refresh the authoritative current stat")
	main.game.pending_run_choices.clear()
	main.game.pending_run_choices.append({
		"id": "ui_offline_upgrade", "type": "perk", "source_level_number": 1,
		"options": [{"id": "ui_offline_upgrade_card", "card_type": "upgrade", "target_perk_id": "ui_offline_perk", "name": "UPGRADE: Exact Offline", "rarity_name": "RARE", "color": "66a6ff", "before_effect": {"stat": "offline", "operation": "add", "value": 0.01}, "after_effect": {"stat": "offline", "operation": "add", "value": 0.02}, "secondary_effects": []}],
	})
	main._show_run_choice(main.game.pending_run_choices[0])
	main._select_run_choice_option("ui_offline_upgrade", 0)
	_expect((main.status_stat_labels.offline as Label).text == "3%", "Selecting an Offline upgrade must immediately refresh the exact current stat")
	main.loot_item_trash_button.pressed.emit()
	_expect(main.loot_item_trash_button.text == "CONFIRM TRASH", "Trash should require an explicit second confirmation")
	_expect(not main.game.get_loot_item("ui_compare_hat").is_empty(), "The first Trash press must not destroy equipment")
	main._close_loot_item_dialog()
	var loot_popup_summary: Dictionary = main.game._empty_resolution_summary()
	loot_popup_summary.loot_found = 1
	loot_popup_summary.loot_kept = 1
	loot_popup_summary.loot_scrap_gained = 6.0
	loot_popup_summary.loot_drops = [main.game.get_loot_item("ui_compare_hat")]
	main._on_batch_resolved(loot_popup_summary)
	_expect(not main.pitch_field.loot_popups.is_empty(), "A live loot drop should create a field popup")
	_expect(str(main.pitch_field.loot_popups[0].heading).contains("MAGIC HAT DROP"), "The field loot popup should name rarity and slot")
	_expect(str(main.pitch_field.loot_popups[0].detail).contains("+6 SCRAP"), "The field loot popup should include auto-scrap recovered in the same batch")
	main.locker_dialog.close_requested.emit()
	await process_frame
	_expect(not main.locker_dialog.visible, "Closing the equipment popup should hide it")

	await _audit_tab_geometry(main, "fresh")
	if "--capture-ui" in OS.get_cmdline_user_args():
		await _capture_visible_tabs(main, "fresh")

	main.game.highest_unlocked = Content.HUMAN_FINAL_INDEX
	main.game.current_opponent = Content.HUMAN_FINAL_INDEX
	main.game.pending_special_encounter = "alien_contact"
	main.game.campaign_story_phase = "alien_contact_pending"
	main.game.alien_arrival_seen = false
	main._refresh_interface()
	await process_frame
	_expect(main.alien_arrival_dialog.visible and main.alien_arrival_dialog.dialog_text.contains("cheering aliens"), "First alien contact should introduce the teleport, crowd, and commissioner without blocking gameplay")
	_expect(not main.game.alien_arrival_seen, "First contact should wait for explicit acceptance before teleporting the player")
	main.alien_arrival_dialog.hide()
	main._begin_alien_contact()
	await process_frame
	main.game.alien_exhibition_grand_slams = 5
	main._refresh_interface()
	_expect(main.game.alien_arrival_seen and main.game.is_alien_exhibition_blocked(), "Accepting first contact should begin the impossible Xylophax exhibition")
	_expect(main.header_subtitle.text == "A baseball game about a toddler who found aliens", "Alien contact should update the subtitle using the current body (got %s; encounter %s; level %d)" % [main.header_subtitle.text, main.game.special_encounter, main.game.current_opponent])
	_expect(main.alien_help_progress_panel.visible and int(main.alien_help_progress_bar.value) == 5, "The field should show a five-of-twelve humiliation meter before HELP exists")
	_expect(not main.alien_help_button.visible, "HELP should remain hidden while the humiliation meter is incomplete")
	_expect(is_equal_approx(main.alien_help_progress_panel.offset_top, main.alien_help_button.offset_top), "The humiliation meter should occupy HELP's eventual field position")
	main.pitch_field._trigger_result_visual({
		"outcome": Content.GRAND_SLAM_INDEX,
		"holds_batter": true,
		"story_taunt": "YOU'RE PATHETIC.",
	})
	_expect(main.pitch_field.result_popups.size() == 2, "A scripted alien Grand Slam should display both the outcome and a separate taunt")
	_expect(str(main.pitch_field.result_popups[1].text) == "YOU'RE PATHETIC.", "The alien's taunt should appear verbatim above the batter")
	main._show_title_screen(false)
	_expect(main.title_art._visible_era() == 1 and main.title_progress_label.text.contains("LEVEL 34"), "Reached alien play should update the title art without revealing later eras")
	main._leave_title_screen(false)
	main.game.alien_exhibition_grand_slams = BaseballGameState.ALIEN_EXHIBITION_GRAND_SLAMS_REQUIRED
	main.game.alien_exhibition_seconds = BaseballGameState.EXHIBITION_SECONDS
	main.game.run_xp = BaseballGameState.DNA_XP_THRESHOLD * 1000.0
	main._refresh_interface()
	_expect(main.alien_help_button.visible and main.alien_help_button.text == "HELP", "A witnessed impossible inning should quietly reveal the red HELP action")
	_expect(not main.alien_help_progress_panel.visible, "HELP should replace—not overlap—the completed humiliation meter")
	_expect(not main.genetic_section.visible and not main.rebirth_story_label.text.contains("genetic"), "The impossible exhibition must not spoil its solution before HELP is clicked")
	_expect(main.era_label.text.begins_with("UNNUMBERED EXHIBITION") and not main.era_label.text.contains("/"), "Alien first contact should use its unnumbered exhibition header (got %s)" % main.era_label.text)
	main._accept_alien_help()
	await process_frame
	_expect(main.alien_help_dialog.visible and main.alien_help_dialog.dialog_text.contains("Come with me if you want to… be really good at baseball"), "HELP should reveal the portal stranger's Time Machine scene")
	_expect(main.game.genetic_offer_unlocked and not main.alien_help_button.visible, "Accepting portal help should persistently reveal Time Travel and dismiss HELP")
	main.alien_help_dialog.hide()
	main._complete_first_genetic_rebirth()
	await process_frame
	_expect(main.game.lifetime_genetic_rebirths == 1 and main.game.dna == 10, "Entering the first portal should immediately perform the promised genetic rebirth (rebirths %d; DNA %d; run XP %s)" % [main.game.lifetime_genetic_rebirths, main.game.dna, str(main.game.run_xp)])
	_expect(main.game.current_opponent == 0 and main.game.body_growth_level == 0, "The first portal should visibly return the player to toddler baseball")
	_expect(main.genetic_rebirth_explanation_dialog.visible and main.genetic_rebirth_explanation_dialog.dialog_text.contains("You gained 10 DNA"), "The automatic rebirth should explain the toddler reset and DNA award")
	_expect(main.genetic_rebirth_explanation_dialog.dialog_text.contains("All prestige upgrades are retained"), "The first-rebirth explanation should state the general retention rule succinctly")
	main.genetic_rebirth_explanation_dialog.hide()
	main._open_body_after_first_rebirth()
	await process_frame
	main.game.pending_story_dialogs.clear()
	main.story_dialog.hide()
	_expect(main.prestige_header_stack.visible, "Genetic offer did not reveal DNA")
	_expect(not main.upgrade_tabs.is_tab_hidden(main.rebirth_tab.get_index()), "Genetic offer should remain available through BODY")
	_expect(main.genetic_section.visible, "Genetic offer did not reveal mutations")
	_expect(main.body_section_buttons.genetic.visible and main.selected_body_section == "genetic", "The first rebirth should reveal and open the DNA subtab")
	_expect(not main.eldritch_section.visible, "Genetic offer prematurely reveals eldritch upgrades")
	_expect(not main.divine_section.visible, "Genetic offer prematurely reveals divine rewards")
	_expect(main.guide_label.text.contains("DNA"), "Genetic reveal did not expand the Guide")
	_expect(not main.guide_label.text.contains("Arcana"), "Genetic Guide prematurely reveals Arcana")
	_expect(not main.inventory_slot_buttons.relic.disabled and main.inventory_slot_buttons.relic.text == "R", "Finishing human baseball should reveal the Relic square")
	_audit_catalog_visibility(main, 1, "genetic")
	await _audit_tab_geometry(main, "genetic")

	main.game.eldritch_offer_unlocked = true
	main.game.highest_unlocked = Content.ELDRITCH_EXHIBITION_INDEX
	main.game.current_opponent = Content.ELDRITCH_EXHIBITION_INDEX
	main._refresh_interface()
	await process_frame
	_expect(main.header_subtitle.text.contains("versus the void"), "The eldritch exhibition should receive its own discovered-milestone subtitle")
	_expect(main.eldritch_section.visible, "Eldritch offer did not reveal magic")
	_expect(main.body_section_buttons.eldritch.visible and main.selected_body_section == "eldritch", "The eldritch offer should reveal and open its own BODY subtab")
	_expect(not main.divine_section.visible, "Eldritch offer prematurely reveals divine rewards")
	_expect(main.era_label.text.begins_with("LEVEL 67") and not main.era_label.text.contains("/"), "Eldritch contact should retain the current-level-only header")
	_expect(main.guide_label.text.contains("Arcana"), "Eldritch reveal did not expand the Guide")
	_expect(not main.guide_label.text.contains("God restore"), "Eldritch Guide prematurely reveals the divine offer")
	main.game.genetic_levels.migratory_instinct = 2
	main.game.genetic_levels.autonomic_coach = 1
	main.game.eldritch_levels.interstellar_itinerary = 1
	main.game.eldritch_levels.front_office_outside_time = 1
	main._refresh_interface()
	await process_frame
	var advance_toggle: CheckButton = main.automation_toggles.advance.button
	_expect(advance_toggle.text.contains("Human 2/32") and advance_toggle.text.contains("Alien 1/33"), "Auto-advance should expose separate per-level human and alien license capacities")
	_expect(main.automation_training_heading.text.contains("0 / 1 SELECTED"), "A genetic coaching rank should expose exactly one selectable Training automation license")
	var catalog_toggle: CheckButton = main.automation_toggles.catalog_ball.button
	_expect(not catalog_toggle.disabled and catalog_toggle.text.contains("READY"), "The eldritch front office should expose independent one-time catalog automation")
	_audit_catalog_visibility(main, 2, "eldritch")
	await _audit_tab_geometry(main, "eldritch")

	main.game.cosmos_conquered = true
	main._refresh_interface()
	await process_frame
	_expect(main.header_subtitle.text == "A baseball game about saving the universe, somehow", "Cosmic victory should complete the subtitle arc")
	main._show_title_screen(false)
	_expect(main.title_art._visible_era() == 3, "Cosmic victory should unlock the complete title treatment")
	main._leave_title_screen(false)
	_expect(main.divine_section.visible, "Cosmic victory did not reveal divine rewards")
	_expect(main.body_section_buttons.divine.visible and main.selected_body_section == "divine", "Cosmic victory should reveal and open the Divine BODY subtab")
	_expect(main.stat_rows.completion.visible, "Cosmic victory did not reveal completion stats")
	_expect(main.guide_label.text.contains("divine blessing"), "Cosmic victory did not expand the Guide")
	var divine_heading: Label = main.divine_section.get_child(0) as Label
	_expect(divine_heading.text.contains("GOD PRESTIGE") and divine_heading.text.contains("DO IT ALL AGAIN"), "The final reset should be presented as God Prestige and state its repeat-campaign purpose")
	var first_blessing: Dictionary = main.divine_buttons[Content.DIVINE_BLESSINGS[0].id]
	_expect((first_blessing.button as Button).text == "DO IT AGAIN", "Available God Prestige blessings should use the final-loop action label")
	main._request_divine_ascension(str(Content.DIVINE_BLESSINGS[0].id))
	await process_frame
	_expect(main.divine_confirmation.visible and main.divine_confirmation.dialog_text.contains("Thanks for saving the universe") and main.divine_confirmation.dialog_text.contains("best reward") and main.divine_confirmation.dialog_text.contains("doing it all again"), "God Prestige confirmation should deliver the promised final-boss epilogue")
	main.divine_confirmation.hide()
	await _audit_tab_geometry(main, "divine")

	main.free()
	if failures.is_empty():
		print("PASS: progressive reveal and tab geometry are stable")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("FAIL: %d interface audit issue(s)" % failures.size())
		quit(1)

func _audit_catalog_visibility(main, visible_tier: int, stage: String) -> void:
	var collections := [
		{"kind": "catalog", "definitions": Content.BALL_UPGRADES, "buttons": main.ball_upgrade_buttons, "owned": main.game.purchased_ball_upgrades},
		{"kind": "catalog", "definitions": Content.MILESTONES, "buttons": main.milestone_buttons, "owned": main.game.purchased_milestones},
	]
	for collection in collections:
		for definition in collection.definitions:
			var id := str(definition.id)
			var entry: Dictionary = collection.buttons[id]
			var container := entry.container as Control
			var button := entry.button as Button
			var label := entry.label as Label
			var required_level := Content.catalog_required_level(definition)
			var tier := 0 if required_level <= Content.HUMAN_FINAL_INDEX else (1 if required_level <= Content.ALIEN_FINAL_INDEX else 2)
			var owned: bool = id in collection.owned
			var should_show: bool = owned or tier <= visible_tier
			_expect(container.visible == should_show, "%s catalog visibility is wrong for %s" % [stage, definition.name])
			if not should_show or owned or main.game.highest_unlocked >= required_level:
				continue
			_expect(button.disabled, "%s should lock %s until its level requirement" % [stage, definition.name])
			_expect(label.text.begins_with("%s\n" % definition.name), "%s locked entry should show only its name and requirements" % stage)
			_expect(button.tooltip_text.contains("REACH LEVEL %d" % (required_level + 1)), "%s locked tooltip should include its level requirement" % stage)
			_expect(not label.text.contains(str(definition.description)), "%s locked entry leaks its effect" % stage)
			_expect(not button.tooltip_text.contains(str(definition.description)), "%s locked tooltip leaks its effect" % stage)

func _audit_upgrade_order(main) -> void:
	var collections := [
		{"definitions": Content.TRAINING, "buttons": main.training_buttons},
		{"definitions": Content.BALL_UPGRADES, "buttons": main.ball_upgrade_buttons},
		{"definitions": Content.MILESTONES, "buttons": main.milestone_buttons},
	]
	for collection in collections:
		var previous_index := -1
		for definition in main._definitions_by_unlock(collection.definitions):
			var entry: Dictionary = collection.buttons[str(definition.id)]
			var container := entry.container as Control
			_expect(container.get_index() > previous_index, "%s is not displayed in unlock-level order" % definition.name)
			previous_index = container.get_index()

func _audit_tab_geometry(main, stage: String) -> void:
	var expected_size: Vector2 = main.upgrade_tabs.size
	var tab_bar: TabBar = main.upgrade_tabs.get_tab_bar()
	_expect(not tab_bar.visible and main.mobile_tab_navigation.visible, "%s should use the readable explicit tab navigator instead of native tiny overflow arrows" % stage)
	for index in main.upgrade_tabs.get_tab_count():
		if main.upgrade_tabs.is_tab_hidden(index):
			continue
		main.upgrade_tabs.current_tab = index
		await process_frame
		await process_frame
		_expect(main.upgrade_tabs.size.is_equal_approx(expected_size), "%s tab %d changed the panel size from %s to %s" % [stage, index, str(expected_size), str(main.upgrade_tabs.size)])
		var tab_control: Control = main.upgrade_tabs.get_tab_control(index)
		if tab_control is ScrollContainer and tab_control.get_child_count() > 0:
			var gutter: MarginContainer = tab_control.get_child(0) as MarginContainer
			var content: Control = gutter.get_child(0)
			_expect(
				gutter.size.x <= tab_control.size.x + 1.0 and content.size.x <= gutter.size.x + 1.0,
				"%s tab %s content is %.1f px wider than its %.1f px viewport"
				% [stage, main.upgrade_tabs.get_tab_title(index), content.size.x, tab_control.size.x]
			)
			for child in content.get_children():
				if child is Control and child.visible:
					_expect(
						child.size.x <= content.size.x + 1.0,
						"%s tab %s child %s is %.1f px wider than its %.1f px content column"
						% [stage, main.upgrade_tabs.get_tab_title(index), child.name, child.size.x, content.size.x]
					)

func _capture_visible_tabs(main, stage: String) -> void:
	main.game.pitch_credit = 0.50
	main.game.live_pitching_enabled = true
	main.pitch_field.configure_from_game(main.game)
	main.pitch_field.queue_redraw()
	for index in main.upgrade_tabs.get_tab_count():
		if main.upgrade_tabs.is_tab_hidden(index):
			continue
		main.upgrade_tabs.current_tab = index
		await process_frame
		await process_frame
		var image := root.get_texture().get_image()
		var title: String = main.upgrade_tabs.get_tab_title(index).to_lower().replace(" ", "-")
		var path := "/private/tmp/ofps-ui-%s-%s.png" % [stage, title]
		var error := image.save_png(path)
		_expect(error == OK, "Could not capture %s" % path)
		print("Captured %s" % path)
	if stage == "fresh":
		main._open_locker("hat")
		await process_frame
		await process_frame
		var locker_image := root.get_texture().get_image()
		var locker_path := "/private/tmp/ofps-ui-fresh-equipment.png"
		var locker_error := locker_image.save_png(locker_path)
		_expect(locker_error == OK, "Could not capture %s" % locker_path)
		print("Captured %s" % locker_path)
		main._close_locker_dialog()
