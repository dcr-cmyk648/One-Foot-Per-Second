extends SceneTree

const Content = preload("res://scripts/content.gd")
const Campaign = preload("res://scripts/campaign.gd")
const GameStateScript = preload("res://scripts/game_state.gd")
const RunContent = preload("res://scripts/run_content.gd")

var failures := 0

func _initialize() -> void:
	print("No Hitter — overhaul data/save contract")
	_test_campaign_topology()
	_test_deterministic_choices()
	_test_choice_save_round_trip()
	_test_schema_25_migration()
	_test_mastery_and_strikeout_gate()
	_test_sticky_boss_and_choice_queue()
	_test_active_volley_queue()
	_test_deferred_level_choices()
	_test_bats_and_clone_fielding()
	_test_loot_and_relic_contract()
	_test_training_batches_and_physical_scale()
	_test_tap_signal_and_determination()
	_test_m1_perk_upgrade_pitch_contract()
	_test_prestige_and_endless_contract()
	_test_first_run_story_and_body_copy()
	_test_story_exhibitions()
	if failures > 0:
		push_error("FAIL: %d overhaul contract test(s) failed" % failures)
		quit(1)
	else:
		print("PASS: overhaul data/save contract")
		quit(0)

func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	failures += 1
	push_error(message)

func _test_m1_perk_upgrade_pitch_contract() -> void:
	var game = GameStateScript.new()
	game.reset_fresh()
	game.pending_story_dialogs.clear()
	# Three owned ordinary perks unlock a deterministic pseudorandom board roll.
	for index in 3:
		game.selected_run_perks.append({
			"id": "owned_%d" % index, "definition_id": "chalk_dust_clairvoyance",
			"name": "Owned %d" % index, "effect": {"stat": "quality", "operation": "add", "magnitude": 0.10, "value": 0.10},
			"penalty": {}, "secondary_effects": [], "upgrade_rank": 0, "upgrade_history": [],
		})
	# This fixed, modest corpus checks the configured 20% chance without an
	# expensive stochastic run. A 12–28% band gives deterministic regression
	# signal while allowing normal seeded variation around the 20% target.
	var upgrade_boards := 0
	var protected_board_seen := false
	var selected_seed := 0
	var serialized_upgrade := {}
	for seed in range(1, 101):
		game.run_seed = seed
		game.run_choice_serial = 0
		var offer := game.create_perk_choice(10, false, false, false)
		var upgrades := (offer.options as Array).filter(func(option: Dictionary) -> bool: return str(option.get("card_type", "")) == "upgrade")
		_expect(upgrades.size() <= 1, "A perk board may contain at most one upgrade")
		for option_value in offer.options:
			var option: Dictionary = option_value
			var definition := RunContent.perk_by_id(str(option.get("definition_id", "")))
			if str(definition.get("stat", "")) in ["body_age", "body_build"]:
				protected_board_seen = true
				_expect(str(option.get("card_type", "")) != "upgrade", "Protected age/body offers must never be displaced")
		if upgrades.size() == 1:
			upgrade_boards += 1
			if serialized_upgrade.is_empty():
				serialized_upgrade = upgrades[0]
				selected_seed = seed
	_expect(upgrade_boards >= 12 and upgrade_boards <= 28, "The fixed 100-seed corpus must remain within the declared 12–28% 20%% upgrade band")
	_expect(protected_board_seen, "The fixed corpus must exercise protected age/body cards")
	game.run_seed = selected_seed
	game.run_choice_serial = 0
	var repeat = GameStateScript.new()
	repeat.reset_fresh()
	repeat.pending_story_dialogs.clear()
	repeat.run_seed = selected_seed
	for index in 3:
		repeat.selected_run_perks.append(game.selected_run_perks[index].duplicate(true))
	var repeated_offer := repeat.create_perk_choice(10, false, false, false)
	_expect(repeated_offer == game.create_perk_choice(10, false, false, false), "Identical seed and serial must reproduce the complete perk board")
	repeat.free()
	_expect(not serialized_upgrade.is_empty() and serialized_upgrade.has("before_effect") and serialized_upgrade.has("after_effect"), "Upgrade cards must serialize exact before/after effects")
	if not serialized_upgrade.is_empty():
		game.pending_run_choices.clear()
		game.pending_run_choices.append({"id": "upgrade", "type": "perk", "created_serial": 9, "options": [serialized_upgrade]})
		var pending_saved := game.to_save_data()
		var pending_restored = GameStateScript.new()
		pending_restored.apply_save_data(pending_saved)
		var loaded_option: Dictionary = pending_restored.pending_run_choices[0].options[0]
		_expect(str(loaded_option.get("card_type", "")) == "upgrade" and loaded_option.get("before_effect", {}) == serialized_upgrade.get("before_effect", {}) and loaded_option.get("after_effect", {}) == serialized_upgrade.get("after_effect", {}), "Serialized upgrade offers must survive load without rerolling")
		pending_restored.free()
		game.resolve_run_choice("upgrade", 0, false)
		var upgraded_id := str(serialized_upgrade.target_perk_id)
		var upgraded_instances: Array = game.selected_run_perks.filter(func(instance: Dictionary) -> bool: return str(instance.id) == upgraded_id)
		_expect(upgraded_instances.size() == 1 and float(upgraded_instances[0].effect.magnitude) > 0.10, "Selecting an upgrade must mutate its owned effect, not add a duplicate")
	var saved := game.to_save_data()
	var restored = GameStateScript.new()
	restored.apply_save_data(saved)
	var restored_upgrade: Array = restored.selected_run_perks.filter(func(instance: Dictionary) -> bool: return int(instance.get("upgrade_rank", 0)) > 0)
	_expect(restored_upgrade.size() == 1 and (restored_upgrade[0].get("upgrade_history", []) as Array).size() == 1, "Upgrade ranks and history must round-trip")
	# Exact additive derived stats agree with the card effect and their authoritative getters.
	game.selected_run_perks.clear()
	game.selected_run_perks.append({"id": "offline", "definition_id": "nap_time_training", "effect": {"stat": "offline", "operation": "add", "magnitude": 0.02, "value": 0.02}, "penalty": {}, "secondary_effects": []})
	game.selected_run_perks.append({"id": "loot", "definition_id": "dryer_lint_luck", "effect": {"stat": "loot", "operation": "add", "magnitude": 0.02, "value": 0.02}, "penalty": {}, "secondary_effects": []})
	_expect(is_equal_approx(game.get_offline_xp_efficiency(), 0.03), "Offline perk effect must equal the displayed authoritative efficiency delta")
	_expect(is_equal_approx(game.get_loot_drop_chance(), 0.14), "Loot perk effect must equal the authoritative drop chance delta")
	var migrated = GameStateScript.new()
	migrated.apply_save_data({"version": 30, "determination_points": 4.0, "selected_run_perks": game.selected_run_perks})
	_expect(is_equal_approx(migrated.get_determination_quality_bonus(), 0.08), "Old Determination meters must migrate without changing their earned bonus")
	_expect(is_equal_approx(game.get_outcome_determination_points(Content.GRAND_SLAM_INDEX), 9.6), "Determination fills 20% more slowly at the largest landmark")
	game.determination_points = 4.0
	_expect(is_equal_approx(game.get_determination_quality_bonus(), 0.092), "The new Determination peak step is 15% stronger")
	for definition_value in RunContent.RUN_PERKS:
		var definition: Dictionary = definition_value
		if str(definition.get("league", "")) != "human" or str(definition.get("stat", "")) not in ["offline", "loot"]:
			continue
		var effect := RunContent.resolved_effect(definition, 33, 4.25)
		_expect(float(effect.magnitude) < 0.08, "Human Offline/Loot perk magnitudes must remain human-tier")
	for first_value in Content.PITCHES.slice(0, 17):
		var first: Dictionary = first_value
		for second_value in Content.PITCHES.slice(0, 17):
			var second: Dictionary = second_value
			var dominates := float(first.bonus) >= float(second.bonus) and float(first.speed_max) >= float(second.speed_max) and float(first.drag_multiplier) <= float(second.drag_multiplier) and (float(first.bonus) > float(second.bonus) or float(first.speed_max) > float(second.speed_max) or float(first.drag_multiplier) < float(second.drag_multiplier))
			_expect(not dominates or str(first.id) == str(second.id), "No ordinary human pitch may dominate another across quality, speed, and drag")
	game.free()
	restored.free()
	migrated.free()

