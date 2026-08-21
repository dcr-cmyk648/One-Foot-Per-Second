extends SceneTree

const Content = preload("res://scripts/content.gd")
const Campaign = preload("res://scripts/campaign.gd")
const GameStateScript = preload("res://scripts/game_state.gd")

var failures: Array[String] = []

func _initialize() -> void:
	print("No Hitter — 100-level progression and economy audit")
	_audit_campaign_topology()
	_audit_physical_anchors()
	_audit_encounter_profiles()
	_audit_economy_and_batching()
	_audit_prestige_curves()
	_audit_terminal_rules()
	if failures.is_empty():
		print("\nPASS: campaign, economy, physical anchors, and terminal rules are internally consistent")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("\nFAIL: %d progression audit issue(s)" % failures.size())
		quit(1)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _audit_campaign_topology() -> void:
	var opponents: Array[Dictionary] = Content.opponents()
	print("\n=== Finite campaign ===")
	_expect(opponents.size() == 100, "The finite campaign must contain exactly 100 numbered levels")
	_expect(Campaign.HUMAN_FINAL_INDEX == 32 and Campaign.ALIEN_FINAL_INDEX == 65 and Campaign.ELDRITCH_FINAL_INDEX == 98 and Campaign.FINAL_BOSS_INDEX == 99, "League boundaries are not 33 + 33 + 33 + Octathulhu")
	var previous_mastery := 0.0
	var previous_reward := 0.0
	var pitch_draft_count := 0
	for index in opponents.size():
		var opponent: Dictionary = opponents[index]
		var authored := Content.campaign_level(index)
		_expect(int(authored.index) == index, "Campaign index mismatch at Level %d" % (index + 1))
		_expect(float(opponent.mastery_required) > 0.0, "Level %d has no mastery requirement" % (index + 1))
		if index > 0 and (index % Campaign.LEVELS_PER_SUBERA) != 0:
			_expect(float(opponent.mastery_required) > previous_mastery, "Mastery must rise within the Level %d sub-era" % (index + 1))
		_expect(float(opponent.reward) > previous_reward or index == 0, "Strikeout reward must rise at Level %d" % (index + 1))
		previous_mastery = float(opponent.mastery_required)
		previous_reward = float(opponent.reward)
		if bool(authored.pitch_draft):
			pitch_draft_count += 1
		if index <= Content.HUMAN_FINAL_INDEX:
			_expect(Content.BASE_STRIKES_REQUIRED[index] == 3, "Human Level %d abandoned three-strike baseball" % (index + 1))
			_expect(Content.OPPONENT_BAT_COUNTS[index] == 1, "Human Level %d has post-human bat coverage" % (index + 1))
		elif index <= Content.ALIEN_FINAL_INDEX:
			_expect(Content.BASE_STRIKES_REQUIRED[index] >= 4 and Content.BASE_STRIKES_REQUIRED[index] <= 8, "Alien Level %d has an impractical authored strike count" % (index + 1))
			_expect(Content.OPPONENT_BAT_COUNTS[index] >= 1 and Content.OPPONENT_BAT_COUNTS[index] <= 4, "Alien bat progression escaped its one-to-four range")
		else:
			_expect(Content.BASE_STRIKES_REQUIRED[index] >= 12, "Eldritch Level %d should demand a visibly nonhuman count" % (index + 1))
	_expect(pitch_draft_count == 23, "Every fifth finite level plus the three off-cadence league bosses should queue a pitch draft")
	for level_number in range(1, 101):
		var index := level_number - 1
		var expected_pitch := level_number % Campaign.PITCH_DRAFT_INTERVAL == 0 or index in [32, 65, 98]
		_expect(bool(Content.campaign_level(index).pitch_draft) == expected_pitch, "Pitch draft cadence mismatch at Level %d" % level_number)
	_expect(str(Content.campaign_level(32).signature_name).contains("Bambino Rex"), "The human finale is not sticky-boss Bambino Rex")
	_expect(str(Content.campaign_level(65).signature_name).contains("Xylophax"), "The alien finale is not playable Xylophax")
	_expect(str(Content.campaign_level(99).signature_name).contains("Octathulhu"), "Level 100 is not Octathulhu")
	_expect(Content.OPPONENT_BAT_COUNTS[65] == 4 and Content.OPPONENT_BAT_COUNTS[99] == 8, "Final bosses need four and eight visible bats")
	_expect(Content.BASE_STRIKES_REQUIRED[99] == 64 and Content.BASE_BALLS_REQUIRED[99] == 2, "Octathulhu's final count changed unexpectedly")
	print("100 levels • 23 pitch drafts • K counts 3 → 8 → 64 • bats 1 → 4 → 8")

