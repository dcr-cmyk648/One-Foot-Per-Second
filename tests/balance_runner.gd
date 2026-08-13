extends SceneTree

const Content = preload("res://scripts/content.gd")
const GameStateScript = preload("res://scripts/game_state.gd")

const MAX_SECONDS := 2.0 * 24.0 * 60.0 * 60.0

var game: BaseballGameState
var elapsed := 0.0
var previous_unlocked := 0
var purchase_count := 0
var human_clear_time := -1.0

func _initialize() -> void:
	game = GameStateScript.new()
	game.rng.seed = 424242
	game.loot_drops_enabled = false
	print("One Foot Per Second — v0.10.4 first-human-lifetime pacing simulation")
	print("00:00:00  Level 01  %s" % game.opponents[0].name)
	while elapsed < MAX_SECONDS and not game.genetic_offer_unlocked:
		_purchase_available_content()
		_purchase_training()
		if game.current_opponent != game.highest_unlocked:
			game.current_opponent = game.highest_unlocked
			game._reset_batter_identity()
		game.selected_distance_index = _best_xp_distance()
		var step := _simulation_step()
		game.simulate_offline(step)
		elapsed += step
		if game.highest_unlocked != previous_unlocked:
			previous_unlocked = game.highest_unlocked
			print(
				"%s  Level %02d  %-43s rate=%-9s speed=%-11s quality=%6.2f threat=%6.2f payload=%-8s xp=%s"
				% [
					_format_clock(elapsed),
					game.highest_unlocked + 1,
					game.opponents[game.highest_unlocked].name,
					BaseballGameState.format_number(game.get_pitch_rate()),
					BaseballGameState.format_speed(game.get_velocity_fps()),
					game.get_pitch_quality(),
					game.get_effective_opponent_difficulty(),
					"×%s" % BaseballGameState.format_number(game.get_pitch_potency()),
					BaseballGameState.format_number(game.xp),
				]
			)
			if game.highest_unlocked == Content.ALIEN_EXHIBITION_INDEX:
				human_clear_time = elapsed
	_purchase_available_content()
	print(
		"Human leagues cleared after %s; Xylophax's one-minute exhibition ended at %s; %d purchases; speed=%s; %s pitches/sec; potential DNA=%d; training=%s"
		% [
			_format_clock(human_clear_time),
			_format_clock(elapsed),
			purchase_count,
			BaseballGameState.format_speed(game.get_velocity_fps()),
			BaseballGameState.format_number(game.get_pitch_rate()),
			game.get_potential_dna(),
			str(game.training_levels),
		]
	)
	var succeeded := game.genetic_offer_unlocked and game.get_potential_dna() > 0
	game.free()
	quit(0 if succeeded else 1)

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
	if elapsed < 2.0 * 60.0 * 60.0:
		return 30.0
	if elapsed < 24.0 * 60.0 * 60.0:
		return 300.0
	return 1800.0

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
	# A deliberately simple player model: repeatedly buy the cheapest affordable
	# fundamental while keeping 20% liquid for nearby one-time unlocks.
	for _purchase in 100:
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

func _format_clock(seconds: float) -> String:
	var whole := int(seconds)
	var days := whole / 86400
	var hours := (whole % 86400) / 3600
	var minutes := (whole % 3600) / 60
	var secs := whole % 60
	if days > 0:
		return "%02dd %02d:%02d:%02d" % [days, hours, minutes, secs]
	return "%02d:%02d:%02d" % [hours, minutes, secs]
