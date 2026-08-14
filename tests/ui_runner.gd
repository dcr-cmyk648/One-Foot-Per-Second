extends SceneTree

const MainScene = preload("res://main.tscn")
const Content = preload("res://scripts/content.gd")

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _run() -> void:
	var main = MainScene.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	main.set_process(false)
	main.pitch_field.set_process(false)
	main.game.reset_fresh()
	main._clear_achievement_toasts()
	main.offline_progress_dialog.hide()
	main._refresh_interface()
	await process_frame

	print("No Hitter — progressive-interface audit")
	_expect(main.title_screen_active and main.title_screen.visible, "The game should open on its title screen instead of pitching behind an unexplained UI")
	_expect(main.title_subtitle_label.text == "A baseball game about a regular ol’ toddler", "The fresh title should remain spoiler-free")
	_expect(main.title_art._visible_era() == 0, "Fresh title art must not reveal alien or cosmic imagery")
	_expect(main.title_menu_stack.get_child_count() == 3, "The title should expose Resume, New Game, and Import Save")
	main._configure_title_layout(Vector2(1600.0, 900.0))
	await process_frame
	_expect(main.title_layout_grid.columns == 2 and main.title_panel.size.x >= 900.0, "A desktop title should use a wide two-column composition instead of a stretched phone card")
	_expect(main.title_action_panel.position.x > main.title_art_frame.position.x, "Desktop title actions should sit beside the matchup art")
	main._open_title_resume_picker()
	_expect(main.title_resume_stack.visible and not main.title_menu_stack.visible, "Resume should open the save-slot picker")
	_expect(main.title_manual_slot_entries.size() == 3, "The title picker should expose all three manual save slots")
	main._close_title_resume_picker()
	main._leave_title_screen(false)
	_expect(not main.title_screen.visible and main.return_to_title_button.text == "TITLE", "Desktop play should retain a path back to the title screen")
	main.return_to_title_button.pressed.emit()
	await process_frame
	_expect(main.title_screen_active and main.title_screen.visible, "The in-game TITLE button should save and return to the title screen")
	main._leave_title_screen(false)
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
	_expect(not main.upgrade_tabs.is_tab_hidden(main.rebirth_tab.get_index()), "Ordinary body growth should be visible from the first pitch")
	_expect(main.rebirth_tab.name == "GROW UP" and main.human_growth_section.visible, "The ordinary body track should live in a plainly named GROW UP tab")
	_expect(not main.genetic_section.visible, "Fresh GROW UP content must not reveal genetic enhancements")
	_expect(main.body_growth_buttons.size() == Content.BODY_GROWTH_STAGES.size() - 1, "Every later human body stage should have one ordered growth row")
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
	_expect(main.upgrade_tabs.find_child("PITCH", false, false) != null, "Pitch types should have their own tab")
	_expect(main.upgrade_tabs.find_child("BALL", false, false) != null, "Ball upgrades should have their own tab")
	_expect(main.upgrade_tabs.find_child("FACILITY", false, false) != null, "Facilities should have their own tab")
	_expect(main.upgrade_tabs.find_child("ACHIEVE", false, false) != null, "Achievements should have their own tab")
	_expect(main.header_title.text == "NO HITTER", "The visible game title should use the new name")
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
	_expect(main.catalog_hide_purchased_toggles.size() == 3, "Every one-time purchase catalog should have its own Hide Purchased toggle")
	main._toggle_catalog_hide_purchased(true, "pitch")
	_expect(not (main.pitch_buttons.dead_fish.container as Control).visible, "Hide Purchased should remove learned pitches from only their catalog")
	_expect((main.pitch_buttons.knuckleball.container as Control).visible, "Hide Purchased should retain locked and available pitch entries")
	main._toggle_catalog_hide_purchased(false, "pitch")
	_expect(not main.equipment_labels.has("bat"), "The batter's bat must not appear in the player's left-side loadout")
	_expect(main.inventory_slot_buttons.size() == 7, "The field should show seven compact equipment squares")
	_expect(main.field_stat_labels.size() == 7, "The live throw profile should contain only facts about the current or next pitch")
	_expect(str(main.field_stat_labels.release.text).contains("1.00 ft/s"), "The field overlay should begin with the game's literal one-foot-per-second release speed")
	_expect(str(main.field_stat_labels.plate.text).contains("1.00 ft/s"), "The untouched Wiffle Ball should arrive at the same one-foot-per-second speed")
	_expect(main.field_stat_labels.drag.text.ends_with("NONE"), "The untouched opening Wiffle Ball should disclose that it has no air-drag model")
	_expect(main.field_stat_labels.distance.text.contains("3 ft"), "The live profile should show the immutable release distance")
	for stat_id in main.field_stat_labels:
		_expect(not (main.field_stat_labels[stat_id] as Label).tooltip_text.is_empty(), "Field stat %s needs a hover explanation" % stat_id)
		_expect((main.field_stat_labels[stat_id] as Label).size.x >= 58.0, "Field stat %s needs actual rendered width inside the field profile" % stat_id)
		_expect((main.field_stat_labels[stat_id] as Label).text.contains("  "), "Field stat %s should paint its name and value in one browser-safe label" % stat_id)
	var field_click := InputEventMouseButton.new()
	field_click.button_index = MOUSE_BUTTON_LEFT
	field_click.pressed = true
	field_click.position = Vector2(310.0, 210.0)
	main.pitch_field._on_field_gui_input(field_click)
	_expect(is_equal_approx(main.game.pitch_credit, 1.0 / 60.0), "Clicking unobstructed field space should advance the opening timer by one third of its former amount")
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
	_expect(is_equal_approx(main.game.batter_cooldown_remaining, 2.95), "A field click should hurry the authoritative next-batter timer")
	_expect(is_equal_approx(main.pitch_field.batter_phase_age, 0.05), "A field click should hurry the visible next-batter meter in lockstep")
	main.game.batter_cooldown_remaining = 0.0
	main.game.batter_replacement_pending = false
	main.pitch_field.batter_phase = "active"
	main.pitch_field.batter_phase_age = 0.0
	main.pitch_field.batter_phase_duration = 0.0
	main._refresh_interface()
	_expect(main.opponent_loadout_dock.get_child_count() == 2, "The opening opponent side should show body and bat squares")
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
	_expect(main.outcome_panels[Content.GRAND_SLAM_INDEX].tooltip_text.contains("Frustration +12"), "The Grand Slam tooltip should expose its maximum Frustration severity")
	_expect(main.outcome_panels[Content.BALL_INDEX].tooltip_text.contains("Frustration +0.20"), "The Ball tooltip should expose its tiny Frustration nudge")
	_expect(main.outcome_panels[1].tooltip_text.contains("unless saved"), "The Home Run tooltip should retain ordinary hit-save behavior")
	_expect(not main.strikeout_payout_label.text.begins_with("0 XP"), "The separate strikeout payout should not repeat zero-XP clutter")
	_expect(main.strikeout_payout_label.text.begins_with("COMPLETED STRIKEOUT:"), "Strikeout XP should appear in one small separate readout")
	_expect(main.frustration_status.get_parent() == main.outcome_footer, "Frustration and strikeout payout should share the compact outcome footer")
	_expect(main.frustration_label.text.begins_with("FRUSTRATION +"), "The field should expose the current outcome-weighted quality bonus")
	_expect(main.frustration_label.tooltip_text.contains("Grand Slam +12") and not main.frustration_label.tooltip_text.contains("since the last"), "Frustration inspection should explain severity rather than elapsed time")
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
		"offline_seconds": 3600.0,
		"offline_xp_efficiency": 0.01,
		"strikeouts": 3.0,
	}, "Welcome back")
	await process_frame
	_expect(main.offline_progress_dialog.visible, "Returning with offline XP should open a summary popup")
	_expect(main.offline_progress_dialog.dialog_text.contains("+12.5 XP"), "The return popup should lead with the exact XP deposited")
	_expect(main.offline_progress_dialog.dialog_text.contains("Offline efficiency: 1%"), "The return popup should explain the multiplier used")
	main.offline_progress_dialog.hide()
	_expect(not main.hard_reset_dialog.visible and main.hard_reset_confirm_button.disabled, "The destructive reset window should begin closed and locked")
	_expect(main.header_subtitle.text == "A baseball game about a regular ol’ toddler", "Fresh human baseball needs the toddler subtitle")
	_expect((main.equipment_labels.body.value as Label).text == "Regular Ol’ Toddler", "The default loadout should identify the player's current body")
	_expect((main.equipment_labels.body.value as Label).tooltip_text.contains("Toddler penalties"), "The opening body inspection should explain why the toddler is so weak")
	_expect(main.status_stat_labels.size() == 9 and not (main.status_stat_labels.speed as Label).text.is_empty(), "Desktop Status should populate every effective progression stat")
	_expect(main.equipment_summary_label.text == "No facilities owned yet", "Fresh Status should not imply an owned or unrevealed upgrade")
	main.game.purchased_milestones.append("regulation_ball")
	main._refresh_interface()
	_expect(main.equipment_progression_list.get_child_count() == 2, "An owned facility should receive its own inspectable Status row")
	_expect((main.equipment_progression_list.get_child(1) as Control).tooltip_text.contains("A Regulation Baseball"), "Owned Status rows should identify their upgrade")
	main.game.purchased_milestones.erase("regulation_ball")
	main._refresh_interface()
	_expect((main.body_growth_buttons.little_kid.container as Control).visible, "The Regular Ol’ Little Kid option should be visible from level 1")
	_expect((main.body_growth_buttons.little_kid.button as Button).disabled, "Growth should remain disabled until the first strikeout supplies its 3 XP cost")
	main.game.xp = main.game.get_strikeout_base_points()
	main._refresh_interface()
	_expect(not (main.body_growth_buttons.little_kid.button as Button).disabled, "One opening strikeout should afford the first growth step")
	main.game.xp = 0.0
	main.game.body_growth_level = 1
	main._refresh_interface()
	_expect(main.header_subtitle.text == "A baseball game about a regular ol’ little kid", "Growing should immediately update the milestone subtitle")
	_expect((main.equipment_labels.body.value as Label).text == "Regular Ol’ Little Kid", "Growing should immediately update the body loadout")
	main.game.body_growth_level = 0
	main._refresh_interface()
	main.game.purchased_milestones.append("steroids")
	main._refresh_interface()
	_expect(main.header_subtitle.text == "A baseball game about a big boi", "The first steroid use should update the subtitle")
	main.game.purchased_milestones.erase("steroids")
	main._refresh_interface()
	main.development_session = false
	main._request_hard_reset()
	await process_frame
	_expect(main.hard_reset_dialog.visible, "Reset Progress should open a hard-stop confirmation window")
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
	_expect((opening_training.button as Button).text == "BUY" and (opening_training.button as Button).custom_minimum_size.y >= 44.0, "Each purchasable upgrade needs a separate touch-sized BUY control")
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
	_expect(main.loot_item_stats.get_child_count() == Content.LOOT_STATS.size(), "The comparison should show every equipment stat, including zero values")
	_expect(main.loot_item_equip_button.text == "SWAP", "An unequipped item should offer an explicit Swap action")
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

	main.game.highest_unlocked = Content.ALIEN_EXHIBITION_INDEX
	main.game.current_opponent = Content.ALIEN_EXHIBITION_INDEX
	main.game.alien_exhibition_seconds = BaseballGameState.EXHIBITION_SECONDS
	main._refresh_interface()
	await process_frame
	_expect(main.header_subtitle.text == "A baseball game about a toddler who found aliens", "Alien contact should update the subtitle using the current body")
	main._show_title_screen(false)
	_expect(main.title_art._visible_era() == 1 and main.title_progress_label.text.contains("LEVEL 31"), "Reached alien play should update the title art without revealing later eras")
	main._leave_title_screen(false)
	_expect(main.alien_help_button.visible and main.alien_help_button.text == "HELP", "A witnessed impossible inning should quietly reveal the red HELP action")
	_expect(not main.genetic_section.visible and not main.rebirth_story_label.text.contains("genetic"), "The impossible exhibition must not spoil its solution before HELP is clicked")
	main._accept_alien_help()
	await process_frame
	_expect(main.alien_help_dialog.visible and main.alien_help_dialog.dialog_text.contains("Come with me if you want to… be really good at baseball"), "HELP should reveal the portal stranger's Time Machine scene")
	main.alien_help_dialog.hide()
	_expect(main.game.genetic_offer_unlocked and not main.alien_help_button.visible, "Accepting portal help should persistently reveal Time Travel and dismiss HELP")
	_expect(main.prestige_header_stack.visible, "Genetic offer did not reveal DNA")
	_expect(not main.upgrade_tabs.is_tab_hidden(main.rebirth_tab.get_index()), "Genetic offer should remain available through GROW UP")
	_expect(main.genetic_section.visible, "Genetic offer did not reveal mutations")
	_expect(not main.eldritch_section.visible, "Genetic offer prematurely reveals eldritch upgrades")
	_expect(not main.divine_section.visible, "Genetic offer prematurely reveals divine rewards")
	_expect(main.era_label.text.begins_with("LEVEL 31") and not main.era_label.text.contains("/"), "Alien contact should retain the current-level-only header")
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
	_expect(main.header_subtitle.text == "A baseball game about one guy versus the void", "The eldritch exhibition should receive its own discovered-milestone subtitle")
	_expect(main.eldritch_section.visible, "Eldritch offer did not reveal magic")
	_expect(not main.divine_section.visible, "Eldritch offer prematurely reveals divine rewards")
	_expect(main.era_label.text.begins_with("LEVEL 41") and not main.era_label.text.contains("/"), "Eldritch contact should retain the current-level-only header")
	_expect(main.guide_label.text.contains("Arcana"), "Eldritch reveal did not expand the Guide")
	_expect(not main.guide_label.text.contains("God restore"), "Eldritch Guide prematurely reveals the divine offer")
	main.game.genetic_levels.migratory_instinct = 2
	main.game.genetic_levels.autonomic_coach = 1
	main.game.eldritch_levels.interstellar_itinerary = 1
	main.game.eldritch_levels.front_office_outside_time = 1
	main._refresh_interface()
	await process_frame
	var advance_toggle: CheckButton = main.automation_toggles.advance.button
	_expect(advance_toggle.text.contains("Human 2/29") and advance_toggle.text.contains("Alien 1/10"), "Auto-advance should expose separate per-level human and alien license capacities")
	_expect(main.automation_training_heading.text.contains("0 / 1 SELECTED"), "A genetic coaching rank should expose exactly one selectable Training automation license")
	var catalog_toggle: CheckButton = main.automation_toggles.catalog_pitch.button
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
		{"definitions": Content.PITCHES, "buttons": main.pitch_buttons, "owned": main.game.unlocked_pitches},
		{"definitions": Content.BALL_UPGRADES, "buttons": main.ball_upgrade_buttons, "owned": main.game.purchased_ball_upgrades},
		{"definitions": Content.MILESTONES, "buttons": main.milestone_buttons, "owned": main.game.purchased_milestones},
	]
	for collection in collections:
		for definition in collection.definitions:
			var id := str(definition.id)
			var entry: Dictionary = collection.buttons[id]
			var container := entry.container as Control
			var button := entry.button as Button
			var label := entry.label as Label
			var tier := 0 if int(definition.required_level) <= Content.HUMAN_FINAL_INDEX else (1 if int(definition.required_level) <= Content.ALIEN_FINAL_INDEX else 2)
			var owned: bool = id in collection.owned
			var should_show: bool = owned or tier <= visible_tier
			_expect(container.visible == should_show, "%s catalog visibility is wrong for %s" % [stage, definition.name])
			if not should_show or owned or main.game.highest_unlocked >= int(definition.required_level):
				continue
			_expect(button.disabled, "%s should lock %s until its level requirement" % [stage, definition.name])
			_expect(label.text.begins_with("%s\n" % definition.name), "%s locked entry should show only its name and requirements" % stage)
			_expect(button.tooltip_text.contains("REACH LEVEL %d" % (int(definition.required_level) + 1)), "%s locked tooltip should include its level requirement" % stage)
			_expect(not label.text.contains(str(definition.description)), "%s locked entry leaks its effect" % stage)
			_expect(not button.tooltip_text.contains(str(definition.description)), "%s locked tooltip leaks its effect" % stage)

func _audit_upgrade_order(main) -> void:
	var collections := [
		{"definitions": Content.TRAINING, "buttons": main.training_buttons},
		{"definitions": Content.PITCHES, "buttons": main.pitch_buttons},
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
