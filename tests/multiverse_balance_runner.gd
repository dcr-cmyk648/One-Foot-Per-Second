extends SceneTree

const Content = preload("res://scripts/content.gd")
const GameStateScript = preload("res://scripts/game_state.gd")
# The audited route currently finishes around day 66.5. A 75-day ceiling keeps
# enough variance for balance edits while still catching a serious regression.
const MAX_SECONDS := 75.0 * 24.0 * 60.0 * 60.0

var game: BaseballGameState
var elapsed := 0.0
var previous_level := 0
var purchase_count := 0
var reset_count := 0

func _initialize() -> void:
	game = GameStateScript.new()
	game.rng.seed = 303003
	game.loot_drops_enabled = false
	print("One Foot Per Second — v0.10.4 multiverse pacing simulation")
	_log_checkpoint("BEGIN")
	while elapsed < MAX_SECONDS and not game.cosmos_conquered:
		_purchase_meta_upgrades()
		_purchase_available_content()
		_purchase_training()
		if _perform_story_or_strategy_reset():
			continue
		if game.current_opponent != game.highest_unlocked:
			game.current_opponent = game.highest_unlocked
			game._reset_batter_identity()
		game.selected_distance_index = _best_xp_distance()
		var step := _simulation_step()
		game.simulate_offline(step)
		elapsed += step
		if game.highest_unlocked != previous_level:
			previous_level = game.highest_unlocked
			if previous_level % 5 == 0 or previous_level in [Content.ALIEN_EXHIBITION_INDEX, Content.ELDRITCH_EXHIBITION_INDEX, Content.FINAL_BOSS_INDEX]:
				_log_checkpoint("LEVEL %02d" % (previous_level + 1))
	_purchase_available_content()
	_log_checkpoint("COSMIC VICTORY" if game.cosmos_conquered else "TIME LIMIT")
	print(
		"Result: %s after %s; %d resets; %d purchases; DNA=%d (+%d ready) Arcana=%d (+%d ready); runXP=%s; genetic=%s; eldritch=%s"
		% [
			"victory" if game.cosmos_conquered else "incomplete",
			_format_clock(elapsed),
			reset_count,
			purchase_count,
			game.dna,
			game.get_potential_dna(),
			game.arcana,
			game.get_potential_arcana(),
			BaseballGameState.format_number(game.run_xp),
			str(game.genetic_levels),
			str(game.eldritch_levels),
		]
	)
	var succeeded := game.cosmos_conquered
	game.free()
	quit(0 if succeeded else 1)

func _perform_story_or_strategy_reset() -> bool:
	if game.is_alien_exhibition_blocked():
		if game.genetic_offer_unlocked and game.get_potential_dna() > 0:
			var award := game.perform_genetic_rebirth()
			reset_count += 1
			print("%s  GENETIC REBIRTH +%d DNA" % [_format_clock(elapsed), award])
			_purchase_meta_upgrades()
			previous_level = 0
			return true
		return false
	# The genetic layer is intentionally played as two increasingly deep loops:
	# first revisit the now-trivial human ladder, then harvest the midpoint of
	# the alien leagues before committing to the eldritch unlock push.
	if not game.eldritch_offer_unlocked:
		var dna_ready := game.get_potential_dna()
		if game.genetic_rebirths == 1 and game.highest_unlocked >= Content.ALIEN_EXHIBITION_INDEX and dna_ready >= 35:
			var second_award := game.perform_genetic_rebirth()
			reset_count += 1
			print("%s  HUMAN DNA LOOP +%d" % [_format_clock(elapsed), second_award])
			_purchase_meta_upgrades()
			previous_level = 0
			return true
		if game.genetic_rebirths == 2 and game.highest_unlocked >= 34 and dna_ready >= 70:
			var deep_award := game.perform_genetic_rebirth()
			reset_count += 1
			print("%s  ALIEN DNA HARVEST +%d" % [_format_clock(elapsed), deep_award])
			_purchase_meta_upgrades()
			previous_level = 0
			return true
		if game.genetic_rebirths >= 3 and game.highest_unlocked >= 37 and dna_ready >= 300 and _has_unbought_genetics():
			var championship_award := game.perform_genetic_rebirth()
			reset_count += 1
			print("%s  CHAMPIONSHIP DNA HARVEST +%d" % [_format_clock(elapsed), championship_award])
			_purchase_meta_upgrades()
			previous_level = 0
			return true
	if game.is_eldritch_exhibition_blocked():
		if not game.eldritch_offer_unlocked:
			return false
		# A second genetic lifetime converts the alien league's much larger XP
		# scale into DNA before the whole reality is discarded.
		if game.genetic_rebirths < 2 and game.get_potential_dna() > 0:
			var dna_award := game.perform_genetic_rebirth()
			reset_count += 1
			print("%s  LATE GENETIC REBIRTH +%d DNA" % [_format_clock(elapsed), dna_award])
			_purchase_meta_upgrades()
			previous_level = 0
			return true
		if game.get_potential_arcana() > 0:
			var arcana_award := game.perform_eldritch_ascension()
			reset_count += 1
			print("%s  ELDRITCH ASCENSION +%d ARCANA" % [_format_clock(elapsed), arcana_award])
			_purchase_meta_upgrades()
			previous_level = 0
			return true
	if game.highest_unlocked >= Content.ELDRITCH_EXHIBITION_INDEX and game.eldritch_ascensions > 0:
		if game.genetic_rebirths < 2 and game.get_potential_dna() > 0:
			var repeat_dna := game.perform_genetic_rebirth()
			reset_count += 1
			print("%s  REALITY DNA HARVEST +%d" % [_format_clock(elapsed), repeat_dna])
			_purchase_meta_upgrades()
			previous_level = 0
			return true
		if int(game.eldritch_levels.velocity_without_distance) < 4 and game.get_potential_arcana() > 0:
			var repeat_arcana := game.perform_eldritch_ascension()
			reset_count += 1
			print("%s  DEEPER ELDRITCH ASCENSION +%d" % [_format_clock(elapsed), repeat_arcana])
			_purchase_meta_upgrades()
			previous_level = 0
			return true
	return false