func _test_campaign_topology() -> void:
	var levels := Campaign.levels()
	_expect(levels.size() == 100, "The finite campaign must contain exactly 100 levels")
	_expect(Content.HUMAN_FINAL_INDEX == 32, "Human baseball must end at level 33")
	_expect(Content.ALIEN_EXHIBITION_INDEX == 33, "The first alien level must follow the unnumbered exhibition")
	_expect(Content.ALIEN_FINAL_INDEX == 65, "Alien baseball must end at level 66")
	_expect(Content.ELDRITCH_EXHIBITION_INDEX == 66, "The first eldritch level must follow the unnumbered exhibition")
	_expect(Content.ELDRITCH_FINAL_INDEX == 98, "The authored eldritch ladder must end at level 99")
	_expect(Content.FINAL_BOSS_INDEX == 99, "Octathulhu must be level 100")
	_expect(Campaign.SUBERAS.size() == 33, "Each league needs eleven authored three-level sub-eras")
	var ids := {}
	var classes := {}
	var bats := {}
	var previous_difficulty := -1.0
	for index in levels.size():
		var level: Dictionary = levels[index]
		_expect(int(level.index) == index and int(level.number) == index + 1, "Campaign indices must be stable")
		_expect(not ids.has(str(level.id)), "Campaign IDs must be unique")
		_expect(not classes.has(str(level.class_name)), "Every authored opponent class must be distinct")
		_expect(not bats.has(str(level.bat_name)), "Every authored opponent bat must be distinct")
		_expect(float(level.difficulty) > previous_difficulty, "Opponent difficulty must rise at every finite level")
		ids[str(level.id)] = true
		classes[str(level.class_name)] = true
		bats[str(level.bat_name)] = true
		previous_difficulty = float(level.difficulty)
		if index <= Content.HUMAN_FINAL_INDEX:
			_expect(int(level.strikes_required) == 3, "Human baseball must keep three strikes")
	_expect(str(levels[32].signature_name).begins_with("Bambino Rex"), "Bambino Rex must close human baseball")
	_expect(str(levels[65].signature_name).begins_with("Xylophax"), "Xylophax must close alien baseball")
	_expect(int(levels[65].bat_count) == 4, "Xylophax must visibly carry four bats")
	_expect(str(levels[98].signature_name).begins_with("Ball-rog"), "Ball-rog must guard the final mortal level")
	_expect(str(levels[99].signature_name).begins_with("Octathulhu"), "Octathulhu must be the final boss")
	_expect(int(levels[99].bat_count) == 8, "Octathulhu must visibly carry eight bats")
	_expect(Campaign.old_index_to_new(0) == 0, "The first schema-25 opponent must stay first")
	_expect(Campaign.old_index_to_new(29) == 32, "The old human champion must map to Bambino Rex")
	_expect(Campaign.old_index_to_new(30) == 33, "The old alien exhibition must map to alien entry")
	_expect(Campaign.old_index_to_new(39) == 65, "The old alien champion must map to Olympus")
	_expect(Campaign.old_index_to_new(40) == 66, "The old eldritch exhibition must map to Earth defense")
	_expect(Campaign.old_index_to_new(44) == 99, "The old Octathulhu must remain Octathulhu")
	var human_subera_starts := 0
	for level_value in levels:
		var level: Dictionary = level_value
		if str(level.get("league", "")) == "human" and bool(level.get("subera_start", false)):
			human_subera_starts += 1
			_expect(not str(level.get("story_key", "")).is_empty(), "Every human sub-era entry must author a story key")
	_expect(human_subera_starts == 11, "Human baseball must expose eleven authored narrative entry points")