func _audit_physical_anchors() -> void:
	print("\n=== Physical anchors ===")
	var human_anchor := float(Content.campaign_level(Content.HUMAN_FINAL_INDEX).speed_anchor_fps)
	var alien_anchor := float(Content.campaign_level(Content.ALIEN_FINAL_INDEX).speed_anchor_fps)
	var final_anchor := float(Content.campaign_level(Content.FINAL_BOSS_INDEX).speed_anchor_fps)
	_expect(absf(human_anchor * 0.681818 - 115.0) < 0.01, "Human finale is not anchored to 115 mph")
	_expect(absf(alien_anchor / BaseballGameState.SPEED_OF_SOUND_FPS - 5000.0) < 0.1, "Alien finale is not anchored to Mach 5000")
	_expect(absf(final_anchor / BaseballGameState.SPEED_OF_LIGHT_FPS - 5000.0) < 0.1, "Octathulhu is not anchored to 5000c")
	_expect(str(Content.DISTANCE_TIERS[5].label) == "60 ft 6 in", "Human regulation range changed")
	_expect(str(Content.DISTANCE_TIERS[16].name).contains("OLYMPUS MOUND"), "Alien finale does not use Olympus Mound")
	_expect(str(Content.DISTANCE_TIERS[27].name).contains("PLUTO"), "Eldritch finale does not span Earth to Pluto")
	var fresh := GameStateScript.new()
	fresh.reset_fresh()
	_expect(is_equal_approx(fresh.get_representative_pitch_speed(), 1.0), "A new run no longer releases at one foot per second")
	var opening_drag_loss := fresh.get_pitch_drag_loss_fraction()
	_expect(opening_drag_loss >= 0.005 and opening_drag_loss <= 0.010, "The opening Wiffle Ball should lose roughly 0.5–1% to air drag")
	_expect(fresh.get_resolved_flight_seconds() >= 3.0 and fresh.get_resolved_flight_seconds() <= 3.02, "The opening three-foot throw should remain roughly three seconds")
	_expect(fresh.get_representative_plate_speed() < 1.0 and fresh.get_representative_plate_speed() > 0.99, "An untouched opening Wiffle Ball should lose a small real amount of speed")
	fresh.free()
	print("115 mph • Mach 5000 from Olympus Mound • 5000c from Earth to Pluto")

