extends SceneTree

const Content = preload("res://scripts/content.gd")
const GameStateScript = preload("res://scripts/game_state.gd")
const PitchFieldScript = preload("res://scripts/pitch_field.gd")

var failures: Array[String] = []

func _initialize() -> void:
	print("One Foot Per Second — v0.10.5 multiverse regression suite")
	_test_content()
	_test_initial_balance_and_velocity_layers()
	_test_pitch_phase_state_machine()
	_test_live_field_contract()
	_test_distance_risk_and_reward()
	_test_overmastery_farming()
	_test_opponent_counters()
	_test_opponent_variants()
	_test_strikeout_only_economy()
	_test_strikeout_loot_and_equipment()
	_test_projectile_snapshots()
	_test_batter_rotation()
	_test_progression_and_purchases()
	_test_story_exhibitions_and_reset_boundaries()
	_test_divine_restoration()
	_test_save_round_trip_and_migration()
	_test_save_backup_codec()
	_test_cosmic_completion_and_magnitude()
	if failures.is_empty():
		print("PASS: all tests completed")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("FAIL: %d test(s) failed" % failures.size())
		quit(1)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _expect_close(actual: float, expected: float, message: String, tolerance := 0.00001) -> void:
	if absf(actual - expected) > maxf(absf(expected) * tolerance, tolerance):
		failures.append("%s (got %s, expected %s)" % [message, str(actual), str(expected)])

func _test_save_backup_codec() -> void:
	var original: BaseballGameState = GameStateScript.new()
	original.xp = 12345.0
	original.highest_unlocked = 4
	original.current_opponent = 3
	var encoded := original.get_save_json(true)
	_expect(encoded.contains("\n"), "Portable backups should be readable JSON instead of an opaque payload")
	var decoded := original.decode_save_text(encoded)
	_expect(bool(decoded.get("ok", false)), "A current portable save should pass validation")
	var restored: BaseballGameState = GameStateScript.new()
	if bool(decoded.get("ok", false)):
		restored.apply_save_data(decoded.data)
	_expect_close(restored.xp, 12345.0, "Portable backup import should preserve XP")
	_expect(restored.highest_unlocked == 4 and restored.current_opponent == 3, "Portable backup import should preserve ladder position")
	_expect(not bool(original.decode_save_text("not json").get("ok", false)), "Save import must reject malformed JSON")
	_expect(not bool(original.decode_save_text("[]").get("ok", false)), "Save import must reject non-object JSON")
	_expect(not bool(original.decode_save_text("{}").get("ok", false)), "Save import must reject unrelated JSON objects")
	var future := original.to_save_data()
	future.version = BaseballGameState.SAVE_VERSION + 1
	_expect(not bool(original.decode_save_text(JSON.stringify(future)).get("ok", false)), "Save import must reject unknown future schemas")
	var malformed := original.to_save_data()
	malformed.training_levels = []
	_expect(not bool(original.decode_save_text(JSON.stringify(malformed)).get("ok", false)), "Save import must reject malformed structured sections")
	original.free()
	restored.free()

func _test_content() -> void:
	var opponents: Array[Dictionary] = Content.opponents()
	_expect(opponents.size() == 45, "Expected 45 opponent classes")
	_expect(Content.HUMAN_FINAL_INDEX == 29, "The human campaign must end at level 30")
	_expect(Content.ALIEN_EXHIBITION_INDEX == 30, "Xylophax must open the genetic layer")
	_expect(Content.ALIEN_FINAL_INDEX == 39, "The alien championship must end at level 40")
	_expect(Content.ELDRITCH_EXHIBITION_INDEX == 40, "N'Kthra must open the eldritch layer")
	_expect(Content.FINAL_BOSS_INDEX == 44, "Octathulhu must remain the final boss")
	_expect(Content.OPPONENT_NAMES[30] == "Alien Exhibition Commissioner", "Level 31 should be a reusable batter class")
	_expect(Content.OPPONENT_NAMES[43] == "Unstrikeable Void Titan", "Ball-rog's class should remain generic")
	_expect(Content.SIGNATURE_BATTER_NAMES[30] == "Xylophax, Genetic Commissioner", "The genetic commissioner changed unexpectedly")
	_expect(str(Content.SIGNATURE_BATTER_NAMES[40]).begins_with("N'Kthra"), "The eldritch exhibition needs an explicit elder deity")
	_expect(Content.SIGNATURE_BATTER_NAMES[43] == "Ball-rog, the Unstrikeable", "Ball-rog should remain the penultimate named batter")
	_expect(Content.SIGNATURE_BATTER_NAMES[44] == "Octathulhu, God of the Eightfold Swing", "Final named opponent changed unexpectedly")
	_expect(Content.PITCHES.size() == 14, "Expected fourteen pitch types")
	_expect(Content.TRAINING.size() == 7, "Expected seven repeatable training axes")
	var training_ids: Array[String] = []
	for definition in Content.TRAINING:
		training_ids.append(str(definition.id))
	_expect(training_ids == ["velocity", "command", "recovery", "distance_control", "turnover", "hit_recovery", "pitch_calling"], "Training should expose one clear purchase per base stat in unlock order")
	_expect(Content.BALL_UPGRADES.size() == 26, "Expected twenty-six ball evolutions")
	_expect(Content.MILESTONES.size() == 42, "Expected forty-two interstitial facilities and interventions")
	_expect(Content.DISTANCE_TIERS.size() == 15, "Expected the 3-foot-to-galaxy range ladder")
	_expect(Content.SCALE_UPGRADES.is_empty(), "Physical scale must live in prestige layers, not ordinary XP")
	_expect(Content.GENETIC_UPGRADES.size() == 13, "Expected thirteen genetic enhancements")
	_expect(Content.ELDRITCH_UPGRADES.size() == 11, "Expected eleven eldritch abilities")
	_expect(Content.DIVINE_BLESSINGS.size() == 6, "Expected six collectible divine blessings")
	_expect(Content.LOOT_SLOTS.size() == 7, "Expected six human equipment slots and one post-human Relic")
	_expect(str(Content.LOOT_SLOTS[5].id) == "cleats", "Cleats should remain a regular equipment slot")
	_expect(str(Content.LOOT_SLOTS[6].id) == "relic", "The seventh equipment slot should be the post-human Relic")
	_expect(Content.LOOT_RARITIES.size() == 5, "Expected five Diablo-style loot tiers")
	var rarity_probability := 0.0
	for rarity_index in Content.LOOT_RARITIES.size():
		var rarity: Dictionary = Content.LOOT_RARITIES[rarity_index]
		rarity_probability += float(rarity.probability)
		_expect(int(rarity.affix_count) == rarity_index, "Loot rarity should add one affix per tier")
	_expect_close(rarity_probability, 1.0, "Loot rarity probabilities must sum to one")
	_expect(float(Content.LOOT_RARITIES[3].probability) < 0.005, "Legendary gear should be an actual event, not a routine drop")
	_expect(float(Content.LOOT_RARITIES[4].probability) <= 0.0003, "Unique gear should be exceptionally rare")
	_expect(Content.BAT_NAMES.size() == opponents.size(), "Every opponent needs a distinct bat")
	_expect(Content.OPPONENT_DIFFICULTY_ANCHORS.size() == Content.ERA_NAMES.size() + 1, "Difficulty anchors must include the final boss")
	_expect(Content.BATTER_NAME_POOLS.size() == Content.ERA_NAMES.size(), "Every era needs a rotating name pool")
	_expect(Content.OUTCOME_NAMES.size() == 8, "Fair hits, Foul, Ball, and Strike should produce eight outcomes")
	_expect(Content.OUTCOME_XP == [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], "No individual pitch outcome may pay XP")
	for index in Content.HUMAN_FINAL_INDEX + 1:
		_expect(Content.BASE_STRIKES_REQUIRED[index] == 3, "Every human batter must use three strikes")
		_expect(Content.BASE_BALLS_REQUIRED[index] == 4, "Every human batter must use four Balls per walk")
	_expect(Content.BASE_STRIKES_REQUIRED[30] == 4 and Content.BASE_STRIKES_REQUIRED[39] == 9, "Alien counts should rise from four to nine")
	_expect(Content.BASE_STRIKES_REQUIRED[40] == 12 and Content.BASE_STRIKES_REQUIRED[44] == 64, "Eldritch counts should rise from twelve to sixty-four")
	_expect(Content.BASE_BALLS_REQUIRED[35] == 3 and Content.BASE_BALLS_REQUIRED[44] == 2, "Stranger leagues should require fewer Balls per walk")
	_expect(str(Content.BALL_UPGRADES[15].name) == "World-Series Game Ball", "The complete human ball ladder should remain recognizably baseball")
	_expect(int(Content.ball_upgrade_by_id("railgun_jacket").required_level) > Content.HUMAN_FINAL_INDEX, "Railgun equipment must remain post-human")
	for pool in Content.BATTER_NAME_POOLS:
		_expect(pool.size() >= 10, "Every era needs enough rotating names")
	_expect(Content.batter_display_name(0, 0) == "Little Timmy", "The first batter should be Little Timmy")
	_expect(Content.batter_display_name(0, 1) != Content.batter_display_name(0, 0), "Replacement batters need distinct names")
	var unique_bats := {}
	for bat_name in Content.BAT_NAMES:
		unique_bats[str(bat_name)] = true
	_expect(unique_bats.size() == opponents.size(), "Every opponent bat name should be unique")
	for index in opponents.size():
		_expect(float(opponents[index].reward) > 0.0, "Opponent reward must be positive at index %d" % index)
		if index > 0:
			_expect(float(opponents[index].difficulty) > float(opponents[index - 1].difficulty), "Opponent threat must rise at index %d" % index)
		if str(opponents[index].trait) != "standard":
			_expect(not Content.trait_description(str(opponents[index].trait)).is_empty(), "Special traits need visible formulas")
	for era_index in Content.ERA_NAMES.size():
		var opponent_index := era_index * 5
		_expect_close(float(opponents[opponent_index].difficulty), float(Content.OPPONENT_DIFFICULTY_ANCHORS[era_index]), "Each era should start on its threat anchor")
	for collection in [Content.PITCHES, Content.BALL_UPGRADES, Content.MILESTONES]:
		var previous_cost := -1.0
		var previous_level := -1
		for definition in collection:
			var cost := float(definition.cost)
			_expect(cost > previous_cost, "%s costs should rise through its channel" % str(definition.name))
			_expect(int(definition.required_level) >= previous_level, "%s should appear in unlock-level order" % str(definition.name))
			previous_cost = cost
			previous_level = int(definition.required_level)