func _has_unbought_genetics() -> bool:
	for definition in Content.GENETIC_UPGRADES:
		if int(game.genetic_levels.get(str(definition.id), 0)) < int(definition.max_level):
			return true
	return false

func _purchase_meta_upgrades() -> void:
	var genetic_priority := [
		"fast_twitch_everything", "compound_pitching_eye", "ancestral_memory",
		"extra_arms", "parallel_pitching_lobes", "compressed_strike_genome", "prehensile_outfield",
		"elastic_ucl_colony", "ball_gland",
		"migratory_instinct", "autonomic_coach", "predator_scouting", "autonomic_wardrobe",
	]
	var eldritch_priority := [
		"mirror_clones", "non_euclidean_bullpen", "portal_outfield", "velocity_without_distance", "time_compression",
		"eyes_behind_moon", "mercy_is_euclidean", "causal_seams",
		"memory_of_flesh",
	]
	var bought := true
	while bought:
		bought = false
		for id in genetic_priority:
			if game.can_buy_genetic(id):
				game.buy_genetic(id)
				purchase_count += 1
				bought = true
		for id in eldritch_priority:
			if game.can_buy_eldritch(id):
				game.buy_eldritch(id)
				purchase_count += 1
				bought = true

func _purchase_available_content() -> void:
	var bought := true
	while bought:
		bought = false
		for definition in Content.PITCHES:
			if game.can_buy_pitch(str(definition.id)):
				game.buy_pitch(str(definition.id))
				purchase_count += 1
				bought = true
		for definition in Content.BALL_UPGRADES:
			if game.can_buy_ball_upgrade(str(definition.id)):
				game.buy_ball_upgrade(str(definition.id))
				purchase_count += 1
				bought = true
		for definition in Content.MILESTONES:
			if game.can_buy_milestone(str(definition.id)):
				game.buy_milestone(str(definition.id))
				purchase_count += 1
				bought = true

func _purchase_training() -> void:
	for _purchase in 150:
		var cheapest_id := ""
		var cheapest_cost := BaseballGameState.MAX_NUMBER
		for id in game.training_levels:
			var cost := game.get_training_cost(str(id))
			if cost < cheapest_cost:
				cheapest_cost = cost
				cheapest_id = str(id)
		if cheapest_id.is_empty() or cheapest_cost > game.xp * 0.80:
			return
		game.buy_training(cheapest_id)
		purchase_count += 1

func _best_xp_distance() -> int:
	var original := game.selected_distance_index
	var best_index := 0
	var best_rate := -1.0
	for index in game.get_max_distance_index() + 1:
		game.selected_distance_index = index
		var rate := game.get_estimated_xp_per_second(game.current_opponent)
		if rate > best_rate:
			best_rate = rate
			best_index = index
	game.selected_distance_index = original
	return best_index

func _simulation_step() -> float:
	if elapsed < 6.0 * 60.0 * 60.0:
		return 60.0
	if elapsed < 24.0 * 60.0 * 60.0:
		return 300.0
	if elapsed < 7.0 * 24.0 * 60.0 * 60.0:
		return 1800.0
	return 10800.0

func _log_checkpoint(label: String) -> void:
	print(
		"%s  %-14s L%02d %-35s speed=%-10s rate=%-7s Q=%6.2f T=%6.2f D=%d(+%d) A=%d(+%d)"
		% [
			_format_clock(elapsed),
			label,
			game.highest_unlocked + 1,
			str(game.opponents[game.highest_unlocked].name),
			BaseballGameState.format_speed(game.get_velocity_fps()),
			BaseballGameState.format_number(game.get_pitch_rate()),
			game.get_pitch_quality(),
			game.get_effective_opponent_difficulty(),
			game.dna,
			game.get_potential_dna(),
			game.arcana,
			game.get_potential_arcana(),
		]
	)

func _format_clock(seconds: float) -> String:
	var whole := int(seconds)
	var days := whole / 86400
	var hours := (whole % 86400) / 3600
	var minutes := (whole % 3600) / 60
	var secs := whole % 60
	if days > 0:
		return "%02dd %02d:%02d:%02d" % [days, hours, minutes, secs]
	return "%02d:%02d:%02d" % [hours, minutes, secs]
