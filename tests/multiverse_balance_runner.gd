extends SceneTree

const Content = preload("res://scripts/content.gd")
const GameStateScript = preload("res://scripts/game_state.gd")

# This is a deliberately competent, loot-free player rather than a cheat build.
# The clock is a guardrail, not a promised campaign length: the update's pacing
# targets are soft and every chosen draft remains deterministic for this seed.
const MAX_SECONDS := 120.0 * 24.0 * 60.0 * 60.0
const STEP_SECONDS := 900.0
# Two hours is intentionally much coarser than an interactive return (and so
# remains a conservative release audit), but is not an integer multiple of the
# three half-hour farm/push blocks.  Consecutive idle returns therefore rotate
# through every tactical phase instead of perpetually buying on one phase.
const POST_ELDRITCH_STEP_SECONDS := 2.0 * 60.0 * 60.0
const FARM_BLOCK_SECONDS := 30.0 * 60.0
const GENETIC_PRIORITY := [
	"fast_twitch_everything", "compound_pitching_eye", "ancestral_memory",
	"extra_arms", "parallel_pitching_lobes", "ball_gland", "inherited_scorebook",
	"boss_perk_license", "loaded_draft_dice", "expanded_draft_board",
	"elastic_ucl_colony", "compressed_strike_genome",
]
const ELDRITCH_PRIORITY := [
	"velocity_without_distance", "eyes_behind_moon", "mirror_clones",
	"non_euclidean_bullpen", "unbound_windup", "time_compression", "causal_seams",
	"mercy_is_euclidean", "corrupted_drafts", "fielding_clearance",
	"many_angled_pockets", "memory_of_flesh",
]

var game: BaseballGameState
var elapsed := 0.0
var last_frontier_time := 0.0
var previous_frontier := 0
var purchases := 0
var catalog_purchases := 0
var training_purchases := 0
var genetic_purchases := 0
var eldritch_purchases := 0
var resets := 0
var last_status_day := -1
var boundary_settlements := 0

func _initialize() -> void:
	game = GameStateScript.new()
	game.reset_fresh()
	game.pending_story_dialogs.clear()
	game.loot_drops_enabled = false
	game.rng.seed = 303003
	game.run_seed = 303003
	print("No Hitter — choice-aware multiverse audit")
	_print_checkpoint("BEGIN")
	while elapsed < MAX_SECONDS and not game.cosmos_conquered:
		_resolve_all_choices()
		_buy_meta_upgrades()
		_buy_catalog_and_training()
		if _resolve_story_transition_or_reset():
			continue
		if _finance_physical_license():
			continue
		if _resolve_ready_witnessed_boss():
			continue
		_select_audited_opponent()
		var simulation_step := _simulation_step_seconds()
		game.simulate_active_time(simulation_step)
		_settle_long_interval_residue(simulation_step)
		elapsed += simulation_step
		var status_day := int(elapsed / (24.0 * 60.0 * 60.0))
		if status_day > last_status_day:
			last_status_day = status_day
			if status_day > 0:
				_print_checkpoint("DAY %03d" % status_day)
		if game.highest_unlocked != previous_frontier:
			previous_frontier = game.highest_unlocked
			last_frontier_time = elapsed
			if (
				previous_frontier % 3 == 0
				or previous_frontier in [
					Content.HUMAN_FINAL_INDEX,
					Content.ALIEN_FINAL_INDEX,
					Content.ELDRITCH_FINAL_INDEX,
					Content.FINAL_BOSS_INDEX,
				]
			):
				_print_checkpoint("LEVEL %03d" % (previous_frontier + 1))
		if _perform_strategic_prestige():
			continue

	_resolve_all_choices()
	_print_checkpoint("COSMIC VICTORY" if game.cosmos_conquered else "TIME LIMIT")
	print("RESULT  %s after %s • %d resets • %d purchases (%d catalog, %d Training, %d DNA, %d Arcana)" % [
		"victory" if game.cosmos_conquered else "incomplete",
		_format_clock(elapsed), resets, purchases, catalog_purchases,
		training_purchases, genetic_purchases, eldritch_purchases,
	])
	print("META  DNA=%d (+%d ready) Arcana=%d (+%d ready) genetics=%s eldritch=%s" % [
		game.dna, game.get_potential_dna(), game.arcana, game.get_potential_arcana(),
		str(game.genetic_levels), str(game.eldritch_levels),
	])
	print("FINAL GATE  speed=%s • level=%03d • audit boundary settlements=%d" % [
		BaseballGameState.format_speed(game.get_velocity_fps()),
		game.highest_unlocked + 1,
		boundary_settlements,
	])
	var success := game.cosmos_conquered
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
	var metrics := candidate.get_at_bat_metrics(frontier)
	var speed_anchor := float(Content.campaign_level(frontier).get("speed_anchor_fps", 1.0))
	var speed_ratio := candidate.get_velocity_fps() / maxf(speed_anchor, 1.0)
	return (
		log(maxf(float(metrics.strikeout_probability), 1.0e-18))
		+ log(maxf(candidate.get_estimated_xp_per_second(frontier), 1.0e-18)) * 0.30
		+ log(maxf(speed_ratio, 1.0e-18)) * 0.75
		+ log(maxf(candidate.get_mastery_multiplier(), 1.0e-18)) * 0.20
		+ log(maxf(candidate.get_pitch_potency(), 1.0e-18)) * 0.08
	)