func _test_initial_balance_and_velocity_layers() -> void:
	var game: BaseballGameState = GameStateScript.new()
	game.rng.seed = 12345
	_expect_close(game.get_velocity_fps(), 1.0, "Initial velocity should be 1 ft/s")
	_expect_close(game.get_pitch_rate(), 0.25, "Initial cadence should be one pitch per four seconds")
	_expect(game.get_strikes_per_batter() == 3, "Human baseball should start with three strikes")
	_expect_close(game.get_pitch_distance_feet(), 3.0, "Initial mound should be 3 feet")
	_expect_close(game.get_physical_flight_seconds(), 3.0, "The opening lob should take three seconds")
	_expect_close(game.get_batter_cooldown_multiplier(), 1.0, "Fresh batter cooldown should use the full stated delay")
	_expect_close(game.get_base_batter_turnover_seconds(), 3.0, "Fresh lineup time should be three seconds")
	_expect_close(game.get_hit_delay_factor(), 1.0, "Fresh fair-hit delay should be unmodified")
	_expect_close(game.get_pitch_cycle_progress(), 0.0, "The opening pitch meter should begin empty")
	game.pitch_credit = 0.50
	_expect_close(game.get_pitch_cycle_progress(), 0.50, "The pitch meter should expose authoritative release credit")
	_expect_close(game.get_seconds_until_next_pitch(), 2.0, "Half of the opening four-second wind-up should leave two seconds")
	game.batter_cooldown_remaining = 1.0
	_expect_close(game.get_pitch_cycle_progress(), 0.0, "The pitch meter should clear while the plate is empty")
	game.batter_cooldown_remaining = 0.0
	game.pitch_credit = 0.0
	game.training_levels.turnover = 1
	_expect_close(game.get_base_batter_turnover_seconds(), 2.85, "One Lineup Hustle rank should remove 0.15 seconds")
	_expect_close(game.get_batter_cooldown_multiplier(), 0.95, "The compatibility cooldown ratio should follow base lineup time")
	game.training_levels.hit_recovery = 1
	_expect_close(game.get_outcome_turnover_bonus(4), 0.95, "Shake It Off should reduce only a fair hit's extra delay")
	_expect_close(game.get_outcome_turnover_bonus(Content.BALL_INDEX), 1.0, "Shake It Off must not reduce a walk's non-hit delay")
	game.training_levels.turnover = 0
	game.training_levels.hit_recovery = 0
	var probabilities: Array[float] = game.get_outcome_probabilities()
	var total := 0.0
	for probability in probabilities:
		total += probability
		_expect(probability >= 0.0 and probability <= 1.0, "Outcome probability outside [0, 1]")
	_expect_close(total, 1.0, "Outcome probabilities must sum to one")
	_expect(probabilities.size() == 8, "The outcome model should include fair hits, Fouls, Balls, and Strikes")
	_expect(probabilities[Content.STRIKE_INDEX] > 0.20 and probabilities[Content.STRIKE_INDEX] < 0.40, "The opening strike chance should be poor but viable")
	var opening_contact := 0.0
	for outcome in Content.FOUL_INDEX + 1:
		opening_contact += probabilities[outcome]
	_expect(opening_contact > 0.50, "The toddler should still make contact most of the time")
	_expect(probabilities[Content.FOUL_INDEX] > 0.0 and probabilities[Content.BALL_INDEX] > 0.0, "Opening baseball should already include Fouls and Balls")
	_expect(game.get_strikeout_chance_per_at_bat() > 0.01, "The opening pitcher must have a real chance to finish a three-strike count")
	var opening_pitch_entries := game.get_pitch_selection_entries()
	_expect(opening_pitch_entries.size() == 1 and str(opening_pitch_entries[0].id) == "dead_fish", "The fresh pitcher should only call the learned Dead-Fish Lob")
	var dead_fish_speed := game.get_pitch_speed_range("dead_fish")
	_expect_close(dead_fish_speed.x, 1.0, "The opening pitch-speed range should start at exactly 1 ft/s")
	_expect_close(dead_fish_speed.y, 1.0, "The opening pitch-speed range should end at exactly 1 ft/s")
	game.unlocked_pitches.append("four_seam")
	var neutral_calling := game.get_pitch_selection_entries()
	_expect(neutral_calling.size() == 2 and is_equal_approx(float(neutral_calling[0].probability), 0.5), "Learned pitches should be selected uniformly before Pitch Calling training")
	game.training_levels.pitch_calling = 1
	var trained_calling := game.get_pitch_selection_entries()
	_expect(float(trained_calling[1].probability) > float(trained_calling[0].probability), "Pitch Calling should favor the stronger learned pitch without disabling weaker pitches")
	game.training_levels.pitch_calling = 0

	game.training_levels.velocity = 1000
	game.purchased_milestones = ["regulation_ball", "weighted_balls", "steroids"]
	_expect_close(game.get_velocity_fps(), BaseballGameState.HUMAN_SPEED_CAP_FPS, "Unmodified biology must stop at 211.6 mph")
	game.current_opponent = Content.HUMAN_FINAL_INDEX
	game.highest_unlocked = Content.HUMAN_FINAL_INDEX
	_expect(not game.is_speed_gate_blocked(), "The exact human cap should satisfy Bambino Rex")
	game.training_levels.velocity = 0
	_expect(game.is_speed_gate_blocked(), "Bambino Rex should reject a sub-limit first attempt")
	_expect(game.get_outcome_probabilities() == [1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], "A failed velocity trial must be 100% Grand Slams")

	game.genetic_offer_unlocked = true
	game.genetic_rebirths = 1
	game.training_levels.velocity = 1000
	game.genetic_levels.fast_twitch_everything = 6
	_expect_close(game.get_velocity_fps(), BaseballGameState.ALIEN_SPEED_CAP_FPS, "Genetic bodies must stop at Mach 12")
	game.eldritch_offer_unlocked = true
	game.eldritch_ascensions = 1
	game.eldritch_levels.velocity_without_distance = 4
	_expect_close(game.get_velocity_fps(), BaseballGameState.SPEED_OF_LIGHT_FPS, "Eldritch pitching must stop at exactly 1c")
	_expect(BaseballGameState.format_speed(game.get_velocity_fps()).ends_with("c"), "Relativistic speed should use c notation")
	game.free()

func _test_pitch_phase_state_machine() -> void:
	var game: BaseballGameState = GameStateScript.new()
	game.rng.seed = 6006
	var release := game._resolve_elapsed(4.0, true, true)
	_expect_close(float(release.pitches), 0.0, "A release must not resolve before reaching the batter")
	_expect_close(float(release.released_pitches), 1.0, "The opening wind-up should release exactly one ball")
	_expect(release.pitch_events.size() == 1 and str(release.pitch_events[0].phase) == "release", "A launch should publish only a release event")
	_expect(str(release.pitch_events[0].pitch_id) == "dead_fish" and str(release.pitch_events[0].pitch_name) == "Dead-Fish Lob", "Every release should snapshot and announce its selected pitch")
	_expect_close(float(release.pitch_events[0].pitch_speed_fps), 1.0, "The first release should display an exact 1 ft/s speed")
	_expect(game.is_pitch_in_flight(), "A released opening lob should enter the immutable flight phase")
	_expect_close(game.pitch_flight_remaining, 3.0, "The opening three-foot lob should retain its full three-second flight")
	var frozen_remaining := game.pitch_flight_remaining
	var frozen_duration := game.pending_volley_flight_duration
	var frozen_speed := game.pending_volley_speed_fps
	var frozen_pitch := game.pending_volley_pitch_id
	game.training_levels.velocity = 20
	_expect_close(game.pitch_flight_remaining, frozen_remaining, "A speed purchase must not move an already released ball")
	game.highest_unlocked = 5
	_expect(game.set_distance_index(2), "The player should be able to move the mound while a pitch is flying")
	_expect_close(game.pitch_flight_remaining, frozen_remaining, "Moving the mound must not move an already released ball")
	_expect(game.pending_volley_distance_index == 0 and game.pending_volley_flight_duration == frozen_duration, "A released pitch must retain its original distance and duration")
	_expect(game.set_current_opponent(1), "The player should be able to select another unlocked batter during flight")
	_expect(game.pending_volley_pitch_id == frozen_pitch and game.pending_volley_speed_fps == frozen_speed, "Retargeting must preserve the released pitch type and exact speed")
	_expect(game.pending_volley_opponent_index == 1, "The released pitch should now resolve against the newly selected batter")
	game.pending_volley_outcome = Content.STRIKE_INDEX
	game.pending_volley_saved = false
	var during_flight := game._resolve_elapsed(2.9, true, true)
	_expect_close(float(during_flight.released_pitches), 0.0, "No second human ball may launch during flight")
	_expect_close(float(during_flight.pitches), 0.0, "A ball must remain unresolved until impact")
	var impact := game._resolve_elapsed(0.1, true, true)
	_expect_close(float(impact.pitches), 1.0, "Impact should resolve the one immutable opening ball")
	_expect(impact.pitch_events.size() == 1 and str(impact.pitch_events[0].phase) == "impact", "Impact should publish exactly one outcome event")
	_expect(int(impact.pitch_events[0].opponent_index) == 1 and int(impact.pitch_events[0].distance_index) == 0, "Impact should use the selected batter but the release-time distance")
	_expect(not game.is_pitch_in_flight() and is_zero_approx(game.pitch_credit), "Pitch cooldown must begin empty only after impact")
	var early_windup := game._resolve_elapsed(game.get_pitch_cooldown_seconds() * 0.90, true, true)
	_expect_close(float(early_windup.released_pitches), 0.0, "The next ball must respect the complete post-impact cooldown")
	var next_release := game._resolve_elapsed(game.get_pitch_cooldown_seconds() * 0.11, true, true)
	_expect_close(float(next_release.released_pitches), 1.0, "The next pitch should release only after the post-impact cooldown completes")
	game.pending_volley_outcome = Content.GRAND_SLAM_INDEX
	game.pending_volley_saved = false
	var terminal_impact := game._resolve_elapsed(game.pitch_flight_remaining, true, true)
	_expect_close(float(terminal_impact.pitches), 1.0, "The terminal ball should resolve at the plate")
	_expect_close(game.batter_cooldown_remaining, 12.0, "Grand Slam downtime must begin at impact, not release")
	var pitches_before_empty_plate := game.lifetime_pitches
	game.live_pitching_enabled = false
	game._resolve_elapsed(1.0, true, false)
	_expect_close(game.lifetime_pitches, pitches_before_empty_plate, "The pitcher must not throw while the visual plate is empty")
	_expect_close(game.batter_cooldown_remaining, 11.0, "The on-deck clock should continue while pitching is paused")
	game.free()

func _test_live_field_contract() -> void:
	var game: BaseballGameState = GameStateScript.new()
	game.rng.seed = 515151
	var field: PitchField = _make_field(game)
	game.batch_resolved.connect(field.notify_batch)
	var maximum_outbound := 0
	var empty_plate_frames := 0
	for _step in 500:
		field._process(0.10)
		var plate_ready_before_simulation := field.is_plate_ready_for_pitch()
		var serial_before := field.pitch_serial
		game.live_pitching_enabled = field.is_simulation_clock_available()
		game.advance(0.10)
		if game.is_pitch_in_flight():
			# Force long terminal gaps so this integration run repeatedly audits an
			# empty plate rather than depending on a fortunate random hit.
			game.pending_volley_outcome = Content.GRAND_SLAM_INDEX
			game.pending_volley_saved = false
		field.configure_from_game(game)
		maximum_outbound = maxi(maximum_outbound, field.get_rendered_pitch_count())
		if not plate_ready_before_simulation:
			empty_plate_frames += 1
			_expect(field.pitch_serial == serial_before, "The integrated pitcher launched while the plate or prior pitch was unavailable")
	_expect(field.pitch_serial >= 3, "The live field integration should complete several real pitch cycles")
	_expect(maximum_outbound <= 1, "Human live play must never render more than one unresolved outbound ball")
	_expect(empty_plate_frames > 20, "The integration audit should cover visible batter-replacement downtime")
	field.free()
	game.free()

func _test_distance_risk_and_reward() -> void:
	var game: BaseballGameState = GameStateScript.new()
	var near_probabilities: Array[float] = game.get_outcome_probabilities()
	_expect(game.get_max_distance_index() == 0, "Fresh players should only have the 3-foot mound")
	game.highest_unlocked = 5
	_expect(game.set_distance_index(2), "An unlocked farther mound should be selectable")
	_expect_close(game.get_pitch_distance_feet(), 12.0, "Backyard Challenge should be 12 feet")
	_expect_close(game.get_distance_xp_multiplier(), 1.6, "Farther ranges should multiply XP")
	_expect_close(game.get_distance_difficulty(), 0.45, "Farther ranges should add threat")
	_expect_close(game.get_physical_flight_seconds(), 12.0, "True flight time should be distance divided by speed")
	var far_probabilities: Array[float] = game.get_outcome_probabilities()
	_expect(far_probabilities[0] > near_probabilities[0], "Moving farther should make home runs more likely")
	game.set_distance_index(999)
	_expect(game.selected_distance_index == game.get_max_distance_index(), "Range selection must clamp to unlocked tiers")
	game.free()

