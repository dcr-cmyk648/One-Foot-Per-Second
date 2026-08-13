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
	main._refresh_interface()
	await process_frame

	print("One Foot Per Second — v0.10.1 progressive-interface audit")
	var margin: MarginContainer
	for child in main.get_children():
		if child is MarginContainer:
			margin = child
			break
	var page: VBoxContainer = margin.get_child(0)
	var body: HBoxContainer = page.get_child(1)
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
	_expect(main.upgrade_tabs.is_tab_hidden(main.rebirth_tab.get_index()), "Fresh UI reveals the Rebirth tab")
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
	_expect(main.era_label.text.contains("/ 30"), "Fresh campaign header should present only human baseball")
	_expect(main.upgrade_tabs.find_child("LOCKER", false, false) == null, "The full-width Locker tab should be removed")
	_expect(main.upgrade_tabs.find_child("PITCH", false, false) != null, "Pitch types should have their own tab")
	_expect(main.upgrade_tabs.find_child("BALL", false, false) != null, "Ball upgrades should have their own tab")
	_expect(main.upgrade_tabs.find_child("FACILITY", false, false) != null, "Facilities should have their own tab")
	_expect(not main.equipment_labels.has("bat"), "The batter's bat must not appear in the player's left-side loadout")
	_expect(main.inventory_slot_buttons.size() == 7, "The field should show seven compact equipment squares")
	_expect(main.field_stat_labels.size() == 7, "The default field should expose every base trained stat in a compact overlay")
	_expect(str(main.field_stat_labels.speed.text).contains("1.00 ft/s"), "The field overlay should begin with the game's literal one-foot-per-second speed")
	for stat_id in main.field_stat_labels:
		_expect(not (main.field_stat_labels[stat_id] as Label).tooltip_text.is_empty(), "Field stat %s needs a hover explanation" % stat_id)
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
			_expect(outcome_stack.get_child_count() == 3, "Outcome cards should contain only a name, percentage, and compact timer delta")
			_expect(str((outcome_stack.get_child(2) as Label).text).begins_with("+"), "Every outcome card should expose its compact lineup-delay bonus")
			_expect(not outcome_panel.tooltip_text.is_empty(), "Detailed outcome rules should live in hover text")
	_expect(not main.strikeout_payout_label.text.begins_with("0 XP"), "The separate strikeout payout should not repeat zero-XP clutter")
	_expect(main.strikeout_payout_label.text.begins_with("COMPLETED STRIKEOUT:"), "Strikeout XP should appear in one small separate readout")
	_expect(main.hard_reset_button != null and main.hard_reset_button.text == "RESET PROGRESS", "A visible progress-reset control should exist")
	_expect(main.export_save_button != null and main.export_save_button.text == "EXPORT", "A visible portable-save export control should exist")
	_expect(main.load_save_button != null and main.load_save_button.text == "LOAD", "A visible portable-save load control should exist")
	_expect(not main.import_save_confirmation.visible, "The load-save replacement confirmation should begin closed")
	_expect(not main.hard_reset_dialog.visible and main.hard_reset_confirm_button.disabled, "The destructive reset window should begin closed and locked")
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
	_expect(not str(main.training_buttons.velocity.text).contains("🔒"), "Speed Training should be the only fundamental available from the opening level")
	for training_id in ["command", "recovery", "distance_control", "turnover", "hit_recovery", "pitch_calling"]:
		_expect(str(main.training_buttons[training_id].text).contains("🔒"), "%s should begin level-gated" % training_id)
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
	var hat_style := main.inventory_slot_buttons.hat.get_theme_stylebox("normal") as StyleBoxFlat
	var expected_equipped_border := Color.WHITE.lerp(Color(Content.LOOT_RARITIES[2].color), 0.55)
	_expect(hat_style.border_color.is_equal_approx(expected_equipped_border) and hat_style.border_width_left == 3, "An equipped slot should use a thick, bright version of its rarity color")
	_expect(main.inventory_slot_buttons.hat.text == "✓H", "An equipped field slot should carry an explicit checkmark")
	main._open_locker("hat")
	await process_frame
	_expect(main.locker_dialog.visible, "Clicking a field equipment square should open the equipment popup")
	_expect(main.locker_dialog_slot_buttons.size() == 7, "The equipment popup should preserve every slot selector")
	var first_item_panel: PanelContainer = main.locker_dialog_items.get_child(0)
	var first_item_row: HBoxContainer = first_item_panel.get_child(0)
	var first_item_button: Button = first_item_row.get_child(0)
	var first_star_button: Button = first_item_row.get_child(1)
	_expect(first_item_button.text.contains("POWER") and first_item_button.text.contains("EQUIPPED"), "Locker rows should expose Power and make the equipped item unmistakable")
	_expect(first_star_button.position.x + first_star_button.size.x <= first_item_row.size.x + 1.0, "The favorite star must remain inside the item row")
	_expect(main.locker_dialog.min_size.x >= 800 and main.locker_dialog.min_size.y >= 560, "The equipment popup should enforce enough room for complete item rows")
	main.locker_dialog.close_requested.emit()
	await process_frame
	_expect(not main.locker_dialog.visible, "Closing the equipment popup should hide it")

	await _audit_tab_geometry(main, "fresh")
	if "--capture-ui" in OS.get_cmdline_user_args():
		await _capture_visible_tabs(main, "fresh")

	main.game.genetic_offer_unlocked = true
	main._refresh_interface()
	await process_frame
	_expect(main.prestige_header_stack.visible, "Genetic offer did not reveal DNA")
	_expect(not main.upgrade_tabs.is_tab_hidden(main.rebirth_tab.get_index()), "Genetic offer did not reveal Rebirth")
	_expect(main.genetic_section.visible, "Genetic offer did not reveal mutations")
	_expect(not main.eldritch_section.visible, "Genetic offer prematurely reveals eldritch upgrades")
	_expect(not main.divine_section.visible, "Genetic offer prematurely reveals divine rewards")
	_expect(main.era_label.text.contains("/ 40"), "Genetic reveal should expose the alien campaign, not later layers")
	_expect(main.guide_label.text.contains("DNA"), "Genetic reveal did not expand the Guide")
	_expect(not main.guide_label.text.contains("Arcana"), "Genetic Guide prematurely reveals Arcana")
	_expect(not main.inventory_slot_buttons.relic.disabled and main.inventory_slot_buttons.relic.text == "R", "Finishing human baseball should reveal the Relic square")
	_audit_catalog_visibility(main, 1, "genetic")
	await _audit_tab_geometry(main, "genetic")

	main.game.eldritch_offer_unlocked = true
	main._refresh_interface()
	await process_frame
	_expect(main.eldritch_section.visible, "Eldritch offer did not reveal magic")
	_expect(not main.divine_section.visible, "Eldritch offer prematurely reveals divine rewards")
	_expect(main.era_label.text.contains("/ 45"), "Eldritch reveal should expose the complete opponent ladder")
	_expect(main.guide_label.text.contains("Arcana"), "Eldritch reveal did not expand the Guide")
	_expect(not main.guide_label.text.contains("God restore"), "Eldritch Guide prematurely reveals the divine offer")
	_audit_catalog_visibility(main, 2, "eldritch")
	await _audit_tab_geometry(main, "eldritch")

	main.game.cosmos_conquered = true
	main._refresh_interface()
	await process_frame
	_expect(main.divine_section.visible, "Cosmic victory did not reveal divine rewards")
	_expect(main.stat_rows.completion.visible, "Cosmic victory did not reveal completion stats")
	_expect(main.guide_label.text.contains("divine blessing"), "Cosmic victory did not expand the Guide")
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
			var button: Button = collection.buttons[id]
			var tier := 0 if int(definition.required_level) <= Content.HUMAN_FINAL_INDEX else (1 if int(definition.required_level) <= Content.ALIEN_FINAL_INDEX else 2)
			var owned: bool = id in collection.owned
			var should_show: bool = owned or tier <= visible_tier
			_expect(button.visible == should_show, "%s catalog visibility is wrong for %s" % [stage, definition.name])
			if not should_show or owned or main.game.highest_unlocked >= int(definition.required_level):
				continue
			_expect(button.disabled, "%s should lock %s until its level requirement" % [stage, definition.name])
			_expect(button.text.begins_with("%s\n🔒 " % definition.name), "%s locked entry should show only its name and requirements" % stage)
			_expect(button.tooltip_text.contains("REACH LEVEL %d" % (int(definition.required_level) + 1)), "%s locked tooltip should include its level requirement" % stage)
			_expect(not button.text.contains(str(definition.description)), "%s locked entry leaks its effect" % stage)
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
			var button: Button = collection.buttons[str(definition.id)]
			_expect(button.get_index() > previous_index, "%s is not displayed in unlock-level order" % definition.name)
			previous_index = button.get_index()

func _audit_tab_geometry(main, stage: String) -> void:
	var expected_size: Vector2 = main.upgrade_tabs.size
	var tab_bar: TabBar = main.upgrade_tabs.get_tab_bar()
	for index in main.upgrade_tabs.get_tab_count():
		if main.upgrade_tabs.is_tab_hidden(index):
			continue
		main.upgrade_tabs.current_tab = index
		await process_frame
		await process_frame
		_expect(main.upgrade_tabs.size.is_equal_approx(expected_size), "%s tab %d changed the panel size from %s to %s" % [stage, index, str(expected_size), str(main.upgrade_tabs.size)])
		var tab_rect := tab_bar.get_tab_rect(index)
		_expect(tab_rect.end.x <= tab_bar.size.x + 1.0, "%s tab labels overflow the visible tab bar" % stage)
		var tab_control: Control = main.upgrade_tabs.get_tab_control(index)
		if tab_control is ScrollContainer and tab_control.get_child_count() > 0:
			var content: Control = tab_control.get_child(0)
			_expect(
				content.size.x <= tab_control.size.x + 1.0,
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
