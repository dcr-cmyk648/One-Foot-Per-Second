extends SceneTree

const Content = preload("res://scripts/content.gd")
const GameState = preload("res://scripts/game_state.gd")

var failures := 0

func _expect(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func _fresh():
	var game = GameState.new()
	game.reset_fresh()
	game.pending_story_dialogs.clear()
	return game

func _resolve(game, outcome: int, count: int) -> Dictionary:
	var summary: Dictionary = game._empty_resolution_summary()
	game._apply_pitch_outcome(summary, outcome, -1.0, count, false, 0)
	game._apply_resolution(summary, true)
	return summary

func _test_enhancements() -> void:
	var steroids: Dictionary = Content.body_modifier_by_id("steroids")
	_expect(steroids.effects == {"speed": 1.45, "payload": 1.15, "recovery": 0.82, "visual_size": 1.08}, "Human steroids retain their exact large upside and slower-windup downside")
	_expect(str(steroids.description).contains("windup ×1.22"), "Human steroid copy states the authoritative recovery downside")
	var alien = _fresh()
	alien.genetic_rebirths = 1
	var speed := alien.get_body_velocity_fps()
	var recovery := alien.get_recovery_rate()
	var payload := alien.get_pitch_potency()
	alien.genetic_levels.xenobiotic_overclock = 1
	_expect(is_equal_approx(alien.get_body_velocity_fps() / speed, 4.0) and is_equal_approx(alien.get_recovery_rate() / recovery, 2.0) and is_equal_approx(alien.get_pitch_potency() / payload, 5.0), "Alien overclock has exact strong upside with no negative axis")
	alien.eldritch_ascensions = 1
	var eldritch_speed := alien.get_body_velocity_fps()
	var eldritch_recovery := alien.get_recovery_rate()
	var eldritch_payload := alien.get_pitch_potency()
	alien.eldritch_levels.recursive_muscle = 1
	_expect(is_equal_approx(alien.get_body_velocity_fps() / eldritch_speed, 50.0) and is_equal_approx(alien.get_recovery_rate() / eldritch_recovery, 0.15) and is_equal_approx(alien.get_pitch_potency() / eldritch_payload, 100.0), "Eldritch muscle has exact enormous upside and visible slow-windup downside")
	alien.free()

func _test_equipment_tiers_and_save() -> void:
	var game = _fresh()
	game.rng.seed = 9001
	var human: Dictionary = game._generate_loot_item(Content.HUMAN_FINAL_INDEX, 0, 4)
	game.rng.seed = 9001
	var alien: Dictionary = game._generate_loot_item(Content.ALIEN_EXHIBITION_INDEX, 0, 5)
	game.rng.seed = 9001
	var eldritch: Dictionary = game._generate_loot_item(Content.ELDRITCH_EXHIBITION_INDEX, 0, 10)
	_expect(float(human.affix_tier) == 1.0 and float(alien.affix_tier) == 3.0 and float(eldritch.affix_tier) == 12.0, "New human, alien, and eldritch equipment stores explicit 1×/3×/12× affix metadata")
	_expect(game.get_loot_item_power(eldritch) > game.get_loot_item_power(alien) and game.get_loot_item_power(alien) > game.get_loot_item_power(human), "Tiered affixes increase comparison and auto-equip Power")
	_expect(float(game._generate_opponent_variant(Content.ELDRITCH_EXHIBITION_INDEX, 0).affix_tier) == 12.0, "Enemy loadouts expose the same eldritch tier scale as their drops")
	var legacy := human.duplicate(true)
	legacy.erase("affix_tier")
	var save := game.to_save_data()
	save.version = 31
	save.loot_items = [legacy]
	save.equipped_loot = {"hat": str(legacy.id)}
	var restored = GameState.new()
	restored.apply_save_data(save)
	var restored_item := restored.get_loot_item(str(legacy.id))
	_expect(float(restored_item.affix_tier) == 1.0 and restored_item.stats == legacy.stats, "Legacy equipment without tier metadata migrates neutrally and round-trips unchanged")
	var snapshot = _fresh()
	snapshot._begin_pitch_volley(snapshot._empty_resolution_summary(), 0.0)
	var released: Dictionary = snapshot.active_volleys[0].duplicate(true)
	snapshot.loot_items.append({"id": "tiered-pants", "slot": "pants", "item_level": Content.ELDRITCH_EXHIBITION_INDEX + 1, "rarity": 10, "name": "Infinite Inseam", "stats": {"speed_bonus": 0.60}, "roll_quality": 1.0, "color": "68d5ff", "favorite": false, "source_name": "", "tradeoff": false, "affix_tier": 12.0})
	snapshot.equipped_loot.pants = "tiered-pants"
	snapshot.loot_revision += 1
	_expect(snapshot.active_volleys[0].speed_fps == released.speed_fps and snapshot.active_volleys[0].plate_speed_fps == released.plate_speed_fps, "Equipping tiered gear cannot mutate a released volley snapshot")
	var cap_values: Array[float] = []
	for tier in [1.0, 3.0, 12.0]:
		var capped = _fresh()
		capped.loot_items.append({"id": "cap-%s" % str(tier), "slot": "hat", "item_level": 1, "rarity": 0, "name": "Cap", "stats": {"speed_bonus": 9.0}, "roll_quality": 1.0, "color": "68d5ff", "favorite": false, "source_name": "", "tradeoff": false, "affix_tier": tier})
		capped.equipped_loot.hat = "cap-%s" % str(tier)
		capped.loot_revision += 1
		cap_values.append(float(capped.get_raw_equipment_bonuses().speed_bonus))
		capped.free()
	_expect(is_equal_approx(cap_values[0], 0.15) and is_equal_approx(cap_values[1], 0.45) and is_equal_approx(cap_values[2], 1.8), "Effective ordinary equipment caps scale human/alien/eldritch as ×1/×3/×12")
	game.free()
	restored.free()
	snapshot.free()

func _test_mastery_and_determination() -> void:
	var strike = _fresh()
	var strike_summary := _resolve(strike, Content.STRIKE_INDEX, 1)
	var expected_called := strike.get_strikeout_base_points(0) / float(strike.get_strikes_required(0)) * 0.70 * strike.get_mastery_multiplier()
	_expect(float(strike_summary.mastery_gained) > 0.0 and is_equal_approx(strike.get_mastery_per_called_strike(), expected_called), "Every online called Strike grants the exact 0.70× base Mastery component")
	_expect(is_equal_approx(strike.get_completed_strikeout_mastery(), strike.get_mastery_per_called_strike() * strike.get_strikes_required(0) + strike.get_strikeout_mastery_bonus()), "Completed-strikeout lookahead includes every called Strike plus the 0.80× completion component")
	var completed = _fresh()
	var completed_summary := _resolve(completed, Content.STRIKE_INDEX, 3)
	_expect(float(completed_summary.mastery_gained) > float(strike_summary.mastery_gained) * 3.0, "A completed strikeout adds its transparent completion Mastery component")
	var ready = _fresh()
	var requirement := ready.get_mastery_requirement(0)
	ready.opponent_mastery[0] = requirement - ready.get_mastery_per_called_strike() * 0.5
	_resolve(ready, Content.STRIKE_INDEX, 1)
	_expect(ready.highest_unlocked == 0, "Crossing Mastery without a completed strikeout waits for the next strikeout")
	ready.plate_strikes = ready.get_strikes_required(0) - 1
	_resolve(ready, Content.STRIKE_INDEX, 1)
	_expect(ready.highest_unlocked == 1, "A threshold-crossing strikeout unlocks immediately")
	var determination = _fresh()
	_expect(is_equal_approx(determination.get_outcome_determination_points(Content.GRAND_SLAM_INDEX), 12.0) and is_equal_approx(GameState.DETERMINATION_REFERENCE_POINTS, 6.0) and is_equal_approx(GameState.DETERMINATION_QUALITY_PER_DOUBLING, 0.14), "Determination exposes the exact slower six-point, +140-quality-per-doubling contract")
	var v31_save := determination.to_save_data()
	v31_save.version = 31
	v31_save.determination_points = 10.0
	var v31_expected := GameState.V31_DETERMINATION_QUALITY_PER_DOUBLING * log(1.0 + 10.0 / GameState.V31_DETERMINATION_REFERENCE_POINTS) / log(2.0)
	var migrated = GameState.new()
	migrated.apply_save_data(v31_save)
	_expect(is_equal_approx(migrated.get_determination_quality_bonus(), v31_expected), "v31 Determination migration preserves the exact pre-load quality bonus")
	determination.free()
	migrated.free()
	strike.free()
	completed.free()
	ready.free()

func _test_estimator_migration() -> void:
	var fresh = _fresh()
	_expect(not fresh.has_xp_estimator() and not fresh.can_buy_genetic("scoreboard_calculus"), "Fresh campaigns neither reveal nor can buy the estimator before genetic discovery")
	fresh.genetic_offer_unlocked = true
	fresh.dna = 1
	_expect(not fresh.has_xp_estimator() and fresh.can_buy_genetic("scoreboard_calculus"), "Discovered genetics shows the estimator as a one-DNA locked convenience upgrade")
	fresh.check_achievements()
	var before_income := fresh.get_xp_multiplier()
	_expect(fresh.buy_genetic("scoreboard_calculus") and fresh.has_xp_estimator(), "Buying the estimator immediately reveals it")
	_expect(is_equal_approx(before_income, fresh.get_xp_multiplier()), "The estimator purchase does not modify XP income")
	var legacy_save := fresh.to_save_data()
	legacy_save.version = 31
	legacy_save.genetic_levels.erase("scoreboard_calculus")
	var legacy = GameState.new()
	legacy.apply_save_data(legacy_save)
	_expect(legacy.has_xp_estimator(), "Genuinely progressed legacy genetic saves retain prior unconditional estimator access")
	var undiscovered := GameState.new()
	legacy_save.genetic_offer_unlocked = false
	legacy_save.genetic_levels.erase("scoreboard_calculus")
	undiscovered.apply_save_data(legacy_save)
	_expect(not undiscovered.has_xp_estimator(), "Undiscovered legacy saves remain spoiler-safe")
	var enhancement_save := fresh.to_save_data()
	enhancement_save.genetic_levels.xenobiotic_overclock = 1
	enhancement_save.eldritch_levels.recursive_muscle = 1
	var enhanced = GameState.new()
	enhanced.apply_save_data(enhancement_save)
	_expect(enhanced.has_genetic_upgrade("xenobiotic_overclock") and enhanced.has_eldritch_upgrade("recursive_muscle"), "Enhancement ranks save and round-trip exactly")
	fresh.free()
	legacy.free()
	undiscovered.free()
	enhanced.free()

func _initialize() -> void:
	_test_enhancements()
	_test_equipment_tiers_and_save()
	_test_mastery_and_determination()
	_test_estimator_migration()
	if failures == 0:
		print("PASS: campaign balance M2 contract")
		quit(0)
	else:
		quit(1)