func _test_overmastery_farming() -> void:
	var game: BaseballGameState = GameStateScript.new()
	var requirement := float(game.opponents[0].mastery_required)
	game.opponent_mastery[0] = requirement
	_expect_close(game.get_overmastery_doublings(), 0.0, "Mastery at the unlock target should not yet earn a farming bonus")
	_expect_close(game.get_opponent_farm_xp_multiplier(), 1.0, "The farming XP bonus should begin only past mastery")
	var base_probabilities := game.get_loot_rarity_probabilities()
	game.opponent_mastery[0] = requirement * 16.0
	_expect_close(game.get_overmastery_doublings(), 4.0, "Sixteen times the mastery target should equal four excess doublings")
	_expect_close(game.get_opponent_farm_xp_multiplier(), 1.05, "Each excess mastery doubling should add only a small XP bonus")
	_expect_close(game.get_opponent_loot_luck(), 0.20, "Loot luck should follow the same logarithmic mastery track")
	var farm_probabilities := game.get_loot_rarity_probabilities()
	_expect_close(farm_probabilities.reduce(func(total, value): return total + value, 0.0), 1.0, "Mastery-adjusted rarity odds must still sum to one")
	_expect(float(farm_probabilities[0]) < float(base_probabilities[0]), "Overmastery should reduce the Common share")
	_expect(
		float(farm_probabilities[3]) + float(farm_probabilities[4])
		> float(base_probabilities[3]) + float(base_probabilities[4]),
		"Overmastery should improve the odds of Legendary and Unique loot"
	)
	var baseline_game: BaseballGameState = GameStateScript.new()
	baseline_game.rng.seed = 5150
	baseline_game.opponent_mastery[0] = requirement
	var baseline_item := baseline_game._generate_loot_item(0, 0, 2)
	game.rng.seed = 5150
	var mastered_item := game._generate_loot_item(0, 0, 2)
	_expect(float(mastered_item.roll_quality) > float(baseline_item.roll_quality), "Overmastery should gently improve affix roll quality")
	_expect(int(mastered_item.item_level) == 1, "A mastered opening batter must still drop only level-one loot")
	game.opponent_mastery[7] = float(game.opponents[7].mastery_required) * 1.0e12
	var capped_item := game._generate_loot_item(7, 0, 4)
	_expect(int(capped_item.item_level) == 8, "Loot item level must remain capped to the batter being farmed")
	_expect(not game.get_overmastery_summary().is_empty(), "The active farming bonus should have a visible summary")
	baseline_game.free()
	game.free()

func _test_opponent_counters() -> void:
	var game: BaseballGameState = GameStateScript.new()
	game.highest_unlocked = 44
	game.genetic_offer_unlocked = true
	game.genetic_rebirths = 1
	game.eldritch_offer_unlocked = true
	game.eldritch_ascensions = 1
	game.current_opponent = 24
	var close_penalty := game.get_opponent_trait_penalty()
	game.selected_distance_index = 7
	_expect(game.get_opponent_trait_penalty() < close_penalty, "The Call-Up should reward regulation distance")
	game.current_opponent = 30
	game.genetic_levels.extra_arms = 0
	_expect_close(game.get_opponent_trait_penalty(), 0.75, "Xylophax should punish one throwing arm")
	game.genetic_levels.extra_arms = 1
	_expect_close(game.get_opponent_trait_penalty(), 0.0, "A second arm should answer Xylophax")
	game.current_opponent = 40
	game.eldritch_levels.time_compression = 0
	_expect_close(game.get_opponent_trait_penalty(), 0.80, "N'Kthra should punish one time layer")
	game.eldritch_levels.time_compression = 1
	_expect_close(game.get_opponent_trait_penalty(), 0.0, "A second time layer should answer N'Kthra")
	game.current_opponent = 44
	game.genetic_levels.extra_arms = 0
	game.eldritch_levels.mirror_clones = 0
	game.eldritch_levels.time_compression = 0
	var sparse_penalty := game.get_opponent_trait_penalty()
	game.genetic_levels.extra_arms = 3
	game.eldritch_levels.mirror_clones = 5
	game.eldritch_levels.time_compression = 3
	_expect(game.get_opponent_trait_penalty() < sparse_penalty, "Octathulhu should weaken against the complete bullpen")
	game.free()

func _test_opponent_variants() -> void:
	var game: BaseballGameState = GameStateScript.new()
	var opening := game.get_current_batter_variant()
	var opening_loadout: Array = opening.loadout
	_expect(str(opening.name) == "Little Timmy" and str(opening.class_name) == "Wiffle-Bat Toddler", "The UI should separate an individual's name from the reusable class")
	_expect(opening_loadout.size() == 2, "The first toddler should expose only body and bat on the opponent side")
	_expect(str(opening_loadout[0].id) == "body" and str(opening_loadout[1].id) == "bat", "Opponent body and bat should lead the vertical loadout")
	var first_bonus := game.get_opponent_variant_difficulty()
	game.batter_replacement_pending = true
	game._complete_batter_replacement()
	var replacement := game.get_current_batter_variant()
	_expect(str(replacement.name) != str(opening.name), "Each replacement batter should receive a new individual name")
	_expect(not is_equal_approx(float(replacement.difficulty_bonus), first_bonus), "Replacement bodies and equipment should reroll their small threat modifiers")
	game.highest_unlocked = Content.HUMAN_FINAL_INDEX
	game.current_opponent = Content.HUMAN_FINAL_INDEX
	game._reset_batter_identity()
	_expect((game.get_current_batter_variant().loadout as Array).size() == 8, "An MLB champion should carry body, bat, and six mundane equipment slots")
	game.highest_unlocked = Content.ALIEN_EXHIBITION_INDEX
	game.current_opponent = Content.ALIEN_EXHIBITION_INDEX
	game._reset_batter_identity()
	var alien_loadout: Array = game.get_current_batter_variant().loadout
	_expect(alien_loadout.size() == 9 and str(alien_loadout.back().id) == "relic", "Post-human opponents should add the hidden Relic slot")
	game.free()

func _test_strikeout_only_economy() -> void:
	var game: BaseballGameState = GameStateScript.new()
	var strike_summary := game._empty_resolution_summary()
	game._apply_pitch_outcome(strike_summary, Content.STRIKE_INDEX)
	_expect(game.plate_strikes == 1 and float(strike_summary.strikeouts) == 0.0, "Strike one should preserve the batter and pay nothing")
	game._apply_pitch_outcome(strike_summary, Content.STRIKE_INDEX)
	_expect(game.plate_strikes == 2 and float(strike_summary.strikeouts) == 0.0, "Strike two should preserve the batter and pay nothing")
	game._apply_pitch_outcome(strike_summary, Content.STRIKE_INDEX)
	_expect(game.plate_strikes == 0 and float(strike_summary.strikeouts) == 1.0, "Only strike three should complete a human strikeout")
	game._apply_resolution(strike_summary, false)
	_expect_close(float(strike_summary.earned_xp), 15.0, "A three-strike human out should pay 3 × 5 base XP")
	_expect_close(game.xp, 15.0, "The completed strikeout should be the only banked XP")
	_expect_close(game.lifetime_strikeouts, 1.0, "Completed strikeouts should have their own lifetime statistic")
	var strike_events: Array = strike_summary.pitch_events
	_expect(strike_events.size() == 3, "Exact simulation should publish one render event per physical pitch")
	_expect(bool(strike_events.back().strikeout), "The terminal pitch event should snapshot its strikeout")

	var hit_game: BaseballGameState = GameStateScript.new()
	hit_game.plate_strikes = 2
	var hit_summary := hit_game._empty_resolution_summary()
	hit_game._apply_pitch_outcome(hit_summary, 4)
	hit_game._apply_resolution(hit_summary, false)
	_expect(hit_game.plate_strikes == 0, "An unprotected single should erase the count")
	_expect_close(hit_game.batter_cooldown_remaining, 4.0, "A single should create the three-second base change plus one extra second")
	_expect_close(hit_game.xp, 0.0, "A hit must never award XP")

	var count_game: BaseballGameState = GameStateScript.new()
	count_game.plate_strikes = 1
	count_game.plate_balls = 2
	var foul_summary := count_game._empty_resolution_summary()
	count_game._apply_pitch_outcome(foul_summary, Content.FOUL_INDEX)
	_expect(count_game.plate_strikes == 2 and count_game.plate_balls == 2, "A Foul should add a strike while preserving the Ball count")
	count_game._apply_pitch_outcome(foul_summary, Content.FOUL_INDEX)
	_expect(count_game.plate_strikes == 2 and float(foul_summary.strikeouts) == 0.0, "A Foul must never provide strike three")
	var walk_summary := count_game._empty_resolution_summary()
	count_game.plate_balls = 3
	count_game._apply_pitch_outcome(walk_summary, Content.BALL_INDEX)
	_expect(bool(walk_summary.pitch_events.back().walk), "Ball four should explicitly produce a walk")
	_expect(count_game.plate_strikes == 0 and count_game.plate_balls == 0, "A walk should reset the complete count")
	_expect_close(count_game.batter_cooldown_remaining, 4.0, "A walk should use the same replacement delay as a Single")
	count_game._apply_resolution(walk_summary, false)
	_expect_close(count_game.xp, 0.0, "A walk must never award XP")
	_expect(count_game.get_balls_required() == 4, "Human baseball should require four Balls")
	count_game.current_opponent = 35
	_expect(count_game.get_balls_required() == 3, "Interstellar batters should walk after three Balls")
	count_game.current_opponent = Content.FINAL_BOSS_INDEX
	_expect(count_game.get_balls_required() == 2, "The final gods should walk after only two Balls")

	var protected_game: BaseballGameState = GameStateScript.new()
	protected_game.genetic_levels.prehensile_outfield = 1
	protected_game.plate_strikes = 2
	var protected_summary := protected_game._empty_resolution_summary()
	protected_game._apply_pitch_outcome(protected_summary, 4)
	protected_game._apply_resolution(protected_summary, false)
	_expect(protected_game.plate_strikes == 2, "A protected single should hold the count")
	_expect_close(float(protected_summary.saved_hits), 1.0, "A protected hit should be recorded as saved")
	_expect_close(protected_game.batter_cooldown_remaining, 0.0, "A saved hit should not empty the plate")

	protected_game.divine_blessings = ["angels_outfield"]
	protected_game.plate_strikes = 2
	var slam_summary := protected_game._empty_resolution_summary()
	protected_game._apply_pitch_outcome(slam_summary, Content.GRAND_SLAM_INDEX)
	_expect(protected_game.plate_strikes == 0, "A Grand Slam must defeat even divine hit protection")
	_expect_close(float(slam_summary.saved_hits), 0.0, "A Grand Slam can never be saved")
	_expect_close(protected_game.batter_cooldown_remaining, 12.0, "A Grand Slam should impose the longest empty-plate delay")

	var clone_game: BaseballGameState = GameStateScript.new()
	clone_game.eldritch_levels.mirror_clones = 1
	_expect_close(clone_game.get_hit_save_chance(1), 0.40, "One mirror-clone rank should catch 40% of ordinary hits")
	clone_game.eldritch_levels.portal_outfield = 1
	_expect_close(clone_game.get_hit_save_chance(1), 0.52, "Clone and portal saves should combine independently")
	_expect_close(clone_game.get_hit_save_chance(Content.GRAND_SLAM_INDEX), 0.0, "Grand Slams must bypass clones and portals")

	clone_game.current_opponent = 34
	_expect(clone_game.get_base_strikes_required() == 6, "The fifth alien should demand six unmodified strikes")
	clone_game.genetic_levels.compressed_strike_genome = 3
	_expect(clone_game.get_strikes_required() == 3, "Maximum count compression should reduce six post-human strikes to three")
	_expect_close(clone_game.get_strikeout_base_points(), 30.0, "Count compression should retain the six-strike bounty")
	clone_game.current_opponent = Content.HUMAN_FINAL_INDEX
	_expect(clone_game.get_strikes_required() == 3, "Genetics must never alter human baseball's three-strike rule")

	var stalled_live_game: BaseballGameState = GameStateScript.new()
	stalled_live_game.highest_unlocked = Content.ALIEN_EXHIBITION_INDEX
	stalled_live_game.current_opponent = Content.ALIEN_EXHIBITION_INDEX
	var stalled_summary := stalled_live_game._resolve_elapsed(30.0, true, true)
	_expect_close(float(stalled_summary.pitches), 0.0, "A long live frame must release without prematurely resolving its hidden result")
	_expect_close(float(stalled_summary.released_pitches), 1.0, "A stalled live frame must release only one human ball")
	_expect(stalled_summary.pitch_events.size() == 1 and str(stalled_summary.pitch_events[0].phase) == "release", "A stalled frame should emit one release and no advance knowledge")
	_expect_close(stalled_live_game.batter_cooldown_remaining, 0.0, "Batter cooldown must not begin before the released ball impacts")
	_expect(stalled_live_game.is_pitch_in_flight(), "The stalled-frame ball should remain the only authoritative live projectile")

	game.free()
	hit_game.free()
	count_game.free()
	protected_game.free()
	clone_game.free()
	stalled_live_game.free()