func _test_deterministic_choices() -> void:
	var first = GameStateScript.new()
	var second = GameStateScript.new()
	first.run_seed = 424242
	second.run_seed = 424242
	first.run_choice_serial = 0
	second.run_choice_serial = 0
	var first_offer: Dictionary = first.create_perk_choice(11, true, false, false)
	var second_offer: Dictionary = second.create_perk_choice(11, true, false, false)
	_expect(first_offer == second_offer, "A saved run seed and serial must reproduce the same offer")
	_expect((first_offer.options as Array).size() == 2, "A normal run should offer two perks before prestige")
	for option in first_offer.options:
		_expect(int(option.rarity_rank) >= 2, "A sub-era finale must guarantee Rare-or-better cards")
	var pitch_offer: Dictionary = first.create_pitch_choice(11, false, false)
	_expect((pitch_offer.options as Array).size() == 2, "A sub-era pitch draft should offer two paths")
	first.free()
	second.free()

func _test_choice_save_round_trip() -> void:
	var original = GameStateScript.new()
	original.reset_fresh()
	original.pending_story_dialogs.clear()
	original.run_seed = 991991
	original.create_perk_choice(8, false, false, true)
	original.create_pitch_choice(8, false, true)
	var selected_choice: Dictionary = original.pending_run_choices[0]
	var selected := original.resolve_run_choice(str(selected_choice.id), 0)
	_expect(not selected.is_empty(), "A valid pending perk must resolve")
	original.record_story("human_school_ball", "", "", false)
	var saved := original.to_save_data()
	var restored = GameStateScript.new()
	restored.apply_save_data(saved)
	_expect(restored.run_seed == original.run_seed, "Run seed must survive saves")
	_expect(restored.run_choice_serial == original.run_choice_serial, "Choice serial must survive saves")
	_expect(restored.selected_run_perks == original.selected_run_perks, "Selected perk instances must survive exactly")
	_expect(restored.pending_run_choices == original.pending_run_choices, "Unresolved choices must survive without rerolling")
	_expect(restored.pitch_levels == original.pitch_levels, "Pitch levels must survive saves")
	_expect(restored.story_journal == original.story_journal, "Story journal must survive saves")
	_expect("human_school_ball" in restored.story_seen, "Story presentation keys must survive saves")
	original.free()
	restored.free()

func _test_schema_25_migration() -> void:
	var old_mastery: Array[float] = []
	for index in 45:
		old_mastery.append(float(index + 1) * 10.0)
	var migrated = GameStateScript.new()
	migrated.apply_save_data({
		"version": 25,
		"highest_unlocked": 44,
		"current_opponent": 30,
		"body_growth_level": 8,
		"purchased_body_modifiers": ["suspicious_vitamins"],
		"unlocked_pitches": ["dead_fish", "curveball", "slider"],
		"opponent_mastery": old_mastery,
		"genetic_offer_unlocked": true,
		"eldritch_offer_unlocked": true,
		"genetic_rebirths": 2,
		"eldritch_ascensions": 1,
	})
	_expect(migrated.highest_unlocked == 99, "A completed schema-25 campaign must retain final-boss access")
	_expect(migrated.current_opponent == 33, "The old alien exhibition must map to alien entry")
	_expect(is_equal_approx(migrated.opponent_mastery[99], old_mastery[44]), "Final-boss mastery must map to level 100")
	_expect(migrated.selected_run_perks.size() >= 2, "Legacy age and body modifiers must become run perks")
	_expect(int(migrated.pitch_levels.get("curveball", 0)) == 1, "Every legacy learned pitch must become a level-one pitch")
	_expect(not migrated.story_journal.is_empty(), "An established save must receive a seeded story journal")
	_expect(migrated.pending_run_choices.is_empty(), "Migration must not surprise an established run with retroactive drafts")
	migrated.free()

func _test_mastery_and_strikeout_gate() -> void:
	var game = GameStateScript.new()
	game.reset_fresh()
	game.pending_story_dialogs.clear()
	var requirement := game.get_mastery_requirement(0)
	game.opponent_mastery[0] = requirement - 0.0001
	var contact_summary: Dictionary = game._empty_resolution_summary()
	game._apply_pitch_outcome(contact_summary, 4, -1.0, 1, false)
	game._apply_resolution(contact_summary, true)
	_expect(game.opponent_mastery[0] >= requirement, "A Single should contribute a small amount of mastery")
	_expect(game.highest_unlocked == 0, "Mastery crossing 100% without a strikeout must not clear the level")
	_expect(is_equal_approx(float(contact_summary.earned_xp), 0.0), "Non-strikeout mastery must never pay XP")
	var grand_slam_before: float = float(game.opponent_mastery[0])
	var grand_slam_summary: Dictionary = game._empty_resolution_summary()
	game._apply_pitch_outcome(grand_slam_summary, Content.GRAND_SLAM_INDEX, -1.0, 1, false)
	game._apply_resolution(grand_slam_summary, true)
	_expect(is_equal_approx(game.opponent_mastery[0], grand_slam_before), "Grand Slams must award no mastery")
	var strikeout_summary: Dictionary = game._empty_resolution_summary()
	game._apply_pitch_outcome(strikeout_summary, Content.STRIKE_INDEX, -1.0, 3, false)
	game._apply_resolution(strikeout_summary, true)
	_expect(game.highest_unlocked == 1, "A completed strikeout at ready mastery must clear the level")
	_expect(float(strikeout_summary.earned_xp) > 0.0, "Only the completed strikeout should pay XP")
	_expect(game.pending_run_choices.size() == 1, "A normal clear must queue one perk choice")
	game.free()