func _resolve_story_transition_or_reset() -> bool:
	if not game.pending_special_encounter.is_empty():
		_resolve_all_choices()
		if game.begin_special_encounter(game.pending_special_encounter):
			_print_checkpoint("FIRST CONTACT")
			return true
	if game.is_alien_exhibition_blocked():
		if not game.genetic_offer_unlocked:
			_witness_scripted_grand_slams(true)
			game.accept_alien_help()
		var award := game.perform_genetic_rebirth()
		if award > 0:
			resets += 1
			previous_frontier = 0
			last_frontier_time = elapsed
			print("%s  GENETIC REBIRTH +%d DNA" % [_format_clock(elapsed), award])
			return true
	if game.is_eldritch_exhibition_blocked():
		if not game.eldritch_offer_unlocked:
			_witness_scripted_grand_slams(false)
		var award := game.perform_eldritch_ascension()
		if award > 0:
			resets += 1
			previous_frontier = 0
			last_frontier_time = elapsed
			print("%s  ELDRITCH ASCENSION +%d ARCANA" % [_format_clock(elapsed), award])
			return true
	return false

func _witness_scripted_grand_slams(alien: bool) -> void:
	var needed := (
		BaseballGameState.ALIEN_EXHIBITION_GRAND_SLAMS_REQUIRED - game.alien_exhibition_grand_slams
		if alien
		else BaseballGameState.ELDRITCH_EXHIBITION_GRAND_SLAMS_REQUIRED - game.eldritch_exhibition_grand_slams
	)
	for _slam in maxi(needed, 0):
		var summary := game._empty_resolution_summary()
		game._apply_pitch_outcome(summary, Content.GRAND_SLAM_INDEX, -1.0, 1, false)
		game._apply_resolution(summary, true)
		elapsed += game.get_pitch_cooldown_seconds() + game.get_resolved_flight_seconds()

func _resolve_ready_witnessed_boss() -> bool:
	if not game.is_sticky_boss_active() or not game.is_opponent_ready_for_strikeout():
		return false
	# Mastery cannot waive a physical velocity trial. Let the normal economy loop
	# keep training until the pitch can actually reach the boss.
	if game.is_speed_gate_blocked():
		return false
	var metrics := game.get_at_bat_metrics()
	if float(metrics.strikeout_probability) <= 0.0:
		return false
	var expected_wait := float(metrics.cycle_seconds) / maxf(float(metrics.strikeout_probability), 1.0e-12)
	elapsed += minf(expected_wait, 30.0 * 24.0 * 60.0 * 60.0)
	game._check_opponent_unlock(1.0, true)
	_resolve_all_choices()
	return true

