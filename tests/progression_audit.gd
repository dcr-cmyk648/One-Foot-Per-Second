extends SceneTree

const Content = preload("res://scripts/content.gd")
const GameStateScript = preload("res://scripts/game_state.gd")

var failures: Array[String] = []

func _initialize() -> void:
	print("One Foot Per Second — v0.10.0 progression and economy audit")
	_audit_ladder()
	_audit_encounter_profiles()
	_audit_prestige_curves()
	_audit_terminal_rules()
	if failures.is_empty():
		print("\nPASS: progression formulas are internally consistent")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("\nFAIL: %d audit issue(s)" % failures.size())
		quit(1)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _audit_ladder() -> void:
	var opponents: Array[Dictionary] = Content.opponents()
	print("\n=== Complete opponent ladder ===")
	print("Lv  Era                         K   Mastery        Reward   Opponent")
	for index in opponents.size():
		var opponent: Dictionary = opponents[index]
		print(
			"%02d  %-27s %2d  %-13s  ×%-7s  %s"
			% [
				index + 1,
				str(opponent.era),
				Content.BASE_STRIKES_REQUIRED[index],
				BaseballGameState.format_number(float(opponent.mastery_required)),
				BaseballGameState.format_number(float(opponent.reward)),
				str(opponent.name),
			]
		)
		if index <= Content.HUMAN_FINAL_INDEX:
			_expect(Content.BASE_STRIKES_REQUIRED[index] == 3, "Human level %d does not use three strikes" % (index + 1))
		if index > 0:
			_expect(float(opponent.mastery_required) > float(opponents[index - 1].mastery_required), "Mastery does not rise at level %d" % (index + 1))
	_expect(Content.BASE_STRIKES_REQUIRED[30] == 4 and Content.BASE_STRIKES_REQUIRED[39] == 9, "Alien count curve changed unexpectedly")
	_expect(Content.BASE_STRIKES_REQUIRED[40] == 12 and Content.BASE_STRIKES_REQUIRED[44] == 64, "Eldritch count curve changed unexpectedly")

func _audit_encounter_profiles() -> void:
	print("\n=== Representative at-bat profiles ===")
	print("Profile                    K req  Pitch K   K/at-bat  HR save   Active rate      XP/s")

	var fresh := GameStateScript.new()
	_print_profile("Fresh vs Little Timmy", fresh)
	_expect(fresh.get_strikeout_chance_per_at_bat() > 0.01, "The opening at-bat is mathematically impractical")

	var human := GameStateScript.new()
	_max_ordinary_build(human, Content.HUMAN_FINAL_INDEX)
	human.highest_unlocked = Content.HUMAN_FINAL_INDEX
	human.current_opponent = Content.HUMAN_FINAL_INDEX
	_print_profile("Human cap vs Bambino Rex", human)
	_expect(absf(human.get_velocity_fps() - BaseballGameState.HUMAN_SPEED_CAP_FPS) < 0.01, "First human completion is not capped at 211.6 mph")
	_expect(human.get_strikes_required() == 3, "The human final does not retain three strikes")

	var alien := GameStateScript.new()
	_max_ordinary_build(alien, Content.ALIEN_FINAL_INDEX)
	alien.genetic_rebirths = 1
	alien.genetic_offer_unlocked = true
	_max_genetics(alien)
	alien.highest_unlocked = Content.ALIEN_FINAL_INDEX
	alien.current_opponent = Content.ALIEN_FINAL_INDEX
	alien.selected_distance_index = alien.get_max_distance_index()
	_print_profile("Genetic ace vs Solar Champ", alien)
	_expect(alien.get_strikes_required() == 6, "Alien final should be nine base strikes compressed to six")
	_expect(alien.get_strikeout_chance_per_at_bat() > 0.01, "The alien final is mathematically impractical at its layer ceiling")

	var elder := GameStateScript.new()
	_max_ordinary_build(elder, Content.FINAL_BOSS_INDEX)
	elder.genetic_rebirths = 1
	elder.eldritch_ascensions = 1
	elder.genetic_offer_unlocked = true
	elder.eldritch_offer_unlocked = true
	_max_genetics(elder)
	_max_eldritch(elder)
	for opponent_index in [40, 41, 42, 43, 44]:
		elder.highest_unlocked = opponent_index
		elder.current_opponent = opponent_index
		elder.selected_distance_index = elder.get_max_distance_index()
		_print_profile("Eldritch L%02d" % (opponent_index + 1), elder)
		_expect(elder.get_strikeout_chance_per_at_bat() > 0.001, "Eldritch level %d is mathematically impractical at its layer ceiling" % (opponent_index + 1))

	fresh.free()
	human.free()
	alien.free()
	elder.free()