func _test_sticky_boss_and_choice_queue() -> void:
	var game = GameStateScript.new()
	game.reset_fresh()
	game.pending_story_dialogs.clear()
	game.highest_unlocked = Content.HUMAN_FINAL_INDEX
	game.current_opponent = Content.HUMAN_FINAL_INDEX
	game.selected_distance_index = game.get_prescribed_distance_index(game.current_opponent)
	var requirement := game.get_mastery_requirement()
	game.opponent_mastery[game.current_opponent] = requirement - game.get_strikeout_mastery_bonus() * 0.5
	_expect(game._update_sticky_boss_state(), "A finale should summon its sticky boss when the next strikeout can finish it")
	_expect(game.is_sticky_boss_active(), "The summoned finale boss must remain active")
	game.batter_generation = 7
	var hit_summary: Dictionary = game._empty_resolution_summary()
	game._apply_pitch_outcome(hit_summary, 1, -1.0, 1, false)
	game._apply_resolution(hit_summary, true)
	_expect(game.batter_generation == 0 and game.is_sticky_boss_active(), "A hit must not rotate a sticky boss out")
	game.opponent_mastery[game.current_opponent] = requirement
	var offline_k: Dictionary = game._empty_resolution_summary()
	game._apply_pitch_outcome(offline_k, Content.STRIKE_INDEX, -1.0, 3, false)
	game._apply_resolution(offline_k, false, 0.01)
	_expect(game.highest_unlocked == Content.HUMAN_FINAL_INDEX, "Offline simulation must not bypass a witnessed finale boss")
	var live_k: Dictionary = game._empty_resolution_summary()
	game._apply_pitch_outcome(live_k, Content.STRIKE_INDEX, -1.0, 3, false)
	game._apply_resolution(live_k, true)
	_expect(game.highest_unlocked == Content.HUMAN_FINAL_INDEX, "First contact must remain outside the numbered ladder until its story is accepted")
	_expect(game.pending_special_encounter == "alien_contact", "Beating Bambino for the first time must queue unnumbered first contact")
	_expect(game.pending_run_choices.size() >= 2, "A league boss must queue both perk and boss-pitch rewards")
	_expect(not game.begin_special_encounter("alien_contact"), "First contact must wait for mandatory queued choices")
	while not game.pending_run_choices.is_empty():
		var choice: Dictionary = game.pending_run_choices[0]
		game.resolve_run_choice(str(choice.id), 0)
	_expect(game.begin_special_encounter("alien_contact"), "Resolving the queue must allow the unnumbered exhibition")
	_expect(game.highest_unlocked == Content.ALIEN_EXHIBITION_INDEX, "Accepting first contact must stage it on the first alien field")
	_expect(game.get_outcome_probabilities()[Content.GRAND_SLAM_INDEX] == 1.0, "First-contact Xylophax must be impossible before rebirth")
	game.free()

func _test_active_volley_queue() -> void:
	var game = GameStateScript.new()
	game.reset_fresh()
	game.pending_story_dialogs.clear()
	game.eldritch_levels["unbound_windup"] = 1
	var release_summary: Dictionary = game._empty_resolution_summary()
	game._begin_pitch_volley(release_summary, 0.0)
	game._begin_pitch_volley(release_summary, 0.1)
	_expect(game.active_volleys.size() == 2, "Unbound Windup must preserve overlapping immutable volleys")
	_expect(
		int(game.active_volleys[0].id) != int(game.active_volleys[1].id),
		"Every overlapping volley must have a stable unique id"
	)
	var saved := game.to_save_data()
	var restored = GameStateScript.new()
	restored.apply_save_data(saved)
	_expect(restored.active_volleys == game.active_volleys, "Every in-flight volley must survive a save round-trip")
	_expect(restored.next_volley_id == game.next_volley_id, "Volley identity allocation must survive saves")
	var rehydrated_duration := float(restored.active_volleys[0].duration)
	restored.simulate_active_time(rehydrated_duration + 0.2)
	_expect(restored.active_volleys.is_empty(), "A rehydrated authoritative volley must resolve without a rendered field clock")

	var first_id := int(game.active_volleys[0].id)
	game.active_volleys[0].ball_count = 2
	game.active_volleys[0].outcomes = [Content.STRIKE_INDEX, 4]
	game.active_volleys[0].saved_flags = [false, false]
	var impact_summary: Dictionary = game._empty_resolution_summary()
	game._resolve_active_volley_at(0, impact_summary, 0.25)
	var impact_events: Array = (impact_summary.pitch_events as Array).filter(
		func(event: Dictionary) -> bool: return str(event.get("phase", "")) == "impact"
	)
	_expect(impact_events.size() == 1, "Resolving one volley must emit one combined impact event")
	if not impact_events.is_empty():
		_expect(int(impact_events[0].volley_id) == first_id, "An impact must identify only the volley that arrived")
		_expect((impact_events[0].outcomes as Array) == [Content.STRIKE_INDEX, 4], "Balls in one volley must preserve independent outcomes")

	# The mixed hit above makes its batter depart, so the other released volley
	# must lose its target instead of curving into the replacement.
	var lost_events: Array = (impact_summary.pitch_events as Array).filter(
		func(event: Dictionary) -> bool: return str(event.get("phase", "")) == "target_lost"
	)
	_expect(game.active_volleys.is_empty(), "A departing batter must orphan every other overlapping volley")
	_expect(lost_events.size() == 1, "Every orphaned volley must emit one target-lost visual event")
	game.free()
	restored.free()