func _finance_physical_license() -> bool:
	var frontier := game.highest_unlocked
	if frontier not in [Content.ALIEN_FINAL_INDEX, Content.FINAL_BOSS_INDEX]:
		return false
	if not game.is_speed_gate_blocked(frontier):
		return false
	var best := 0
	var best_rate := 0.0
	for index in frontier:
		var rate := game.get_estimated_xp_per_second(index)
		if rate > best_rate:
			best_rate = rate
			best = index
	if best_rate <= 0.0:
		return false
	if game.current_opponent != best:
		game.set_current_opponent(best)
	# A competent player who has reached a published velocity trial stops buying
	# unrelated fundamentals and farms the best known batter for the next exact
	# ten Speed ranks or unlocked Speed facility. Advance that savings plan analytically
	# instead of iterating thousands of UI-sized 15-minute blocks.
	for _batch in 1000:
		var bought_speed_project := false
		for definition_value in Content.MILESTONES:
			var definition: Dictionary = definition_value
			if "speed" in (definition.get("stats", []) as Array) and game.can_buy_milestone(str(definition.id)):
				game.buy_milestone(str(definition.id))
				purchases += 1
				catalog_purchases += 1
				bought_speed_project = true
		if not game.is_speed_gate_blocked(frontier):
			break
		if game.can_buy_training_batch("velocity", 10):
			game.buy_training_batch("velocity", 10)
			purchases += 1
			training_purchases += 10
			continue
		if bought_speed_project:
			continue
		var next_cost := game.get_training_batch_cost("velocity", 10)
		if next_cost >= BaseballGameState.MAX_NUMBER:
			return false
		best_rate = game.get_estimated_xp_per_second(best)
		if best_rate <= 0.0:
			return false
		var required_xp := maxf(next_cost - game.xp, 0.0)
		var farm_seconds := maxf(required_xp / best_rate, 1.0)
		# Do not mistake an asymptotic body ceiling for a sensible savings target.
		# If ten more ranks cost over four hours at the best known farm, ordinary
		# simulation gets a chance to trigger the much stronger prestige decision.
		if farm_seconds > 4.0 * 60.0 * 60.0 or elapsed + farm_seconds >= MAX_SECONDS:
			return false
		# This is a release-time economy audit, not an offline-resolution audit (that
		# path has its own coverage). Crediting the exact expected income avoids
		# resolving millions of pitches once the published Mach/c gate dominates the
		# purchase plan, while preserving the same elapsed time and prestige totals.
		game.xp = minf(BaseballGameState.MAX_NUMBER, game.xp + required_xp)
		game.run_xp = minf(BaseballGameState.MAX_NUMBER, game.run_xp + required_xp)
		game.lifetime_xp = minf(BaseballGameState.MAX_NUMBER, game.lifetime_xp + required_xp)
		game.current_run_seconds = minf(
			BaseballGameState.MAX_NUMBER,
			game.current_run_seconds + farm_seconds
		)
		elapsed += farm_seconds
	if game.is_speed_gate_blocked(frontier):
		return false
	game.set_current_opponent(frontier)
	last_frontier_time = elapsed
	_print_checkpoint("PHYSICAL LICENSE")
	return true

func _perform_strategic_prestige() -> bool:
	# Reaching the final authored opponent is the audit's win condition, not a
	# signal to optimize the next reality. Once Octathulhu is available, keep
	# farming its Mastery and let `_resolve_ready_witnessed_boss()` supply the
	# witnessed final K. The old policy ascended at the end of the exact interval
	# that made the boss ready, one loop before that resolver could run.
	if game.highest_unlocked >= Content.FINAL_BOSS_INDEX:
		return false
	var stalled := elapsed - last_frontier_time
	if game.eldritch_offer_unlocked and game.eldritch_ascensions > 0:
		# Inside an eldritch reality, rebuild genetics through several lives before
		# spending accumulated reality DNA on another ascension.
		if game.highest_unlocked >= Content.ELDRITCH_EXHIBITION_INDEX:
			if stalled >= 8.0 * 60.0 * 60.0 and game.get_potential_arcana() > 0 and _has_unfinished_meta_targets(Content.ELDRITCH_UPGRADES, ELDRITCH_PRIORITY, game.eldritch_levels):
				var arcana_award := game.perform_eldritch_ascension()
				if arcana_award > 0:
					resets += 1
					previous_frontier = 0
					last_frontier_time = elapsed
					print("%s  DEEPER ASCENSION +%d ARCANA" % [_format_clock(elapsed), arcana_award])
					return true
		# Two farm returns may precede the rotating push return.  Give the
		# phase-safe two-hour audit a complete three-return cycle before calling
		# a healthy farm streak a DNA-reset stall.
		elif stalled >= 6.0 * 60.0 * 60.0 and game.get_potential_dna() > 0 and _has_unfinished_meta_targets(Content.GENETIC_UPGRADES, GENETIC_PRIORITY, game.genetic_levels):
			var dna_award := game.perform_genetic_rebirth()
			if dna_award > 0:
				resets += 1
				previous_frontier = 0
				last_frontier_time = elapsed
				print("%s  REALITY DNA LOOP +%d" % [_format_clock(elapsed), dna_award])
				return true
	elif game.genetic_offer_unlocked and not game.eldritch_offer_unlocked:
		# The first alien campaign is intentionally a multi-rebirth climb.
		if stalled >= 2.0 * 60.0 * 60.0 and game.get_potential_dna() > 0 and _has_unfinished_meta_targets(Content.GENETIC_UPGRADES, GENETIC_PRIORITY, game.genetic_levels):
			var dna_award := game.perform_genetic_rebirth()
			if dna_award > 0:
				resets += 1
				previous_frontier = 0
				last_frontier_time = elapsed
				print("%s  DNA LOOP +%d" % [_format_clock(elapsed), dna_award])
				return true
	return false