func _test_loot_item(
	item_id: String,
	slot: String,
	item_level: int,
	rarity: int,
	stats: Dictionary
) -> Dictionary:
	return {
		"id": item_id,
		"slot": slot,
		"item_level": item_level,
		"rarity": rarity,
		"name": "%s Test Gear" % item_id,
		"stats": stats.duplicate(true),
		"roll_quality": 1.0,
		"color": "ffffff",
		"favorite": false,
	}

func _test_strikeout_loot_and_equipment() -> void:
	var first_drop_game: BaseballGameState = GameStateScript.new()
	first_drop_game.rng.seed = 404
	var first_summary := first_drop_game._empty_resolution_summary()
	for _strike in 3:
		first_drop_game._apply_pitch_outcome(first_summary, Content.STRIKE_INDEX)
	first_drop_game._apply_resolution(first_summary, false)
	_expect(int(first_summary.loot_found) == 1, "The first career strikeout should teach loot with one guaranteed drop")
	_expect(first_drop_game.loot_items.size() == 1, "The tutorial drop should enter the locker")
	var tutorial_hat: Dictionary = first_drop_game.loot_items[0]
	_expect(str(tutorial_hat.name) == "Little Timmy's Oversized Cap", "The first loot item should be the named tutorial cap")
	_expect(str(tutorial_hat.slot) == "hat" and int(tutorial_hat.rarity) == 0, "The tutorial cap should be a Common hat")
	_expect(str(first_drop_game.equipped_loot.hat) == str(tutorial_hat.id), "An empty slot should auto-equip its first drop")

	var hit_game: BaseballGameState = GameStateScript.new()
	var hit_summary := hit_game._empty_resolution_summary()
	hit_game._apply_pitch_outcome(hit_summary, Content.GRAND_SLAM_INDEX)
	hit_game._apply_resolution(hit_summary, false)
	_expect(int(hit_summary.loot_found) == 0 and hit_game.loot_items.is_empty(), "Hits must never roll strikeout loot")

	var disabled_game: BaseballGameState = GameStateScript.new()
	disabled_game.loot_drops_enabled = false
	var disabled_summary := disabled_game._empty_resolution_summary()
	disabled_game._resolve_strikeout_loot(100.0, 60.0, disabled_summary)
	_expect(disabled_game.loot_items.is_empty(), "The deterministic no-loot audit switch should suppress every drop")

	var pity_game: BaseballGameState = GameStateScript.new()
	pity_game.rng.seed = 405
	pity_game.lifetime_loot_found = 1.0
	pity_game.loot_dry_streak = BaseballGameState.LOOT_PITY_ROLLS - 1
	var pity_summary := pity_game._empty_resolution_summary()
	pity_game._resolve_strikeout_loot(1.0, 0.0, pity_summary)
	_expect(int(pity_summary.loot_found) == 1, "The tenth eligible dry roll should guarantee a parcel")

	var tier_game: BaseballGameState = GameStateScript.new()
	tier_game.rng.seed = 406
	for rarity_index in Content.LOOT_RARITIES.size():
		var item := tier_game._generate_loot_item(44, rarity_index % Content.LOOT_SLOTS.size(), rarity_index)
		var rarity: Dictionary = Content.LOOT_RARITIES[rarity_index]
		_expect(item.stats.size() == int(rarity.affix_count) + 1, "%s gear should have its primary stat plus the advertised affixes" % str(rarity.name))
		_expect(not str(item.name).is_empty(), "Every generated loot tier needs a readable name")

	var cap_game: BaseballGameState = GameStateScript.new()
	cap_game.highest_unlocked = Content.FINAL_BOSS_INDEX
	cap_game.genetic_offer_unlocked = true
	var excessive_stats := {
		"speed_bonus": 0.90,
		"rate_bonus": 0.90,
		"quality_bonus": 0.90,
		"xp_bonus": 0.90,
		"mastery_bonus": 0.90,
		"distance_bonus": 0.90,
	}
	for slot_index in Content.LOOT_SLOTS.size():
		var slot := str(Content.LOOT_SLOTS[slot_index].id)
		cap_game._add_loot_item(_test_loot_item("cap_%d" % slot_index, slot, 45, 4, excessive_stats))
	var capped := cap_game.get_raw_equipment_bonuses()
	for stat_id in BaseballGameState.EQUIPMENT_CAPS:
		_expect_close(float(capped[stat_id]), float(BaseballGameState.EQUIPMENT_CAPS[stat_id]), "Total equipment %s should stop at its moderate cap" % str(stat_id))
	cap_game.genetic_rebirths = 1
	cap_game.eldritch_ascensions = 1
	cap_game.training_levels.velocity = 1000
	cap_game.genetic_levels.fast_twitch_everything = 6
	cap_game.eldritch_levels.velocity_without_distance = 4
	for milestone_definition in Content.MILESTONES:
		cap_game.purchased_milestones.append(str(milestone_definition.id))
	_expect_close(cap_game.get_body_velocity_fps(), BaseballGameState.SPEED_OF_LIGHT_FPS, "The final body should still stop at 1c")
	_expect_close(cap_game.get_velocity_fps(), BaseballGameState.SPEED_OF_LIGHT_FPS * 1.15, "Equipment should provide a small, optional post-body-cap overage")
	cap_game.eldritch_levels.mirror_clones = 2
	_expect_close(cap_game.get_equipment_inheritance_factor(), 0.25, "Four unlinked pitchers should each receive one quarter of the original's gear bonus")
	_expect_close(float(cap_game.get_equipment_bonuses().speed_bonus), 0.15 / 4.0, "Unlinked clone gear should dilute the capped bonus")
	cap_game.eldritch_levels.clone_dress_code = 1
	_expect_close(cap_game.get_equipment_inheritance_factor(), 1.0, "Clone Dress Code should copy the complete loadout")
	_expect_close(float(cap_game.get_equipment_bonuses().speed_bonus), 0.15, "Linked clones should receive the full capped bonus")
	var geared_field: PitchField = _make_field(cap_game)
	_expect(geared_field.snapshot.gear_colors.size() == Content.LOOT_SLOTS.size(), "Every equipped slot should tint the abstract pitcher")
	_expect(bool(geared_field.snapshot.clone_gear_linked), "The field should know when clone equipment is inherited")
	geared_field.free()

	var capacity_game: BaseballGameState = GameStateScript.new()
	capacity_game._add_loot_item(_test_loot_item("protected", "hat", 1, 0, {"quality_bonus": 0.01}))
	capacity_game._add_loot_item(_test_loot_item("favorite", "hat", 1, 0, {"quality_bonus": 0.01}))
	_expect(capacity_game.toggle_loot_favorite("favorite"), "A stored item should be star-protectable")
	capacity_game._add_loot_item(_test_loot_item("weak_common", "hat", 1, 0, {"quality_bonus": 0.010}))
	capacity_game._add_loot_item(_test_loot_item("weak_magic", "hat", 1, 1, {"quality_bonus": 0.005}))
	for item_index in 12:
		capacity_game._add_loot_item(_test_loot_item("better_%02d" % item_index, "hat", 2, 0, {"quality_bonus": 0.020}))
	_expect(capacity_game.get_loot_items_for_slot("hat").size() == BaseballGameState.LOOT_ITEMS_PER_SLOT, "Each slot should retain exactly ten items")
	_expect(not capacity_game.get_loot_item("protected").is_empty(), "The equipped item must be protected from automatic pruning")
	_expect(not capacity_game.get_loot_item("favorite").is_empty(), "A starred item must be protected from automatic pruning")
	_expect(capacity_game.get_loot_item("weak_common").is_empty(), "Overflow should remove a low-Power unstarred item")
	_expect(capacity_game.get_loot_item("weak_magic").is_empty(), "Rarity must not protect the lowest-Power unstarred item")
	var sorted_hats := capacity_game.get_loot_items_for_slot("hat")
	_expect(capacity_game.get_loot_item_power(sorted_hats[0]) >= capacity_game.get_loot_item_power(sorted_hats.back()), "Locker items should sort from highest Power to lowest")

	var auto_gear_game: BaseballGameState = GameStateScript.new()
	auto_gear_game._add_loot_item(_test_loot_item("auto_weak", "hat", 1, 0, {"quality_bonus": 0.01}))
	auto_gear_game._add_loot_item(_test_loot_item("auto_strong", "hat", 1, 0, {"quality_bonus": 0.03}))
	_expect(str(auto_gear_game.equipped_loot.hat) == "auto_weak", "Without the prestige upgrade, a new sidegrade should not silently replace equipment")
	auto_gear_game.genetic_offer_unlocked = true
	auto_gear_game.dna = 5
	_expect(auto_gear_game.buy_genetic("autonomic_wardrobe"), "Autonomic Wardrobe should be purchasable after genetic prestige")
	_expect(str(auto_gear_game.equipped_loot.hat) == "auto_strong", "Buying Autonomic Wardrobe should immediately equip the highest-Power item")
	auto_gear_game._add_loot_item(_test_loot_item("auto_best", "hat", 1, 0, {"quality_bonus": 0.05}))
	_expect(str(auto_gear_game.equipped_loot.hat) == "auto_best", "Autonomic Wardrobe should react to a stronger new drop")

	var wipe_game: BaseballGameState = GameStateScript.new()
	wipe_game._add_loot_item(_test_loot_item("futureless", "hat", 10, 2, {"quality_bonus": 0.02}))
	wipe_game.genetic_offer_unlocked = true
	wipe_game.highest_unlocked = Content.ALIEN_EXHIBITION_INDEX
	wipe_game.run_xp = BaseballGameState.DNA_XP_THRESHOLD
	_expect(wipe_game.perform_genetic_rebirth() == 1, "The loot reset test should complete a genetic rebirth")
	_expect(wipe_game.loot_items.is_empty(), "Ordinary equipment should be left behind during genetic time travel")

	var wardrobe_game: BaseballGameState = GameStateScript.new()
	wardrobe_game.rng.seed = 407
	wardrobe_game.eldritch_levels.reverse_terminator = 2
	wardrobe_game.genetic_offer_unlocked = true
	wardrobe_game.highest_unlocked = Content.ALIEN_EXHIBITION_INDEX
	for slot_index in Content.LOOT_SLOTS.size():
		var slot := str(Content.LOOT_SLOTS[slot_index].id)
		wardrobe_game._add_loot_item(_test_loot_item("wardrobe_%d" % slot_index, slot, 20, 2, {str(Content.LOOT_SLOTS[slot_index].primary_stat): 0.02}))
	wardrobe_game.run_xp = BaseballGameState.DNA_XP_THRESHOLD
	wardrobe_game.perform_genetic_rebirth()
	_expect(wardrobe_game.loot_items.size() == 2 and wardrobe_game.get_equipped_loot_count() == 2, "Reverse Terminator rank two should preserve exactly two equipped pieces")
	_expect(wardrobe_game.last_time_travel_retained_slots.size() == 2, "Reverse Terminator should report the two randomly selected slots")

	var reality_game: BaseballGameState = GameStateScript.new()
	reality_game.eldritch_levels.reverse_terminator = 7
	reality_game.eldritch_offer_unlocked = true
	reality_game.highest_unlocked = Content.ELDRITCH_EXHIBITION_INDEX
	reality_game._add_loot_item(_test_loot_item("doomed_relic", "relic", 45, 4, {"mastery_bonus": 0.08}))
	reality_game.reality_dna_earned = 1.0
	_expect(reality_game.perform_eldritch_ascension() == 1, "The loot reset test should complete an eldritch ascension")
	_expect(reality_game.loot_items.is_empty(), "Destroying reality should erase even Reverse-Terminator equipment")

	var saved_game: BaseballGameState = GameStateScript.new()
	saved_game._add_loot_item(_test_loot_item("saved_cleats", "cleats", 17, 3, {"distance_bonus": 0.04, "speed_bonus": 0.02}))
	saved_game.toggle_loot_favorite("saved_cleats")
	saved_game.lifetime_loot_found = 12.0
	var loaded_game: BaseballGameState = GameStateScript.new()
	loaded_game.apply_save_data(saved_game.to_save_data())
	_expect(not loaded_game.get_loot_item("saved_cleats").is_empty(), "Locker contents should survive a save round-trip")
	_expect(str(loaded_game.equipped_loot.cleats) == "saved_cleats", "Equipped slots should survive a save round-trip")
	_expect(bool(loaded_game.get_loot_item("saved_cleats").favorite), "Star protection should survive a save round-trip")
	_expect_close(loaded_game.lifetime_loot_found, 12.0, "Lifetime loot statistics should survive saves")

	var slot_gate_game: BaseballGameState = GameStateScript.new()
	_expect(not slot_gate_game.is_loot_slot_unlocked("relic"), "The Relic slot should start locked")
	for drop_index in 100:
		_expect(str(slot_gate_game._generate_loot_item(0).slot) != "relic", "Human batters must never drop post-human Relics")
	slot_gate_game.highest_unlocked = Content.ALIEN_EXHIBITION_INDEX
	slot_gate_game.genetic_offer_unlocked = true
	_expect(slot_gate_game.is_loot_slot_unlocked("relic"), "Finishing human baseball should unlock the Relic slot")
	var post_human_relic := slot_gate_game._generate_loot_item(30, 6, 0)
	_expect(str(post_human_relic.slot) == "relic" and int(post_human_relic.item_level) == 31, "The first alien should be able to drop a level-31 Relic")

	first_drop_game.free()
	hit_game.free()
	disabled_game.free()
	pity_game.free()
	tier_game.free()
	cap_game.free()
	capacity_game.free()
	auto_gear_game.free()
	wipe_game.free()
	wardrobe_game.free()
	reality_game.free()
	saved_game.free()
	loaded_game.free()
	slot_gate_game.free()