func _test_deferred_level_choices() -> void:
	var game = GameStateScript.new()
	game.reset_fresh()
	game.pending_story_dialogs.clear()
	var requirement := game.get_mastery_requirement(0)
	game.opponent_mastery[0] = requirement
	var clear_summary: Dictionary = game._empty_resolution_summary()
	game._apply_pitch_outcome(clear_summary, Content.STRIKE_INDEX, -1.0, 3, false)
	game._apply_resolution(clear_summary, true)
	_expect(game.highest_unlocked == 1, "A cleared ordinary level should unlock its successor immediately")
	_expect(game.current_opponent == 0, "A cleared level should remain active for voluntary farming")
	_expect(game.has_pending_run_choices(), "A clear should serialize its mandatory reward before transition")
	_expect(not game.set_current_opponent(1), "Direct level movement must not bypass an unresolved draft")
	var farm_summary := game.simulate_active_time(8.0)
	_expect(float(farm_summary.released_pitches) > 0.0 or game.get_active_volley_count() > 0, "A cleared level must keep pitching while draft choices wait")
	while game.has_pending_run_choices():
		var choice := game.get_next_pending_run_choice()
		_expect(not game.resolve_run_choice(str(choice.id), 0).is_empty(), "A queued reward must remain resolvable after farming")
	_expect(game.set_current_opponent(1), "Resolving choices should reopen the requested next-level transition")
	game.free()

func _test_bats_and_clone_fielding() -> void:
	var game = GameStateScript.new()
	game.reset_fresh()
	game.pending_story_dialogs.clear()
	var base: Array[float] = [0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.10, 0.60]
	var four_bat := game._apply_bat_overload_penalty(base, 0, Content.ALIEN_FINAL_INDEX)
	var base_contact := 0.0
	var four_bat_contact := 0.0
	for outcome in Content.HIT_OUTCOME_COUNT:
		base_contact += base[outcome]
		four_bat_contact += four_bat[outcome]
	base_contact += base[Content.FOUL_INDEX]
	four_bat_contact += four_bat[Content.FOUL_INDEX]
	_expect(four_bat_contact > base_contact + 0.35, "Unused bats must confer a large reciprocal contact advantage")

	game.genetic_rebirths = 1
	game.genetic_levels.extra_arms = 3
	var uncovered := game._apply_bat_overload_penalty(base, 4, Content.ALIEN_FINAL_INDEX)
	_expect(float(uncovered[Content.STRIKE_INDEX]) > float(base[Content.STRIKE_INDEX]), "A ball beyond every enemy bat must receive a stacking Strike advantage")

	game.eldritch_ascensions = 1
	game.eldritch_levels.mirror_clones = 1
	game.eldritch_levels.portal_outfield = 1
	game.eldritch_levels.fielding_clearance = 1
	var coverage := game.get_clone_field_coverage_chance()
	var catch_chance := game.get_clone_catch_chance()
	var single_save := game.get_hit_save_chance(Content.SINGLE_INDEX)
	_expect(coverage > 0.0 and coverage < 1.0, "Mirror clones must supply probabilistic spatial coverage")
	_expect(catch_chance > 0.0 and catch_chance < 1.0, "Catching practice must be an independent probabilistic check")
	_expect(is_equal_approx(single_save, coverage * catch_chance), "A save chance must require both coverage and catch success")
	_expect(is_equal_approx(game.get_hit_save_chance(3), 0.0), "Fielding tier one must not catch Doubles")
	_expect(is_equal_approx(game.get_hit_save_chance(Content.GRAND_SLAM_INDEX), 0.0), "Grand Slams must remain unsavable")

	# A caught human fair ball is an ordinary out with no XP; the same catch in
	# a post-human league preserves the active batter and count.
	game.current_opponent = 0
	game.highest_unlocked = 0
	var human_summary: Dictionary = game._empty_resolution_summary()
	game._apply_pitch_outcome(human_summary, Content.SINGLE_INDEX, -1.0, 1, true, 0)
	game._apply_resolution(human_summary, true)
	_expect(game.batter_replacement_pending, "A caught human hit must retire the batter")
	_expect(is_equal_approx(float(human_summary.earned_xp), 0.0), "A caught out must not award strikeout XP")
	game.batter_replacement_pending = false
	game.batter_cooldown_remaining = 0.0
	game.current_opponent = Content.ALIEN_EXHIBITION_INDEX
	game.highest_unlocked = Content.ALIEN_EXHIBITION_INDEX
	var alien_summary: Dictionary = game._empty_resolution_summary()
	game._apply_pitch_outcome(
		alien_summary,
		Content.SINGLE_INDEX,
		-1.0,
		1,
		true,
		Content.ALIEN_EXHIBITION_INDEX
	)
	game._apply_resolution(alien_summary, true)
	_expect(not game.batter_replacement_pending, "A post-human clone catch must preserve the batter")
	game.free()