func _select_audited_opponent() -> void:
	var frontier := game.highest_unlocked
	var best := frontier
	var best_rate := game.get_estimated_xp_per_second(frontier)
	for index in frontier + 1:
		var rate := game.get_estimated_xp_per_second(index)
		if rate > best_rate:
			best_rate = rate
			best = index
	# Two 30-minute blocks farm the best known payout; every third block pushes
	# frontier mastery. This models the intended tactical fallback without letting
	# a scorer wait forever for one mathematically perfect purchase.
	var pushing_frontier := int(elapsed / FARM_BLOCK_SECONDS) % 3 == 2
	var target := frontier if pushing_frontier or best == frontier else best
	if target != game.current_opponent:
		game.set_current_opponent(target)

func _simulation_step_seconds() -> float:
	# Long physical-license grinds do not need four UI-like balance decisions per
	# hour. Chunk them into four-hour blocks so this deterministic audit remains a
	# practical release check while still buying between meaningful idle returns.
	if (
		game.highest_unlocked in [Content.ALIEN_FINAL_INDEX, Content.FINAL_BOSS_INDEX]
		and game.is_speed_gate_blocked(game.highest_unlocked)
	):
		return 4.0 * 60.0 * 60.0
	# The first human and alien climbs retain 15-minute purchasing resolution so
	# their pacing audit remains useful. Once eldritch prestige has been witnessed,
	# every resolution path is closed-form and the remaining check is whether the
	# multi-reality economy can reach its authored gates at all. Two-hour idle
	# decisions are deliberately conservative (purchases happen later, never sooner)
	# while keeping this release gate practical to rerun. Two hours rotates through
	# the runner's three 30-minute farm/push phases instead of phase-locking.
	if game.eldritch_ascensions > 0:
		return POST_ELDRITCH_STEP_SECONDS
	return STEP_SECONDS

func _settle_long_interval_residue(simulation_step: float) -> void:
	if simulation_step <= 0.0:
		return
	if not game.is_pitch_in_flight():
		return
	# Every audit return is an artificial decision boundary (15 minutes before
	# eldritch play and two hours after it). Aggregate expected rewards for the
	# completed interval have already been applied; any remaining authoritative
	# volley is only boundary residue. Mark it target-lost and clear the cycle so
	# the next return cannot repeatedly spend exact transitions replaying visual
	# carryover. This is conservative: it can only discard that residual volley.
	game._lose_target_for_active_volleys("audit_boundary")
	game._clear_pitch_cycle()
	boundary_settlements += 1