func _make_field(game: BaseballGameState) -> PitchField:
	var field: PitchField = PitchFieldScript.new()
	field.size = Vector2(900.0, 420.0)
	field._setup_ball_stream()
	field._setup_range_arrows()
	field.configure_from_game(game)
	return field

func _test_projectile_snapshots() -> void:
	var game: BaseballGameState = GameStateScript.new()
	var field: PitchField = _make_field(game)
	_expect(field.is_rendering_one_to_one(), "The opening should render every physical pitch")
	_expect(field.should_draw_pitch_cooldown_meter(), "A readable opening cadence should show the pitcher wind-up meter")
	_expect_close(field.last_pitch_speed_fps, 1.0, "The field should begin with a visible 1 ft/s pitch-speed readout")
	_expect(field.get_ball_limit() == 4 and field.get_remaining_ball_icons() == 4, "The opening batter should expose a four-Ball walk meter")
	game.pitch_credit = 0.50
	field.configure_from_game(game)
	_expect_close(field.get_pitch_cooldown_progress(), 0.50, "The field wind-up dial should mirror authoritative release credit")
	_expect_close(field._get_pitch_cycle_rate(), game.get_pitch_rate(), "The wind-up dial should use active physical pitch rate, not turnover-diluted output")
	_expect_close((1.0 - field.get_pitch_cooldown_progress()) / field._get_pitch_cycle_rate(), 2.0, "A half-filled opening dial should show two seconds to release")
	game.pitch_credit = 0.0
	field.configure_from_game(game)
	_expect(field._get_camera_scale() > 3.5, "The opening should use the extra-close camera")
	var pitcher_radius := field._get_pitcher_visual_scale() * 10.0
	var toddler_radius := field._get_batter_intrinsic_size() * field._get_camera_scale() * 10.0
	_expect(pitcher_radius / toddler_radius > 1.45 and pitcher_radius / toddler_radius < 1.65, "The opening pitcher should be roughly fifty percent larger than the toddler")
	_expect(field.move_closer_arrow.disabled and field.move_farther_arrow.disabled, "Locked mound arrows should be disabled")
	var untouched_slot := field.next_ball_slot
	field._process(8.0)
	_expect(field.next_ball_slot == untouched_slot, "Frame time alone must never manufacture a visual pitch")
	field._spawn_pitch(0.0)
	_expect(field.should_draw_pitch_cooldown_meter(), "The wind-up meter should remain visible while an earlier pitch is in flight")
	var original_data: Dictionary = field.get_launch_snapshot(0)
	_expect(absf(float(original_data.signed_curve)) < 0.01, "Opening pitches should be nearly straight")
	_expect_close(float(original_data.trail_length), 1.0, "A one-arm opening pitch must render as one ball without a fake missile trail")
	_expect(float(original_data.projectile_scale) > 2.5, "Opening balls should scale with the tighter camera")
	var opening_mound := field._get_mound_position(game.get_pitch_distance_feet())
	var release_offset := Vector2(original_data.source) - opening_mound
	_expect(release_offset.length() < field._get_pitcher_visual_scale() * 19.0, "The rectangular throwing arm and release should stay compact")
	_expect(release_offset.length() > field._get_pitcher_visual_scale() * 10.0, "The release point should sit just beyond the pitcher ring")
	_expect(release_offset.is_equal_approx(field._get_arm_release_offset(0, 1)), "The ball should originate at the drawn hand")
	var resting_arm: Dictionary = field._get_throw_arm_geometry(0, 1, 0.0)
	var releasing_arm: Dictionary = field._get_throw_arm_geometry(0, 1, 1.0)
	_expect(Vector2(releasing_arm.end).length() > Vector2(resting_arm.end).length(), "The rectangular arm should move forward to release")
	_expect(absf(Vector2(releasing_arm.end).angle()) < absf(Vector2(resting_arm.end).angle()), "The rectangular arm should point toward the plate at release")
	field._process(float(original_data.duration) + 0.01)
	_expect(field.get_rendered_pitch_count() == 0, "Expired projectile slots must be explicitly retired")
	_expect_close(field.ball_multimesh.get_instance_custom_data(0).g, 0.0, "An expired GPU instance must have zero stored duration")
	var resting_bat_angle := field._get_bat_shaft_angle(0, 1, 0.0)
	var contact_bat_angle := field._get_bat_shaft_angle(0, 1, 1.0)
	_expect(cos(resting_bat_angle) > 0.0 and cos(contact_bat_angle) < 0.0, "The bat should swing toward the incoming ball")

	game.training_levels.velocity = 24
	game.training_levels.distance_control = 6
	game.highest_unlocked = 5
	field.configure_from_game(game)
	_expect(float(field.snapshot.pitcher_size_multiplier) > 1.0 and float(field.snapshot.pitcher_size_multiplier) < 2.0, "Pitcher size should grow smoothly with strength without reaching an uncapped scale")
	_expect(not field.move_farther_arrow.disabled, "The farther arrow should activate after a range unlock")
	var unchanged_data: Dictionary = field.get_launch_snapshot(0)
	_expect_close(float(unchanged_data.duration), float(original_data.duration), "An in-flight ball must keep its release-time duration")
	_expect_close(float(unchanged_data.signed_curve), float(original_data.signed_curve), "An in-flight ball must keep its release-time arc")
	_expect(Vector2(unchanged_data.source).is_equal_approx(Vector2(original_data.source)), "An in-flight ball must keep its source")
	field._spawn_pitch(0.0)
	var upgraded_data: Dictionary = field.get_launch_snapshot(1)
	_expect(float(upgraded_data.duration) < float(original_data.duration), "A speed upgrade should affect only newly released pitches")

	game.genetic_levels.extra_arms = 1
	game.genetic_rebirths = 1
	game.genetic_levels.parallel_pitching_lobes = 1
	field.configure_from_game(game)
	field.spawn_credit = 0.0
	var volley_start := field.next_ball_slot
	var volley_launched := field.notify_batch({
		"pitches": 0.0,
		"released_pitches": 2.0,
		"elapsed_seconds": 0.1,
		"pitch_events": [
			{"phase": "release", "elapsed_offset": 0.1, "ball_count": 2, "flight_seconds": field.travel_time},
		],
	})
	var left_arm_pitch: Dictionary = field.get_launch_snapshot(volley_start)
	var right_arm_pitch: Dictionary = field.get_launch_snapshot((volley_start + 1) % PitchField.MAX_VISUAL_BALLS)
	_expect(volley_launched == 2, "Two authoritative release events should draw exactly two balls")
	_expect(not left_arm_pitch.is_empty() and not right_arm_pitch.is_empty(), "Two arms should release a complete two-ball volley")
	_expect_close(float(left_arm_pitch.spawn_time), float(right_arm_pitch.spawn_time), "Balls from one multi-arm throw should launch simultaneously")
	_expect(not Vector2(left_arm_pitch.source).is_equal_approx(Vector2(right_arm_pitch.source)), "Each arm should release from its own hand")
	field.notify_batch({
		"pitches": 2.0,
		"elapsed_seconds": 0.1,
		"pitch_events": [{"phase": "impact", "outcome": Content.STRIKE_INDEX, "strike_count": 2, "strikeout": false, "ball_count": 2}],
	})
	field.batter_phase = "waiting"
	field.batter_phase_duration = 5.0
	field.batter_phase_age = 1.0
	var empty_plate_slot := field.next_ball_slot
	var empty_plate_launches := field.notify_batch({
		"pitches": 0.0,
		"released_pitches": 1.0,
		"elapsed_seconds": 0.1,
		"pitch_events": [{"phase": "release", "elapsed_offset": 0.1, "ball_count": 1, "flight_seconds": 1.0}],
	})
	_expect(empty_plate_launches == 0 and field.next_ball_slot == empty_plate_slot, "The pitcher must not throw while the plate is empty")
	_expect(not field.should_draw_pitch_cooldown_meter(), "The pitcher meter must yield to the on-deck meter at an empty plate")
	field.batter_phase = "active"
	field.batter_phase_age = 0.0
	field.batter_phase_duration = 0.0
	var loaded_cooldown_game: BaseballGameState = GameStateScript.new()
	loaded_cooldown_game.batter_cooldown_remaining = 2.5
	var loaded_cooldown_field: PitchField = _make_field(loaded_cooldown_game)
	_expect(loaded_cooldown_field.batter_phase == "waiting", "A loaded replacement delay must restore an empty visual plate")
	_expect(loaded_cooldown_field.get_current_batter_name().begins_with("ON DECK:"), "A loaded replacement delay should name the on-deck batter")
	_expect_close(loaded_cooldown_field.get_batter_arrival_progress(), 0.0, "A loaded arrival timer should begin empty")
	loaded_cooldown_field.free()
	loaded_cooldown_game.free()
	var terminal_game: BaseballGameState = GameStateScript.new()
	var terminal_field: PitchField = _make_field(terminal_game)
	var terminal_launches := terminal_field.notify_batch({
		"pitches": 0.0,
		"released_pitches": 1.0,
		"elapsed_seconds": 0.1,
			"pitch_events": [{"phase": "release", "elapsed_offset": 0.1, "ball_count": 1, "flight_seconds": 3.0, "pitch_id": "dead_fish", "pitch_name": "Dead-Fish Lob", "pitch_speed_fps": 1.0}],
		})
	_expect(terminal_launches == 1 and not terminal_field.is_plate_ready_for_pitch(), "Any immutable ball in flight should reserve the batter without revealing its result")
	_expect(terminal_field.last_pitch_name == "DEAD-FISH LOB" and terminal_field.pitch_call_age == 0.0, "A release should create a named pitch call over the pitcher")
	_expect_close(terminal_field.last_pitch_speed_fps, 1.0, "A release should update the exact visible pitch speed")
	var blocked_launches := terminal_field.notify_batch({
		"pitches": 0.0,
		"released_pitches": 1.0,
		"elapsed_seconds": 0.1,
		"pitch_events": [{"phase": "release", "elapsed_offset": 0.1, "ball_count": 1, "flight_seconds": 3.0}],
	})
	_expect(blocked_launches == 0, "No new ball may launch while the current human pitch remains unresolved")
	terminal_field.notify_batch({
		"pitches": 1.0,
		"elapsed_seconds": 0.1,
		"pitch_events": [{"phase": "impact", "outcome": Content.GRAND_SLAM_INDEX, "saved": false, "strikeout": false, "ball_count": 1}],
	})
	_expect(terminal_field.batter_end_pending, "Only the impact event should reveal a Grand Slam and begin batter turnover")
	terminal_game.live_pitching_enabled = false
	terminal_game._resolve_elapsed(8.0, true, false)
	_expect_close(terminal_game.lifetime_pitches, 0.0, "The live simulation must not resolve hidden pitches while the visual plate is unavailable")
	terminal_field.free()
	terminal_game.free()

	game.genetic_levels.extra_arms = 3
	game.genetic_levels.parallel_pitching_lobes = 3
	game.eldritch_levels.mirror_clones = 5
	game.eldritch_levels.time_compression = 3
	game.eldritch_levels.non_euclidean_bullpen = 4
	game.training_levels.recovery = 26
	field.configure_from_game(game)
	var curved_slot := field.next_ball_slot
	field._spawn_pitch(0.0)
	var salvo_data: Dictionary = field.get_launch_snapshot(curved_slot)
	_expect(absf(float(salvo_data.signed_curve)) > 0.10, "Multi-body late-game salvos should unlock large arcs")

	game.highest_unlocked = 44
	game.current_opponent = 44
	game.selected_distance_index = Content.DISTANCE_TIERS.size() - 1
	game.genetic_rebirths = 1
	game.eldritch_ascensions = 1
	game.training_levels.velocity = 400
	game.training_levels.command = 730
	game.genetic_levels.fast_twitch_everything = 6
	game.eldritch_levels.velocity_without_distance = 4
	game.genetic_levels.compound_pitching_eye = 6
	game.genetic_levels.compressed_strike_genome = 3
	game.eldritch_levels.eyes_behind_moon = 5
	for pitch_definition in Content.PITCHES:
		if str(pitch_definition.id) not in game.unlocked_pitches:
			game.unlocked_pitches.append(str(pitch_definition.id))
	for milestone_definition in Content.MILESTONES:
		game.purchased_milestones.append(str(milestone_definition.id))
	game.genetic_levels.elastic_ucl_colony = 5
	field.configure_from_game(game)
	_expect(field._get_camera_scale() < 0.60, "Galaxy-width pitching should zoom far outward")
	_expect(field._get_environment_stage() == 3, "Cosmic play should use dense space")
	_expect(game.get_volley_size() == 2048, "The complete bullpen should reach the designed 2,048-ball final volley")
	_expect(field.is_rendering_one_to_one(), "The renderer should draw every designed endgame ball before abstraction is necessary")
	_expect_close(field.get_visual_weight(), 1.0, "The designed maximum volley should remain below the 4,000-projectile budget")

	var fresh_game: BaseballGameState = GameStateScript.new()
	field.configure_from_game(fresh_game)
	field.pending_results.clear()
	field.batter_terminal_in_flight = false
	field.return_balls.clear()
	field.last_pitch_visual_travel_time = field.travel_time
	field._create_return_ball(Content.STRIKE_INDEX, 0.0, false)
	var missed_strike: Dictionary = field.return_balls.back()
	var incoming_distance := Vector2(missed_strike.start).distance_to(
		field._get_mound_position(fresh_game.get_pitch_distance_feet())
	)
	var continuation_distance := Vector2(missed_strike.start).distance_to(Vector2(missed_strike.finish))
	var expected_continuation_time := field.last_pitch_visual_travel_time * continuation_distance / incoming_distance
	_expect(bool(missed_strike.missed_strike), "A missed strike should be identified as an untouched continuation")
	_expect_close(float(missed_strike.duration), expected_continuation_time, "A missed strike should preserve its incoming screen speed")
	_expect(Vector2(missed_strike.control).is_equal_approx(Vector2(missed_strike.start).lerp(Vector2(missed_strike.finish), 0.5)), "An opening missed strike should continue straight through the plate")
	_expect(float(missed_strike.fade_start) < 0.10, "A missed strike should fade gradually across its continuation")
	field.return_balls.clear()
	var terminal_batch_start := field.next_ball_slot
	var terminal_batch_launches := field.notify_batch({
		"pitches": 3.0,
		"elapsed_seconds": 0.1,
		"pitch_events": [
			{"elapsed_offset": 0.1, "outcome": 4, "saved": false, "strikeout": false},
			{"elapsed_offset": 0.1, "outcome": Content.STRIKE_INDEX, "saved": false, "strikeout": false},
			{"elapsed_offset": 0.1, "outcome": Content.STRIKE_INDEX, "saved": false, "strikeout": false},
		],
	})
	_expect(terminal_batch_launches == 1, "A terminal Single must discard stale later events instead of producing a mixed-color burst")
	_expect(field.next_ball_slot == (terminal_batch_start + 1) % PitchField.MAX_VISUAL_BALLS, "Only the terminal pitch should consume a projectile slot")
	_expect(field.pending_results.size() == 1 and field.batter_terminal_in_flight, "The terminal pitch should reserve the batter until impact")
	field._update_result_visuals(10.0)
	_expect(field.batter_end_pending, "A caught-up terminal result should begin, not skip, batter turnover")
	_expect_close(field.batter_end_delay, PitchField.BATTER_CONTACT_HOLD, "A newly triggered result must retain its full contact hold")
	_expect(field.result_popups.size() == 1 and float(field.result_popups[0].age) == 0.0, "A newly triggered popup must not be aged by the frame that created it")
	_expect(field.return_balls.size() == 1 and float(field.return_balls[0].age) == 0.0, "A newly created green Single return must not be aged or replayed as a pitch")
	field._reset_batter_for_opponent(0)
	field.pending_results.clear()
	field.return_balls.clear()
	field.result_popups.clear()
	field.notify_batch({"visual_outcome": 0, "pitches": 1.0, "earned_xp": 0.0})
	field._update_result_visuals(2.99)
	field._update_result_visuals(0.02)
	_expect(not field.result_popups.is_empty(), "A resolved pitch should create a batter popup")
	_expect(not field.return_balls.is_empty(), "A resolved pitch should create a returned ball")
	fresh_game.eldritch_levels.mirror_clones = 1
	field.configure_from_game(fresh_game)
	field._create_return_ball(1, 0.25, true)
	_expect(bool(field.return_balls.back().relay), "A clone-saved hit should target a bullpen catcher")
	var catch_duration := float(field.return_balls.back().duration)
	field._update_result_visuals(catch_duration + 0.01)
	_expect(bool(field.return_balls.back().relayed), "The bullpen catcher should relay the saved ball to the main pitcher")
	fresh_game.free()
	field.free()
	game.free()