func _test_loot_and_relic_contract() -> void:
	var game = GameStateScript.new()
	game.reset_fresh()
	game.pending_story_dialogs.clear()
	game.highest_unlocked = Content.FINAL_BOSS_INDEX
	game.current_opponent = Content.FINAL_BOSS_INDEX
	game.eldritch_ascensions = 1
	game.eldritch_levels.many_angled_pockets = 2
	game._sync_equipped_relic_slots()
	_expect(game.get_relic_slot_count() == 3, "Many-Angled Pockets must add one Relic slot per rank")

	var relic_slot_index := -1
	var hat_slot_index := -1
	for index in Content.LOOT_SLOTS.size():
		var slot_id := str(Content.LOOT_SLOTS[index].id)
		if slot_id == "relic":
			relic_slot_index = index
		elif slot_id == "hat":
			hat_slot_index = index
	_expect(relic_slot_index >= 0 and hat_slot_index >= 0, "Loot tables must include Hat and Relic slots")

	var relics: Array[Dictionary] = []
	for relic_number in 3:
		var relic := game._generate_loot_item(
			Content.FINAL_BOSS_INDEX,
			relic_slot_index,
			Content.LOOT_RARITIES.size() - 1
		)
		relic.id = "test_relic_%d" % relic_number
		relic.name = "Test Relic %d" % (relic_number + 1)
		relics.append(relic)
		game.loot_items.append(relic)
		_expect((relic.stats as Dictionary).size() == 1, "Every Relic must contain exactly one uncapped stat")
		for value in (relic.stats as Dictionary).values():
			_expect(float(value) > 0.0, "Relic effects must always be positive")
		_expect(game.equip_loot(str(relic.id), relic_number), "Every unlocked Relic slot must accept one item")
	_expect(game.get_equipped_relic_items().size() == 3, "All three equipped Relics must contribute simultaneously")

	var saw_one_affix := false
	var saw_multiple_affixes := false
	var saw_tradeoff := false
	for sample in 64:
		var ordinary := game._generate_loot_item(
			Content.FINAL_BOSS_INDEX,
			hat_slot_index,
			Content.LOOT_RARITIES.size() - 1
		)
		var stats: Dictionary = ordinary.stats
		saw_one_affix = saw_one_affix or stats.size() == 1
		saw_multiple_affixes = saw_multiple_affixes or stats.size() > 1
		for value in stats.values():
			saw_tradeoff = saw_tradeoff or float(value) < 0.0
	_expect(saw_one_affix and saw_multiple_affixes, "Normal affix count must vary independently of rarity")
	_expect(saw_tradeoff, "Normal multi-affix gear must sometimes roll a meaningful negative tradeoff")

	var saved := game.to_save_data()
	var restored = GameStateScript.new()
	restored.apply_save_data(saved)
	_expect(restored.equipped_relics == game.equipped_relics, "Every equipped Relic slot must survive save migration")
	game.free()
	restored.free()

func _test_training_batches_and_physical_scale() -> void:
	var game = GameStateScript.new()
	game.reset_fresh()
	game.pending_story_dialogs.clear()
	game.xp = 1.0e12
	var ten_rank_cost := game.get_training_batch_cost("velocity", 10)
	var summed_cost := 0.0
	for rank in 10:
		game.training_levels.velocity = rank
		summed_cost += game.get_training_cost("velocity")
	game.training_levels.velocity = 0
	_expect(is_equal_approx(ten_rank_cost, BaseballGameState.rounded_cost(summed_cost)), "Training x10 must equal ten exact rounded rank costs")
	var xp_before: float = game.xp
	_expect(game.buy_training_batch("velocity", 10), "An affordable x10 Training batch must purchase atomically")
	_expect(int(game.training_levels.velocity) == 10, "A Training x10 purchase must add exactly ten ranks")
	_expect(is_equal_approx(game.xp, xp_before - ten_rank_cost), "A Training batch must deduct its displayed exact cost")
	_expect(not game.buy_training_batch("velocity", 7), "Only x1, x10, and x100 Training batches are valid")

	game.reset_fresh()
	game.pending_story_dialogs.clear()
	_expect(is_equal_approx(game.get_pitch_distance_feet(), 3.0), "The opening range must be three physical feet")
	_expect(game.get_physical_flight_seconds() >= 3.0 and game.get_physical_flight_seconds() <= 3.02, "The one-foot-per-second opening pitch must remain roughly three seconds")
	_expect(game.get_representative_plate_speed() < 1.0 and game.get_representative_plate_speed() > 0.99, "The untouched Wiffle Ball must lose a small real amount of speed to air")
	game.highest_unlocked = Content.HUMAN_FINAL_INDEX
	_expect(is_equal_approx(game.get_velocity_cap_fps(), BaseballGameState.HUMAN_SPEED_CAP_FPS), "A first body must retain the 115 mph human ceiling")
	game.genetic_rebirths = 1
	_expect(is_equal_approx(game.get_velocity_cap_fps(), BaseballGameState.ALIEN_SPEED_CAP_FPS), "Genetic baseball must expose the Mach 5000 ceiling")
	game.eldritch_ascensions = 1
	_expect(is_equal_approx(game.get_velocity_cap_fps(), BaseballGameState.ELDRITCH_SPEED_CAP_FPS), "Eldritch baseball must expose the 5000c ceiling")
	var alien_anchor := float(Content.campaign_level(Content.ALIEN_FINAL_INDEX).speed_anchor_fps)
	var final_anchor := float(Content.campaign_level(Content.FINAL_BOSS_INDEX).speed_anchor_fps)
	_expect(absf(alien_anchor / BaseballGameState.ALIEN_SPEED_CAP_FPS - 1.0) < 0.001, "Olympus Mound must be anchored at Mach 5000")
	_expect(absf(final_anchor / BaseballGameState.ELDRITCH_SPEED_CAP_FPS - 1.0) < 0.001, "Earth-to-Pluto Octathulhu must be anchored at 5000c")
	game.free()