func _print_profile(label: String, game: BaseballGameState) -> void:
	var probabilities := game.get_outcome_probabilities()
	print(
		"%-27s %2d     %6.2f%%   %7.3f%%   %6.2f%%   %-12s  %s"
		% [
			label,
			game.get_strikes_required(),
			float(probabilities[Content.STRIKE_INDEX]) * 100.0,
			game.get_strikeout_chance_per_at_bat() * 100.0,
			game.get_hit_save_chance(1) * 100.0,
			BaseballGameState.format_number(game.get_effective_pitch_rate()),
			BaseballGameState.format_number(game.get_estimated_xp_per_second()),
		]
	)

func _max_ordinary_build(game: BaseballGameState, maximum_level: int) -> void:
	for id in game.training_levels:
		game.training_levels[id] = 400
	for definition in Content.PITCHES:
		if int(definition.required_level) <= maximum_level and str(definition.id) not in game.unlocked_pitches:
			game.unlocked_pitches.append(str(definition.id))
	for definition in Content.BALL_UPGRADES:
		if int(definition.required_level) <= maximum_level:
			game.purchased_ball_upgrades.append(str(definition.id))
	for definition in Content.MILESTONES:
		if int(definition.required_level) <= maximum_level:
			game.purchased_milestones.append(str(definition.id))

func _max_genetics(game: BaseballGameState) -> void:
	for definition in Content.GENETIC_UPGRADES:
		game.genetic_levels[definition.id] = int(definition.max_level)

func _max_eldritch(game: BaseballGameState) -> void:
	for definition in Content.ELDRITCH_UPGRADES:
		game.eldritch_levels[definition.id] = int(definition.max_level)

func _audit_prestige_curves() -> void:
	print("\n=== Prestige award breakpoints ===")
	var game := GameStateScript.new()
	game.genetic_offer_unlocked = true
	game.highest_unlocked = Content.ALIEN_EXHIBITION_INDEX
	for multiplier in [1.0, 8.0, 1000.0, 1000000.0]:
		game.run_xp = BaseballGameState.DNA_XP_THRESHOLD * multiplier
		var award := game.get_potential_dna()
		print("Run XP %-10s × threshold -> %d DNA" % [BaseballGameState.format_number(multiplier), award])
	_expect(_potential_dna_at(game, 1.0) == 1, "DNA should begin at one")
	_expect(_potential_dna_at(game, 8.0) == 2, "Eight normalized run-XP should produce two DNA")
	_expect(_potential_dna_at(game, 1000.0) == 10, "One thousand normalized run-XP should produce ten DNA")

	game.eldritch_offer_unlocked = true
	game.highest_unlocked = Content.ELDRITCH_EXHIBITION_INDEX
	for dna_total in [1.0, 10.0, 1000.0, 1000000.0]:
		game.reality_dna_earned = dna_total
		print("Reality DNA %-10s -> %d Arcana" % [BaseballGameState.format_number(dna_total), game.get_potential_arcana()])
	_expect(_potential_arcana_at(game, 1000.0) == 63, "One thousand reality DNA should produce sixty-three Arcana")
	game.free()

func _potential_dna_at(game: BaseballGameState, multiplier: float) -> int:
	game.run_xp = BaseballGameState.DNA_XP_THRESHOLD * multiplier
	return game.get_potential_dna()

func _potential_arcana_at(game: BaseballGameState, dna_total: float) -> int:
	game.reality_dna_earned = dna_total
	return game.get_potential_arcana()

func _audit_terminal_rules() -> void:
	print("\n=== Terminal-rule audit ===")
	var game := GameStateScript.new()
	game.divine_blessings = ["angels_outfield"]
	game.genetic_levels.prehensile_outfield = 3
	game.eldritch_levels.mirror_clones = 5
	game.eldritch_levels.portal_outfield = 4
	for outcome in Content.HIT_OUTCOME_COUNT:
		var chance := game.get_hit_save_chance(outcome)
		print("%-10s save chance: %6.2f%%" % [Content.OUTCOME_NAMES[outcome], chance * 100.0])
		if outcome == Content.GRAND_SLAM_INDEX:
			_expect(chance == 0.0, "Grand Slams became preventable")
		else:
			_expect(chance == 1.0, "Angels in the Outfield should protect every ordinary hit")
	_expect(Content.OUTCOME_XP.max() == 0.0, "An individual pitch outcome still pays XP")
	print("Only a completed strikeout pays: %s base XP at the human three-strike count." % BaseballGameState.format_number(game.get_strikeout_base_points()))
	game.free()