func _test_batter_rotation() -> void:
	var game: BaseballGameState = GameStateScript.new()
	var field: PitchField = _make_field(game)
	_expect(field.get_current_batter_name() == "Little Timmy", "The first visible batter should be individually named")
	_expect(field.get_remaining_strike_icons() == 3, "A fresh batter should show three strike icons")
	field._trigger_result_visual({"outcome": Content.BALL_INDEX, "xp": 0.0, "salvo": 0.0, "plate_ball_count": 1, "walk": false})
	_expect(field.visual_ball_count == 1 and field.get_remaining_ball_icons() == 3, "A called Ball should fill one slot of the visible walk meter")
	field._trigger_result_visual({"outcome": Content.FOUL_INDEX, "xp": 0.0, "salvo": 0.0, "strike_count": 1, "plate_ball_count": 1})
	_expect(field.visual_strike_count == 1 and field.visual_ball_count == 1 and not field.batter_end_pending, "A visible Foul should advance only the strike side of the count")
	field.visual_strike_count = 0
	for strike_number in 2:
		field._trigger_result_visual({"outcome": Content.STRIKE_INDEX, "xp": 0.0, "salvo": 0.0, "strike_count": strike_number + 1, "plate_ball_count": 1, "strikeout": false})
		_expect(field.visual_strike_count == strike_number + 1, "A non-terminal strike should advance the visible count")
		_expect(not field.batter_end_pending, "The batter should remain through strike two")
		_expect(str(field.result_popups[0].text) == "STRIKE", "A non-terminal popup should show only the outcome name")
	field._trigger_result_visual({"outcome": Content.STRIKE_INDEX, "xp": 15.0, "salvo": 0.0, "strike_count": 0, "strikeout": true})
	_expect(field.batter_end_pending, "Strike three should end the batter")
	_expect(field.get_remaining_strike_icons() == 0, "Strike three should remove the last icon")
	_expect(str(field.result_popups[0].text) == "STRIKEOUT", "Strike three should receive only the strikeout call")
	var first_name := field.current_batter_name
	field._update_batter_lifecycle(PitchField.BATTER_CONTACT_HOLD + 0.01)
	field._update_batter_lifecycle(field._get_batter_exit_duration(Content.STRIKE_INDEX) + 0.01)
	_expect(field.batter_phase == "waiting", "A human strikeout should still leave a brief believable lineup-change gap")
	_expect(field.current_batter_name != first_name, "A replacement should get a new in-level name")
	field._update_batter_lifecycle(field._get_batter_replacement_delay(Content.STRIKE_INDEX) + PitchField.BATTER_ENTRY_DURATION + 0.02)
	_expect(field.batter_phase == "active", "The replacement should enter and become active")
	field._trigger_result_visual({"outcome": 1, "xp": 0.0, "salvo": 0.0, "saved": false, "strike_count": 0, "strikeout": false})
	_expect(str(field.result_popups[0].text) == "HOME RUN", "Hit popups should omit count and XP annotations")
	field._update_batter_lifecycle(PitchField.BATTER_CONTACT_HOLD + field._get_batter_exit_duration(1) + 0.02)
	_expect(field.batter_phase == "waiting", "A home run should leave the plate empty for a long replacement gap")
	_expect(field.get_current_batter_name().begins_with("ON DECK:"), "A hit replacement gap should identify the on-deck batter")
	_expect(field.get_batter_arrival_progress() > 0.0 and field.get_batter_arrival_progress() < 1.0, "The on-deck timer should fill through the replacement gap")
	field._update_batter_lifecycle(field._get_batter_replacement_delay(1) + PitchField.BATTER_ENTRY_DURATION + 0.02)
	_expect(field.batter_phase == "active", "A home-run replacement should eventually enter")
	_expect_close(field.get_batter_arrival_progress(), 0.0, "The on-deck timer should clear when the batter is active")

	game.highest_unlocked = 34
	game.current_opponent = 34
	game.genetic_levels.compressed_strike_genome = 2
	field.configure_from_game(game)
	_expect(field.get_strike_limit() == 4, "Two compression ranks should reduce a six-strike alien to four")
	for strike_number in 3:
		field._trigger_result_visual({"outcome": Content.STRIKE_INDEX, "xp": 0.0, "salvo": 0.0, "strike_count": strike_number + 1, "strikeout": false})
		_expect(not field.batter_end_pending, "The compressed alien count should survive through strike three")
	_expect(field.get_remaining_strike_icons() == 1, "Three strikes should leave one of four icons")
	field._trigger_result_visual({"outcome": Content.STRIKE_INDEX, "xp": 30.0, "salvo": 0.0, "strike_count": 0, "strikeout": true})
	_expect(field.batter_end_pending, "The compressed alien should leave on strike four")
	_expect(
		field._get_batter_replacement_delay(0) > field._get_batter_replacement_delay(1)
		and field._get_batter_replacement_delay(1) > field._get_batter_replacement_delay(2)
		and field._get_batter_replacement_delay(2) > field._get_batter_replacement_delay(3)
		and field._get_batter_replacement_delay(3) > field._get_batter_replacement_delay(4)
		and field._get_batter_replacement_delay(4) > field._get_batter_replacement_delay(Content.STRIKE_INDEX),
		"Replacement delay should descend from Grand Slam to strikeout"
	)
	_expect_close(field._get_batter_replacement_delay(Content.BALL_INDEX), field._get_batter_replacement_delay(4) + 0.04, "A walk and Single should have matching complete turnover time despite distinct exit animations", 0.02)
	field.snapshot.time_layers = 8.0
	field.snapshot.batter_downtimes = [1.5, 1.0, 0.75, 0.625, 0.5, 0.0, 0.5, 0.375]
	var compressed_home_run_timeline := (
		PitchField.BATTER_CONTACT_HOLD * field._get_lifecycle_time_scale(1)
		+ field._get_batter_exit_duration(1)
		+ field._get_batter_replacement_delay(1)
		+ PitchField.BATTER_ENTRY_DURATION * field._get_lifecycle_time_scale(1)
	)
	_expect_close(compressed_home_run_timeline, 1.0, "Time compression should accelerate the complete eight-second Home Run timeline")
	field.snapshot.time_layers = 1.0
	var exit_visuals := {}
	for outcome in [0, 1, 2, 3, 4, Content.BALL_INDEX, Content.STRIKE_INDEX]:
		field.batter_phase = "leaving"
		field.batter_exit_outcome = outcome
		field.batter_phase_duration = field._get_batter_exit_duration(outcome)
		field.batter_phase_age = field.batter_phase_duration * 0.5
		var visual: Dictionary = field._get_batter_transition_visual()
		_expect(Vector2(visual.offset).x > 0.0 and Vector2(visual.offset).y < 0.0, "Every departed batter should clear toward the upper-right")
		exit_visuals["%.2f,%.2f,%.2f" % [Vector2(visual.offset).x, Vector2(visual.offset).y, float(visual.rotation)]] = true
	_expect(exit_visuals.size() == 7, "Every terminal outcome should have a distinct exit motion")
	field.batter_phase = "entering"
	field.batter_phase_duration = PitchField.BATTER_ENTRY_DURATION
	field.batter_phase_age = PitchField.BATTER_ENTRY_DURATION * 0.5
	var entrance_visual: Dictionary = field._get_batter_transition_visual()
	_expect(Vector2(entrance_visual.offset).x < 0.0 and Vector2(entrance_visual.offset).y > 0.0, "Replacement batters should enter from the lower-left")
	field.free()
	game.free()