func _audit_encounter_profiles() -> void:
	print("\n=== Representative matchup ceilings ===")
	var fresh := GameStateScript.new()
	fresh.reset_fresh()
	var fresh_metrics := fresh.get_at_bat_metrics()
	var fresh_strike := float((fresh_metrics.probabilities as Array)[Content.STRIKE_INDEX])
	_expect(fresh_strike >= 0.35, "The opening toddler has regressed to an excessively low called-Strike rate")
	_expect(float(fresh_metrics.strikeout_probability) >= 0.08, "The opening three-strike plate appearance is mathematically punishing")
	_print_profile("Fresh Little Timmy", fresh)

	var human := GameStateScript.new()
	human.reset_fresh()
	human.highest_unlocked = Content.HUMAN_FINAL_INDEX
	human.current_opponent = Content.HUMAN_FINAL_INDEX
	human._sync_distance_to_current_opponent()
	human.training_levels.velocity = 100000
	_expect(human.get_velocity_fps() >= BaseballGameState.HUMAN_SPEED_CAP_FPS * 0.999, "Human Speed Training cannot asymptotically satisfy Bambino's 115 mph trial")
	_expect(not human.is_speed_gate_blocked(), "A human body at its asymptotic limit is still blocked by Bambino")
	_print_profile("Human limit vs Bambino", human)

	var alien := GameStateScript.new()
	_prepare_layer_ceiling(alien, Content.ALIEN_FINAL_INDEX, true, false)
	_expect(alien.get_velocity_fps() >= BaseballGameState.ALIEN_SPEED_CAP_FPS * 0.80, "A complete genetic build cannot satisfy Xylophax's physical license")
	_expect(not alien.is_speed_gate_blocked(), "Xylophax remains physically impossible at the genetic ceiling")
	_expect(alien.get_strikeout_chance_per_at_bat() > 0.0, "Xylophax is mathematically impossible at the genetic ceiling")
	_print_profile("Genetic ceiling vs Xylophax", alien)

	var elder := GameStateScript.new()
	_prepare_layer_ceiling(elder, Content.FINAL_BOSS_INDEX, true, true)
	_expect(elder.get_velocity_fps() >= BaseballGameState.ELDRITCH_SPEED_CAP_FPS * 0.80, "A complete eldritch build cannot satisfy Octathulhu's physical license")
	_expect(not elder.is_speed_gate_blocked(), "Octathulhu remains physically impossible at the eldritch ceiling")
	_expect(elder.get_strikeout_chance_per_at_bat() > 0.0, "Octathulhu is mathematically impossible at the eldritch ceiling")
	_print_profile("Eldritch ceiling vs Octathulhu", elder)
	fresh.free()
	human.free()
	alien.free()
	elder.free()

func _prepare_layer_ceiling(game: BaseballGameState, opponent_index: int, genetic: bool, eldritch: bool) -> void:
	game.reset_fresh()
	game.genetic_offer_unlocked = genetic
	game.genetic_rebirths = 1 if genetic else 0
	game.eldritch_offer_unlocked = eldritch
	game.eldritch_ascensions = 1 if eldritch else 0
	game.highest_unlocked = opponent_index
	game.current_opponent = opponent_index
	game._sync_distance_to_current_opponent()
	for id in game.training_levels:
		game.training_levels[id] = 1000000000
	for definition_value in Content.PITCHES:
		var definition: Dictionary = definition_value
		var pitch_id := str(definition.id)
		if pitch_id not in game.unlocked_pitches:
			game.unlocked_pitches.append(pitch_id)
		game.pitch_levels[pitch_id] = 100
		game.pitch_draft_power[pitch_id] = 1000000.0
	for definition_value in Content.BALL_UPGRADES:
		var definition: Dictionary = definition_value
		if Content.catalog_required_level(definition) <= opponent_index:
			game.purchased_ball_upgrades.append(str(definition.id))
	for definition_value in Content.MILESTONES:
		var definition: Dictionary = definition_value
		if Content.catalog_required_level(definition) <= opponent_index:
			game.purchased_milestones.append(str(definition.id))
	if genetic:
		for definition_value in Content.GENETIC_UPGRADES:
			var definition: Dictionary = definition_value
			if definition.has("max_level"):
				game.genetic_levels[str(definition.id)] = int(definition.max_level)
	if eldritch:
		for definition_value in Content.ELDRITCH_UPGRADES:
			var definition: Dictionary = definition_value
			if definition.has("max_level"):
				game.eldritch_levels[str(definition.id)] = int(definition.max_level)
	game._invalidate_milestone_effect_cache()