func _test_tap_signal_and_determination() -> void:
	var game = GameStateScript.new()
	game.reset_fresh()
	game.pending_story_dialogs.clear()
	var determination_before: float = game.determination_points
	var tap := game.apply_field_tap(false)
	_expect(bool(tap.get("applied", false)) and str(tap.get("phase", "")) == "recovery", "An opening field tap must feed the rolling recovery signal")
	_expect(is_zero_approx(float(tap.get("seconds", -1.0))), "A field tap must not teleport a timer")
	_expect(game.get_live_tap_rate() > 0.0 and float(tap.get("speed_multiplier", 1.0)) > 1.0, "A field tap must raise a smooth live-rate multiplier")
	_expect(game.determination_points > determination_before, "Every useful field tap must add Determination")
	_expect(game.get_tap_timer_speed_multiplier_for_rate(10.0, 8.0) > game.get_tap_timer_speed_multiplier_for_rate(1.0, 8.0), "Long timers must receive a larger—but still smooth—tap-rate benefit")
	_expect(game.get_field_tap_fatigue_multiplier_for_burst_rate(80.0) < game.get_field_tap_fatigue_multiplier_for_burst_rate(4.0), "Macro-speed tapping must receive extra diminishing returns")
	game.genetic_levels.autonomic_clicking_finger = 4
	game.eldritch_levels.hands_beyond_the_mouse = 2
	_expect(game.get_automatic_clicker_count() == 3, "Eldritch hands must add independent automatic clickers")
	_expect(game.get_effective_automatic_field_tap_rate() > 0.0, "Automatic clickers must contribute a fatigue-aware live rate")
	game.field_tap_burst_rate = 20.0
	game._decay_field_tap_fatigue(5.0)
	_expect(game.field_tap_burst_rate < 20.0, "The rolling tap signal must decay when input stops")
	game.free()

func _test_prestige_and_endless_contract() -> void:
	var game = GameStateScript.new()
	game.reset_fresh()
	game.pending_story_dialogs.clear()
	game.genetic_offer_unlocked = true
	game.highest_unlocked = Content.ALIEN_EXHIBITION_INDEX
	game.run_xp = BaseballGameState.DNA_XP_THRESHOLD * 8.0
	var dna_award := game.get_potential_dna()
	_expect(dna_award >= 2, "The first prestige preview must scale from body XP")
	_expect(game.perform_genetic_rebirth() == dna_award, "Genetic rebirth must grant its previewed DNA")
	_expect(game.genetic_rebirths == 1 and game.current_opponent == 0, "Genetic rebirth must return a modified baby to level one")
	game.genetic_levels.extra_arms = 1
	_expect(game.get_arm_count() == 2.0 and game.get_volley_size() >= 2, "An extra-arm rank must automatically expand the released volley")

	game.eldritch_offer_unlocked = true
	game.highest_unlocked = Content.ELDRITCH_EXHIBITION_INDEX
	game.reality_dna_earned = 1000.0
	var arcana_award := game.get_potential_arcana()
	_expect(arcana_award >= 60, "Arcana must scale from all DNA earned in the current reality")
	_expect(game.perform_eldritch_ascension() == arcana_award, "Eldritch ascension must grant its previewed Arcana")
	_expect(game.dna == 0 and int(game.genetic_levels.extra_arms) == 0, "Eldritch ascension must destroy current-reality genetics")

	game.cosmos_conquered = true
	var blessing_id := str(Content.DIVINE_BLESSINGS[0].id)
	_expect(game.perform_divine_ascension(blessing_id), "A cosmic victory must permit God Prestige")
	_expect(game.has_divine_blessing(blessing_id) and game.divine_ascensions == 1, "God Prestige must preserve its chosen blessing")
	game.highest_unlocked = Content.FINAL_BOSS_INDEX
	game.current_opponent = Content.FINAL_BOSS_INDEX
	game.opponent_mastery[Content.FINAL_BOSS_INDEX] = game.get_mastery_requirement(Content.FINAL_BOSS_INDEX)
	game.cosmos_conquered = false
	game._check_opponent_unlock(1.0, true)
	while not game.pending_run_choices.is_empty():
		var choice: Dictionary = game.pending_run_choices[0]
		game.resolve_run_choice(str(choice.id), 0)
	_expect(game.cosmos_conquered and game.endless_unlocked, "Returning to Octathulhu after God Prestige must unlock Extra Innings")
	_expect(game.begin_endless_mode(), "The player must be able to choose the post-victory endless ladder")
	var first_difficulty := game.get_effective_opponent_difficulty()
	game.opponent_mastery[Content.FINAL_BOSS_INDEX] = game.get_mastery_requirement(Content.FINAL_BOSS_INDEX)
	game._check_opponent_unlock(1.0, true)
	_expect(game.endless_level == 2, "Clearing an Extra Inning must advance the procedural ladder")
	_expect(game.get_effective_opponent_difficulty() > first_difficulty, "Every Extra Inning must be harder than the last")
	_expect(not game.pending_run_choices.is_empty(), "Every Extra Inning clear must continue the run-draft loop")
	game.free()