func _test_progression_and_purchases() -> void:
	var game: BaseballGameState = GameStateScript.new()
	game.rng.seed = 7
	var summary: Dictionary = game.simulate_offline(1800.0)
	_expect(not summary.is_empty(), "Offline simulation should produce a summary")
	_expect(game.xp > 0.0, "Thirty opening minutes should produce XP")
	_expect(game.highest_unlocked >= 1, "Opening mastery should unlock another opponent")
	game.xp = 10000.0
	var initial_speed := game.get_velocity_fps()
	_expect(game.buy_training("velocity"), "Velocity training should purchase")
	_expect_close(game.get_velocity_fps(), initial_speed + BaseballGameState.VELOCITY_PER_RANK_FPS, "Velocity training should add 0.15 ft/s to the base")
	_expect(BaseballGameState.format_cost(game.get_training_cost("velocity")).find(".") == -1, "Displayed costs should have no decimals")
	_expect(BaseballGameState.format_cost(18.0) == "20", "Costs should round upward readably")
	_expect(BaseballGameState.format_cost(240.0) == "300", "Hundreds should round to one significant digit")
	_expect(BaseballGameState.format_cost(1.0e15) == "1e15", "Scientific costs should normalize")
	_expect(game.buy_pitch("four_seam"), "The four-seam should purchase")
	game.highest_unlocked = maxi(game.highest_unlocked, 11)
	var lineup_before := game.get_base_batter_turnover_seconds()
	_expect(game.buy_training("turnover"), "Lineup Hustle should be a visible repeatable purchase")
	_expect_close(game.get_base_batter_turnover_seconds(), lineup_before - BaseballGameState.LINEUP_SECONDS_PER_RANK, "Lineup training should reduce the universal replacement delay additively")
	var single_bonus_before := game.get_outcome_turnover_bonus(4)
	_expect(game.buy_training("hit_recovery"), "Shake It Off should be a separate repeatable purchase")
	_expect_close(game.get_outcome_turnover_bonus(4), single_bonus_before * 0.95, "Hit recovery should reduce the extra fair-hit delay")
	_expect_close(game.get_outcome_turnover_bonus(Content.BALL_INDEX), 1.0, "Hit recovery should not change a walk's extra delay")

	var gate_game: BaseballGameState = GameStateScript.new()
	gate_game.highest_unlocked = 4
	gate_game.xp = 1000.0
	var radar_requirements := gate_game.get_milestone_unmet_requirements(Content.milestone_by_id("backyard_radar_target"))
	_expect(not radar_requirements.is_empty() and str(radar_requirements[0]).contains("THROW AT"), "A speed-gated facility should name only its unmet throwing challenge")
	gate_game.training_levels.velocity = 10
	_expect(gate_game.can_buy_milestone("backyard_radar_target"), "Meeting a facility's level, speed, and cost gates should unlock it")
	gate_game.highest_unlocked = 14
	_expect(not gate_game.is_milestone_unlocked("borrowed_high_speed_camera"), "A distance-gated facility should remain locked at the near mound")
	gate_game.set_distance_index(4)
	_expect(gate_game.is_milestone_unlocked("borrowed_high_speed_camera"), "Using the required mound should satisfy a distance challenge")
	gate_game.free()

	game.genetic_offer_unlocked = true
	game.dna = 100
	game.highest_unlocked = 34
	game.current_opponent = 34
	var quality_before_gene := game.get_pitch_quality()
	_expect(game.buy_genetic("compressed_strike_genome"), "Compressed Strike Genome should purchase with DNA")
	_expect(game.get_strikes_per_batter() == 5, "The first compression rank should remove one of six alien strikes")
	_expect_close(game.get_pitch_quality(), quality_before_gene, "Count compression should not secretly alter pitch quality")
	_expect(game.buy_genetic("prehensile_outfield"), "Prehensile Outfield Reflex should purchase with DNA")
	_expect_close(game.get_hit_save_chance(4), 1.0, "The first fielding rank should guarantee singles are saved")
	_expect(game.buy_genetic("extra_arms"), "A genetic arm rank should purchase")
	_expect_close(game.get_arm_count(), 2.0, "The first arm rank should double arms")

	game.eldritch_offer_unlocked = true
	game.arcana = 100
	_expect(game.buy_eldritch("mirror_clones"), "A mirror clone rank should purchase")
	_expect_close(game.get_clone_count(), 2.0, "The first clone rank should double pitcher bodies")
	var base_rate := game.get_pitch_rate()
	game.purchased_milestones.append("pitch_clock_loophole")
	_expect_close(game.get_pitch_rate(), base_rate * 1.10, "Pitch-Clock Loophole should apply its advertised Recovery multiplier")
	game.purchased_milestones.append("outer_dark_umpire")
	_expect_close(game.get_mastery_multiplier(), 2.50, "The Outer-Dark umpire should multiply mastery")
	game.purchased_ball_upgrades = ["pocket_singularity", "taped_seams"]
	_expect(game.get_current_ball_name() == "Pocket-Singularity Center", "Loadout should show the strongest ball regardless of purchase order")
	game.free()

func _test_story_exhibitions_and_reset_boundaries() -> void:
	var game: BaseballGameState = GameStateScript.new()
	game.highest_unlocked = Content.ALIEN_EXHIBITION_INDEX
	game.current_opponent = Content.ALIEN_EXHIBITION_INDEX
	_expect(game.is_alien_exhibition_blocked(), "The first alien exhibition should be unwinnable")
	_expect(game.get_outcome_probabilities() == [1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], "Xylophax should hit 100% Grand Slams before the offer")
	game.simulate_offline(59.0)
	_expect(not game.genetic_offer_unlocked, "The genetic offer should not arrive before one minute")
	game.simulate_offline(1.0)
	_expect(game.genetic_offer_unlocked, "The genetic offer should arrive at one minute")
	game.run_xp = BaseballGameState.DNA_XP_THRESHOLD * 1000.0
	_expect(game.get_potential_dna() == 10, "DNA should be the cube root of normalized body XP")
	var dna_award := game.perform_genetic_rebirth()
	_expect(dna_award == 10 and game.dna == 10, "Genetic rebirth should grant its previewed DNA")
	_expect(game.highest_unlocked == 0 and game.run_xp == 0.0, "Genetic rebirth should reset the body and ladder")
	_expect(game.genetic_rebirths == 1 and game.lifetime_genetic_rebirths == 1, "Genetic rebirth counters should advance")
	_expect(game.genetic_offer_unlocked, "The Time Machine offer should survive genetic rebirth")
	game.buy_genetic("extra_arms")
	game.highest_unlocked = Content.ALIEN_EXHIBITION_INDEX
	game.run_xp = BaseballGameState.DNA_XP_THRESHOLD
	game.perform_genetic_rebirth()
	_expect(int(game.genetic_levels.extra_arms) == 1, "Genetic enhancements should survive later genetic rebirths")

	game.highest_unlocked = Content.ELDRITCH_EXHIBITION_INDEX
	game.current_opponent = Content.ELDRITCH_EXHIBITION_INDEX
	game.genetic_levels.predator_scouting = 1
	game.auto_farm_enabled = true
	game.advance(0.5)
	_expect(game.current_opponent == Content.ELDRITCH_EXHIBITION_INDEX, "Auto-scout must not flee a required story countdown")
	game.simulate_offline(59.5)
	_expect(game.eldritch_offer_unlocked, "N'Kthra should reveal eldritch ascension after one minute")
	game.reality_dna_earned = 1000.0
	_expect(game.get_potential_arcana() == 63, "Arcana should scale as reality DNA^0.60")
	game.dna = 77
	game.genetic_levels.extra_arms = 3
	game.eldritch_levels.mirror_clones = 1
	var arcana_award := game.perform_eldritch_ascension()
	_expect(arcana_award == 63 and game.arcana == 63, "Eldritch ascension should grant its previewed Arcana")
	_expect(game.dna == 0 and game.genetic_rebirths == 0, "Eldritch ascension should erase DNA and current-reality genetic count")
	_expect(int(game.genetic_levels.extra_arms) == 0, "Eldritch ascension should erase genetics")
	_expect(int(game.eldritch_levels.mirror_clones) == 1, "Eldritch magic should survive reality destruction")
	_expect(game.eldritch_ascensions == 1 and game.lifetime_eldritch_ascensions == 1, "Eldritch counters should advance")
	_expect(game.highest_unlocked == 0 and game.reality_dna_earned == 0.0, "Reality destruction should reset the ladder and reality DNA")
	game.free()