func _print_profile(label: String, game: BaseballGameState) -> void:
	var metrics := game.get_at_bat_metrics()
	print("%-34s speed=%-12s Strike=%7.3f%% K=%8.5f%% Kreq=%d bats=%d" % [
		label,
		BaseballGameState.format_speed(game.get_velocity_fps()),
		float((metrics.probabilities as Array)[Content.STRIKE_INDEX]) * 100.0,
		float(metrics.strikeout_probability) * 100.0,
		game.get_strikes_required(),
		game.get_opponent_bat_count(),
	])

func _audit_economy_and_batching() -> void:
	print("\n=== Economy and exact Training batches ===")
	var game := GameStateScript.new()
	game.reset_fresh()
	var manual_sum := 0.0
	for rank in 10:
		game.training_levels.velocity = rank
		manual_sum += game.get_training_cost("velocity")
	game.training_levels.velocity = 0
	var batch_cost := game.get_training_batch_cost("velocity", 10)
	print("Velocity x10 sequential=%s batch=%s" % [str(manual_sum), str(batch_cost)])
	_expect(is_equal_approx(batch_cost, BaseballGameState.rounded_cost(manual_sum)), "Train x10 does not equal the displayed rounded total of ten sequential costs")
	game.xp = batch_cost
	_expect(game.buy_training_batch("velocity", 10), "An exactly funded x10 purchase was rejected")
	_expect(int(game.training_levels.velocity) == 10 and absf(game.xp) < 0.001, "Train x10 partially purchased or mischarged ranks")
	var first_facility: Dictionary = Content.MILESTONES[0]
	_expect(game.get_milestone_cost(str(first_facility.id)) >= float(first_facility.cost) * 256.0, "Facilities lost their major savings-goal repricing")
	_expect(game.get_training_cost("velocity") < game.get_milestone_cost(str(first_facility.id)), "Opening Training should remain the incremental spend below a Facility")
	game.free()

func _audit_prestige_curves() -> void:
	print("\n=== Prestige award breakpoints ===")
	var game := GameStateScript.new()
	game.reset_fresh()
	game.genetic_offer_unlocked = true
	game.highest_unlocked = Content.ALIEN_EXHIBITION_INDEX
	_expect(_potential_dna_at(game, 1.0) == 1, "DNA should begin at one")
	_expect(_potential_dna_at(game, 8.0) == 2, "Eight normalized run-XP should produce two DNA")
	_expect(_potential_dna_at(game, 1000.0) == 10, "Exact cube thresholds must not round ten DNA down to nine")
	game.eldritch_offer_unlocked = true
	game.highest_unlocked = Content.ELDRITCH_EXHIBITION_INDEX
	game.lifetime_genetic_rebirths = 1
	_expect(_potential_arcana_at(game, 1000.0) == 63, "One thousand reality DNA should produce sixty-three Arcana")
	game.free()

func _potential_dna_at(game: BaseballGameState, multiplier: float) -> int:
	game.run_xp = BaseballGameState.DNA_XP_THRESHOLD * multiplier
	return game.get_potential_dna()

func _potential_arcana_at(game: BaseballGameState, dna_total: float) -> int:
	game.reality_dna_earned = dna_total
	return game.get_potential_arcana()

func _audit_terminal_rules() -> void:
	print("\n=== Terminal and reward rules ===")
	var game := GameStateScript.new()
	game.reset_fresh()
	game.divine_blessings = ["angels_outfield"]
	game.genetic_levels.prehensile_outfield = 3
	game.eldritch_levels.mirror_clones = 5
	game.eldritch_levels.portal_outfield = 8
	for outcome in Content.HIT_OUTCOME_COUNT:
		var chance := game.get_hit_save_chance(outcome)
		if outcome == Content.GRAND_SLAM_INDEX:
			_expect(chance == 0.0, "Grand Slams became preventable")
		else:
			_expect(chance == 1.0, "Angels in the Outfield should protect every ordinary fair hit")
	_expect(Content.OUTCOME_XP.max() == 0.0, "An individual ball outcome still pays XP")
	_expect(game.get_strikeout_base_points() > 0.0, "Completed strikeouts lost their sole XP payout")
	game.free()