func _buy_catalog_and_training() -> void:
	# Strong one-time upgrades remain the priority, but the 256x Facility lane
	# means the audit normally has only one or two actually affordable choices.
	for _pass in 120:
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
		var bought := game.buy_ball_upgrade(str(selected.id)) if str(selected.kind) == "ball" else game.buy_milestone(str(selected.id))
		if not bought:
			break
		purchases += 1
		catalog_purchases += 1

	var budget := game.xp * 0.40
	var ranks_bought_this_visit := 0
	while ranks_bought_this_visit < 180:
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
				"speed": 8.0, "quality": 5.0, "mastery": 2.8,
				"recovery": 2.5, "payload": 2.0, "drag": 2.0,
				"xp": 1.6, "lineup": 1.2, "hit_delay": 1.0,
			}.get(stat, 0.65))
			var priority := weight / maxf(log(cost + 10.0), 1.0)
			if (
				id == "velocity"
				and game.highest_unlocked in [Content.ALIEN_FINAL_INDEX, Content.FINAL_BOSS_INDEX]
				and game.is_speed_gate_blocked(game.highest_unlocked)
			):
				priority += 1000.0
			if priority > best_priority or (is_equal_approx(priority, best_priority) and cost < best_cost):
				best_priority = priority
				best_cost = cost
				best_id = id
		if best_id.is_empty():
			break
		# Buy at most ten adjacent ranks from the selected lane per decision. The
		# exact batch price is the sum of sequential rounded costs, while re-scoring
		# after ten ranks remains close to the greedy player and avoids running the
		# full achievement catalog 180 times in every closed-form time block.
		var quantity := 1
		var ten_cost := game.get_training_batch_cost(best_id, 10)
		if (
			ranks_bought_this_visit + 10 <= 180
			and ten_cost <= budget
			and ten_cost <= game.xp
		):
			quantity = 10
			best_cost = ten_cost
		game.buy_training_batch(best_id, quantity)
		budget -= best_cost
		purchases += 1
		training_purchases += quantity
		ranks_bought_this_visit += quantity

func _buy_meta_upgrades() -> void:
	var bought := true
	while bought:
		bought = false
		for id in GENETIC_PRIORITY:
			if _below_authored_max(Content.GENETIC_UPGRADES, id, game.genetic_levels) and game.can_buy_genetic(id):
				game.buy_genetic(id)
				purchases += 1
				genetic_purchases += 1
				bought = true
		for id in ELDRITCH_PRIORITY:
			if _below_authored_max(Content.ELDRITCH_UPGRADES, id, game.eldritch_levels) and game.can_buy_eldritch(id):
				game.buy_eldritch(id)
				purchases += 1
				eldritch_purchases += 1
				bought = true

func _below_authored_max(definitions: Array, id: String, levels: Dictionary) -> bool:
	for definition_value in definitions:
		var definition: Dictionary = definition_value
		if str(definition.id) != id:
			continue
		return definition.has("max_level") and int(levels.get(id, 0)) < int(definition.max_level)
	return false

func _has_unfinished_meta_targets(definitions: Array, priorities: Array, levels: Dictionary) -> bool:
	for id_value in priorities:
		if _below_authored_max(definitions, str(id_value), levels):
			return true
	return false

func _print_checkpoint(label: String) -> void:
	var metrics := game.get_at_bat_metrics()
	print("%s  %-18s L%03d %-30s speed=%-12s Strike=%7.3f%% K=%8.4f%% Q=%-10s D=%-10s XP=%-9s V=%d DNA=%d(+%d) A=%d(+%d)" % [
		_format_clock(elapsed), label, game.highest_unlocked + 1,
		str(game.get_current_opponent().name), BaseballGameState.format_speed(game.get_velocity_fps()),
		float((metrics.probabilities as Array)[Content.STRIKE_INDEX]) * 100.0,
		float(metrics.strikeout_probability) * 100.0,
		BaseballGameState.format_number(game.get_pitch_quality()),
		BaseballGameState.format_number(game.get_effective_opponent_difficulty()),
		BaseballGameState.format_number(game.xp), int(game.training_levels.velocity),
		game.dna, game.get_potential_dna(), game.arcana, game.get_potential_arcana(),
	])

func _format_clock(seconds: float) -> String:
	var whole := int(maxf(seconds, 0.0))
	var days := whole / 86400
	var hours := (whole % 86400) / 3600
	var minutes := (whole % 3600) / 60
	var secs := whole % 60
	if days > 0:
		return "%02dd %02d:%02d:%02d" % [days, hours, minutes, secs]
	return "%02d:%02d:%02d" % [hours, minutes, secs]