func _test_first_run_story_and_body_copy() -> void:
	var game = GameStateScript.new()
	game.reset_fresh()
	_expect(bool(game.catalog_hide_purchased.pitch) and bool(game.catalog_hide_purchased.ball) and bool(game.catalog_hide_purchased.facility) and not game.catalog_hide_purchased.has("body"), "Fresh catalog filters retain only visible one-time catalog controls")
	_expect(game.get_next_story_dialog().get("id", "") == "prologue_little_timmy", "A fresh run must queue the toddler prologue before ordinary play")
	_expect(game.story_journal.size() >= 1 and str(game.story_journal[0].body).contains("one foot per second"), "The opening story must be journaled with the one-foot-per-second premise")
	for subera_index in range(1, 11):
		var next_index := subera_index * Campaign.LEVELS_PER_SUBERA
		var next_level := Campaign.level(next_index)
		var story_id := str(next_level.story_key)
		_expect(not RunContent.story_by_id(story_id).is_empty(), "Every human sub-era story key must have authored copy")
		game.highest_unlocked = next_index
		game.current_opponent = next_index - 1
		_expect(game.set_current_opponent(next_index), "Entering %s must succeed after its rewards resolve" % str(next_level.subera))
		_expect(story_id in game.story_seen, "Entering %s must queue its authored first-lifetime story" % str(next_level.subera))
		var story_count: int = game.story_journal.size()
		game.current_opponent = next_index - 1
		game.set_current_opponent(next_index)
		_expect(game.story_journal.size() == story_count, "A sub-era story must only record once")
	var timing = GameStateScript.new()
	timing.reset_fresh()
	timing.pending_story_dialogs.clear()
	timing.story_journal.clear()
	timing.story_seen.clear()
	timing.current_opponent = Campaign.LEVELS_PER_SUBERA - 1
	timing.highest_unlocked = timing.current_opponent
	timing.opponent_mastery[timing.current_opponent] = timing.get_mastery_requirement()
	timing._check_opponent_unlock(1.0, true)
	_expect("arrive_tee_ball" not in timing.story_seen, "Clearing a sub-era finale must not present the next chapter while farming")
	while timing.has_pending_run_choices():
		var choice := timing.get_next_pending_run_choice()
		timing.resolve_run_choice(str(choice.id), 0)
	_expect(timing.set_current_opponent(Campaign.LEVELS_PER_SUBERA), "The successor level must be enterable after mandatory rewards resolve")
	_expect("arrive_tee_ball" in timing.story_seen, "Entering the successor level must queue its chapter arrival")
	var entry_count: int = timing.story_journal.size()
	timing.current_opponent = Campaign.LEVELS_PER_SUBERA - 1
	timing.set_current_opponent(Campaign.LEVELS_PER_SUBERA)
	_expect(timing.story_journal.size() == entry_count, "Entry stories must remain once-per-ID after revisiting the boundary")
	var first_age := game.get_body_age_step_effect(1)
	_expect(float(first_age.speed_multiplier) > 1.0 and float(first_age.quality_bonus) > 0.0 and float(first_age.recovery_multiplier) > 1.0 and float(first_age.visual_size_multiplier) > 1.0, "Age cards must expose every real first-step body bonus")
	var age_effect := {"stat": "body_age", "operation": "body", "age_order": 1}
	_expect(int(age_effect.age_order) == 1, "Age effects must retain their selected step metadata")
	var explicit_false := game.to_save_data()
	explicit_false["catalog_hide_purchased"] = {"pitch": false, "ball": false, "facility": false, "body": false}
	var restored = GameStateScript.new()
	restored.apply_save_data(explicit_false)
	_expect(not bool(restored.catalog_hide_purchased.pitch) and not restored.catalog_hide_purchased.has("body"), "Saved Body filter preferences are ignored because BODY has no visible filter")
	var missing_filters := game.to_save_data()
	missing_filters.erase("catalog_hide_purchased")
	var migrated = GameStateScript.new()
	migrated.apply_save_data(missing_filters)
	_expect(bool(migrated.catalog_hide_purchased.pitch) and not migrated.catalog_hide_purchased.has("body"), "Missing catalog preferences preserve visible catalog defaults without inventing a Body filter")
	game.free()
	restored.free()
	migrated.free()
	timing.free()

func _test_story_exhibitions() -> void:
	var game = GameStateScript.new()
	game.reset_fresh()
	game.pending_story_dialogs.clear()
	game.pending_special_encounter = "alien_contact"
	_expect(game.begin_special_encounter("alien_contact"), "The accepted alien transmission must start the unnumbered exhibition")
	_expect(game.get_outcome_probabilities()[Content.GRAND_SLAM_INDEX] == 1.0, "First-contact Xylophax must hit guaranteed Grand Slams")
	for _slam in BaseballGameState.ALIEN_EXHIBITION_GRAND_SLAMS_REQUIRED:
		var summary := game._empty_resolution_summary()
		game._apply_pitch_outcome(summary, Content.GRAND_SLAM_INDEX, -1.0, 1, false)
		game._apply_resolution(summary, true)
	_expect(game.is_alien_help_available(), "Only witnessed humiliation must reveal HELP")
	_expect(game.accept_alien_help() and game.genetic_offer_unlocked, "HELP must persistently reveal Time Travel")

	game._reset_body_progress()
	game.pending_special_encounter = "eldritch_contact"
	_expect(game.begin_special_encounter("eldritch_contact"), "The accepted eldritch transmission must start the unnumbered doom exhibition")
	_expect(game.get_outcome_probabilities()[Content.GRAND_SLAM_INDEX] == 1.0, "First-contact Octathulhu must hit guaranteed Grand Slams")
	for _slam in BaseballGameState.ELDRITCH_EXHIBITION_GRAND_SLAMS_REQUIRED:
		var summary := game._empty_resolution_summary()
		game._apply_pitch_outcome(summary, Content.GRAND_SLAM_INDEX, -1.0, 1, false)
		game._apply_resolution(summary, true)
	_expect(game.eldritch_offer_unlocked and game.is_story_offer_ready(), "Only witnessed doom must reveal eldritch ascension")
	_expect(game.story_journal.size() > 0, "Campaign and prestige discoveries must be retained in the Story journal")
	game.free()
