extends SceneTree

const Content = preload("res://scripts/content.gd")
const GameStateScript = preload("res://scripts/game_state.gd")

const MAX_SECONDS := 48.0 * 60.0 * 60.0
const STEP_SECONDS := 30.0

var game: BaseballGameState
var elapsed := 0.0
var previous_frontier := 0
var purchases := 0
var catalog_purchases := 0
var training_purchases := 0

func _initialize() -> void:
	game = GameStateScript.new()
	game.reset_fresh()
	game.pending_story_dialogs.clear()
	game.loot_drops_enabled = false
	game.rng.seed = 424242
	game.run_seed = 424242
	print("No Hitter — choice-aware first-lifetime audit")
	_print_frontier()
	while elapsed < MAX_SECONDS and not game.genetic_offer_unlocked:
		_resolve_all_choices()
		_buy_catalog_and_training()
		if not game.pending_special_encounter.is_empty():
			game.begin_special_encounter(game.pending_special_encounter)
			continue
		if game.is_alien_exhibition_blocked():
			var exhibition_summary := game._empty_resolution_summary()
			game._resolve_aggregate_time(STEP_SECONDS, exhibition_summary, false, true)
			game._apply_resolution(exhibition_summary, false)
			elapsed += STEP_SECONDS
			if game.is_alien_help_available():
				game.accept_alien_help()
			continue
		if game.current_opponent != game.highest_unlocked:
			game.set_current_opponent(game.highest_unlocked)
		if game.is_sticky_boss_active() and game.is_opponent_ready_for_strikeout():
			# Offline aggregation is intentionally forbidden from crossing witnessed
			# bosses. The audit charges one expected frontier strikeout cycle, then
			# supplies the witnessed final K explicitly.
			var metrics := game.get_at_bat_metrics()
			elapsed += float(metrics.cycle_seconds) / maxf(float(metrics.strikeout_probability), 0.000001)
			game._check_opponent_unlock(1.0, true)
		else:
			game.simulate_active_time(STEP_SECONDS)
			elapsed += STEP_SECONDS
		if game.highest_unlocked != previous_frontier:
			previous_frontier = game.highest_unlocked
			_print_frontier()
	print("RESULT  time=%s level=%d purchases=%d (%d catalog, %d Training) XP=%s speed=%s recovery=%s/s quality=%s DNA=%d" % [
		_format_clock(elapsed),
		game.highest_unlocked + 1,
		purchases,
		catalog_purchases,
		training_purchases,
		BaseballGameState.format_number(game.xp),
		BaseballGameState.format_speed(game.get_velocity_fps()),
		BaseballGameState.format_number(game.get_recovery_rate()),
		BaseballGameState.format_rating(game.get_pitch_quality()),
		game.get_potential_dna(),
	])
	print("TRAINING %s" % str(game.training_levels))
	print("CATALOG %d Balls, %d Facilities" % [game.purchased_ball_upgrades.size(), game.purchased_milestones.size()])
	var success := game.genetic_offer_unlocked
	game.free()
	quit(0 if success else 1)

func _resolve_all_choices() -> void:
	while not game.pending_run_choices.is_empty():
		var choice: Dictionary = game.pending_run_choices[0]
		var best_index := 0
		var best_score := -BaseballGameState.MAX_NUMBER
		for option_index in (choice.options as Array).size():
			var candidate = GameStateScript.new()
			candidate.apply_save_data(game.to_save_data())
			candidate.loot_drops_enabled = false
			candidate.resolve_run_choice(str(choice.id), option_index)
			var score := _state_score(candidate)
			candidate.free()
			if score > best_score:
				best_score = score
				best_index = option_index
		game.resolve_run_choice(str(choice.id), best_index)

func _state_score(candidate: BaseballGameState) -> float:
	var frontier := candidate.highest_unlocked
	var speed_anchor := float(Content.campaign_level(frontier).get("speed_anchor_fps", 1.0))
	var speed_ratio := candidate.get_velocity_fps() / maxf(speed_anchor, 1.0)
	var metrics := candidate.get_at_bat_metrics(frontier)
	return (
		log(maxf(float(metrics.strikeout_probability), 1.0e-12))
		+ log(maxf(candidate.get_estimated_xp_per_second(frontier), 1.0e-12)) * 0.35
		+ log(maxf(speed_ratio, 1.0e-9)) * 0.45
		+ log(maxf(candidate.get_mastery_multiplier(), 1.0e-9)) * 0.20
	)