func _test_divine_restoration() -> void:
	var game: BaseballGameState = GameStateScript.new()
	game.cosmos_conquered = true
	game.dna = 50
	game.arcana = 20
	game.genetic_rebirths = 3
	game.eldritch_ascensions = 2
	game.lifetime_genetic_rebirths = 7
	game.lifetime_eldritch_ascensions = 4
	game.genetic_levels.extra_arms = 3
	game.eldritch_levels.mirror_clones = 5
	_expect(game.perform_divine_ascension("let_there_be_fastballs"), "A cosmic victory should allow one divine blessing")
	_expect(game.has_divine_blessing("let_there_be_fastballs"), "The chosen blessing should persist")
	_expect(game.divine_ascensions == 1, "Divine restoration should count a saved universe")
	_expect(game.dna == 0 and game.arcana == 0, "Divine restoration should erase lower currencies")
	_expect(game.genetic_rebirths == 0 and game.eldritch_ascensions == 0, "Divine restoration should erase current lower-layer counts")
	_expect(game.lifetime_genetic_rebirths == 7 and game.lifetime_eldritch_ascensions == 4, "Lifetime reset statistics should survive God")
	_expect(int(game.genetic_levels.extra_arms) == 0 and int(game.eldritch_levels.mirror_clones) == 0, "Divine restoration should erase mutations and magic")
	_expect_close(game.get_velocity_fps(), 10.0, "Let There Be Fastballs should make the next universe start at 10 ft/s")
	_expect(not game.perform_divine_ascension("let_there_be_fastballs"), "A blessing cannot be claimed twice without another victory")

	for definition in Content.DIVINE_BLESSINGS:
		var id := str(definition.id)
		if game.has_divine_blessing(id):
			continue
		game.cosmos_conquered = true
		_expect(game.perform_divine_ascension(id), "Every named blessing should be collectible across victories")
	_expect(game.all_divine_blessings_owned(), "All named blessings should eventually be owned")
	game.cosmos_conquered = true
	var mastery_before_halo := game.get_mastery_multiplier()
	_expect(game.perform_divine_ascension("halo"), "Wins after all blessings should award Halos")
	_expect(game.divine_halos == 1, "The first excess victory should grant one Halo")
	_expect_close(game.get_mastery_multiplier(), mastery_before_halo * 1.50, "A Halo should multiply mastery by 1.50")
	game.free()

func _test_save_round_trip_and_migration() -> void:
	var original: BaseballGameState = GameStateScript.new()
	original.xp = 12345.5
	original.run_xp = 77777.0
	original.lifetime_xp = 987654.0
	original.highest_unlocked = 42
	original.current_opponent = 37
	original.selected_distance_index = 12
	original.dna = 123
	original.arcana = 17
	original.genetic_rebirths = 2
	original.eldritch_ascensions = 1
	original.lifetime_genetic_rebirths = 8
	original.lifetime_eldritch_ascensions = 3
	original.divine_ascensions = 2
	original.divine_halos = 1
	original.reality_dna_earned = 456.0
	original.genetic_offer_unlocked = true
	original.eldritch_offer_unlocked = true
	original.training_levels.velocity = 9
	original.training_levels.turnover = 7
	original.genetic_levels.compressed_strike_genome = 3
	original.genetic_levels.prehensile_outfield = 2
	original.eldritch_levels.mirror_clones = 2
	original.eldritch_levels.portal_outfield = 3
	original.lifetime_strikeouts = 2468.0
	original.current_body_strikeouts = 135.0
	original.plate_strikes = 3
	original.plate_balls = 2
	original.batter_cooldown_remaining = 0.8
	original.divine_blessings = ["let_there_be_fastballs"]
	original.unlocked_pitches.append("four_seam")
	original.purchased_milestones.append("regulation_ball")
	original.opponent_mastery[3] = 77.0
	var restored: BaseballGameState = GameStateScript.new()
	restored.apply_save_data(original.to_save_data())
	_expect_close(restored.xp, original.xp, "XP should survive a save round-trip")
	_expect(restored.current_opponent == 37 and restored.highest_unlocked == 42, "Opponent access should survive a save round-trip")
	_expect(restored.selected_distance_index == 12, "Pitching distance should survive a save round-trip")
	_expect(restored.dna == 123 and restored.arcana == 17, "Prestige currencies should survive a save round-trip")
	_expect(restored.lifetime_genetic_rebirths == 8 and restored.lifetime_eldritch_ascensions == 3, "Lifetime reset stats should survive saves")
	_expect(restored.get_strikes_per_batter() == 4, "Genetic count compression should survive saves")
	_expect(int(restored.genetic_levels.prehensile_outfield) == 2 and int(restored.eldritch_levels.portal_outfield) == 3, "Hit-protection upgrades should survive saves")
	_expect_close(restored.lifetime_strikeouts, 2468.0, "Strikeout totals should survive saves")
	_expect(restored.plate_strikes == 3 and restored.plate_balls == 2 and restored.batter_cooldown_remaining > 0.0, "The complete live count should survive saves")
	_expect_close(restored.get_clone_count(), 4.0, "Eldritch clones should survive saves")
	_expect(restored.has_divine_blessing("let_there_be_fastballs") and restored.divine_halos == 1, "Divine rewards should survive saves")
	_expect("four_seam" in restored.unlocked_pitches and restored.has_milestone("regulation_ball"), "Ordinary purchases should survive saves")
	_expect_close(restored.opponent_mastery[3], 77.0, "Mastery should survive saves")
	_expect(int(restored.training_levels.turnover) == 7, "Batter-cooldown training should survive saves")

	var legacy_data := {
		"version": 5,
		"xp": 1000.0,
		"run_xp": 2000.0,
		"highest_unlocked": 44,
		"current_opponent": 44,
		"rings": 12,
		"seasons_completed": 2,
		"auto_advance_enabled": true,
		"auto_train_enabled": true,
		"auto_farm_enabled": true,
		"scale_levels": {"arms": 3, "clones": 5, "time": 2, "strike_capacity": 4},
		"training_levels": {"velocity": 20, "command": 10, "spin": 10, "deception": 10, "recovery": 10},
		"unlocked_pitches": ["dead_fish"],
	}
	var migrated: BaseballGameState = GameStateScript.new()
	migrated.apply_save_data(legacy_data)
	_expect(migrated.dna == 12, "Legacy Rings should become DNA")
	_expect(migrated.genetic_rebirths >= 2 and migrated.eldritch_ascensions >= 1, "Late legacy access should unlock corresponding layers")
	_expect_close(migrated.get_arm_count(), 8.0, "Legacy arm ranks should migrate to genetics")
	_expect_close(migrated.get_clone_count(), 32.0, "Legacy clone ranks should migrate to eldritch magic")
	_expect_close(migrated.get_time_multiplier(), 4.0, "Legacy time ranks should migrate to eldritch magic")
	_expect(int(migrated.genetic_levels.compressed_strike_genome) == 3, "Legacy strike capacity should migrate to count compression")
	_expect(migrated.get_strikes_per_batter() == 61, "Legacy count investment should remove three strikes from Octathulhu's sixty-four")
	_expect(migrated.auto_advance_enabled and migrated.auto_train_enabled and migrated.auto_farm_enabled, "Legacy automation should remain unlocked")
	_expect(int(migrated.training_levels.command) == 42, "Legacy additive Command, Spin, and Deception should preserve their quality under the new +0.08 ranks")

	var version_six_data := {
		"version": 6,
		"highest_unlocked": 40,
		"current_opponent": 40,
		"genetic_levels": {"expanded_strike_genome": 2},
		"eldritch_levels": {"impossible_count": 3},
		"result_totals": [11.0, 22.0, 33.0, 44.0, 55.0],
	}
	var version_six: BaseballGameState = GameStateScript.new()
	version_six.apply_save_data(version_six_data)
	_expect(int(version_six.genetic_levels.compressed_strike_genome) == 2, "v6 expanded counts should become compression")
	_expect(int(version_six.eldritch_levels.portal_outfield) == 3, "v6 impossible counts should become portal fielding")
	_expect(version_six.result_totals == [0.0, 11.0, 22.0, 33.0, 44.0, 0.0, 0.0, 55.0], "v6 outcome history should gain Grand Slam, Foul, and Ball buckets")

	var legacy_belt := _test_loot_item("legacy_belt", "belt", 18, 2, {"mastery_bonus": 0.03})
	legacy_belt.erase("favorite")
	var version_eight_data := {
		"version": 8,
		"highest_unlocked": 30,
		"current_opponent": 30,
		"genetic_offer_unlocked": true,
		"loot_items": [legacy_belt],
		"equipped_loot": {"belt": "legacy_belt"},
	}
	var version_eight: BaseballGameState = GameStateScript.new()
	version_eight.apply_save_data(version_eight_data)
	var migrated_belt := version_eight.get_loot_item("legacy_belt")
	_expect(str(migrated_belt.slot) == "jockstrap", "v8 Belt equipment should migrate into the Jock Strap slot")
	_expect(str(version_eight.equipped_loot.jockstrap) == "legacy_belt", "An equipped v8 Belt should remain equipped after migration")
	_expect(not bool(migrated_belt.favorite), "Legacy equipment should default to unstarred")
	original.free()
	restored.free()
	migrated.free()
	version_six.free()
	version_eight.free()

func _test_cosmic_completion_and_magnitude() -> void:
	var game: BaseballGameState = GameStateScript.new()
	game.highest_unlocked = 44
	game.current_opponent = 44
	game.selected_distance_index = Content.DISTANCE_TIERS.size() - 1
	game.genetic_offer_unlocked = true
	game.eldritch_offer_unlocked = true
	game.genetic_rebirths = 1
	game.eldritch_ascensions = 1
	for id in game.training_levels:
		game.training_levels[id] = 400
	for definition in Content.GENETIC_UPGRADES:
		game.genetic_levels[definition.id] = int(definition.max_level)
	for definition in Content.ELDRITCH_UPGRADES:
		game.eldritch_levels[definition.id] = int(definition.max_level)
	for definition in Content.PITCHES:
		if str(definition.id) not in game.unlocked_pitches:
			game.unlocked_pitches.append(str(definition.id))
	for definition in Content.MILESTONES:
		game.purchased_milestones.append(str(definition.id))
	for definition in Content.BALL_UPGRADES:
		game.purchased_ball_upgrades.append(str(definition.id))
	_expect_close(game.get_velocity_fps(), BaseballGameState.SPEED_OF_LIGHT_FPS, "Final velocity should be exactly light speed")
	_expect(not game.is_speed_gate_blocked(), "A 1c pitch should penetrate Octathulhu's causality armor")
	var rate := game.get_pitch_rate()
	_expect(game.get_volley_size() == 2048, "Maximum arms, clones, time layers, and capacity should produce 2,048 simultaneous balls")
	_expect(rate > 10000.0 and rate <= BaseballGameState.MAX_PHYSICAL_PITCH_RATE, "Final physical throughput should be enormous without exceeding its safety budget")
	_expect(game.get_pitch_potency() >= 1.0e18, "Late absurdity should live in ball payload as well as projectile count")
	game.opponent_mastery[44] = float(game.get_current_opponent().mastery_required)
	var victory := game._check_opponent_unlock()
	_expect(game.cosmos_conquered and victory.begins_with("COSMOS CONQUERED"), "Mastering Octathulhu should trigger cosmic victory")
	_expect(game._check_opponent_unlock().is_empty(), "Cosmic victory should fire only once")

	var started := Time.get_ticks_usec()
	var summary: Dictionary = game.simulate_offline(365.0 * 24.0 * 60.0 * 60.0)
	var elapsed_ms := float(Time.get_ticks_usec() - started) / 1000.0
	_expect(not is_nan(float(summary.pitches)) and not is_nan(float(summary.earned_xp)), "Large aggregate simulation should remain finite")
	_expect(game.lifetime_pitches > 1.0e8, "The seven-day offline cap should retain a vast active-pitch volume after batter downtime")
	_expect(elapsed_ms < 250.0, "Large aggregate simulation took unexpectedly long: %.2f ms" % elapsed_ms)
	print("Final form: %s/s at %s; seven-day aggregate in %.3f ms" % [BaseballGameState.format_number(rate), BaseballGameState.format_speed(game.get_velocity_fps()), elapsed_ms])
	game.free()