func _buy_catalog_and_training() -> void:
	# Buy strong one-time content before incremental Training. This is an
	# intentionally optimistic audit: an available purchase is taken immediately
	# when its actual frontier score improves. The future UI may leave the choice
	# to the player, but balance must survive a competent greedy policy.
	for _pass in 300:
		var candidates: Array[Dictionary] = []
		for definition_value in Content.BALL_UPGRADES:
			var definition: Dictionary = definition_value
			if game.can_buy_ball_upgrade(str(definition.id)):
				candidates.append({"kind": "ball", "id": str(definition.id), "cost": game.get_ball_upgrade_cost(str(definition.id))})
		for definition_value in Content.MILESTONES:
			var definition: Dictionary = definition_value
			if game.can_buy_milestone(str(definition.id)):
				candidates.append({"kind": "facility", "id": str(definition.id), "cost": game.get_milestone_cost(str(definition.id))})
		if candidates.is_empty():
			break
		candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a.cost) < float(b.cost))
		var selected: Dictionary = candidates[0]
		var bought := (
			game.buy_ball_upgrade(str(selected.id))
			if str(selected.kind) == "ball"
			else game.buy_milestone(str(selected.id))
		)
		if not bought:
			break
		purchases += 1
		catalog_purchases += 1

	# Spend at most 35% of liquid XP on the best affordable next Training rank
	# each visit. This keeps room for the next meaningful catalog purchase while
	# still modeling a player who continuously pumps fundamentals.
	var budget := game.xp * 0.35
	for _rank in 120:
		var best_id := ""
		var best_cost := BaseballGameState.MAX_NUMBER
		var best_priority := -BaseballGameState.MAX_NUMBER
		for id_value in game.training_levels.keys():
			var id := str(id_value)
			var cost := game.get_training_cost(id)
			if cost > budget or cost > game.xp:
				continue
			var definition := Content.training_by_id(id)
			var stat := str((definition.get("stats", [""]) as Array)[0])
			var weight: float = float({
				"speed": 6.0,
				"quality": 3.0,
				"mastery": 2.4,
				"recovery": 2.0,
				"payload": 1.8,
				"xp": 1.6,
				"drag": 1.4,
				"lineup": 1.2,
				"hit_delay": 1.0,
			}.get(stat, 0.7))
			var priority := float(weight) / maxf(log(cost + 10.0), 1.0)
			if priority > best_priority or (is_equal_approx(priority, best_priority) and cost < best_cost):
				best_priority = priority
				best_cost = cost
				best_id = id
		if best_id.is_empty():
			break
		game.buy_training(best_id)
		budget -= best_cost
		purchases += 1
		training_purchases += 1

func _print_frontier() -> void:
	var metrics := game.get_at_bat_metrics()
	print("%s  L%03d  %-34s speed=%-12s recovery=%-7s Q=%-7.3f D=%-7.3f Strike=%6.2f%% K=%7.3f%% mastery=%s XP=%s" % [
		_format_clock(elapsed),
		game.highest_unlocked + 1,
		str(game.get_current_opponent().name),
		BaseballGameState.format_speed(game.get_velocity_fps()),
		BaseballGameState.format_number(game.get_recovery_rate()),
		game.get_pitch_quality(),
		game.get_effective_opponent_difficulty(),
		float((metrics.probabilities as Array)[Content.STRIKE_INDEX]) * 100.0,
		float(metrics.strikeout_probability) * 100.0,
		BaseballGameState.format_number(game.get_mastery_requirement()),
		BaseballGameState.format_number(game.xp),
	])

func _format_clock(seconds: float) -> String:
	var whole := int(seconds)
	var days := whole / 86400
	var hours := (whole % 86400) / 3600
	var minutes := (whole % 3600) / 60
	var secs := whole % 60
	if days > 0:
		return "%02dd %02d:%02d:%02d" % [days, hours, minutes, secs]
	return "%02d:%02d:%02d" % [hours, minutes, secs]
