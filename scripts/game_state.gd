class_name BaseballGameState
extends Node

signal batch_resolved(summary: Dictionary)
signal progression_changed(message: String)
signal save_status_changed(message: String)
signal achievement_unlocked(definition: Dictionary, total_unlocked: int)

const Content = preload("res://scripts/content.gd")
const SAVE_PATH := "user://one_foot_per_second_save.json"
const SAVE_BACKUP_PATH := "user://one_foot_per_second_save.backup.json"
const SAVE_TEMP_PATH := "user://one_foot_per_second_save.pending.json"
const SAVE_CORRUPT_PATH := "user://one_foot_per_second_save.unreadable.json"
const SAVE_VERSION := 17
const MAX_IMPORTED_SAVE_CHARACTERS := 16 * 1024 * 1024
const SIMULATION_STEP := 0.10
const OFFLINE_AGGREGATE_CYCLE_THRESHOLD := 8.0
const MAX_NUMBER := 1.0e280
const MAX_OFFLINE_SECONDS := 7.0 * 24.0 * 60.0 * 60.0
const EXHIBITION_SECONDS := 60.0
const FASTEST_RECORDED_PITCH_MPH := 105.8
const HUMAN_SPEED_CAP_FPS := FASTEST_RECORDED_PITCH_MPH * 2.0 / 0.681818
const SPEED_OF_SOUND_FPS := 1125.33
const ALIEN_SPEED_CAP_FPS := SPEED_OF_SOUND_FPS * 12.0
const SPEED_OF_LIGHT_FPS := 983571056.0
const DNA_XP_THRESHOLD := 1.0e10
const STRIKEOUT_POINTS_PER_REQUIRED_STRIKE := 5.0
const OPENING_STRIKEOUT_BASE_POINTS := 5.0
const BASE_VELOCITY_FPS := 1.0
const VELOCITY_PER_RANK_FPS := 0.15
const QUALITY_PER_RANK := 0.08
const BASE_RECOVERY_RATE := 0.25
const RECOVERY_PER_RANK := 0.035
const RECOVERY_MAX_RANK := 26
const LINEUP_SECONDS_PER_RANK := 0.15
const LINEUP_MIN_SECONDS := 1.50
const LINEUP_MAX_RANK := 10
const HIT_DELAY_FACTOR_PER_RANK := 0.05
const HIT_DELAY_MIN_FACTOR := 0.60
const HIT_RECOVERY_MAX_RANK := 8
const CALLING_BIAS_PER_RANK := 0.50
const DISTANCE_FACTOR_PER_RANK := 0.025
const DISTANCE_MIN_FACTOR := 0.50
const BASE_OFFLINE_XP_EFFICIENCY := 0.01
const OFFLINE_XP_EFFICIENCY_PER_RANK := 0.01
const OFFLINE_XP_MAX_RANK := 24
# Active input is deliberately modest: the displayed opening 1.7% and each
# Field Hustle increment are exactly one third of their original values.
const BASE_FIELD_TAP_FRACTION := 1.0 / 60.0
const FIELD_TAP_FRACTION_PER_RANK := 1.0 / 600.0
const FIELD_TAP_MAX_RANK := 6
const FIELD_TAP_PHASE_CAP := 0.50
# Every completed plate appearance has a believable lineup-change baseline.
# Contact adds the displayed delay on top; a walk uses the Single bonus.
const BASE_BATTER_TURNOVER_SECONDS := 3.0
const OUTCOME_TURNOVER_BONUS_SECONDS := [9.0, 5.0, 3.0, 2.0, 1.0, 0.0, 1.0, 0.0]
const MAX_BATTER_DOWNTIME_SECONDS := BASE_BATTER_TURNOVER_SECONDS + OUTCOME_TURNOVER_BONUS_SECONDS[Content.GRAND_SLAM_INDEX]
# Literal throws are deliberately finite: at the renderer's 0.16 second
# minimum travel time, this cap produces at most 3,200 simultaneous outbound
# balls. The idle game's larger numbers come from payload potency and rewards.
const MAX_PHYSICAL_PITCH_RATE := 20000.0
const LOOT_DROP_CHANCE := 0.12
const LOOT_PITY_ROLLS := 10
const LOOT_ROLL_INTERVAL_SECONDS := 5.0
const LOOT_ITEMS_PER_SLOT := 10
const LOOT_EXACT_ROLL_LIMIT := 120
const LOOT_SCRAP_RARITY_MULTIPLIERS := [1.0, 3.0, 8.0, 20.0, 50.0]
const OVERMASTERY_XP_PER_DOUBLING := 0.0125
const OVERMASTERY_LOOT_LUCK_PER_DOUBLING := 0.05
const MASTERY_REQUIREMENT_FACTOR_PER_RANK := 0.85
# Every point of opponent mastery makes that exact matchup a little easier.
# The logarithm deliberately has no hard ceiling: doubling an already enormous
# mastery total always helps, but by the same modest +quality step.
const MASTERY_MATCHUP_QUALITY_PER_DOUBLING := 0.12
# Bad results supply a second, temporary adaptation bonus. Frustration is scored
# once per resolved volley rather than once per physical projectile, so an
# eldritch 2,048-ball salvo remains one baseball result. Four frustration points
# grant the first +0.08 quality step; every later step takes twice as many.
const FRUSTRATION_REFERENCE_POINTS := 4.0
const FRUSTRATION_QUALITY_PER_DOUBLING := 0.08
const FRUSTRATION_OUTCOME_POINTS := [12.0, 8.0, 5.0, 3.0, 1.0, 0.10, 0.20, 0.0]
# Save v16 stored seconds on the old time-based curve. Keeping its reference
# interval here lets migration preserve the exact earned quality bonus.
const LEGACY_FRUSTRATION_INTERVAL_SECONDS := 15.0
const EQUIPMENT_EFFECT_FACTOR_PER_RANK := 1.20
const EQUIPMENT_CAPS := {
	"speed_bonus": 0.15,
	"rate_bonus": 0.18,
	"quality_bonus": 0.50,
	"xp_bonus": 0.25,
	"mastery_bonus": 0.20,
	"distance_bonus": 0.15,
}

var opponents: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()

var xp := 0.0
var run_xp := 0.0
var lifetime_xp := 0.0
var lifetime_pitches := 0.0
var lifetime_field_taps := 0.0
var lifetime_field_tap_seconds := 0.0
var lifetime_saved_hits := 0.0
var lifetime_max_pitch_speed_fps := 1.0
var lifetime_max_distance_index := 0
var lifetime_max_loot_rarity := -1
var current_opponent := 0
var highest_unlocked := 0
var selected_distance_index := 0
var dna := 0
var arcana := 0
var genetic_rebirths := 0
var eldritch_ascensions := 0
var divine_ascensions := 0
var divine_halos := 0
var lifetime_genetic_rebirths := 0
var lifetime_eldritch_ascensions := 0
var reality_dna_earned := 0.0
var lifetime_dna_earned := 0.0
var lifetime_arcana_earned := 0.0
var genetic_offer_unlocked := false
var eldritch_offer_unlocked := false
var alien_exhibition_seconds := 0.0
var eldritch_exhibition_seconds := 0.0
var cosmos_conquered := false
# A legitimate No Hitter attempt begins when God restores a completed universe.
# Lower prestige layers preserve it; any fair-contact outcome, including one
# rescued by clones or portals, permanently spoils that universe's attempt.
var no_hitter_attempt_valid := false

var training_levels := {
	"velocity": 0,
	"command": 0,
	"field_hustle": 0,
	"recovery": 0,
	"turnover": 0,
	"hit_recovery": 0,
	"pitch_calling": 0,
	"distance_control": 0,
	"offline_efficiency": 0,
}
var scale_levels := {}
var genetic_levels := {
	"ancestral_memory": 0,
	"fast_twitch_everything": 0,
	"compound_pitching_eye": 0,
	"extra_arms": 0,
	"parallel_pitching_lobes": 0,
	"elastic_ucl_colony": 0,
	"ball_gland": 0,
	"compressed_strike_genome": 0,
	"prehensile_outfield": 0,
	"migratory_instinct": 0,
	"autonomic_coach": 0,
	"predator_scouting": 0,
	"autonomic_wardrobe": 0,
	"inherited_scorebook": 0,
	"symbiotic_wardrobe": 0,
}
var eldritch_levels := {
	"mirror_clones": 0,
	"time_compression": 0,
	"non_euclidean_bullpen": 0,
	"velocity_without_distance": 0,
	"eyes_behind_moon": 0,
	"causal_seams": 0,
	"portal_outfield": 0,
	"memory_of_flesh": 0,
	"mercy_is_euclidean": 0,
	"reverse_terminator": 0,
	"clone_dress_code": 0,
}
var divine_blessings: Array[String] = []
var unlocked_pitches: Array[String] = ["dead_fish"]
var purchased_ball_upgrades: Array[String] = []
var purchased_milestones: Array[String] = []
var unlocked_achievements: Array[String] = []
var achievement_revision := 0
var catalog_hide_purchased := {
	"pitch": false,
	"ball": false,
	"facility": false,
}
var milestone_effect_cache_count := -1
var milestone_effect_cache := {}
var opponent_mastery: Array[float] = []
var result_totals: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var lifetime_strikeouts := 0.0
var current_body_strikeouts := 0.0
var frustration_points := 0.0
var plate_strikes := 0
var plate_balls := 0
var batter_cooldown_remaining := 0.0
var batter_generation := 0
var batter_replacement_pending := false
var current_batter_variant: Dictionary = {}

var loot_items: Array[Dictionary] = []
var equipped_loot := {
	"hat": "",
	"jersey": "",
	"jockstrap": "",
	"glove": "",
	"pants": "",
	"cleats": "",
	"relic": "",
}
var next_loot_id := 1
var loot_dry_streak := 0
var loot_roll_cooldown_remaining := 0.0
var lifetime_loot_found := 0.0
var current_body_loot_found := 0.0
var loot_overflow_discarded := 0.0
var scrap := 0.0
var loot_revision := 0
var equipment_bonus_cache_revision := -1
var equipment_bonus_cache_unlock_state := ""
var equipment_bonus_cache := {}
var last_time_travel_retained_slots: Array[String] = []
# Deterministic pacing audits disable drops to prove that random equipment is
# never a progression requirement. This is a development switch, not save data.
var loot_drops_enabled := true
# The live field owns the visible batter entrance/exit timeline. It can pause
# releases without pausing story clocks, automation, or offline simulation.
# This prevents the economy from silently resolving pitches at an empty plate.
var live_pitching_enabled := true

var consecutive_home_runs := 0
# Wind-up progress only. It is frozen at zero while a released volley is in
# flight and starts filling again only after that volley resolves at the plate.
var pitch_credit := 0.0
var pitch_flight_remaining := 0.0
var pending_volley_flight_duration := 0.0
var pending_volley_size := 0
var pending_volley_outcome := Content.STRIKE_INDEX
var pending_volley_saved := false
var pending_volley_pitch_id := "dead_fish"
var pending_volley_speed_fps := 1.0
var pending_volley_distance_index := 0
var pending_volley_opponent_index := 0
var foreground_timer_serial := 0
var field_tap_phase_key := ""
var field_tap_phase_original_seconds := 0.0
var field_tap_advanced_seconds := 0.0
var simulation_accumulator := 0.0
var last_batch: Dictionary = {}
var last_offline_seconds := 0.0
var auto_advance_enabled := false
var auto_train_enabled := false
var auto_farm_enabled := false
var automation_accumulator := 0.0
var last_load_succeeded := false
var last_load_had_error := false
var last_load_recovered := false
var last_loaded_save_timestamp := 0.0
var last_load_message := ""
var last_load_failure_reason := ""
var save_writes_locked := false

func _init() -> void:
	opponents = Content.opponents()
	rng.randomize()
	_reset_mastery()
	_refresh_batter_variant()

func _refresh_batter_variant() -> void:
	current_batter_variant = _generate_opponent_variant(current_opponent, batter_generation)

func _reset_batter_identity() -> void:
	batter_generation = 0
	batter_replacement_pending = false
	_refresh_batter_variant()

func _complete_batter_replacement() -> void:
	if not batter_replacement_pending:
		return
	batter_replacement_pending = false
	batter_generation = (batter_generation + 1) % 1000000000
	_refresh_batter_variant()
	_start_new_foreground_timer_phase()

func _opponent_variant_seed(opponent_index: int, generation: int) -> int:
	# Cosmetic/difficulty rolls are deterministic from the batter identity. This
	# keeps save files compact and makes a named batter's visible loadout stable.
	return 911382323 + opponent_index * 972663749 + generation * 1013904223

func _sample_opponent_rarity(local_rng: RandomNumberGenerator, opponent_index: int) -> int:
	var progress := float(clampi(opponent_index, 0, opponents.size() - 1)) / float(maxi(opponents.size() - 1, 1))
	var score := local_rng.randf() + progress * 0.78
	if score >= 1.52:
		return 4
	if score >= 1.22:
		return 3
	if score >= 0.90:
		return 2
	if score >= 0.54:
		return 1
	return 0

func _generate_opponent_variant(opponent_index: int, generation: int) -> Dictionary:
	var bounded := clampi(opponent_index, 0, opponents.size() - 1)
	var local_rng := RandomNumberGenerator.new()
	local_rng.seed = _opponent_variant_seed(bounded, maxi(generation, 0))
	var era_index := clampi(int(bounded / 5), 0, Content.ERA_NAMES.size() - 1)
	var body_names := [
		"Toddler Body", "Youth Athlete", "School Athlete", "College Athlete",
		"Professional Body", "Elite Human Body", "Modified Alien Body",
		"Interstellar Giant", "Eldritch Form",
	]
	var body_roll := local_rng.randf_range(-0.055, 0.075) + float(era_index) * 0.006
	var entries: Array[Dictionary] = [{
		"id": "body",
		"letter": "O",
		"name": str(body_names[era_index]),
		"rarity": 0,
		"color": Color.from_hsv(fmod(0.03 + float(bounded) * 0.1375 + float(generation) * 0.071, 1.0), 0.58, 0.96),
		"difficulty_bonus": body_roll,
	}]
	var bat_rarity := _sample_opponent_rarity(local_rng, bounded)
	var bat_bonus := lerpf(0.025, 0.105, float(bounded) / float(maxi(opponents.size() - 1, 1)))
	bat_bonus *= float(Content.loot_rarity(bat_rarity).strength) * local_rng.randf_range(0.82, 1.18)
	entries.append({
		"id": "bat",
		"letter": "B",
		"name": str(Content.BAT_NAMES[bounded]),
		"rarity": bat_rarity,
		"color": Color(Content.loot_rarity(bat_rarity).color),
		"difficulty_bonus": bat_bonus,
	})

	# Additional equipment arrives gradually: none for the very first classes,
	# all six mundane slots by MLB, and a Relic only in post-human baseball.
	var extra_count := clampi(int(floor(float(bounded + 1) / 5.0)), 0, 6)
	for slot_index in extra_count:
		var definition: Dictionary = Content.LOOT_SLOTS[slot_index]
		var rarity_index := _sample_opponent_rarity(local_rng, bounded)
		var rarity: Dictionary = Content.loot_rarity(rarity_index)
		var base_names: Array = definition.base_names
		var gear_name := str(base_names[era_index])
		var gear_bonus := lerpf(0.010, 0.048, float(bounded) / float(maxi(opponents.size() - 1, 1)))
		gear_bonus *= float(rarity.strength) * local_rng.randf_range(0.78, 1.16)
		entries.append({
			"id": str(definition.id),
			"letter": str(definition.letter),
			"name": gear_name,
			"rarity": rarity_index,
			"color": Color(rarity.color),
			"difficulty_bonus": gear_bonus,
		})
	if bounded >= Content.ALIEN_EXHIBITION_INDEX:
		var relic_definition: Dictionary = Content.LOOT_SLOTS.back()
		var relic_rarity := _sample_opponent_rarity(local_rng, bounded)
		var relic_bonus := lerpf(0.045, 0.16, float(bounded - Content.ALIEN_EXHIBITION_INDEX) / float(maxi(Content.FINAL_BOSS_INDEX - Content.ALIEN_EXHIBITION_INDEX, 1)))
		relic_bonus *= float(Content.loot_rarity(relic_rarity).strength) * local_rng.randf_range(0.85, 1.15)
		entries.append({
			"id": "relic",
			"letter": str(relic_definition.letter),
			"name": str((relic_definition.base_names as Array)[era_index]),
			"rarity": relic_rarity,
			"color": Color(Content.loot_rarity(relic_rarity).color),
			"difficulty_bonus": relic_bonus,
		})
	var total_bonus := 0.0
	for entry in entries:
		total_bonus += float(entry.difficulty_bonus)
	return {
		"opponent_index": bounded,
		"generation": generation,
		"name": Content.batter_display_name(bounded, generation),
		"class_name": str(opponents[bounded].name),
		"body_scale": local_rng.randf_range(0.96, 1.04),
		"difficulty_bonus": total_bonus,
		"loadout": entries,
	}

func get_current_batter_variant() -> Dictionary:
	if current_batter_variant.is_empty():
		_refresh_batter_variant()
	return current_batter_variant

func get_current_batter_name() -> String:
	return str(get_current_batter_variant().name)

func get_opponent_variant_difficulty() -> float:
	return float(get_current_batter_variant().get("difficulty_bonus", 0.0))

func _reset_mastery() -> void:
	opponent_mastery.clear()
	for _index in opponents.size():
		opponent_mastery.append(0.0)

func _reset_genetic_levels() -> void:
	genetic_levels = {
		"ancestral_memory": 0,
		"fast_twitch_everything": 0,
		"compound_pitching_eye": 0,
		"extra_arms": 0,
		"parallel_pitching_lobes": 0,
		"elastic_ucl_colony": 0,
		"ball_gland": 0,
		"compressed_strike_genome": 0,
		"prehensile_outfield": 0,
		"migratory_instinct": 0,
		"autonomic_coach": 0,
		"predator_scouting": 0,
		"autonomic_wardrobe": 0,
		"inherited_scorebook": 0,
		"symbiotic_wardrobe": 0,
	}

func _reset_eldritch_levels() -> void:
	eldritch_levels = {
		"mirror_clones": 0,
		"time_compression": 0,
		"non_euclidean_bullpen": 0,
		"velocity_without_distance": 0,
		"eyes_behind_moon": 0,
		"causal_seams": 0,
		"portal_outfield": 0,
		"memory_of_flesh": 0,
		"mercy_is_euclidean": 0,
		"reverse_terminator": 0,
		"clone_dress_code": 0,
	}

func is_alien_exhibition_blocked() -> bool:
	return current_opponent == Content.ALIEN_EXHIBITION_INDEX and genetic_rebirths <= 0

func is_eldritch_exhibition_blocked() -> bool:
	return current_opponent == Content.ELDRITCH_EXHIBITION_INDEX and eldritch_ascensions <= 0

func is_story_exhibition_blocked() -> bool:
	return is_alien_exhibition_blocked() or is_eldritch_exhibition_blocked()

func is_story_offer_ready() -> bool:
	return (
		(is_alien_exhibition_blocked() and genetic_offer_unlocked)
		or (is_eldritch_exhibition_blocked() and eldritch_offer_unlocked)
	)

func is_speed_gate_blocked(opponent_index: int = current_opponent) -> bool:
	if opponent_index == Content.HUMAN_FINAL_INDEX and not genetic_offer_unlocked:
		return get_velocity_fps() < HUMAN_SPEED_CAP_FPS * 0.999
	if opponent_index == Content.ALIEN_FINAL_INDEX:
		return get_velocity_fps() < SPEED_OF_SOUND_FPS * 3.0
	if opponent_index == Content.FINAL_BOSS_INDEX:
		return get_velocity_fps() < SPEED_OF_LIGHT_FPS * 0.999
	return false

func get_speed_gate_status_text(opponent_index: int = current_opponent) -> String:
	if not is_speed_gate_blocked(opponent_index):
		return ""
	match opponent_index:
		Content.HUMAN_FINAL_INDEX:
			return "VELOCITY TRIAL • Reach the human limit: 211.6 mph."
		Content.ALIEN_FINAL_INDEX:
			return "INTERSTELLAR LICENSE • Reach Mach 3."
		Content.FINAL_BOSS_INDEX:
			return "CAUSALITY ARMOR • Only a pitch at 1c can count."
		_:
			return ""

func _advance_story_encounters(seconds: float) -> void:
	if is_alien_exhibition_blocked() and not genetic_offer_unlocked:
		alien_exhibition_seconds = minf(alien_exhibition_seconds + maxf(seconds, 0.0), EXHIBITION_SECONDS)
		if alien_exhibition_seconds >= EXHIBITION_SECONDS:
			genetic_offer_unlocked = true
			progression_changed.emit(
				"XYLOPHAX'S OFFER: Add arms in the womb, borrow a Time Machine, and be born better."
			)
			check_achievements()
	if is_eldritch_exhibition_blocked() and not eldritch_offer_unlocked:
		eldritch_exhibition_seconds = minf(eldritch_exhibition_seconds + maxf(seconds, 0.0), EXHIBITION_SECONDS)
		if eldritch_exhibition_seconds >= EXHIBITION_SECONDS:
			eldritch_offer_unlocked = true
			progression_changed.emit(
				"THE LAST AEON'S OFFER: Destroy this reality and pitch with what remains outside it."
			)
			check_achievements()

func get_story_status_text() -> String:
	if is_alien_exhibition_blocked():
		if genetic_offer_unlocked:
			return "GENETIC OFFER READY • Open REBIRTH and use the Time Machine."
		return "COURTESY EXHIBITION • 100% GRAND SLAMS • Offer in %ds" % int(ceil(EXHIBITION_SECONDS - alien_exhibition_seconds))
	if is_eldritch_exhibition_blocked():
		if eldritch_offer_unlocked:
			return "ELDRITCH OFFER READY • Open REBIRTH and abandon this reality."
		return "IMPOSSIBLE EXHIBITION • 100% GRAND SLAMS • Revelation in %ds" % int(ceil(EXHIBITION_SECONDS - eldritch_exhibition_seconds))
	return ""

func reset_fresh() -> void:
	xp = 0.0
	run_xp = 0.0
	lifetime_xp = 0.0
	lifetime_pitches = 0.0
	lifetime_field_taps = 0.0
	lifetime_field_tap_seconds = 0.0
	lifetime_saved_hits = 0.0
	lifetime_max_pitch_speed_fps = 1.0
	lifetime_max_distance_index = 0
	lifetime_max_loot_rarity = -1
	current_opponent = 0
	highest_unlocked = 0
	selected_distance_index = 0
	dna = 0
	arcana = 0
	genetic_rebirths = 0
	eldritch_ascensions = 0
	divine_ascensions = 0
	divine_halos = 0
	lifetime_genetic_rebirths = 0
	lifetime_eldritch_ascensions = 0
	reality_dna_earned = 0.0
	lifetime_dna_earned = 0.0
	lifetime_arcana_earned = 0.0
	genetic_offer_unlocked = false
	eldritch_offer_unlocked = false
	alien_exhibition_seconds = 0.0
	eldritch_exhibition_seconds = 0.0
	cosmos_conquered = false
	no_hitter_attempt_valid = false
	training_levels = {
		"velocity": 0,
		"command": 0,
		"field_hustle": 0,
		"recovery": 0,
		"turnover": 0,
		"hit_recovery": 0,
		"pitch_calling": 0,
		"distance_control": 0,
		"offline_efficiency": 0,
	}
	scale_levels = {}
	_reset_genetic_levels()
	_reset_eldritch_levels()
	divine_blessings.clear()
	unlocked_pitches = ["dead_fish"]
	purchased_ball_upgrades.clear()
	purchased_milestones.clear()
	unlocked_achievements.clear()
	achievement_revision += 1
	catalog_hide_purchased = {
		"pitch": false,
		"ball": false,
		"facility": false,
	}
	_invalidate_milestone_effect_cache()
	result_totals = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	lifetime_strikeouts = 0.0
	current_body_strikeouts = 0.0
	frustration_points = 0.0
	plate_strikes = 0
	plate_balls = 0
	batter_cooldown_remaining = 0.0
	_reset_batter_identity()
	loot_items.clear()
	equipped_loot = {
		"hat": "",
		"jersey": "",
		"jockstrap": "",
		"glove": "",
		"pants": "",
		"cleats": "",
		"relic": "",
	}
	next_loot_id = 1
	loot_dry_streak = 0
	loot_roll_cooldown_remaining = 0.0
	lifetime_loot_found = 0.0
	current_body_loot_found = 0.0
	loot_overflow_discarded = 0.0
	scrap = 0.0
	loot_revision += 1
	last_time_travel_retained_slots.clear()
	consecutive_home_runs = 0
	_clear_pitch_cycle()
	simulation_accumulator = 0.0
	last_batch.clear()
	last_offline_seconds = 0.0
	auto_advance_enabled = false
	auto_train_enabled = false
	auto_farm_enabled = false
	automation_accumulator = 0.0
	_reset_mastery()

func _clear_pitch_cycle() -> void:
	pitch_credit = 0.0
	pitch_flight_remaining = 0.0
	pending_volley_flight_duration = 0.0
	pending_volley_size = 0
	pending_volley_outcome = Content.STRIKE_INDEX
	pending_volley_saved = false
	pending_volley_pitch_id = "dead_fish"
	pending_volley_speed_fps = 1.0
	pending_volley_distance_index = selected_distance_index
	pending_volley_opponent_index = current_opponent
	_start_new_foreground_timer_phase()

func _start_new_foreground_timer_phase() -> void:
	foreground_timer_serial = (foreground_timer_serial + 1) % 1000000000
	field_tap_phase_key = ""
	field_tap_phase_original_seconds = 0.0
	field_tap_advanced_seconds = 0.0

func get_field_tap_fraction() -> float:
	var rank := clampi(
		int(training_levels.get("field_hustle", 0)),
		0,
		FIELD_TAP_MAX_RANK
	)
	return BASE_FIELD_TAP_FRACTION + float(rank) * FIELD_TAP_FRACTION_PER_RANK

func get_field_tap_phase_cap() -> float:
	return FIELD_TAP_PHASE_CAP

func apply_field_tap() -> Dictionary:
	var phase := ""
	var timer_total := 0.0
	var timer_remaining := 0.0
	if is_pitch_in_flight():
		phase = "flight"
		timer_total = maxf(pending_volley_flight_duration, pitch_flight_remaining)
		timer_remaining = pitch_flight_remaining
	elif batter_cooldown_remaining > 0.000001:
		phase = "lineup"
		timer_total = batter_cooldown_remaining
		timer_remaining = batter_cooldown_remaining
	elif live_pitching_enabled:
		phase = "recovery"
		timer_total = get_pitch_cooldown_seconds()
		timer_remaining = get_seconds_until_next_pitch()
	if phase.is_empty() or timer_total <= 0.000001 or timer_remaining <= 0.000001:
		return {"applied": false, "phase": phase, "reason": "no_timer"}

	var phase_key := "%s:%d" % [phase, foreground_timer_serial]
	if phase_key != field_tap_phase_key:
		field_tap_phase_key = phase_key
		field_tap_phase_original_seconds = timer_total
		field_tap_advanced_seconds = 0.0
	var original := maxf(field_tap_phase_original_seconds, 0.000001)
	var remaining_tap_budget := maxf(
		original * FIELD_TAP_PHASE_CAP - field_tap_advanced_seconds,
		0.0
	)
	var maximum_without_skipping_resolution := timer_remaining
	if phase == "flight":
		# Keep the immutable volley alive for one normal simulation tick so its
		# authoritative impact event and the visual ball reach the plate together.
		maximum_without_skipping_resolution = maxf(timer_remaining - 0.000001, 0.0)
	var advance_seconds := minf(
		original * get_field_tap_fraction(),
		minf(remaining_tap_budget, maximum_without_skipping_resolution)
	)
	if advance_seconds <= 0.000001:
		return {
			"applied": false,
			"phase": phase,
			"reason": "idle_limit",
			"cap": FIELD_TAP_PHASE_CAP,
		}

	field_tap_advanced_seconds += advance_seconds
	match phase:
		"flight":
			pitch_flight_remaining = maxf(pitch_flight_remaining - advance_seconds, 0.000001)
		"lineup":
			batter_cooldown_remaining = maxf(batter_cooldown_remaining - advance_seconds, 0.0)
			if batter_cooldown_remaining <= 0.000001:
				_complete_batter_replacement()
		"recovery":
			pitch_credit = minf(
				pitch_credit + advance_seconds * maxf(get_recovery_rate(), 0.000001),
				1.0
			)
	lifetime_field_taps = minf(MAX_NUMBER, lifetime_field_taps + 1.0)
	lifetime_field_tap_seconds = minf(
		MAX_NUMBER,
		lifetime_field_tap_seconds + advance_seconds
	)
	check_achievements()
	return {
		"applied": true,
		"phase": phase,
		"seconds": advance_seconds,
		"fraction": advance_seconds / original,
		"tap_fraction": get_field_tap_fraction(),
		"cap": FIELD_TAP_PHASE_CAP,
	}

func is_pitch_in_flight() -> bool:
	return pending_volley_size > 0 and pitch_flight_remaining > 0.0

func advance(delta: float) -> void:
	simulation_accumulator += maxf(delta, 0.0)
	# Ordinary idle accounting can run at a coarse cadence, but a visible flight
	# and batter handoff share a frame-by-frame animation clock with PitchField.
	# Advancing those phases every rendered frame prevents the shader ball from
	# reaching (and disappearing at) the plate while the authoritative 0.10 s
	# simulation accumulator is still waiting to publish its impact.
	var visual_timeline_active := (
		is_pitch_in_flight()
		or batter_cooldown_remaining > 0.0
		or not live_pitching_enabled
	)
	if simulation_accumulator < SIMULATION_STEP and not visual_timeline_active:
		return
	var elapsed := simulation_accumulator
	simulation_accumulator = 0.0
	_advance_story_encounters(elapsed)
	_resolve_elapsed(elapsed, true, true)
	_run_automation(elapsed)

func _run_automation(elapsed: float) -> void:
	automation_accumulator += elapsed
	if automation_accumulator < 0.50:
		return
	automation_accumulator = 0.0
	if auto_train_enabled and has_genetic_upgrade("autonomic_coach"):
		var purchases := 0
		for _purchase in 20:
			var cheapest_id := ""
			var cheapest_cost := MAX_NUMBER
			for id in training_levels:
				var cost := get_training_cost(str(id))
				if cost < cheapest_cost:
					cheapest_cost = cost
					cheapest_id = str(id)
			if cheapest_id.is_empty() or cheapest_cost > xp:
				break
			xp -= cheapest_cost
			training_levels[cheapest_id] = int(training_levels[cheapest_id]) + 1
			purchases += 1
		if purchases > 0:
			progression_changed.emit("Auto-coach purchased %d training ranks." % purchases)
	var story_countdown_active := (
		(is_alien_exhibition_blocked() and not genetic_offer_unlocked)
		or (is_eldritch_exhibition_blocked() and not eldritch_offer_unlocked)
	)
	if (
		auto_farm_enabled
		and has_genetic_upgrade("predator_scouting")
		and not story_countdown_active
		and not is_pitch_in_flight()
		and batter_cooldown_remaining <= 0.0
	):
		var best_opponent := current_opponent
		var best_distance := selected_distance_index
		var best_rate := get_estimated_xp_per_second(current_opponent)
		var original_opponent := current_opponent
		var original_distance := selected_distance_index
		for opponent_index in highest_unlocked + 1:
			current_opponent = opponent_index
			for distance_index in get_max_distance_index() + 1:
				selected_distance_index = distance_index
				var candidate_rate := get_estimated_xp_per_second(opponent_index)
				if candidate_rate > best_rate * 1.02:
					best_rate = candidate_rate
					best_opponent = opponent_index
					best_distance = distance_index
		current_opponent = original_opponent
		selected_distance_index = original_distance
		if best_opponent != current_opponent or best_distance != selected_distance_index:
			current_opponent = best_opponent
			selected_distance_index = best_distance
			_clear_pitch_cycle()
			plate_strikes = 0
			plate_balls = 0
			batter_cooldown_remaining = 0.0
			_reset_batter_identity()
			consecutive_home_runs = 0
			progression_changed.emit(
				"Auto-scout moved to %s at %s."
				% [opponents[best_opponent].name, Content.DISTANCE_TIERS[best_distance].label]
			)

func simulate_offline(seconds: float) -> Dictionary:
	var bounded_seconds := clampf(seconds, 0.0, MAX_OFFLINE_SECONDS)
	last_offline_seconds = bounded_seconds
	if bounded_seconds < 1.0:
		return {}
	_advance_story_encounters(bounded_seconds)
	var efficiency := get_offline_xp_efficiency()
	var summary := _resolve_elapsed(bounded_seconds, false, false, efficiency)
	summary["offline_seconds"] = bounded_seconds
	summary["offline_xp_efficiency"] = efficiency
	last_batch = summary
	return summary

# Deterministic pacing audits use the same closed-form at-bat math at the full
# foreground reward rate. It is intentionally separate from offline catch-up so
# test acceleration cannot silently bypass the player's offline-efficiency stat.
func simulate_active_time(seconds: float) -> Dictionary:
	var bounded_seconds := clampf(seconds, 0.0, MAX_OFFLINE_SECONDS)
	if bounded_seconds <= 0.0:
		return {}
	_advance_story_encounters(bounded_seconds)
	var summary := _resolve_elapsed(bounded_seconds, false, false)
	summary["simulated_active_seconds"] = bounded_seconds
	last_batch = summary
	return summary

func _empty_resolution_summary() -> Dictionary:
	return {
		"pitches": 0.0,
		"released_pitches": 0.0,
		"released_volleys": 0,
		"elapsed_seconds": 0.0,
		"pitch_events": [],
		"counts": [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
		"strikeouts": 0.0,
		"saved_hits": 0.0,
		"frustration_events": [],
		"aggregate_frustration_points": 0.0,
		"aggregate_frustration_strikeouts": 0.0,
		"frustration_gained": 0.0,
		"raw_earned_xp": 0.0,
		"earned_xp": 0.0,
		"base_score": 0.0,
		"mastery_gained": 0.0,
		"visual_outcome": Content.STRIKE_INDEX,
		"visual_strikeout": false,
		"visual_saved": false,
		"visual_xp": 0.0,
		"visual_strike_count": plate_strikes,
		"visual_ball_count": plate_balls,
		"strike_requirement": get_strikes_required(),
		"ball_requirement": get_balls_required(),
		"loot_found": 0,
		"loot_kept": 0,
		"loot_discarded": 0,
		"loot_scrap_gained": 0.0,
		"loot_drops": [],
		"unlocked_message": "",
	}

func _resolve_elapsed(
	seconds: float,
	stochastic: bool,
	should_emit: bool,
	xp_reward_multiplier := 1.0
) -> Dictionary:
	var summary := _empty_resolution_summary()
	var remaining := maxf(seconds, 0.0)
	summary.elapsed_seconds = remaining
	if not live_pitching_enabled:
		# The field uses this gate only while a departed batter is being replaced.
		# Flight remains an active simulation phase and never enters this branch.
		batter_cooldown_remaining = maxf(batter_cooldown_remaining - remaining, 0.0)
		if batter_cooldown_remaining <= 0.000001:
			_complete_batter_replacement()
		pitch_credit = 0.0
		_apply_resolution(summary, should_emit, xp_reward_multiplier)
		return summary
	# Repeat universes remember both prestige offers. Once their exhibition
	# batter is reached, hold the ball until the player takes the already-known
	# reset instead of manufacturing unavoidable Grand Slams into a clean run.
	if is_story_offer_ready() and not is_pitch_in_flight():
		pitch_credit = 0.0
		_apply_resolution(summary, should_emit, xp_reward_multiplier)
		return summary
	var elapsed_offset := 0.0
	var recovery_rate := maxf(get_recovery_rate(), 0.000001)
	var active_cycle_seconds := 1.0 / recovery_rate + get_resolved_flight_seconds()
	var use_aggregate := (
		not should_emit
		and remaining / maxf(active_cycle_seconds, 0.000001) > OFFLINE_AGGREGATE_CYCLE_THRESHOLD
	)

	# Before switching a long offline interval to closed-form math, finish any
	# already-saved batter delay or immutable in-flight volley exactly.
	if use_aggregate:
		if batter_cooldown_remaining > 0.0:
			var opening_cooldown := minf(remaining, batter_cooldown_remaining)
			batter_cooldown_remaining -= opening_cooldown
			remaining -= opening_cooldown
			elapsed_offset += opening_cooldown
			if batter_cooldown_remaining <= 0.000001:
				_complete_batter_replacement()
		if remaining > 0.0 and is_pitch_in_flight():
			var opening_flight := minf(remaining, pitch_flight_remaining)
			pitch_flight_remaining -= opening_flight
			remaining -= opening_flight
			elapsed_offset += opening_flight
			if pitch_flight_remaining <= 0.000001:
				_resolve_pending_volley(summary, elapsed_offset)
		if remaining > 0.0 and batter_cooldown_remaining > 0.0:
			var impact_cooldown := minf(remaining, batter_cooldown_remaining)
			batter_cooldown_remaining -= impact_cooldown
			remaining -= impact_cooldown
			elapsed_offset += impact_cooldown
			if batter_cooldown_remaining <= 0.000001:
				_complete_batter_replacement()
		if remaining > 0.0 and not is_pitch_in_flight() and not is_story_offer_ready():
			pitch_credit = 0.0
			_resolve_aggregate_time(remaining, summary, stochastic)
		_apply_resolution(summary, should_emit, xp_reward_multiplier)
		return summary

	var transitions := 0
	while remaining > 0.000001 and transitions < 256:
		if batter_cooldown_remaining > 0.0:
			var cooldown_step := minf(remaining, batter_cooldown_remaining)
			batter_cooldown_remaining -= cooldown_step
			remaining -= cooldown_step
			elapsed_offset += cooldown_step
			if batter_cooldown_remaining <= 0.000001:
				_complete_batter_replacement()
			if remaining <= 0.000001:
				break
		if is_pitch_in_flight():
			var flight_step := minf(remaining, pitch_flight_remaining)
			pitch_flight_remaining -= flight_step
			remaining -= flight_step
			elapsed_offset += flight_step
			if pitch_flight_remaining > 0.000001:
				break
			_resolve_pending_volley(summary, elapsed_offset)
			transitions += 1
			# One live callback may either launch or resolve a volley, never race
			# onward into its next cooldown. This makes long frames visually honest.
			if should_emit:
				break
			continue
		if is_story_offer_ready():
			pitch_credit = 0.0
			break
		var needed_credit := maxf(1.0 - pitch_credit, 0.0)
		var time_to_release := needed_credit / recovery_rate
		if time_to_release > remaining:
			pitch_credit += recovery_rate * remaining
			elapsed_offset += remaining
			remaining = 0.0
			break
		remaining -= time_to_release
		elapsed_offset += time_to_release
		pitch_credit = 0.0
		_begin_pitch_volley(
			summary,
			float(summary.elapsed_seconds) if should_emit else elapsed_offset
		)
		transitions += 1
		if should_emit:
			break
	if remaining > 0.000001 and not should_emit and not is_story_offer_ready():
		pitch_credit = 0.0
		_resolve_aggregate_time(remaining, summary, stochastic)
	_apply_resolution(summary, should_emit, xp_reward_multiplier)
	return summary

func _resolve_one_pitch(summary: Dictionary, _stochastic: bool, elapsed_offset := -1.0) -> void:
	var probabilities := get_outcome_probabilities()
	var outcome := _sample_outcome(probabilities)
	_apply_pitch_outcome(summary, outcome, elapsed_offset)

func _begin_pitch_volley(summary: Dictionary, elapsed_offset: float) -> void:
	_start_new_foreground_timer_phase()
	pending_volley_size = get_volley_size()
	pending_volley_pitch_id = _sample_pitch_id()
	pending_volley_speed_fps = _sample_pitch_speed(pending_volley_pitch_id)
	pending_volley_distance_index = selected_distance_index
	lifetime_max_pitch_speed_fps = maxf(lifetime_max_pitch_speed_fps, pending_volley_speed_fps)
	lifetime_max_distance_index = maxi(lifetime_max_distance_index, pending_volley_distance_index)
	pending_volley_opponent_index = current_opponent
	pending_volley_outcome = _sample_outcome(get_outcome_probabilities_for_pitch(
		pending_volley_pitch_id,
		pending_volley_speed_fps,
		pending_volley_opponent_index,
		pending_volley_distance_index
	))
	pending_volley_saved = (
		pending_volley_outcome < Content.HIT_OUTCOME_COUNT
		and rng.randf() < get_hit_save_chance(pending_volley_outcome)
	)
	pending_volley_flight_duration = get_resolved_flight_seconds_for_speed(
		pending_volley_speed_fps,
		pending_volley_distance_index
	)
	pitch_flight_remaining = pending_volley_flight_duration
	summary.released_pitches = float(summary.released_pitches) + float(pending_volley_size)
	summary.released_volleys = int(summary.released_volleys) + 1
	var pitch_events: Array = summary.pitch_events
	pitch_events.append({
		"phase": "release",
		"elapsed_offset": elapsed_offset,
		"ball_count": pending_volley_size,
		"flight_seconds": pitch_flight_remaining,
		"pitch_id": pending_volley_pitch_id,
		"pitch_name": str(Content.pitch_by_id(pending_volley_pitch_id).name),
		"pitch_speed_fps": pending_volley_speed_fps,
		"distance_index": pending_volley_distance_index,
		"opponent_index": pending_volley_opponent_index,
	})

func _resolve_pending_volley(summary: Dictionary, elapsed_offset: float) -> void:
	var ball_count := maxi(pending_volley_size, 1)
	var outcome := pending_volley_outcome
	var saved := pending_volley_saved
	var release_distance := pending_volley_distance_index
	# If the player selected another batter during flight, that batter owns the
	# impact. Distance remains release-time immutable so moving the mound never
	# teleports a ball or changes its payout after it leaves the hand.
	var resolved_opponent := current_opponent
	pending_volley_size = 0
	pitch_flight_remaining = 0.0
	pending_volley_flight_duration = 0.0
	pending_volley_outcome = Content.STRIKE_INDEX
	pending_volley_saved = false
	pending_volley_pitch_id = "dead_fish"
	pending_volley_speed_fps = get_representative_pitch_speed("dead_fish")
	_start_new_foreground_timer_phase()
	_apply_pitch_outcome(
		summary,
		outcome,
		elapsed_offset,
		ball_count,
		saved,
		resolved_opponent,
		release_distance
	)

# Kept separate from sampling so the complete at-bat state machine can be
# exercised deterministically by regression tests (and, later, scripted story
# pitches) without duplicating any economy rules.
func _apply_pitch_outcome(
	summary: Dictionary,
	requested_outcome: int,
	elapsed_offset := -1.0,
	ball_count := 1,
	saved_override: Variant = null,
	resolved_opponent: int = current_opponent,
	resolved_distance: int = selected_distance_index
) -> void:
	var outcome := clampi(requested_outcome, 0, Content.OUTCOME_NAMES.size() - 1)
	var resolved_balls := maxi(ball_count, 1)
	var counts: Array = summary.counts
	counts[outcome] = float(counts[outcome]) + float(resolved_balls)
	summary.pitches = float(summary.pitches) + float(resolved_balls)
	var saved := false
	var struck_out := false
	var walked := false
	if outcome < Content.HIT_OUTCOME_COUNT:
		no_hitter_attempt_valid = false
	if outcome == Content.STRIKE_INDEX:
		plate_strikes += resolved_balls
		if plate_strikes >= get_strikes_required():
			struck_out = true
			plate_strikes = 0
			plate_balls = 0
			batter_cooldown_remaining = get_batter_downtime(Content.STRIKE_INDEX)
			batter_replacement_pending = true
			summary.strikeouts = float(summary.strikeouts) + 1.0
			consecutive_home_runs = 0
	elif outcome == Content.FOUL_INDEX:
		plate_strikes = mini(plate_strikes + resolved_balls, maxi(get_strikes_required() - 1, 0))
	elif outcome == Content.BALL_INDEX:
		plate_balls += resolved_balls
		if plate_balls >= get_balls_required():
			walked = true
			plate_strikes = 0
			plate_balls = 0
			batter_cooldown_remaining = get_batter_downtime(Content.BALL_INDEX)
			batter_replacement_pending = true
			consecutive_home_runs = 0
	else:
		saved = (
			bool(saved_override)
			if saved_override != null
			else rng.randf() < get_hit_save_chance(outcome)
		)
		if saved:
			summary.saved_hits = float(summary.saved_hits) + float(resolved_balls)
		else:
			plate_strikes = 0
			plate_balls = 0
			batter_cooldown_remaining = get_batter_downtime(outcome)
			batter_replacement_pending = true
			consecutive_home_runs = mini(consecutive_home_runs + 1, 20)
	summary.visual_outcome = outcome
	summary.visual_strikeout = struck_out
	summary.visual_saved = saved
	summary.visual_xp = (
		get_strikeout_base_points(resolved_opponent)
		* get_xp_multiplier(resolved_opponent, resolved_distance)
		if struck_out
		else 0.0
	)
	summary.visual_strike_count = plate_strikes
	summary.visual_ball_count = plate_balls
	summary.strike_requirement = get_strikes_required()
	summary.ball_requirement = get_balls_required()
	summary["resolved_opponent_index"] = resolved_opponent
	summary["resolved_distance_index"] = resolved_distance
	if summary.has("frustration_events"):
		var frustration_events: Array = summary.frustration_events
		frustration_events.append({
			"outcome": outcome,
			"strikeout": struck_out,
		})
	# Outcomes are emitted only now, at impact. The release event intentionally
	# contains no result, so neither the UI nor the pitcher cadence can reveal a
	# hit before the ball reaches the batter.
	if summary.has("pitch_events"):
		var pitch_events: Array = summary.pitch_events
		pitch_events.append({
			"phase": "impact",
			"elapsed_offset": (
				float(summary.get("elapsed_seconds", 0.0))
				if elapsed_offset < 0.0
				else elapsed_offset
			),
			"outcome": outcome,
			"strikeout": struck_out,
			"walk": walked,
			"saved": saved,
			"xp": summary.visual_xp,
			"strike_count": plate_strikes,
			"plate_ball_count": plate_balls,
			"strike_requirement": get_strikes_required(),
			"ball_requirement": get_balls_required(),
			"opponent_index": resolved_opponent,
			"distance_index": resolved_distance,
			"ball_count": resolved_balls,
		})

func _resolve_aggregate_time(seconds: float, summary: Dictionary, stochastic: bool) -> void:
	var metrics := get_at_bat_metrics()
	lifetime_max_pitch_speed_fps = maxf(
		lifetime_max_pitch_speed_fps,
		get_representative_pitch_speed()
	)
	lifetime_max_distance_index = maxi(lifetime_max_distance_index, selected_distance_index)
	var cycle_seconds := maxf(float(metrics.cycle_seconds), 0.000001)
	var cycles := minf(seconds / cycle_seconds, MAX_NUMBER)
	var active_volleys := minf(cycles * float(metrics.active_volleys), MAX_NUMBER)
	var active_pitches := minf(cycles * float(metrics.active_pitches), MAX_NUMBER)
	var probabilities: Array = metrics.probabilities
	var counts: Array = summary.counts
	for index in probabilities.size():
		counts[index] = minf(float(counts[index]) + active_pitches * float(probabilities[index]), MAX_NUMBER)
	var strikeouts := minf(cycles * float(metrics.strikeout_probability), MAX_NUMBER)
	var saved_hits := minf(active_pitches * float(metrics.saved_hit_probability), MAX_NUMBER)
	var aggregate_frustration := 0.0
	for index in probabilities.size():
		aggregate_frustration = minf(
			MAX_NUMBER,
			aggregate_frustration
			+ active_volleys * float(probabilities[index]) * get_outcome_frustration_points(index)
		)
	summary.pitches = minf(float(summary.pitches) + active_pitches, MAX_NUMBER)
	summary.strikeouts = minf(float(summary.strikeouts) + strikeouts, MAX_NUMBER)
	summary.saved_hits = minf(float(summary.saved_hits) + saved_hits, MAX_NUMBER)
	summary.aggregate_frustration_points = minf(
		MAX_NUMBER,
		float(summary.get("aggregate_frustration_points", 0.0)) + aggregate_frustration
	)
	summary.aggregate_frustration_strikeouts = minf(
		MAX_NUMBER,
		float(summary.get("aggregate_frustration_strikeouts", 0.0)) + strikeouts
	)
	# Aggregate simulation ends between volleys. Live play never enters this path.
	var requirement := get_strikes_required()
	plate_strikes = (
		int(floor(active_volleys * (
			float(probabilities[Content.STRIKE_INDEX])
			+ float(probabilities[Content.FOUL_INDEX]) * 0.5
		)))
		* get_volley_size()
	) % maxi(requirement, 1)
	plate_balls = int(floor(active_volleys * float(probabilities[Content.BALL_INDEX]))) % maxi(get_balls_required(), 1)
	batter_cooldown_remaining = 0.0
	_clear_pitch_cycle()
	if cycles >= 1.0:
		batter_replacement_pending = true
		_complete_batter_replacement()
	var visual_outcome := _sample_outcome(probabilities)
	var visual_saved := false
	var visual_strikeout := false
	if visual_outcome == Content.STRIKE_INDEX:
		var strike_pitch_count := maxf(active_pitches * float(probabilities[Content.STRIKE_INDEX]), 0.000001)
		visual_strikeout = rng.randf() < clampf(strikeouts / strike_pitch_count, 0.0, 1.0)
		if visual_strikeout:
			plate_strikes = 0
			plate_balls = 0
	elif visual_outcome < Content.HIT_OUTCOME_COUNT:
		visual_saved = rng.randf() < get_hit_save_chance(visual_outcome)
	if not stochastic:
		# Offline summaries should be deterministic while their aggregate counts
		# remain exact; choose the most likely pitch for the cosmetic snapshot.
		visual_outcome = probabilities.find(probabilities.max())
		visual_saved = visual_outcome < Content.HIT_OUTCOME_COUNT and get_hit_save_chance(visual_outcome) >= 0.5
		visual_strikeout = false
	summary.visual_outcome = visual_outcome
	summary.visual_saved = visual_saved
	summary.visual_strikeout = visual_strikeout
	summary.visual_xp = get_strikeout_base_points() * get_xp_multiplier() if visual_strikeout else 0.0
	summary.visual_strike_count = plate_strikes
	summary.visual_ball_count = plate_balls
	summary.strike_requirement = requirement
	summary.ball_requirement = get_balls_required()

func _apply_resolution(summary: Dictionary, should_emit: bool, xp_reward_multiplier := 1.0) -> void:
	var pitch_count := float(summary.pitches)
	var released_count := float(summary.get("released_pitches", 0.0))
	var strikeouts := float(summary.strikeouts)
	var counts: Array = summary.counts
	if no_hitter_attempt_valid:
		# Aggregate catch-up resolves expected outcomes rather than individual
		# animation events. It cannot certify a clean inning once any positive fair
		# contact exists, so an offline shortcut never grants this extreme challenge.
		for hit_index in Content.HIT_OUTCOME_COUNT:
			if float(counts[hit_index]) > 0.0:
				no_hitter_attempt_valid = false
				break
	for index in mini(counts.size(), result_totals.size()):
		result_totals[index] = minf(MAX_NUMBER, result_totals[index] + float(counts[index]))
	var reward_opponent := clampi(int(summary.get("resolved_opponent_index", current_opponent)), 0, opponents.size() - 1)
	var reward_distance := int(summary.get("resolved_distance_index", selected_distance_index))
	var base_score := minf(strikeouts * get_strikeout_base_points(reward_opponent), MAX_NUMBER)
	var called_strikes := maxf(float(counts[Content.STRIKE_INDEX]), 0.0)
	# A normal completed count is worth the same mastery it was before, but its
	# value now arrives one called Strike at a time. Reduced post-human counts
	# preserve the old per-strikeout progression benefit of count compression.
	var mastery_per_strike := (
		get_strikeout_base_points(reward_opponent)
		/ float(maxi(get_strikes_required(reward_opponent), 1))
	)
	var mastery_gained := minf(
		called_strikes * mastery_per_strike * get_mastery_multiplier(),
		MAX_NUMBER
	)
	var raw_earned_xp := minf(base_score * get_xp_multiplier(reward_opponent, reward_distance), MAX_NUMBER)
	var earned_xp := minf(raw_earned_xp * maxf(xp_reward_multiplier, 0.0), MAX_NUMBER)
	summary.base_score = base_score
	summary.mastery_gained = mastery_gained
	summary.raw_earned_xp = raw_earned_xp
	summary.earned_xp = earned_xp
	xp = minf(MAX_NUMBER, xp + earned_xp)
	run_xp = minf(MAX_NUMBER, run_xp + earned_xp)
	lifetime_xp = minf(MAX_NUMBER, lifetime_xp + earned_xp)
	lifetime_pitches = minf(MAX_NUMBER, lifetime_pitches + pitch_count)
	lifetime_strikeouts = minf(MAX_NUMBER, lifetime_strikeouts + strikeouts)
	current_body_strikeouts = minf(MAX_NUMBER, current_body_strikeouts + strikeouts)
	lifetime_saved_hits = minf(
		MAX_NUMBER,
		lifetime_saved_hits + float(summary.get("saved_hits", 0.0))
	)
	_resolve_strikeout_loot(strikeouts, float(summary.elapsed_seconds), summary)
	opponent_mastery[reward_opponent] = minf(
		MAX_NUMBER,
		opponent_mastery[reward_opponent] + mastery_gained
	)
	_apply_frustration_summary(summary)
	summary.unlocked_message = _check_opponent_unlock()
	check_achievements()
	last_batch = summary
	if should_emit and (pitch_count > 0.0 or released_count > 0.0):
		batch_resolved.emit(summary)

func _resolve_strikeout_loot(strikeouts: float, elapsed_seconds: float, summary: Dictionary) -> void:
	if not loot_drops_enabled:
		return
	var elapsed := maxf(elapsed_seconds, 0.0)
	var initial_cooldown := maxf(loot_roll_cooldown_remaining, 0.0)
	loot_roll_cooldown_remaining = maxf(initial_cooldown - elapsed, 0.0)
	var completed_strikeouts := int(floor(maxf(strikeouts, 0.0) + 1.0e-9))
	if completed_strikeouts <= 0 or is_story_exhibition_blocked():
		return

	# A roll is attached to a completed strikeout, but dense late-game bullpens
	# can only open one locker parcel per five seconds. This prevents thousands of
	# identical items from being materialized per frame without changing XP math.
	var opportunities := 0
	if elapsed <= 0.000001:
		opportunities = 1 if initial_cooldown <= 0.0 else 0
	elif elapsed >= initial_cooldown:
		opportunities = 1 + int(floor((elapsed - initial_cooldown) / LOOT_ROLL_INTERVAL_SECONDS))
	opportunities = mini(opportunities, completed_strikeouts)
	if opportunities <= 0:
		return
	loot_roll_cooldown_remaining = LOOT_ROLL_INTERVAL_SECONDS

	var first_career_drop := lifetime_loot_found < 1.0
	var successes := _roll_loot_success_count(opportunities, first_career_drop)
	if successes <= 0:
		return
	lifetime_loot_found = minf(MAX_NUMBER, lifetime_loot_found + float(successes))
	current_body_loot_found = minf(MAX_NUMBER, current_body_loot_found + float(successes))
	summary.loot_found = int(summary.get("loot_found", 0)) + successes

	if first_career_drop:
		var first_item := _generate_loot_item(current_opponent, 0, 0)
		first_item.name = "Little Timmy's Oversized Cap"
		_store_generated_loot(first_item, summary)
		successes -= 1
	if successes <= 0:
		return
	if successes <= LOOT_EXACT_ROLL_LIMIT:
		for _drop in successes:
			_store_generated_loot(_generate_loot_item(current_opponent), summary)
	else:
		_generate_bulk_loot(successes, current_opponent, summary)

func _roll_loot_success_count(opportunities: int, guarantee_first: bool) -> int:
	var remaining := maxi(opportunities, 0)
	var successes := 0
	if guarantee_first and remaining > 0:
		successes += 1
		remaining -= 1
		loot_dry_streak = 0
	if remaining <= LOOT_EXACT_ROLL_LIMIT:
		for _roll in remaining:
			var guaranteed := loot_dry_streak >= LOOT_PITY_ROLLS - 1
			if guaranteed or rng.randf() < LOOT_DROP_CHANCE:
				successes += 1
				loot_dry_streak = 0
			else:
				loot_dry_streak += 1
		return successes

	# Truncated geometric expectation for a 12% roll with a guarantee on roll 10.
	# Bulk offline simulation samples around that exact long-run cadence instead
	# of looping once for every eligible eldritch strikeout.
	var miss_chance := 1.0 - LOOT_DROP_CHANCE
	var expected_cycle := (1.0 - pow(miss_chance, LOOT_PITY_ROLLS)) / LOOT_DROP_CHANCE
	var mean_successes := float(remaining) / expected_cycle
	var deviation := sqrt(maxf(mean_successes * 0.45, 1.0))
	var bulk_successes := clampi(int(round(rng.randfn(mean_successes, deviation))), 0, remaining)
	successes += bulk_successes
	loot_dry_streak = rng.randi_range(0, LOOT_PITY_ROLLS - 1)
	return successes

func _generate_bulk_loot(successes: int, opponent_index: int, summary: Dictionary) -> void:
	var generated := 0
	var prefiltered_scrap := 0.0
	var available_slots := _available_loot_slot_indices(opponent_index)
	var slot_count := available_slots.size()
	if slot_count <= 0:
		return
	var rarity_probabilities := get_loot_rarity_probabilities(opponent_index)
	for available_index in slot_count:
		var slot_index: int = available_slots[available_index]
		var drops_for_slot := successes / slot_count
		if available_index < successes % slot_count:
			drops_for_slot += 1
		if drops_for_slot <= 0:
			continue
		var rarity_counts: Array[int] = []
		var assigned := 0
		for rarity_index in Content.LOOT_RARITIES.size():
			var count := int(floor(float(drops_for_slot) * float(rarity_probabilities[rarity_index])))
			assigned += count
			rarity_counts.append(maxi(count, 0))
		# Rounding residue belongs to Common rather than inflating Unique odds.
		rarity_counts[0] += maxi(drops_for_slot - assigned, 0)

		# Generate only the ten strongest tier candidates per slot. Everything
		# omitted is necessarily lower-level/equal-level and lower-tier than a
		# retained candidate, so it is the same loot the 10-item cap would remove.
		var slot_generation_budget := mini(drops_for_slot, LOOT_ITEMS_PER_SLOT)
		var generated_counts: Array[int] = []
		generated_counts.resize(Content.LOOT_RARITIES.size())
		generated_counts.fill(0)
		for rarity_index in range(Content.LOOT_RARITIES.size() - 1, -1, -1):
			var count_to_generate := mini(rarity_counts[rarity_index], slot_generation_budget)
			if rarity_counts[rarity_index] > 0:
				lifetime_max_loot_rarity = maxi(lifetime_max_loot_rarity, rarity_index)
			for _candidate in count_to_generate:
				_store_generated_loot(
					_generate_loot_item(opponent_index, slot_index, rarity_index),
					summary
				)
			generated += count_to_generate
			generated_counts[rarity_index] = count_to_generate
			slot_generation_budget -= count_to_generate
			if slot_generation_budget <= 0:
				break
		for rarity_index in Content.LOOT_RARITIES.size():
			var discarded_for_rarity := rarity_counts[rarity_index] - generated_counts[rarity_index]
			prefiltered_scrap += float(discarded_for_rarity) * get_loot_scrap_value_for_level(
				opponent_index + 1,
				rarity_index
			)
	var prefiltered := maxi(successes - generated, 0)
	if prefiltered > 0:
		summary.loot_discarded = int(summary.get("loot_discarded", 0)) + prefiltered
		loot_overflow_discarded = minf(MAX_NUMBER, loot_overflow_discarded + float(prefiltered))
		scrap = minf(MAX_NUMBER, scrap + prefiltered_scrap)
		summary.loot_scrap_gained = minf(
			MAX_NUMBER,
			float(summary.get("loot_scrap_gained", 0.0)) + prefiltered_scrap
		)

func _sample_loot_rarity(opponent_index: int = current_opponent) -> int:
	var roll := rng.randf()
	var cumulative := 0.0
	var probabilities := get_loot_rarity_probabilities(opponent_index)
	for index in probabilities.size():
		cumulative += float(probabilities[index])
		if roll <= cumulative:
			return index
	return Content.LOOT_RARITIES.size() - 1

func _generate_loot_item(opponent_index: int, forced_slot := -1, forced_rarity := -1) -> Dictionary:
	var available_slots := _available_loot_slot_indices(opponent_index)
	if available_slots.is_empty():
		available_slots.append(0)
	var slot_index: int
	var bounded_forced_slot := clampi(forced_slot, 0, Content.LOOT_SLOTS.size() - 1)
	if forced_slot >= 0 and bounded_forced_slot in available_slots:
		slot_index = bounded_forced_slot
	else:
		slot_index = available_slots[rng.randi_range(0, available_slots.size() - 1)]
	var rarity_index := clampi(forced_rarity, 0, Content.LOOT_RARITIES.size() - 1) if forced_rarity >= 0 else _sample_loot_rarity(opponent_index)
	var slot: Dictionary = Content.LOOT_SLOTS[slot_index]
	var rarity: Dictionary = Content.LOOT_RARITIES[rarity_index]
	var item_level := clampi(opponent_index + 1, 1, opponents.size())
	var level_progress := float(item_level - 1) / float(maxi(opponents.size() - 1, 1))
	var selected_stats: Array[String] = [str(slot.primary_stat)]
	var available_stats: Array[String] = []
	for stat in Content.LOOT_STATS:
		var stat_id := str(stat.id)
		if stat_id not in selected_stats:
			available_stats.append(stat_id)
	for _affix in int(rarity.affix_count):
		if available_stats.is_empty():
			break
		var selection := rng.randi_range(0, available_stats.size() - 1)
		selected_stats.append(available_stats[selection])
		available_stats.remove_at(selection)

	var stats := {}
	var total_roll := 0.0
	for stat_index in selected_stats.size():
		var stat_id := selected_stats[stat_index]
		var primary := stat_index == 0
		var raw_quality_roll := rng.randf()
		var loot_luck := get_opponent_loot_luck(opponent_index)
		var quality_roll := pow(raw_quality_roll, 1.0 / (1.0 + loot_luck))
		var roll_quality := lerpf(0.70, 1.00, quality_roll)
		total_roll += roll_quality
		var value := _loot_stat_value(
			stat_id,
			level_progress,
			float(rarity.strength),
			roll_quality,
			primary
		)
		stats[stat_id] = value

	var item_id := "L%09d" % next_loot_id
	while not get_loot_item(item_id).is_empty():
		next_loot_id += 1
		item_id = "L%09d" % next_loot_id
	next_loot_id += 1
	var hue := fmod(float(slot_index) / float(Content.LOOT_SLOTS.size()) + float(rarity_index) * 0.055 + rng.randf_range(-0.025, 0.025), 1.0)
	if hue < 0.0:
		hue += 1.0
	var visual_color := Color.from_hsv(hue, 0.40 + rarity_index * 0.10, 0.82 + rarity_index * 0.035)
	var item := {
		"id": item_id,
		"slot": str(slot.id),
		"item_level": item_level,
		"rarity": rarity_index,
		"name": "",
		"stats": stats,
		"roll_quality": total_roll / float(maxi(selected_stats.size(), 1)),
		"color": visual_color.to_html(false),
		"favorite": false,
	}
	item.name = _make_loot_name(item, slot, rarity, selected_stats)
	return item

func _loot_stat_value(
	stat_id: String,
	level_progress: float,
	rarity_strength: float,
	roll_quality: float,
	primary: bool
) -> float:
	var value := 0.0
	if stat_id == "quality_bonus":
		value = lerpf(0.018, 0.070, level_progress) if primary else lerpf(0.008, 0.035, level_progress)
	else:
		value = lerpf(0.010, 0.042, level_progress) if primary else lerpf(0.006, 0.026, level_progress)
	return value * rarity_strength * roll_quality

func _make_loot_name(item: Dictionary, slot: Dictionary, rarity: Dictionary, selected_stats: Array[String]) -> String:
	var era_index := clampi(int((int(item.item_level) - 1) / 5), 0, Content.ERA_NAMES.size() - 1)
	var base_names: Array = slot.base_names
	var base_name := str(base_names[era_index])
	var rarity_index := int(item.rarity)
	if rarity_index <= 0:
		return base_name
	var prefixes: Array = Content.LOOT_PREFIXES[rarity_index]
	var prefix := str(prefixes[rng.randi_range(0, prefixes.size() - 1)])
	var suffix_stat: String = selected_stats.back()
	var suffix_options: Array = Content.LOOT_SUFFIXES[suffix_stat]
	var suffix := str(suffix_options[rng.randi_range(0, suffix_options.size() - 1)])
	if rarity_index == 1:
		return "%s %s" % [prefix, base_name]
	if rarity_index == Content.LOOT_RARITIES.size() - 1:
		return "The %s %s of %s" % [prefix, base_name, suffix]
	return "%s %s of %s" % [prefix, base_name, suffix]

func _store_generated_loot(item: Dictionary, summary: Dictionary) -> void:
	var result := _add_loot_item(item)
	if bool(result.kept):
		summary.loot_kept = int(summary.get("loot_kept", 0)) + 1
		var drops: Array = summary.get("loot_drops", [])
		if drops.size() < 12:
			drops.append(item.duplicate(true))
	var removed: Array = result.get("removed", [])
	if not removed.is_empty():
		summary.loot_discarded = int(summary.get("loot_discarded", 0)) + removed.size()
	var scrap_gained := float(result.get("scrap", 0.0))
	if scrap_gained > 0.0:
		summary.loot_scrap_gained = minf(
			MAX_NUMBER,
			float(summary.get("loot_scrap_gained", 0.0)) + scrap_gained
		)

func _add_loot_item(item: Dictionary) -> Dictionary:
	var stored: Dictionary = item.duplicate(true)
	stored["favorite"] = bool(stored.get("favorite", false))
	lifetime_max_loot_rarity = maxi(
		lifetime_max_loot_rarity,
		clampi(int(stored.get("rarity", 0)), 0, Content.LOOT_RARITIES.size() - 1)
	)
	loot_items.append(stored)
	var slot := str(stored.slot)
	var capacity_result := _enforce_loot_slot_capacity(slot)
	var removed: Array = capacity_result.get("removed", [])
	var kept := not get_loot_item(str(stored.id)).is_empty()
	if has_genetic_upgrade("autonomic_wardrobe"):
		auto_equip_highest_power(false)
	loot_overflow_discarded = minf(MAX_NUMBER, loot_overflow_discarded + float(removed.size()))
	loot_revision += 1
	return {
		"kept": kept,
		"removed": removed,
		"scrap": float(capacity_result.get("scrap", 0.0)),
	}

func _enforce_loot_slot_capacity(slot: String) -> Dictionary:
	var slot_items := get_loot_items_for_slot(slot, false)
	var removed: Array[String] = []
	var scrap_gained := 0.0
	while slot_items.size() > LOOT_ITEMS_PER_SLOT:
		var candidates: Array[Dictionary] = []
		var equipped_id := str(equipped_loot.get(slot, ""))
		for item in slot_items:
			if str(item.id) != equipped_id and not bool(item.get("favorite", false)):
				candidates.append(item)
		if candidates.is_empty():
			break
		candidates.sort_custom(Callable(self, "_loot_is_worse"))
		var doomed: Dictionary = candidates[0]
		var doomed_id := str(doomed.id)
		scrap_gained += get_loot_scrap_value(doomed)
		for index in range(loot_items.size() - 1, -1, -1):
			if str(loot_items[index].id) == doomed_id:
				loot_items.remove_at(index)
				break
		removed.append(doomed_id)
		slot_items = get_loot_items_for_slot(slot, false)
	if scrap_gained > 0.0:
		scrap = minf(MAX_NUMBER, scrap + scrap_gained)
	return {"removed": removed, "scrap": scrap_gained}

func get_loot_scrap_value(item: Dictionary) -> float:
	return get_loot_scrap_value_for_level(
		int(item.get("item_level", 1)),
		int(item.get("rarity", 0))
	)

func get_loot_scrap_value_for_level(item_level: int, rarity_index: int) -> float:
	var bounded_rarity := clampi(rarity_index, 0, LOOT_SCRAP_RARITY_MULTIPLIERS.size() - 1)
	return float(maxi(item_level, 1)) * float(LOOT_SCRAP_RARITY_MULTIPLIERS[bounded_rarity])

func _loot_is_worse(left: Dictionary, right: Dictionary) -> bool:
	var left_power := get_loot_item_power(left)
	var right_power := get_loot_item_power(right)
	if left_power != right_power:
		return left_power < right_power
	if int(left.rarity) != int(right.rarity):
		return int(left.rarity) < int(right.rarity)
	if int(left.item_level) != int(right.item_level):
		return int(left.item_level) < int(right.item_level)
	return str(left.id) < str(right.id)

func _loot_is_better(left: Dictionary, right: Dictionary) -> bool:
	return _loot_is_worse(right, left)

func get_loot_item(item_id: String) -> Dictionary:
	for item in loot_items:
		if str(item.id) == item_id:
			return item
	return {}

func get_loot_items_for_slot(slot: String, sorted := true) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item in loot_items:
		if str(item.slot) == slot:
			result.append(item)
	if sorted:
		result.sort_custom(Callable(self, "_loot_is_better"))
	return result

func get_equipped_loot_item(slot: String) -> Dictionary:
	return get_loot_item(str(equipped_loot.get(slot, "")))

func auto_equip_highest_power(emit_message := true) -> int:
	var changed := 0
	for definition in Content.LOOT_SLOTS:
		var slot := str(definition.id)
		if not is_loot_slot_unlocked(slot):
			continue
		var items := get_loot_items_for_slot(slot)
		if items.is_empty():
			continue
		var best_id := str(items[0].id)
		if str(equipped_loot.get(slot, "")) == best_id:
			continue
		equipped_loot[slot] = best_id
		changed += 1
	if changed > 0:
		loot_revision += 1
		if emit_message:
			progression_changed.emit("AUTONOMIC WARDROBE: equipped %d highest-Power item%s." % [
				changed,
				"" if changed == 1 else "s",
			])
	return changed

func is_loot_slot_unlocked(slot: String, unlock_level: int = highest_unlocked) -> bool:
	var definition := Content.loot_slot_by_id(slot)
	if definition.is_empty():
		return false
	var requirement := int(definition.get("required_level", 0))
	if unlock_level >= requirement:
		return true
	# Once the player has crossed the human boundary, the post-human equipment
	# slot remains known through later genetic time travel resets.
	return requirement <= Content.ALIEN_EXHIBITION_INDEX and (
		genetic_rebirths > 0 or genetic_offer_unlocked
	)

func _available_loot_slot_indices(opponent_index: int) -> Array[int]:
	var result: Array[int] = []
	for index in Content.LOOT_SLOTS.size():
		if opponent_index >= int(Content.LOOT_SLOTS[index].get("required_level", 0)):
			result.append(index)
	return result

func equip_loot(item_id: String) -> bool:
	var item := get_loot_item(item_id)
	if item.is_empty():
		return false
	var slot := str(item.slot)
	if not is_loot_slot_unlocked(slot):
		return false
	if str(equipped_loot.get(slot, "")) == item_id:
		equipped_loot[slot] = ""
		loot_revision += 1
		progression_changed.emit("UNEQUIPPED: %s." % str(item.name))
		check_achievements()
		return true
	equipped_loot[slot] = item_id
	loot_revision += 1
	progression_changed.emit("EQUIPPED: %s." % str(item.name))
	check_achievements()
	return true

func toggle_loot_favorite(item_id: String) -> bool:
	for index in loot_items.size():
		if str(loot_items[index].id) != item_id:
			continue
		var item: Dictionary = loot_items[index]
		item["favorite"] = not bool(item.get("favorite", false))
		loot_items[index] = item
		loot_revision += 1
		progression_changed.emit(
			"%s: %s." % ["FAVORITED" if bool(item.favorite) else "UNFAVORITED", str(item.name)]
		)
		return true
	return false

func trash_loot_item(item_id: String) -> Dictionary:
	for index in loot_items.size():
		if str(loot_items[index].id) != item_id:
			continue
		var item: Dictionary = loot_items[index].duplicate(true)
		var slot := str(item.slot)
		var was_equipped := str(equipped_loot.get(slot, "")) == item_id
		var scrap_gained := get_loot_scrap_value(item)
		if was_equipped:
			equipped_loot[slot] = ""
		loot_items.remove_at(index)
		scrap = minf(MAX_NUMBER, scrap + scrap_gained)
		loot_revision += 1
		if has_genetic_upgrade("autonomic_wardrobe"):
			auto_equip_highest_power(false)
		progression_changed.emit("SCRAPPED: %s for %s Scrap." % [
			str(item.name),
			format_number(scrap_gained, 0),
		])
		return {
			"ok": true,
			"item": item,
			"scrap": scrap_gained,
			"was_equipped": was_equipped,
		}
	return {"ok": false, "scrap": 0.0, "was_equipped": false}

func get_loot_item_power(item: Dictionary) -> int:
	# A single integer for quick comparisons. It is derived from the item's real
	# affix values rather than rarity or item level, so "equip highest Power" is
	# genuinely useful while specialized lower-Power sidegrades can still matter.
	var result := 0.0
	var stats: Dictionary = item.get("stats", {})
	for stat_id in stats:
		var value := float(stats[stat_id])
		result += value * (3.0 if str(stat_id) == "quality_bonus" else 1.0)
	return maxi(int(round(result * 1000.0)), 1)

func get_loot_item_stat_lines(item: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	var stats: Dictionary = item.get("stats", {})
	for definition in Content.LOOT_STATS:
		var stat_id := str(definition.id)
		if not stats.has(stat_id):
			continue
		var value := float(stats[stat_id])
		if str(definition.format) == "additive":
			lines.append("%s +%.3f" % [definition.name, value])
		else:
			lines.append("%s ×%.3f" % [definition.name, 1.0 + value])
	return lines

func get_loot_item_description(item: Dictionary) -> String:
	return " • ".join(get_loot_item_stat_lines(item))

func get_raw_equipment_bonuses() -> Dictionary:
	var unlock_state := "%d:%d:%d:%d" % [
		highest_unlocked,
		int(genetic_offer_unlocked or genetic_rebirths > 0),
		int(eldritch_offer_unlocked or eldritch_ascensions > 0),
		int(genetic_levels.get("symbiotic_wardrobe", 0)),
	]
	if equipment_bonus_cache_revision == loot_revision and equipment_bonus_cache_unlock_state == unlock_state:
		return equipment_bonus_cache.duplicate(true)
	var result := {
		"speed_bonus": 0.0,
		"rate_bonus": 0.0,
		"quality_bonus": 0.0,
		"xp_bonus": 0.0,
		"mastery_bonus": 0.0,
		"distance_bonus": 0.0,
	}
	for slot in equipped_loot:
		if not is_loot_slot_unlocked(str(slot)):
			continue
		var item := get_equipped_loot_item(str(slot))
		if item.is_empty():
			continue
		var stats: Dictionary = item.get("stats", {})
		for stat_id in result:
			result[stat_id] = float(result[stat_id]) + float(stats.get(stat_id, 0.0))
	var effectiveness := get_equipment_effectiveness_multiplier()
	for stat_id in result:
		result[stat_id] = minf(
			float(result[stat_id]) * effectiveness,
			float(EQUIPMENT_CAPS[stat_id])
		)
	equipment_bonus_cache_revision = loot_revision
	equipment_bonus_cache_unlock_state = unlock_state
	equipment_bonus_cache = result.duplicate(true)
	return result

func get_equipment_effectiveness_multiplier() -> float:
	return pow(
		EQUIPMENT_EFFECT_FACTOR_PER_RANK,
		int(genetic_levels.get("symbiotic_wardrobe", 0))
	)

func get_equipment_inheritance_factor() -> float:
	var clones := maxf(get_clone_count(), 1.0)
	if clones <= 1.0 or has_eldritch_upgrade("clone_dress_code"):
		return 1.0
	return 1.0 / clones

func get_equipment_bonuses() -> Dictionary:
	var result := get_raw_equipment_bonuses()
	var inheritance := get_equipment_inheritance_factor()
	for stat_id in result:
		result[stat_id] = float(result[stat_id]) * inheritance
	return result

func get_equipment_bonus_summary(raw := false) -> String:
	var bonuses := get_raw_equipment_bonuses() if raw else get_equipment_bonuses()
	return "Speed ×%.3f • Recovery ×%.3f • Quality +%.3f • XP ×%.3f • Mastery ×%.3f • Distance ×%.3f" % [
		1.0 + float(bonuses.speed_bonus),
		1.0 + float(bonuses.rate_bonus),
		float(bonuses.quality_bonus),
		1.0 + float(bonuses.xp_bonus),
		1.0 + float(bonuses.mastery_bonus),
		1.0 + float(bonuses.distance_bonus),
	]

func get_equipped_loot_count() -> int:
	var result := 0
	for slot in equipped_loot:
		if not get_equipped_loot_item(str(slot)).is_empty():
			result += 1
	return result

func get_equipped_loot_color(slot: String, fallback: Color) -> Color:
	var item := get_equipped_loot_item(slot)
	if item.is_empty():
		return fallback
	return Color(str(item.get("color", fallback.to_html(false))))

func get_equipped_loot_rarity_color(slot: String, fallback: Color) -> Color:
	var item := get_equipped_loot_item(slot)
	if item.is_empty():
		return fallback
	return Color(Content.loot_rarity(int(item.get("rarity", 0))).color)

# Compatibility helper for focused tests: resolve a supplied number of active
# pitches. Normal gameplay resolves elapsed wall time so batter downtime counts.
func _resolve_pitch_batch(pitch_count: float, stochastic: bool, should_emit: bool) -> Dictionary:
	var summary := _empty_resolution_summary()
	if pitch_count <= 128.0:
		for _pitch in int(floor(maxf(pitch_count, 0.0))):
			_resolve_one_pitch(summary, stochastic)
	else:
		var metrics := get_at_bat_metrics()
		var cycles := pitch_count / maxf(float(metrics.active_pitches), 0.000001)
		var probabilities: Array = metrics.probabilities
		var counts: Array = summary.counts
		for index in probabilities.size():
			counts[index] = pitch_count * float(probabilities[index])
		summary.pitches = pitch_count
		summary.strikeouts = cycles * float(metrics.strikeout_probability)
		summary.saved_hits = pitch_count * float(metrics.saved_hit_probability)
		summary.visual_outcome = _sample_outcome(probabilities)
	_apply_resolution(summary, should_emit)
	return summary

func _sample_outcome(probabilities: Array[float]) -> int:
	var roll := rng.randf()
	var cumulative := 0.0
	for index in probabilities.size():
		cumulative += probabilities[index]
		if roll <= cumulative:
			return index
	return Content.STRIKE_INDEX

func get_pitch_selection_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	var minimum_bonus := 0.0
	var maximum_bonus := 0.0
	var first := true
	for pitch_id in unlocked_pitches:
		var definition := Content.pitch_by_id(pitch_id)
		if definition.is_empty():
			continue
		var bonus := float(definition.bonus)
		if first:
			minimum_bonus = bonus
			maximum_bonus = bonus
			first = false
		else:
			minimum_bonus = minf(minimum_bonus, bonus)
			maximum_bonus = maxf(maximum_bonus, bonus)
	if first:
		return [{"id": "dead_fish", "weight": 1.0, "probability": 1.0}]
	var calling_bias := get_pitch_calling_bias()
	var total_weight := 0.0
	for pitch_id in unlocked_pitches:
		var definition := Content.pitch_by_id(pitch_id)
		if definition.is_empty():
			continue
		var quality_position := (
			(float(definition.bonus) - minimum_bonus) / (maximum_bonus - minimum_bonus)
			if maximum_bonus > minimum_bonus
			else 1.0
		)
		var weight := pow(calling_bias, quality_position)
		entries.append({"id": str(definition.id), "weight": weight, "probability": 0.0})
		total_weight += weight
	for entry in entries:
		entry.probability = float(entry.weight) / maxf(total_weight, 0.000001)
	return entries

func get_pitch_calling_bias() -> float:
	var rank := clampi(int(training_levels.get("pitch_calling", 0)), 0, 12)
	return 1.0 + float(rank) * CALLING_BIAS_PER_RANK

func _sample_pitch_id() -> String:
	var entries := get_pitch_selection_entries()
	var roll := rng.randf()
	var cumulative := 0.0
	for entry in entries:
		cumulative += float(entry.probability)
		if roll <= cumulative:
			return str(entry.id)
	return str(entries.back().id) if not entries.is_empty() else "dead_fish"

func get_pitch_speed_range(pitch_id: String) -> Vector2:
	var definition := Content.pitch_by_id(pitch_id)
	if definition.is_empty():
		definition = Content.pitch_by_id("dead_fish")
	var base_speed := get_velocity_fps()
	var gear_limit := get_velocity_cap_fps() * (1.0 + float(get_equipment_bonuses().speed_bonus))
	return Vector2(
		minf(base_speed * float(definition.get("speed_min", 1.0)), gear_limit),
		minf(base_speed * float(definition.get("speed_max", 1.0)), gear_limit)
	)

func get_representative_pitch_speed(pitch_id: String = "") -> float:
	if not pitch_id.is_empty():
		var selected_range := get_pitch_speed_range(pitch_id)
		return (selected_range.x + selected_range.y) * 0.5
	var expected := 0.0
	for entry in get_pitch_selection_entries():
		var speed_range := get_pitch_speed_range(str(entry.id))
		expected += (speed_range.x + speed_range.y) * 0.5 * float(entry.probability)
	return maxf(expected, 0.000001)

func _sample_pitch_speed(pitch_id: String) -> float:
	var speed_range := get_pitch_speed_range(pitch_id)
	if is_equal_approx(speed_range.x, speed_range.y):
		return speed_range.x
	return rng.randf_range(speed_range.x, speed_range.y)

func get_outcome_probabilities_for_pitch(
	pitch_id: String,
	pitch_speed_fps: float,
	opponent_index: int = current_opponent,
	distance_index: int = -1
) -> Array[float]:
	if (
		(opponent_index == Content.ALIEN_EXHIBITION_INDEX and genetic_rebirths <= 0)
		or (opponent_index == Content.ELDRITCH_EXHIBITION_INDEX and eldritch_ascensions <= 0)
		or is_speed_gate_blocked(opponent_index)
	):
		return [1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	var margin := (
		get_pitch_quality_for_pitch(pitch_id, pitch_speed_fps)
		+ get_opponent_mastery_quality_bonus(opponent_index)
		+ get_frustration_quality_bonus()
		- get_effective_opponent_difficulty(opponent_index, distance_index)
	)
	var spread := 0.85
	var thresholds := [-3.80, -3.20, -2.75, -2.35, -1.80]
	var cumulative: Array[float] = []
	for threshold in thresholds:
		cumulative.append(_logistic((float(threshold) - margin) / spread))
	var original_hits: Array[float] = [
		cumulative[0],
		maxf(cumulative[1] - cumulative[0], 0.0),
		maxf(cumulative[2] - cumulative[1], 0.0),
		maxf(cumulative[3] - cumulative[2], 0.0),
		maxf(cumulative[4] - cumulative[3], 0.0),
	]
	var contact_probability := 0.0
	for probability in original_hits:
		contact_probability += probability
	var result: Array[float] = []
	for probability in original_hits:
		result.append(probability * 0.75)
	# A quarter of former fair contact becomes ordinary baseball texture. Fouls
	# can advance the count but never strike out; Balls can build to a walk.
	result.append(contact_probability * 0.10)
	result.append(contact_probability * 0.15)
	result.append(maxf(1.0 - cumulative[4], 0.0))
	return result

func get_outcome_probabilities(opponent_index: int = current_opponent) -> Array[float]:
	var result: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	for entry in get_pitch_selection_entries():
		var pitch_id := str(entry.id)
		var pitch_probabilities := get_outcome_probabilities_for_pitch(
			pitch_id,
			get_representative_pitch_speed(pitch_id),
			opponent_index,
			selected_distance_index
		)
		for index in result.size():
			result[index] += float(pitch_probabilities[index]) * float(entry.probability)
	return result

func get_base_strikes_required(opponent_index: int = current_opponent) -> int:
	var bounded := clampi(opponent_index, 0, Content.BASE_STRIKES_REQUIRED.size() - 1)
	return int(Content.BASE_STRIKES_REQUIRED[bounded])

func get_strikes_required(opponent_index: int = current_opponent) -> int:
	var required := get_base_strikes_required(opponent_index)
	# Three strikes remains inviolate throughout the human ladder. The genetic
	# shortcut matters only once baseball's governing bodies stop being human.
	if opponent_index > Content.HUMAN_FINAL_INDEX:
		required -= clampi(int(genetic_levels.compressed_strike_genome), 0, 3)
	return maxi(required, 3)

func get_strikes_per_batter() -> int:
	return get_strikes_required()

func get_balls_required(opponent_index: int = current_opponent) -> int:
	var bounded := clampi(opponent_index, 0, Content.BASE_BALLS_REQUIRED.size() - 1)
	return maxi(int(Content.BASE_BALLS_REQUIRED[bounded]), 1)

func get_strikeout_base_points(opponent_index: int = current_opponent) -> float:
	# Reducing the live count never reduces its original bounty, which is what
	# makes count compression one of the prestige layer's strongest purchases.
	# The first toddler pays only 5 XP instead of front-loading three ordinary
	# 5-point Strikes into one 15-XP windfall. Early opponents add 1 base XP per
	# level until the established count-based bounty takes over at level 11.
	var bounded := clampi(opponent_index, 0, opponents.size() - 1)
	var full_count_bounty := (
		float(get_base_strikes_required(bounded))
		* STRIKEOUT_POINTS_PER_REQUIRED_STRIKE
	)
	return minf(full_count_bounty, OPENING_STRIKEOUT_BASE_POINTS + float(bounded))

func get_opponent_mastery_quality_bonus(opponent_index: int = current_opponent) -> float:
	if opponent_mastery.is_empty():
		return 0.0
	var bounded := clampi(opponent_index, 0, opponent_mastery.size() - 1)
	var requirement := maxf(get_mastery_requirement(bounded), 0.000001)
	var ratio := maxf(opponent_mastery[bounded] / requirement, 0.0)
	return MASTERY_MATCHUP_QUALITY_PER_DOUBLING * log(1.0 + ratio) / log(2.0)

func get_outcome_frustration_points(outcome: int) -> float:
	if outcome < 0 or outcome >= FRUSTRATION_OUTCOME_POINTS.size():
		return 0.0
	return float(FRUSTRATION_OUTCOME_POINTS[outcome])

func _apply_frustration_summary(summary: Dictionary) -> void:
	var gained := 0.0
	var events: Array = summary.get("frustration_events", [])
	for event_value in events:
		if typeof(event_value) != TYPE_DICTIONARY:
			continue
		var event: Dictionary = event_value
		if bool(event.get("strikeout", false)):
			frustration_points = 0.0
			continue
		var event_points := get_outcome_frustration_points(int(event.get("outcome", Content.STRIKE_INDEX)))
		gained = minf(MAX_NUMBER, gained + event_points)
		frustration_points = minf(MAX_NUMBER, frustration_points + event_points)

	# Closed-form offline play has exact expected totals but no authoritative
	# ordering. When one or more strikeouts occur, the mean final segment after
	# the last reset is one of (strikeouts + 1) equivalent segments.
	var aggregate_points := maxf(float(summary.get("aggregate_frustration_points", 0.0)), 0.0)
	var aggregate_strikeouts := maxf(float(summary.get("aggregate_frustration_strikeouts", 0.0)), 0.0)
	if aggregate_points > 0.0 or aggregate_strikeouts > 0.0:
		gained = minf(MAX_NUMBER, gained + aggregate_points)
		if aggregate_strikeouts > 0.0:
			frustration_points = minf(
				MAX_NUMBER,
				aggregate_points / (aggregate_strikeouts + 1.0)
			)
		else:
			frustration_points = minf(MAX_NUMBER, frustration_points + aggregate_points)
	summary.frustration_gained = gained

func get_frustration_quality_bonus() -> float:
	var intervals := maxf(frustration_points, 0.0) / FRUSTRATION_REFERENCE_POINTS
	return FRUSTRATION_QUALITY_PER_DOUBLING * log(1.0 + intervals) / log(2.0)

func get_frustration_meter_ratio() -> float:
	# A monotonic visual meter for an uncapped logarithmic bonus: it fills half
	# way at the first reference score, then approaches full without falsely
	# implying that the underlying bonus has reached a cap.
	var intervals := maxf(frustration_points, 0.0) / FRUSTRATION_REFERENCE_POINTS
	return intervals / (1.0 + intervals)

func get_hit_save_chance(outcome: int, _opponent_index: int = current_opponent) -> float:
	if outcome < 0 or outcome >= Content.HIT_OUTCOME_COUNT or outcome == Content.GRAND_SLAM_INDEX:
		return 0.0
	if has_divine_blessing("angels_outfield"):
		return 1.0
	# Genetic fielding becomes deterministic from the weakest hit upward.
	var genetic_rank := clampi(int(genetic_levels.prehensile_outfield), 0, 3)
	var weakest_protected_outcome := Content.HIT_OUTCOME_COUNT - genetic_rank
	if genetic_rank > 0 and outcome >= weakest_protected_outcome:
		return 1.0
	# Mirror clones physically chase the ball; portals catch whatever a clone
	# misses. Independent failure probabilities make both upgrades valuable.
	var clone_rank := clampi(int(eldritch_levels.mirror_clones), 0, 5)
	var clone_save := 1.0 - pow(0.60, clone_rank)
	var portal_save := minf(float(eldritch_levels.portal_outfield) * 0.20, 0.80)
	return clampf(1.0 - (1.0 - clone_save) * (1.0 - portal_save), 0.0, 0.999999)

func get_hit_protection_summary() -> String:
	if has_divine_blessing("angels_outfield"):
		return "All ordinary hits protected • Grand Slams always terminal"
	var deterministic: Array[String] = []
	var rank := clampi(int(genetic_levels.prehensile_outfield), 0, 3)
	if rank >= 1:
		deterministic.append("1B")
	if rank >= 2:
		deterministic.append("2B")
	if rank >= 3:
		deterministic.append("3B")
	var ordinary_save := get_hit_save_chance(Content.OUTCOME_NAMES.find("HOME RUN"))
	var base := "None" if deterministic.is_empty() else ", ".join(deterministic) + " guaranteed"
	if ordinary_save > 0.0:
		base += " • clones/portals %.1f%% on remaining ordinary hits" % (ordinary_save * 100.0)
	return base + " • GS always terminal"

func get_batter_downtime(outcome: int) -> float:
	var bounded := clampi(outcome, 0, OUTCOME_TURNOVER_BONUS_SECONDS.size() - 1)
	return get_base_batter_turnover_seconds() + get_outcome_turnover_bonus(bounded)

func get_outcome_turnover_bonus(outcome: int) -> float:
	var bounded := clampi(outcome, 0, OUTCOME_TURNOVER_BONUS_SECONDS.size() - 1)
	var bonus := float(OUTCOME_TURNOVER_BONUS_SECONDS[bounded])
	# Walks use the Single delay, but are not hits. Only fair contact receives
	# Shake It Off and facility hit-delay reductions.
	if bounded < Content.HIT_OUTCOME_COUNT:
		bonus *= get_hit_delay_factor()
	return bonus / get_time_multiplier()

func get_trained_lineup_seconds() -> float:
	var rank := clampi(int(training_levels.get("turnover", 0)), 0, LINEUP_MAX_RANK)
	return maxf(
		BASE_BATTER_TURNOVER_SECONDS - float(rank) * LINEUP_SECONDS_PER_RANK,
		LINEUP_MIN_SECONDS
	)

func get_base_batter_turnover_seconds() -> float:
	return (
		get_trained_lineup_seconds()
		* get_milestone_effect_multiplier("lineup")
		/ get_time_multiplier()
	)

func get_hit_delay_factor() -> float:
	var rank := clampi(int(training_levels.get("hit_recovery", 0)), 0, HIT_RECOVERY_MAX_RANK)
	return (
		maxf(1.0 - float(rank) * HIT_DELAY_FACTOR_PER_RANK, HIT_DELAY_MIN_FACTOR)
		* get_milestone_effect_multiplier("hit_delay")
	)

func get_batter_cooldown_multiplier() -> float:
	# Compatibility ratio for UI/tests that still need a single baseline value.
	# Outcome-specific delays use get_batter_downtime() instead.
	return get_base_batter_turnover_seconds() / BASE_BATTER_TURNOVER_SECONDS

func get_pitch_cycle_progress() -> float:
	if not live_pitching_enabled or batter_cooldown_remaining > 0.0 or is_pitch_in_flight():
		return 0.0
	return clampf(pitch_credit, 0.0, 1.0)

func get_seconds_until_next_pitch() -> float:
	if not live_pitching_enabled or batter_cooldown_remaining > 0.0 or is_pitch_in_flight():
		return 0.0
	return maxf(1.0 - get_pitch_cycle_progress(), 0.0) / maxf(get_recovery_rate(), 0.000001)

func get_at_bat_metrics(opponent_index: int = current_opponent) -> Dictionary:
	var probabilities := get_outcome_probabilities(opponent_index)
	var strike_requirement := get_strikes_required(opponent_index)
	var ball_requirement := get_balls_required(opponent_index)
	var volley_size := maxi(get_volley_size(), 1)
	var fair_terminal: Array[float] = []
	fair_terminal.resize(Content.HIT_OUTCOME_COUNT)
	fair_terminal.fill(0.0)
	var saved_fair_probability := 0.0
	for outcome in Content.HIT_OUTCOME_COUNT:
		var saved_probability := (
			float(probabilities[outcome])
			* get_hit_save_chance(outcome, opponent_index)
		)
		saved_fair_probability += saved_probability
		fair_terminal[outcome] = maxf(float(probabilities[outcome]) - saved_probability, 0.0)

	# Exact absorbing count model. Every transient state is (strikes, Balls).
	# Transitions only increase one count, apart from self-loops caused by saved
	# hits and two-strike Fouls, so descending dynamic programming is sufficient.
	var states := {}
	for strike_count in range(strike_requirement - 1, -1, -1):
		for ball_count in range(ball_requirement - 1, -1, -1):
			var absorption: Array[float] = []
			absorption.resize(Content.OUTCOME_NAMES.size())
			absorption.fill(0.0)
			for outcome in Content.HIT_OUTCOME_COUNT:
				absorption[outcome] = fair_terminal[outcome]
			var self_probability := saved_fair_probability
			var expected_volleys_numerator := 1.0
			var expected_saved_hits_numerator := saved_fair_probability * float(volley_size)

			var foul_probability := float(probabilities[Content.FOUL_INDEX])
			var foul_strikes := mini(strike_count + volley_size, strike_requirement - 1)
			if foul_strikes == strike_count:
				self_probability += foul_probability
			else:
				var foul_state: Dictionary = states["%d:%d" % [foul_strikes, ball_count]]
				expected_volleys_numerator += foul_probability * float(foul_state.expected_volleys)
				expected_saved_hits_numerator += foul_probability * float(foul_state.expected_saved_hits)
				for outcome in absorption.size():
					absorption[outcome] += foul_probability * float((foul_state.absorption as Array)[outcome])

			var ball_probability := float(probabilities[Content.BALL_INDEX])
			var next_ball_count := ball_count + volley_size
			if next_ball_count >= ball_requirement:
				absorption[Content.BALL_INDEX] += ball_probability
			else:
				var ball_state: Dictionary = states["%d:%d" % [strike_count, next_ball_count]]
				expected_volleys_numerator += ball_probability * float(ball_state.expected_volleys)
				expected_saved_hits_numerator += ball_probability * float(ball_state.expected_saved_hits)
				for outcome in absorption.size():
					absorption[outcome] += ball_probability * float((ball_state.absorption as Array)[outcome])

			var strike_probability := float(probabilities[Content.STRIKE_INDEX])
			var next_strike_count := strike_count + volley_size
			if next_strike_count >= strike_requirement:
				absorption[Content.STRIKE_INDEX] += strike_probability
			else:
				var strike_state: Dictionary = states["%d:%d" % [next_strike_count, ball_count]]
				expected_volleys_numerator += strike_probability * float(strike_state.expected_volleys)
				expected_saved_hits_numerator += strike_probability * float(strike_state.expected_saved_hits)
				for outcome in absorption.size():
					absorption[outcome] += strike_probability * float((strike_state.absorption as Array)[outcome])

			var escape_probability := 1.0 - self_probability
			if escape_probability <= 1.0e-15:
				states["%d:%d" % [strike_count, ball_count]] = {
					"absorption": absorption,
					"expected_volleys": MAX_NUMBER,
					"expected_saved_hits": MAX_NUMBER,
				}
				continue
			for outcome in absorption.size():
				absorption[outcome] = clampf(absorption[outcome] / escape_probability, 0.0, 1.0)
			states["%d:%d" % [strike_count, ball_count]] = {
				"absorption": absorption,
				"expected_volleys": minf(expected_volleys_numerator / escape_probability, MAX_NUMBER),
				"expected_saved_hits": minf(expected_saved_hits_numerator / escape_probability, MAX_NUMBER),
			}

	var opening_state: Dictionary = states.get("0:0", {})
	if opening_state.is_empty() or float(opening_state.get("expected_volleys", MAX_NUMBER)) >= MAX_NUMBER:
		var impossible_terminal_probabilities: Array[float] = []
		impossible_terminal_probabilities.resize(Content.OUTCOME_NAMES.size())
		impossible_terminal_probabilities.fill(0.0)
		return {
			"probabilities": probabilities,
			"terminal_probabilities": impossible_terminal_probabilities,
			"saved_hit_probability": 0.0,
			"terminal_hit_probability": 0.0,
			"strikeout_probability": 0.0,
			"active_volleys": MAX_NUMBER,
			"active_pitches": MAX_NUMBER,
			"cycle_seconds": MAX_NUMBER,
			"strikeouts_per_second": 0.0,
			"active_pitches_per_second": 0.0,
		}
	var terminal_probabilities: Array = opening_state.absorption
	var strikeout_probability := float(terminal_probabilities[Content.STRIKE_INDEX])
	var terminal_hit_probability := 0.0
	for outcome in Content.HIT_OUTCOME_COUNT:
		terminal_hit_probability += float(terminal_probabilities[outcome])
	var active_volleys := float(opening_state.expected_volleys)
	var active_pitches := minf(active_volleys * float(volley_size), MAX_NUMBER)
	var saved_hit_probability := clampf(
		float(opening_state.expected_saved_hits) / maxf(active_pitches, 0.000001),
		0.0,
		1.0
	)
	var expected_downtime := 0.0
	for outcome in terminal_probabilities.size():
		if outcome == Content.FOUL_INDEX:
			continue
		expected_downtime += float(terminal_probabilities[outcome]) * get_batter_downtime(outcome)
	var active_volley_seconds := get_pitch_cooldown_seconds() + get_resolved_flight_seconds()
	var cycle_seconds := active_volleys * active_volley_seconds + expected_downtime
	return {
		"probabilities": probabilities,
		"terminal_probabilities": terminal_probabilities,
		"saved_hit_probability": saved_hit_probability,
		"terminal_hit_probability": terminal_hit_probability,
		"strikeout_probability": strikeout_probability,
		"active_volleys": active_volleys,
		"active_pitches": active_pitches,
		"cycle_seconds": maxf(cycle_seconds, 0.000001),
		"strikeouts_per_second": strikeout_probability / maxf(cycle_seconds, 0.000001),
		"active_pitches_per_second": active_pitches / maxf(cycle_seconds, 0.000001),
	}

func get_strikeout_chance_per_at_bat(opponent_index: int = current_opponent) -> float:
	return float(get_at_bat_metrics(opponent_index).strikeout_probability)

func get_effective_pitch_rate(opponent_index: int = current_opponent) -> float:
	return float(get_at_bat_metrics(opponent_index).active_pitches_per_second)

func get_effective_opponent_difficulty(opponent_index: int = current_opponent, distance_index: int = -1) -> float:
	var opponent := opponents[clampi(opponent_index, 0, opponents.size() - 1)]
	var variant_bonus := (
		get_opponent_variant_difficulty()
		if opponent_index == current_opponent
		and int(get_current_batter_variant().get("opponent_index", -1)) == opponent_index
		else 0.0
	)
	return (
		float(opponent.difficulty)
		+ get_distance_difficulty_for_index(distance_index)
		+ get_opponent_trait_penalty(opponent_index, distance_index)
		+ variant_bonus
	)

func get_opponent_trait_penalty(opponent_index: int = current_opponent, distance_index: int = -1) -> float:
	var opponent := opponents[clampi(opponent_index, 0, opponents.size() - 1)]
	var difficulty := 0.0
	var trait_id := str(opponent.trait)
	var arsenal_size := unlocked_pitches.size()
	match trait_id:
		"sequence_reader":
			difficulty += maxf(float(2 - arsenal_size), 0.0) * 0.70
		"scouted", "college_champion", "adaptive_legend":
			difficulty += maxf(float(4 - arsenal_size), 0.0) * 0.48
		"major_distance":
			difficulty += maxf(log(60.5 / maxf(get_pitch_distance_feet_for_index(distance_index), 3.0)) / log(10.0), 0.0) * 0.40
		"switch_experiment":
			difficulty += maxf(log(2.0 / maxf(get_arm_count(), 1.0)) / log(2.0), 0.0) * 0.75
		"cybernetic_learning":
			difficulty += maxf(float(6 - arsenal_size), 0.0) * 0.55
		"four_bats":
			difficulty += maxf(log(100.0 / maxf(get_pitch_rate(), 0.001)) / log(10.0), 0.0) * 0.75
		"chrono":
			difficulty += maxf(log(500.0 / maxf(get_pitch_rate(), 0.001)) / log(10.0), 0.0) * 0.80
		"low_gravity", "plasma_bat", "giant_zone", "solar_champion":
			difficulty += 0.65
		"aeon_rookie":
			difficulty += maxf(log(2.0 / maxf(get_time_multiplier(), 1.0)) / log(2.0), 0.0) * 0.80
		"phase_hitter":
			difficulty += maxf(float(8 - arsenal_size), 0.0) * 0.50
		"hive_mind":
			difficulty += maxf(log(9.0 / maxf(get_clone_count(), 1.0)) / log(3.0), 0.0) * 0.60
		"black_hole":
			difficulty += maxf(log(1.0e6 / maxf(get_velocity_fps(), 1.0)) / log(10.0), 0.0) * 0.42
		"octopus_god":
			difficulty += maxf(log(1000.0 / maxf(get_pitch_rate(), 0.001)) / log(10.0), 0.0) * 0.90
			difficulty += maxf(log(8.0 / maxf(get_arm_count(), 1.0)) / log(2.0), 0.0) * 0.50
	return difficulty

func _logistic(value: float) -> float:
	if value >= 40.0:
		return 1.0
	if value <= -40.0:
		return 0.0
	return 1.0 / (1.0 + exp(-value))

func get_body_velocity_fps() -> float:
	var velocity := get_trained_base_velocity_fps()
	if has_divine_blessing("let_there_be_fastballs"):
		velocity *= 10.0
	velocity *= get_milestone_effect_multiplier("speed")
	velocity *= pow(1.80, int(genetic_levels.fast_twitch_everything))
	velocity *= pow(12.0, int(eldritch_levels.velocity_without_distance))
	return minf(velocity, get_velocity_cap_fps())

func get_trained_base_velocity_fps() -> float:
	return BASE_VELOCITY_FPS + float(maxi(int(training_levels.get("velocity", 0)), 0)) * VELOCITY_PER_RANK_FPS

func get_velocity_fps() -> float:
	# Training and biology stop at the era's body limit. Worn equipment is a
	# deliberately small post-cap bonus, so exceptional pants can exceed a
	# mortal or alien limit without ever being required to clear that gate.
	var gear := get_equipment_bonuses()
	return minf(get_body_velocity_fps() * (1.0 + float(gear.speed_bonus)), MAX_NUMBER)

func get_velocity_cap_fps() -> float:
	if eldritch_ascensions > 0:
		return SPEED_OF_LIGHT_FPS
	if genetic_rebirths > 0:
		return ALIEN_SPEED_CAP_FPS
	return HUMAN_SPEED_CAP_FPS

func get_velocity_stage_name() -> String:
	if eldritch_ascensions > 0:
		return "ELDRITCH LIMIT • 1c"
	if genetic_rebirths > 0:
		return "GENETIC LIMIT • MACH 12"
	return "HUMAN LIMIT • 211.6 MPH"

func get_arm_count() -> float:
	return pow(2.0, clampi(int(genetic_levels.extra_arms), 0, 3))

func get_clone_count() -> float:
	return pow(2.0, clampi(int(eldritch_levels.mirror_clones), 0, 5))

func get_time_multiplier() -> float:
	return pow(2.0, clampi(int(eldritch_levels.time_compression), 0, 3))

func get_throwing_source_count() -> int:
	return maxi(int(round(get_arm_count() * get_clone_count() * get_time_multiplier())), 1)

func get_simultaneous_ball_cap() -> int:
	# Human baseball stays recognizably human regardless of ordinary training.
	# Prenatal coordination unlocks parallel arms; eldritch geometry later makes
	# room for entire cloned bullpens without turning recovery into phantom balls.
	if genetic_rebirths <= 0:
		return 1
	var capacity := int(pow(2.0, clampi(int(genetic_levels.parallel_pitching_lobes), 0, 3)))
	if eldritch_ascensions > 0:
		capacity *= int(pow(4.0, clampi(int(eldritch_levels.non_euclidean_bullpen), 0, 4)))
	return maxi(capacity, 1)

func get_volley_size() -> int:
	return mini(get_throwing_source_count(), get_simultaneous_ball_cap())

func get_pitcher_size_multiplier() -> float:
	# Visual growth is intentionally saturating: every kind of real pitching
	# strength contributes, but no build can become an unreadable field-sized
	# circle. The fresh body is ×1; the complete cosmic build approaches ×2.
	var quality_strength := maxf(get_pitch_quality() - 0.45, 0.0)
	var rate_strength := maxf(log(maxf(get_pitch_rate() / 0.25, 1.0)) / log(2.0), 0.0) * 1.20
	var speed_strength := maxf(log(maxf(get_velocity_fps(), 1.0)) / log(10.0), 0.0) * 0.80
	var payload_strength := maxf(log(maxf(get_pitch_potency(), 1.0)) / log(10.0), 0.0) * 1.50
	var anatomy_strength := (
		log(maxf(get_arm_count(), 1.0)) / log(2.0)
		+ log(maxf(get_clone_count(), 1.0)) / log(2.0)
		+ log(maxf(get_time_multiplier(), 1.0)) / log(2.0)
	) * 2.0
	var strength := quality_strength + rate_strength + speed_strength + payload_strength + anatomy_strength
	return 1.0 + (1.0 - exp(-strength / 70.0))

func get_recovery_rate() -> float:
	var recovery_rank := clampi(int(training_levels.recovery), 0, RECOVERY_MAX_RANK)
	var rate := BASE_RECOVERY_RATE + float(recovery_rank) * RECOVERY_PER_RANK
	rate *= get_milestone_effect_multiplier("recovery")
	rate *= pow(1.18, int(genetic_levels.elastic_ucl_colony))
	rate *= 1.0 + float(get_equipment_bonuses().rate_bonus)
	return minf(rate, MAX_PHYSICAL_PITCH_RATE)

func get_pitch_cooldown_seconds() -> float:
	return 1.0 / maxf(get_recovery_rate(), 0.000001)

func get_pitch_rate() -> float:
	# This is potential physical ball throughput during continuous releases.
	# Actual throughput also includes immutable flight and batter replacement.
	return minf(get_recovery_rate() * float(get_volley_size()), MAX_PHYSICAL_PITCH_RATE)

func get_pitch_potency() -> float:
	var potency := 1.0
	for id in purchased_ball_upgrades:
		var definition := Content.ball_upgrade_by_id(id)
		if not definition.is_empty():
			potency = maxf(potency, float(definition.potency))
	potency *= get_milestone_effect_multiplier("payload")
	potency *= pow(2.50, int(genetic_levels.ball_gland))
	potency *= pow(10.0, int(eldritch_levels.causal_seams))
	if has_divine_blessing("loaves_and_baseballs"):
		potency *= 25.0
	return minf(potency, MAX_NUMBER)

func get_mastery_multiplier() -> float:
	var multiplier := get_milestone_effect_multiplier("mastery")
	multiplier *= pow(1.75, int(eldritch_levels.mercy_is_euclidean))
	if has_divine_blessing("eternal_seventh"):
		multiplier *= 2.0
	multiplier *= pow(1.50, divine_halos)
	multiplier *= 1.0 + float(get_equipment_bonuses().mastery_bonus)
	return minf(multiplier, MAX_NUMBER)

func get_prestige_income_multiplier() -> float:
	return minf(
		pow(1.50, int(genetic_levels.ancestral_memory)) * pow(1.50, divine_halos),
		MAX_NUMBER
	)

func get_xp_multiplier(opponent_index: int = current_opponent, distance_index: int = -1) -> float:
	var bounded_index := clampi(opponent_index, 0, opponents.size() - 1)
	var equipment := get_equipment_bonuses()
	return minf(
		MAX_NUMBER,
		float(opponents[bounded_index].reward)
		* get_prestige_income_multiplier()
		* get_pitch_potency()
		* get_distance_xp_multiplier_for_index(distance_index)
		* get_opponent_farm_xp_multiplier(bounded_index)
		* (1.0 + float(equipment.xp_bonus))
		* get_achievement_xp_multiplier()
	)

func get_achievement_xp_bonus() -> float:
	return float(unlocked_achievements.size()) * Content.DEFAULT_ACHIEVEMENT_XP_BONUS

func get_achievement_xp_multiplier() -> float:
	return 1.0 + get_achievement_xp_bonus()

func has_achievement(id: String) -> bool:
	return id in unlocked_achievements

func get_historical_highest_opponent() -> int:
	var result := highest_unlocked
	if lifetime_genetic_rebirths > 0:
		result = maxi(result, Content.ALIEN_EXHIBITION_INDEX)
	if lifetime_eldritch_ascensions > 0:
		result = maxi(result, Content.ELDRITCH_EXHIBITION_INDEX)
	if divine_ascensions > 0:
		result = maxi(result, Content.FINAL_BOSS_INDEX)
	return clampi(result, 0, Content.FINAL_BOSS_INDEX)

func is_achievement_tier_revealed(tier: String) -> bool:
	match tier:
		"human":
			return true
		"genetic":
			return (
				genetic_offer_unlocked
				or lifetime_genetic_rebirths > 0
				or get_historical_highest_opponent() >= Content.ALIEN_EXHIBITION_INDEX
			)
		"eldritch":
			return (
				eldritch_offer_unlocked
				or lifetime_eldritch_ascensions > 0
				or get_historical_highest_opponent() >= Content.ELDRITCH_EXHIBITION_INDEX
			)
		"divine":
			return cosmos_conquered or divine_ascensions > 0
		_:
			return false

func is_achievement_information_revealed(definition: Dictionary) -> bool:
	var id := str(definition.get("id", ""))
	if has_achievement(id):
		return true
	if not is_achievement_tier_revealed(str(definition.get("tier", "human"))):
		return false
	if bool(definition.get("secret", false)):
		return false
	var reveal_level := int(definition.get("reveal_level", -1))
	if reveal_level >= 0 and get_historical_highest_opponent() < reveal_level:
		return false
	return true

func _achievement_metric_value(definition: Dictionary) -> float:
	var metric := str(definition.get("metric", ""))
	var key = definition.get("key", "")
	match metric:
		"lifetime_pitches":
			return lifetime_pitches
		"field_taps":
			return lifetime_field_taps
		"lifetime_strikeouts":
			return lifetime_strikeouts
		"outcome":
			var outcome_index := clampi(int(key), 0, result_totals.size() - 1)
			return float(result_totals[outcome_index])
		"level":
			return float(get_historical_highest_opponent())
		"distance":
			return float(lifetime_max_distance_index)
		"speed":
			return lifetime_max_pitch_speed_fps
		"training":
			return float(training_levels.get(str(key), 0))
		"pitches_owned":
			return float(unlocked_pitches.size())
		"ball_upgrades_owned":
			return float(purchased_ball_upgrades.size())
		"facilities_owned":
			return float(purchased_milestones.size())
		"loot_found":
			return lifetime_loot_found
		"loot_rarity":
			return float(lifetime_max_loot_rarity)
		"equipped_slots":
			var equipped_count := 0
			for slot in ["hat", "jersey", "jockstrap", "glove", "pants", "cleats"]:
				if not str(equipped_loot.get(slot, "")).is_empty():
					equipped_count += 1
			return float(equipped_count)
		"genetic_offer":
			return 1.0 if genetic_offer_unlocked or lifetime_genetic_rebirths > 0 else 0.0
		"genetic_rebirths":
			return float(lifetime_genetic_rebirths)
		"lifetime_dna":
			return lifetime_dna_earned
		"genetic_upgrades_owned":
			var genetic_count := 0
			for rank in genetic_levels.values():
				if int(rank) > 0:
					genetic_count += 1
			return float(genetic_count)
		"genetic_upgrade":
			return float(genetic_levels.get(str(key), 0))
		"arms":
			return get_arm_count()
		"volley":
			return float(get_volley_size())
		"saved_hits":
			return lifetime_saved_hits
		"relic_owned":
			for item in loot_items:
				if str((item as Dictionary).get("slot", "")) == "relic":
					return 1.0
			return 0.0
		"eldritch_offer":
			return 1.0 if eldritch_offer_unlocked or lifetime_eldritch_ascensions > 0 else 0.0
		"eldritch_ascensions":
			return float(lifetime_eldritch_ascensions)
		"lifetime_arcana":
			return lifetime_arcana_earned
		"clones":
			return get_clone_count()
		"time_layers":
			return get_time_multiplier()
		"eldritch_upgrade":
			return float(eldritch_levels.get(str(key), 0))
		"cosmos":
			return 1.0 if cosmos_conquered or divine_ascensions > 0 else 0.0
		"no_hitter":
			return 1.0 if cosmos_conquered and no_hitter_attempt_valid else 0.0
		"divine_ascensions":
			return float(divine_ascensions)
		"divine_blessings":
			return float(divine_blessings.size())
		"divine_halos":
			return float(divine_halos)
		_:
			return 0.0

func get_achievement_progress(definition: Dictionary) -> Dictionary:
	var current := maxf(_achievement_metric_value(definition), 0.0)
	var threshold := maxf(float(definition.get("threshold", 1.0)), 0.000001)
	var ratio := clampf(current / threshold, 0.0, 1.0)
	var metric := str(definition.get("metric", ""))
	var progress_text := "%s / %s" % [format_number(current, 0), format_number(threshold, 0)]
	match metric:
		"speed":
			progress_text = "%s / %s" % [format_speed(current), format_speed(threshold)]
		"distance":
			var current_index := clampi(int(current), 0, Content.DISTANCE_TIERS.size() - 1)
			var target_index := clampi(int(threshold), 0, Content.DISTANCE_TIERS.size() - 1)
			progress_text = "%s / %s" % [
				str(Content.DISTANCE_TIERS[current_index].label),
				str(Content.DISTANCE_TIERS[target_index].label),
			]
		"level":
			progress_text = "Campaign level %d / %d" % [int(current) + 1, int(threshold) + 1]
		"training", "genetic_upgrade", "eldritch_upgrade":
			progress_text = "Rank %d / %d" % [int(current), int(threshold)]
		"genetic_offer", "eldritch_offer", "relic_owned", "cosmos", "no_hitter":
			progress_text = "COMPLETE" if ratio >= 1.0 else "LOCKED"
	return {
		"current": current,
		"threshold": threshold,
		"ratio": ratio,
		"text": progress_text,
	}

func check_achievements(emit_notifications := true) -> Array[Dictionary]:
	var newly_unlocked: Array[Dictionary] = []
	for definition_value in Content.ACHIEVEMENTS:
		var definition: Dictionary = definition_value
		var id := str(definition.id)
		if id in unlocked_achievements:
			continue
		var progress := get_achievement_progress(definition)
		if float(progress.ratio) < 1.0:
			continue
		unlocked_achievements.append(id)
		achievement_revision += 1
		newly_unlocked.append(definition)
		if emit_notifications:
			achievement_unlocked.emit(definition, unlocked_achievements.size())
	return newly_unlocked

func set_catalog_hide_purchased(catalog_id: String, hidden: bool) -> bool:
	if not catalog_hide_purchased.has(catalog_id):
		return false
	catalog_hide_purchased[catalog_id] = hidden
	return true

func _get_quality_without_pitch(pitch_speed_fps: float) -> float:
	var velocity_score := log(maxf(pitch_speed_fps, 0.0) + 1.0) / log(2.0) * 0.70
	var command_score := float(training_levels.command) * QUALITY_PER_RANK
	var diversity_bonus := maxf(float(unlocked_pitches.size() - 1) * 0.08, 0.0)
	var trained_quality := (
		velocity_score + command_score + diversity_bonus
	) * get_milestone_effect_multiplier("quality")
	trained_quality += float(genetic_levels.compound_pitching_eye) * 1.25
	trained_quality += float(eldritch_levels.eyes_behind_moon) * 2.0
	var equipment_quality := float(get_equipment_bonuses().quality_bonus)
	return trained_quality + equipment_quality

func get_pitch_quality_for_pitch(pitch_id: String, pitch_speed_fps: float) -> float:
	var definition := Content.pitch_by_id(pitch_id)
	var pitch_bonus := -0.25 if definition.is_empty() else float(definition.bonus)
	return _get_quality_without_pitch(pitch_speed_fps) + pitch_bonus

func get_pitch_quality() -> float:
	var expected := 0.0
	for entry in get_pitch_selection_entries():
		var pitch_id := str(entry.id)
		expected += (
			get_pitch_quality_for_pitch(pitch_id, get_representative_pitch_speed(pitch_id))
			* float(entry.probability)
		)
	return expected

func get_expected_base_xp() -> float:
	var metrics := get_at_bat_metrics()
	return (
		float(metrics.strikeout_probability) * get_strikeout_base_points()
		/ maxf(float(metrics.active_pitches), 0.000001)
	)

func get_estimated_xp_per_second(opponent_index: int = current_opponent) -> float:
	var metrics := get_at_bat_metrics(opponent_index)
	return minf(MAX_NUMBER, float(metrics.strikeouts_per_second) * get_strikeout_base_points(opponent_index) * get_xp_multiplier(opponent_index))

func get_current_opponent() -> Dictionary:
	return opponents[current_opponent]

func get_current_distance() -> Dictionary:
	return Content.DISTANCE_TIERS[clampi(selected_distance_index, 0, Content.DISTANCE_TIERS.size() - 1)]

func get_max_distance_index() -> int:
	var result := 0
	for index in Content.DISTANCE_TIERS.size():
		if highest_unlocked >= int(Content.DISTANCE_TIERS[index].required_level):
			result = index
	return result

func set_distance_index(index: int) -> bool:
	var bounded := clampi(index, 0, get_max_distance_index())
	if bounded == selected_distance_index:
		return false
	selected_distance_index = bounded
	lifetime_max_distance_index = maxi(lifetime_max_distance_index, bounded)
	consecutive_home_runs = 0
	var distance := get_current_distance()
	progression_changed.emit(
		"PITCHING DISTANCE: %s • XP ×%s • threat +%.2f"
		% [
			distance.label,
			BaseballGameState.format_number(float(distance.xp_multiplier)),
			get_distance_difficulty(),
		]
	)
	check_achievements()
	return true

func get_distance_xp_multiplier_for_index(distance_index: int = -1) -> float:
	var bounded := selected_distance_index if distance_index < 0 else clampi(
		distance_index,
		0,
		Content.DISTANCE_TIERS.size() - 1
	)
	return minf(
		float(Content.DISTANCE_TIERS[bounded].xp_multiplier)
		* (1.0 + float(get_equipment_bonuses().distance_bonus)),
		MAX_NUMBER
	)

func get_distance_xp_multiplier() -> float:
	return get_distance_xp_multiplier_for_index(selected_distance_index)

func get_distance_penalty_multiplier() -> float:
	var rank := clampi(int(training_levels.get("distance_control", 0)), 0, 20)
	return maxf(1.0 - float(rank) * DISTANCE_FACTOR_PER_RANK, DISTANCE_MIN_FACTOR)

func get_distance_difficulty_for_index(distance_index: int = -1) -> float:
	var bounded := selected_distance_index if distance_index < 0 else clampi(
		distance_index,
		0,
		Content.DISTANCE_TIERS.size() - 1
	)
	return float(Content.DISTANCE_TIERS[bounded].difficulty) * get_distance_penalty_multiplier()

func get_distance_difficulty() -> float:
	return get_distance_difficulty_for_index(selected_distance_index)

func get_pitch_distance_feet_for_index(distance_index: int = -1) -> float:
	var bounded := selected_distance_index if distance_index < 0 else clampi(
		distance_index,
		0,
		Content.DISTANCE_TIERS.size() - 1
	)
	return float(Content.DISTANCE_TIERS[bounded].feet)

func get_pitch_distance_feet() -> float:
	return get_pitch_distance_feet_for_index(selected_distance_index)

func get_physical_flight_seconds() -> float:
	return get_pitch_distance_feet() / maxf(get_representative_pitch_speed(), 0.000001)

func get_resolved_flight_seconds() -> float:
	return get_resolved_flight_seconds_for_speed(get_representative_pitch_speed(), selected_distance_index)

func get_resolved_flight_seconds_for_speed(pitch_speed_fps: float, distance_index: int = -1) -> float:
	# Opening physics are literal: three feet at one foot/second takes three
	# seconds. Astronomical distances compress logarithmically so galaxy baseball
	# remains playable, while every released volley still owns a real flight phase.
	var physical_seconds := get_pitch_distance_feet_for_index(distance_index) / maxf(pitch_speed_fps, 0.000001)
	if physical_seconds <= 3.0:
		return clampf(physical_seconds, 0.16, 3.0)
	return minf(3.0 + log(physical_seconds / 3.0) * 0.35, 5.0)

func set_current_opponent(index: int) -> bool:
	if index < 0 or index > highest_unlocked or index == current_opponent:
		return false
	current_opponent = index
	consecutive_home_runs = 0
	plate_strikes = 0
	plate_balls = 0
	_reset_batter_identity()
	batter_replacement_pending = batter_cooldown_remaining > 0.0
	if is_pitch_in_flight():
		# The released pitch keeps its speed, distance, remaining flight time, and
		# pitch type. Only the batter interaction is resampled for the newly chosen
		# target, which is still unknown to the player until impact.
		pending_volley_opponent_index = current_opponent
		pending_volley_outcome = _sample_outcome(get_outcome_probabilities_for_pitch(
			pending_volley_pitch_id,
			pending_volley_speed_fps,
			current_opponent,
			pending_volley_distance_index
		))
		pending_volley_saved = (
			pending_volley_outcome < Content.HIT_OUTCOME_COUNT
			and rng.randf() < get_hit_save_chance(pending_volley_outcome, current_opponent)
		)
	progression_changed.emit("Now pitching to %s." % opponents[index].name)
	return true

func _check_opponent_unlock() -> String:
	if current_opponent != highest_unlocked:
		return ""
	var requirement := get_mastery_requirement(current_opponent)
	if opponent_mastery[current_opponent] < requirement:
		return ""
	if highest_unlocked >= opponents.size() - 1:
		if cosmos_conquered:
			return ""
		cosmos_conquered = true
		var victory_message := "COSMOS CONQUERED: Octathulhu has run out of causality."
		progression_changed.emit(victory_message)
		check_achievements()
		return victory_message
	highest_unlocked += 1
	var message := "UNLOCKED: %s" % opponents[highest_unlocked].name
	if auto_advance_enabled and has_genetic_upgrade("migratory_instinct"):
		current_opponent = highest_unlocked
		plate_strikes = 0
		plate_balls = 0
		_reset_batter_identity()
		batter_replacement_pending = batter_cooldown_remaining > 0.0
		consecutive_home_runs = 0
		message += " • auto-advanced"
	progression_changed.emit(message)
	check_achievements()
	return message

func get_mastery_ratio(index: int = current_opponent) -> float:
	var bounded_index := clampi(index, 0, opponents.size() - 1)
	var requirement := get_mastery_requirement(bounded_index)
	if requirement <= 0.0:
		return 1.0
	return clampf(opponent_mastery[bounded_index] / requirement, 0.0, 1.0)

func get_mastery_requirement(index: int = current_opponent) -> float:
	var bounded_index := clampi(index, 0, opponents.size() - 1)
	var prestige_rank := int(genetic_levels.get("inherited_scorebook", 0))
	return maxf(
		float(opponents[bounded_index].mastery_required)
		* pow(MASTERY_REQUIREMENT_FACTOR_PER_RANK, prestige_rank),
		0.000001
	)

func get_overmastery_doublings(index: int = current_opponent) -> float:
	var bounded_index := clampi(index, 0, opponents.size() - 1)
	var requirement := get_mastery_requirement(bounded_index)
	var ratio := maxf(opponent_mastery[bounded_index] / requirement, 1.0)
	return maxf(log(ratio) / log(2.0), 0.0)

func get_opponent_farm_xp_multiplier(index: int = current_opponent) -> float:
	return 1.0 + get_overmastery_doublings(index) * OVERMASTERY_XP_PER_DOUBLING

func get_opponent_loot_luck(index: int = current_opponent) -> float:
	return get_overmastery_doublings(index) * OVERMASTERY_LOOT_LUCK_PER_DOUBLING

func get_loot_rarity_probabilities(index: int = current_opponent) -> Array[float]:
	# Raising each base cumulative threshold to this exponent is equivalent to
	# gently biasing one uniform rarity roll upward. The probabilities still sum
	# to one, and the bias grows only logarithmically with excess mastery.
	var exponent := 1.0 + get_opponent_loot_luck(index)
	var result: Array[float] = []
	var base_cumulative := 0.0
	var adjusted_previous := 0.0
	for rarity in Content.LOOT_RARITIES:
		base_cumulative = minf(base_cumulative + float(rarity.probability), 1.0)
		var adjusted_cumulative := pow(base_cumulative, exponent)
		result.append(maxf(adjusted_cumulative - adjusted_previous, 0.0))
		adjusted_previous = adjusted_cumulative
	if not result.is_empty():
		result[result.size() - 1] += maxf(1.0 - adjusted_previous, 0.0)
	return result

func get_overmastery_summary(index: int = current_opponent) -> String:
	var doublings := get_overmastery_doublings(index)
	if doublings <= 0.000001:
		return ""
	return "FARM BONUS  •  XP ×%.3f  •  LOOT LUCK +%.1f%%" % [
		get_opponent_farm_xp_multiplier(index),
		get_opponent_loot_luck(index) * 100.0,
	]

func get_offline_xp_efficiency() -> float:
	var rank := clampi(
		int(training_levels.get("offline_efficiency", 0)),
		0,
		OFFLINE_XP_MAX_RANK
	)
	return BASE_OFFLINE_XP_EFFICIENCY + float(rank) * OFFLINE_XP_EFFICIENCY_PER_RANK

func get_training_cost(id: String) -> float:
	var definition := Content.training_by_id(id)
	if definition.is_empty():
		return MAX_NUMBER
	if highest_unlocked < int(definition.get("required_level", 0)):
		return MAX_NUMBER
	if id == "velocity" and is_velocity_body_capped():
		return MAX_NUMBER
	if definition.has("max_level") and int(training_levels[id]) >= int(definition.max_level):
		return MAX_NUMBER
	return rounded_cost(minf(
		MAX_NUMBER,
		float(definition.base_cost) * pow(float(definition.growth), int(training_levels[id]))
	))

func buy_training(id: String) -> bool:
	if not training_levels.has(id):
		return false
	var definition := Content.training_by_id(id)
	if definition.is_empty():
		return false
	if highest_unlocked < int(definition.get("required_level", 0)):
		return false
	if id == "velocity" and is_velocity_body_capped():
		return false
	if definition.has("max_level") and int(training_levels[id]) >= int(definition.max_level):
		return false
	var cost := get_training_cost(id)
	if xp < cost:
		return false
	xp -= cost
	training_levels[id] = int(training_levels[id]) + 1
	progression_changed.emit("%s is now rank %d." % [Content.training_by_id(id).name, training_levels[id]])
	check_achievements()
	return true

func is_velocity_body_capped() -> bool:
	return get_body_velocity_fps() >= get_velocity_cap_fps() * 0.999999

func can_buy_pitch(id: String) -> bool:
	var definition := Content.pitch_by_id(id)
	return (
		not definition.is_empty()
		and id not in unlocked_pitches
		and highest_unlocked >= int(definition.required_level)
		and xp >= get_pitch_cost(id)
	)

func get_pitch_cost(id: String) -> float:
	var definition := Content.pitch_by_id(id)
	if definition.is_empty():
		return MAX_NUMBER
	return rounded_cost(float(definition.cost))

func buy_pitch(id: String) -> bool:
	if not can_buy_pitch(id):
		return false
	var definition := Content.pitch_by_id(id)
	xp -= get_pitch_cost(id)
	unlocked_pitches.append(id)
	progression_changed.emit("PITCH LEARNED: %s" % definition.name)
	check_achievements()
	return true

func has_ball_upgrade(id: String) -> bool:
	return id in purchased_ball_upgrades

func can_buy_ball_upgrade(id: String) -> bool:
	var definition := Content.ball_upgrade_by_id(id)
	return (
		not definition.is_empty()
		and id not in purchased_ball_upgrades
		and highest_unlocked >= int(definition.required_level)
		and xp >= get_ball_upgrade_cost(id)
	)

func get_ball_upgrade_cost(id: String) -> float:
	var definition := Content.ball_upgrade_by_id(id)
	if definition.is_empty():
		return MAX_NUMBER
	return rounded_cost(float(definition.cost))

func buy_ball_upgrade(id: String) -> bool:
	if not can_buy_ball_upgrade(id):
		return false
	var definition := Content.ball_upgrade_by_id(id)
	xp -= get_ball_upgrade_cost(id)
	purchased_ball_upgrades.append(id)
	progression_changed.emit("BALL EVOLVED: %s" % definition.name)
	check_achievements()
	return true

func has_milestone(id: String) -> bool:
	return id in purchased_milestones

func get_milestone_effect_multiplier(effect_id: String) -> float:
	if milestone_effect_cache_count != purchased_milestones.size():
		milestone_effect_cache = {}
		for id in purchased_milestones:
			var definition := Content.milestone_by_id(id)
			if definition.is_empty():
				continue
			var effects: Dictionary = definition.get("effects", {})
			for stat_id in effects:
				milestone_effect_cache[stat_id] = minf(
					float(milestone_effect_cache.get(stat_id, 1.0)) * float(effects[stat_id]),
					MAX_NUMBER
				)
		milestone_effect_cache_count = purchased_milestones.size()
	return float(milestone_effect_cache.get(effect_id, 1.0))

func _invalidate_milestone_effect_cache() -> void:
	milestone_effect_cache_count = -1
	milestone_effect_cache.clear()

func get_milestone_unmet_requirements(definition: Dictionary) -> Array[String]:
	var requirements: Array[String] = []
	var required_level := int(definition.get("required_level", 0))
	if highest_unlocked < required_level:
		requirements.append("REACH LEVEL %d" % (required_level + 1))
	var required_speed := float(definition.get("required_speed_fps", 0.0))
	if required_speed > 0.0 and get_velocity_fps() + 0.000001 < required_speed:
		requirements.append("THROW AT %s" % BaseballGameState.format_speed(required_speed).to_upper())
	var required_strikeouts := float(definition.get("required_strikeouts", 0.0))
	if required_strikeouts > 0.0 and current_body_strikeouts + 0.000001 < required_strikeouts:
		requirements.append("RECORD %s STRIKEOUTS" % BaseballGameState.format_number(required_strikeouts, 0))
	var required_distance := int(definition.get("required_distance_index", -1))
	if required_distance >= 0 and selected_distance_index < required_distance:
		var bounded := clampi(required_distance, 0, Content.DISTANCE_TIERS.size() - 1)
		requirements.append("USE THE %s MOUND" % str(Content.DISTANCE_TIERS[bounded].label).to_upper())
	return requirements

func is_milestone_unlocked(id: String) -> bool:
	var definition := Content.milestone_by_id(id)
	return not definition.is_empty() and get_milestone_unmet_requirements(definition).is_empty()

func can_buy_milestone(id: String) -> bool:
	var definition := Content.milestone_by_id(id)
	return (
		not definition.is_empty()
		and id not in purchased_milestones
		and get_milestone_unmet_requirements(definition).is_empty()
		and xp >= get_milestone_cost(id)
	)

func get_milestone_cost(id: String) -> float:
	var definition := Content.milestone_by_id(id)
	if definition.is_empty():
		return MAX_NUMBER
	return rounded_cost(float(definition.cost))

func buy_milestone(id: String) -> bool:
	if not can_buy_milestone(id):
		return false
	var definition := Content.milestone_by_id(id)
	xp -= get_milestone_cost(id)
	purchased_milestones.append(id)
	_invalidate_milestone_effect_cache()
	progression_changed.emit("UPGRADE ACQUIRED: %s" % definition.name)
	check_achievements()
	return true

func get_scale_cost(id: String) -> float:
	var definition := Content.scale_by_id(id)
	if definition.is_empty():
		return MAX_NUMBER
	if int(scale_levels[id]) >= int(definition.max_level):
		return MAX_NUMBER
	return rounded_cost(minf(
		MAX_NUMBER,
		float(definition.base_cost) * pow(float(definition.growth), int(scale_levels[id]))
	))

func can_buy_scale(id: String) -> bool:
	var definition := Content.scale_by_id(id)
	return (
		not definition.is_empty()
		and highest_unlocked >= int(definition.required_level)
		and int(scale_levels[id]) < int(definition.max_level)
		and xp >= get_scale_cost(id)
	)

func buy_scale(id: String) -> bool:
	if not can_buy_scale(id):
		return false
	var cost := get_scale_cost(id)
	xp -= cost
	scale_levels[id] = int(scale_levels[id]) + 1
	progression_changed.emit("%s is now rank %d." % [Content.scale_by_id(id).name, scale_levels[id]])
	check_achievements()
	return true

func has_genetic_upgrade(id: String) -> bool:
	return int(genetic_levels.get(id, 0)) > 0

func has_eldritch_upgrade(id: String) -> bool:
	return int(eldritch_levels.get(id, 0)) > 0

func has_divine_blessing(id: String) -> bool:
	return id in divine_blessings

func get_genetic_cost(id: String) -> int:
	var definition := Content.genetic_by_id(id)
	if definition.is_empty():
		return 2147483647
	var rank := int(genetic_levels.get(id, 0))
	if rank >= int(definition.max_level):
		return 2147483647
	return maxi(int(round(float(definition.base_cost) * pow(float(definition.growth), rank))), 1)

func can_buy_genetic(id: String) -> bool:
	var definition := Content.genetic_by_id(id)
	return (
		genetic_offer_unlocked
		and not definition.is_empty()
		and int(genetic_levels.get(id, 0)) < int(definition.max_level)
		and dna >= get_genetic_cost(id)
	)

func buy_genetic(id: String) -> bool:
	if not can_buy_genetic(id):
		return false
	var cost := get_genetic_cost(id)
	dna -= cost
	genetic_levels[id] = int(genetic_levels.get(id, 0)) + 1
	progression_changed.emit("GENETIC ENHANCEMENT: %s rank %d." % [Content.genetic_by_id(id).name, genetic_levels[id]])
	if id == "autonomic_wardrobe":
		auto_equip_highest_power()
	check_achievements()
	return true

func get_eldritch_cost(id: String) -> int:
	var definition := Content.eldritch_by_id(id)
	if definition.is_empty():
		return 2147483647
	var rank := int(eldritch_levels.get(id, 0))
	if rank >= int(definition.max_level):
		return 2147483647
	return maxi(int(round(float(definition.base_cost) * pow(float(definition.growth), rank))), 1)

func can_buy_eldritch(id: String) -> bool:
	var definition := Content.eldritch_by_id(id)
	return (
		eldritch_offer_unlocked
		and not definition.is_empty()
		and int(eldritch_levels.get(id, 0)) < int(definition.max_level)
		and arcana >= get_eldritch_cost(id)
	)

func buy_eldritch(id: String) -> bool:
	if not can_buy_eldritch(id):
		return false
	var cost := get_eldritch_cost(id)
	arcana -= cost
	eldritch_levels[id] = int(eldritch_levels.get(id, 0)) + 1
	progression_changed.emit("ELDRITCH MAGIC: %s rank %d." % [Content.eldritch_by_id(id).name, eldritch_levels[id]])
	check_achievements()
	return true

func get_dna_gain_multiplier() -> float:
	var multiplier := pow(1.50, int(eldritch_levels.memory_of_flesh))
	if has_divine_blessing("book_of_genealogy"):
		multiplier *= 2.0
	return multiplier

func get_arcana_gain_multiplier() -> float:
	return 2.0 if has_divine_blessing("bottom_ninth_revelation") else 1.0

func get_potential_dna() -> int:
	if not genetic_offer_unlocked or highest_unlocked < Content.ALIEN_EXHIBITION_INDEX or run_xp < DNA_XP_THRESHOLD:
		return 0
	var raw_base := pow(run_xp / DNA_XP_THRESHOLD, 1.0 / 3.0)
	# Exact cube thresholds such as 1,000 can land microscopically below their
	# integer in binary floating point. Keep advertised prestige breakpoints exact.
	var base: float = floor(raw_base + maxf(raw_base * 1.0e-12, 1.0e-9))
	return maxi(int(floor(base * get_dna_gain_multiplier())), 1)

func get_potential_arcana() -> int:
	if not eldritch_offer_unlocked or highest_unlocked < Content.ELDRITCH_EXHIBITION_INDEX or reality_dna_earned < 1.0:
		return 0
	var base: float = floor(pow(reality_dna_earned, 0.60))
	return maxi(int(floor(base * get_arcana_gain_multiplier())), 1)

func _empty_equipped_loot() -> Dictionary:
	return {
		"hat": "",
		"jersey": "",
		"jockstrap": "",
		"glove": "",
		"pants": "",
		"cleats": "",
		"relic": "",
	}

func _clear_all_loot_for_reset() -> void:
	loot_items.clear()
	equipped_loot = _empty_equipped_loot()
	current_body_loot_found = 0.0
	loot_dry_streak = 0
	loot_roll_cooldown_remaining = 0.0
	last_time_travel_retained_slots.clear()
	loot_revision += 1

func _prepare_genetic_time_travel_loot() -> Array[String]:
	var equipped_slots: Array[String] = []
	for definition in Content.LOOT_SLOTS:
		var slot := str(definition.id)
		if not get_equipped_loot_item(slot).is_empty():
			equipped_slots.append(slot)
	# Fisher-Yates uses the game's saved RNG stream, making a retention roll
	# testable while still genuinely random during play.
	for index in range(equipped_slots.size() - 1, 0, -1):
		var swap_index := rng.randi_range(0, index)
		var temporary := equipped_slots[index]
		equipped_slots[index] = equipped_slots[swap_index]
		equipped_slots[swap_index] = temporary
	var keep_count := mini(
		clampi(int(eldritch_levels.get("reverse_terminator", 0)), 0, Content.LOOT_SLOTS.size()),
		equipped_slots.size()
	)
	var retained_items: Array[Dictionary] = []
	var retained_slots: Array[String] = []
	for index in keep_count:
		var slot := equipped_slots[index]
		var item := get_equipped_loot_item(slot)
		if not item.is_empty():
			retained_items.append(item.duplicate(true))
			retained_slots.append(slot)
	loot_items = retained_items
	equipped_loot = _empty_equipped_loot()
	for item in retained_items:
		equipped_loot[str(item.slot)] = str(item.id)
	current_body_loot_found = 0.0
	loot_dry_streak = 0
	loot_roll_cooldown_remaining = 0.0
	last_time_travel_retained_slots = retained_slots.duplicate()
	loot_revision += 1
	return retained_slots

func _reset_body_progress() -> void:
	xp = 0.0
	run_xp = 0.0
	training_levels = {
		"velocity": 0,
		"command": 0,
		"field_hustle": 0,
		"recovery": 0,
		"turnover": 0,
		"hit_recovery": 0,
		"pitch_calling": 0,
		"distance_control": 0,
		"offline_efficiency": 0,
	}
	scale_levels = {}
	unlocked_pitches = ["dead_fish"]
	purchased_ball_upgrades.clear()
	purchased_milestones.clear()
	_invalidate_milestone_effect_cache()
	current_opponent = 0
	highest_unlocked = 0
	selected_distance_index = 0
	_clear_pitch_cycle()
	plate_strikes = 0
	plate_balls = 0
	batter_cooldown_remaining = 0.0
	_reset_batter_identity()
	current_body_strikeouts = 0.0
	frustration_points = 0.0
	current_body_loot_found = 0.0
	loot_dry_streak = 0
	loot_roll_cooldown_remaining = 0.0
	consecutive_home_runs = 0
	simulation_accumulator = 0.0
	cosmos_conquered = false
	auto_advance_enabled = auto_advance_enabled and has_genetic_upgrade("migratory_instinct")
	auto_train_enabled = auto_train_enabled and has_genetic_upgrade("autonomic_coach")
	auto_farm_enabled = auto_farm_enabled and has_genetic_upgrade("predator_scouting")
	_reset_mastery()

func perform_genetic_rebirth() -> int:
	var award := get_potential_dna()
	if award <= 0:
		return 0
	dna += award
	reality_dna_earned += award
	lifetime_dna_earned += award
	genetic_rebirths += 1
	lifetime_genetic_rebirths += 1
	genetic_offer_unlocked = true
	alien_exhibition_seconds = EXHIBITION_SECONDS
	var retained_slots := _prepare_genetic_time_travel_loot()
	_reset_body_progress()
	var wardrobe_message := " All loot was left in the future."
	if not retained_slots.is_empty():
		wardrobe_message = " Reverse Terminator preserved: %s." % ", ".join(retained_slots)
	progression_changed.emit(
		("GENETIC REBIRTH: +%d DNA. You were modified as a baby because chronology is optional." % award)
		+ wardrobe_message
	)
	check_achievements()
	return award

func perform_eldritch_ascension() -> int:
	var award := get_potential_arcana()
	if award <= 0:
		return 0
	arcana += award
	lifetime_arcana_earned += award
	eldritch_ascensions += 1
	lifetime_eldritch_ascensions += 1
	dna = 0
	reality_dna_earned = 0.0
	genetic_rebirths = 0
	_reset_genetic_levels()
	genetic_offer_unlocked = true
	alien_exhibition_seconds = EXHIBITION_SECONDS
	eldritch_offer_unlocked = true
	eldritch_exhibition_seconds = EXHIBITION_SECONDS
	auto_advance_enabled = false
	auto_train_enabled = false
	auto_farm_enabled = false
	_clear_all_loot_for_reset()
	_reset_body_progress()
	progression_changed.emit(
		"REALITY DESTROYED: +%d Arcana. Your consciousness found a less doomed bullpen." % award
	)
	check_achievements()
	return award

func all_divine_blessings_owned() -> bool:
	return divine_blessings.size() >= Content.DIVINE_BLESSINGS.size()

func perform_divine_ascension(id: String) -> bool:
	if not cosmos_conquered:
		return false
	if id == "halo":
		if not all_divine_blessings_owned():
			return false
		divine_halos += 1
	else:
		if Content.divine_by_id(id).is_empty() or has_divine_blessing(id):
			return false
		divine_blessings.append(id)
	divine_ascensions += 1
	dna = 0
	arcana = 0
	reality_dna_earned = 0.0
	genetic_rebirths = 0
	eldritch_ascensions = 0
	_reset_genetic_levels()
	_reset_eldritch_levels()
	# God resets the universe, not the pitcher's memory of the two mandatory
	# prestige offers. Repeat campaigns therefore pause at each known exhibition
	# instead of forcing another minute of scripted Grand Slams.
	genetic_offer_unlocked = true
	eldritch_offer_unlocked = true
	alien_exhibition_seconds = EXHIBITION_SECONDS
	eldritch_exhibition_seconds = EXHIBITION_SECONDS
	auto_advance_enabled = false
	auto_train_enabled = false
	auto_farm_enabled = false
	_clear_all_loot_for_reset()
	_reset_body_progress()
	no_hitter_attempt_valid = true
	var reward_name := "Another Halo" if id == "halo" else str(Content.divine_by_id(id).name)
	progression_changed.emit(
		"DIVINE GRAND SLAM: God restored the universe and granted %s." % reward_name
	)
	check_achievements()
	return true

func save_game() -> bool:
	if save_writes_locked:
		save_status_changed.emit("Save recovery required")
		return false
	var save_text := get_save_json()
	if not _write_save_text(SAVE_TEMP_PATH, save_text):
		save_status_changed.emit("Save failed")
		return false
	var pending_decoded := decode_save_text(_read_save_text(SAVE_TEMP_PATH))
	if not bool(pending_decoded.get("ok", false)):
		save_status_changed.emit("Save failed")
		return false

	var current_text := _read_save_text(SAVE_PATH)
	if not current_text.is_empty():
		var current_decoded := decode_save_text(current_text)
		if str(current_decoded.get("reason", "")) == "future_version":
			# An older cached executable must never overwrite a save created by a
			# newer schema. Keep both the primary and pending files for recovery.
			save_writes_locked = true
			last_load_failure_reason = "future_version"
			last_load_message = str(current_decoded.get("message", "A newer save is protected."))
			save_status_changed.emit("Newer save protected")
			return false
		if bool(current_decoded.get("ok", false)):
			if not _write_save_text(SAVE_BACKUP_PATH, current_text):
				save_status_changed.emit("Save failed")
				return false
		else:
			_archive_unreadable_save(current_text)

	var primary_absolute := ProjectSettings.globalize_path(SAVE_PATH)
	var pending_absolute := ProjectSettings.globalize_path(SAVE_TEMP_PATH)
	if FileAccess.file_exists(SAVE_PATH):
		var remove_error := DirAccess.remove_absolute(primary_absolute)
		if remove_error != OK:
			save_status_changed.emit("Save failed")
			return false
	var rename_error := DirAccess.rename_absolute(pending_absolute, primary_absolute)
	if rename_error != OK:
		# The previous valid generation remains recoverable from the backup.
		if FileAccess.file_exists(SAVE_BACKUP_PATH):
			_write_save_text(SAVE_PATH, _read_save_text(SAVE_BACKUP_PATH))
		save_status_changed.emit("Save failed")
		return false
	save_status_changed.emit("Saved")
	return true

func _read_save_text(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text := file.get_as_text()
	file.close()
	return text

func _write_save_text(path: String, text: String) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(text)
	file.flush()
	var write_error := file.get_error()
	file.close()
	return write_error == OK

func _archive_unreadable_save(text: String) -> void:
	if not text.is_empty():
		_write_save_text(SAVE_CORRUPT_PATH, text)

func get_save_json(pretty := false) -> String:
	return JSON.stringify(to_save_data(), "  " if pretty else "")

func decode_save_text(text: String) -> Dictionary:
	if text.is_empty():
		return {"ok": false, "message": "The selected file is empty."}
	if text.length() > MAX_IMPORTED_SAVE_CHARACTERS:
		return {"ok": false, "message": "The selected file is too large to be a game save."}
	var parser := JSON.new()
	if parser.parse(text) != OK:
		return {"ok": false, "message": "The selected file is not valid save JSON."}
	var parsed: Variant = parser.data
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "message": "The selected file is not valid save JSON."}
	var data: Dictionary = parsed
	if not data.has("version"):
		return {"ok": false, "message": "This JSON file is not a No Hitter save."}
	var saved_version := int(data.get("version", -1))
	if saved_version < 1:
		return {"ok": false, "message": "This save has an invalid version number."}
	if saved_version > SAVE_VERSION:
		return {
			"ok": false,
			"reason": "future_version",
			"message": "This save was created by a newer version of the game (save v%d; supported through v%d)." % [saved_version, SAVE_VERSION],
		}
	var dictionary_fields := [
		"training_levels", "genetic_levels", "eldritch_levels", "equipped_loot",
		"catalog_hide_purchased",
	]
	for field in dictionary_fields:
		if data.has(field) and typeof(data[field]) != TYPE_DICTIONARY:
			return {"ok": false, "message": "The save contains an invalid %s section." % str(field)}
	var array_fields := [
		"loot_items", "divine_blessings", "unlocked_pitches", "purchased_ball_upgrades",
		"purchased_milestones", "opponent_mastery", "result_totals", "unlocked_achievements",
	]
	for field in array_fields:
		if data.has(field) and typeof(data[field]) != TYPE_ARRAY:
			return {"ok": false, "message": "The save contains an invalid %s section." % str(field)}
	return {"ok": true, "message": "", "data": data}

func load_game() -> Dictionary:
	last_load_succeeded = false
	last_load_had_error = false
	last_load_recovered = false
	last_loaded_save_timestamp = 0.0
	last_load_message = ""
	last_load_failure_reason = ""
	save_writes_locked = false
	var any_save_file := (
		FileAccess.file_exists(SAVE_PATH)
		or FileAccess.file_exists(SAVE_BACKUP_PATH)
		or FileAccess.file_exists(SAVE_TEMP_PATH)
	)
	var primary_text := _read_save_text(SAVE_PATH)
	var primary_decoded := decode_save_text(primary_text) if FileAccess.file_exists(SAVE_PATH) else {}
	if str(primary_decoded.get("reason", "")) == "future_version":
		last_load_had_error = true
		last_load_failure_reason = "future_version"
		last_load_message = str(primary_decoded.get("message", "A newer save is protected."))
		save_writes_locked = true
		save_status_changed.emit("Newer save protected")
		return {}

	var selected_data: Dictionary = {}
	var selected_path := ""
	var selected_timestamp := -1.0
	# Primary wins an equal-timestamp tie; a newer valid pending or backup
	# generation repairs an interrupted write without losing progress.
	for path in [SAVE_BACKUP_PATH, SAVE_TEMP_PATH, SAVE_PATH]:
		var candidate_text := _read_save_text(path)
		if candidate_text.is_empty():
			continue
		any_save_file = true
		var decoded := decode_save_text(candidate_text)
		if not bool(decoded.get("ok", false)):
			continue
		var candidate_data: Dictionary = decoded.data
		var candidate_timestamp := float(candidate_data.get("saved_at", 0.0))
		if candidate_timestamp >= selected_timestamp:
			selected_timestamp = candidate_timestamp
			selected_data = candidate_data
			selected_path = path

	if selected_data.is_empty():
		if any_save_file:
			last_load_had_error = true
			last_load_failure_reason = "unreadable"
			last_load_message = "The existing save generations could not be read. They were left untouched."
			save_writes_locked = true
			save_status_changed.emit("Save recovery required")
		else:
			save_status_changed.emit("New game")
		return {}

	if not primary_text.is_empty() and not bool(primary_decoded.get("ok", false)):
		last_load_had_error = true
		_archive_unreadable_save(primary_text)
	last_load_recovered = selected_path != SAVE_PATH
	last_load_succeeded = true
	last_loaded_save_timestamp = selected_timestamp
	apply_save_data(selected_data)
	var previous_timestamp := float(selected_data.get("saved_at", Time.get_unix_time_from_system()))
	var elapsed := maxf(Time.get_unix_time_from_system() - previous_timestamp, 0.0)
	var offline_summary := simulate_offline(elapsed)
	if last_load_recovered:
		last_load_message = "Recovered the newest valid automatic save generation."
		save_game()
		save_status_changed.emit("Recovered save")
	else:
		save_status_changed.emit("Loaded")
	return offline_summary

func to_save_data() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"saved_at": Time.get_unix_time_from_system(),
		"xp": xp,
		"run_xp": run_xp,
		"lifetime_xp": lifetime_xp,
		"lifetime_pitches": lifetime_pitches,
		"lifetime_field_taps": lifetime_field_taps,
		"lifetime_field_tap_seconds": lifetime_field_tap_seconds,
		"lifetime_saved_hits": lifetime_saved_hits,
		"lifetime_max_pitch_speed_fps": lifetime_max_pitch_speed_fps,
		"lifetime_max_distance_index": lifetime_max_distance_index,
		"lifetime_max_loot_rarity": lifetime_max_loot_rarity,
		"lifetime_strikeouts": lifetime_strikeouts,
		"current_body_strikeouts": current_body_strikeouts,
		"frustration_points": frustration_points,
		"lifetime_loot_found": lifetime_loot_found,
		"current_body_loot_found": current_body_loot_found,
		"loot_overflow_discarded": loot_overflow_discarded,
		"scrap": scrap,
		"loot_dry_streak": loot_dry_streak,
		"loot_roll_cooldown_remaining": loot_roll_cooldown_remaining,
		"next_loot_id": next_loot_id,
		"loot_items": loot_items,
		"equipped_loot": equipped_loot,
		"plate_strikes": plate_strikes,
		"plate_balls": plate_balls,
		"batter_cooldown_remaining": batter_cooldown_remaining,
		"batter_generation": batter_generation,
		"batter_replacement_pending": batter_replacement_pending,
		"pitch_credit": pitch_credit,
		"pitch_flight_remaining": pitch_flight_remaining,
		"pending_volley_flight_duration": pending_volley_flight_duration,
		"pending_volley_size": pending_volley_size,
		"pending_volley_outcome": pending_volley_outcome,
		"pending_volley_saved": pending_volley_saved,
		"pending_volley_pitch_id": pending_volley_pitch_id,
		"pending_volley_speed_fps": pending_volley_speed_fps,
		"pending_volley_distance_index": pending_volley_distance_index,
		"pending_volley_opponent_index": pending_volley_opponent_index,
		"current_opponent": current_opponent,
		"highest_unlocked": highest_unlocked,
		"selected_distance_index": selected_distance_index,
		"dna": dna,
		"arcana": arcana,
		"genetic_rebirths": genetic_rebirths,
		"eldritch_ascensions": eldritch_ascensions,
		"divine_ascensions": divine_ascensions,
		"divine_halos": divine_halos,
		"lifetime_genetic_rebirths": lifetime_genetic_rebirths,
		"lifetime_eldritch_ascensions": lifetime_eldritch_ascensions,
		"reality_dna_earned": reality_dna_earned,
		"lifetime_dna_earned": lifetime_dna_earned,
		"lifetime_arcana_earned": lifetime_arcana_earned,
		"genetic_offer_unlocked": genetic_offer_unlocked,
		"eldritch_offer_unlocked": eldritch_offer_unlocked,
		"alien_exhibition_seconds": alien_exhibition_seconds,
		"eldritch_exhibition_seconds": eldritch_exhibition_seconds,
		"cosmos_conquered": cosmos_conquered,
		"no_hitter_attempt_valid": no_hitter_attempt_valid,
		"auto_advance_enabled": auto_advance_enabled,
		"auto_train_enabled": auto_train_enabled,
		"auto_farm_enabled": auto_farm_enabled,
		"training_levels": training_levels,
		"scale_levels": scale_levels,
		"genetic_levels": genetic_levels,
		"eldritch_levels": eldritch_levels,
		"divine_blessings": divine_blessings,
		"unlocked_pitches": unlocked_pitches,
		"purchased_ball_upgrades": purchased_ball_upgrades,
		"purchased_milestones": purchased_milestones,
		"unlocked_achievements": unlocked_achievements,
		"catalog_hide_purchased": catalog_hide_purchased,
		"opponent_mastery": opponent_mastery,
		"result_totals": result_totals,
	}

func apply_save_data(data: Dictionary) -> void:
	var saved_version := int(data.get("version", 0))
	xp = clampf(float(data.get("xp", 0.0)), 0.0, MAX_NUMBER)
	run_xp = clampf(float(data.get("run_xp", 0.0)), 0.0, MAX_NUMBER)
	lifetime_xp = clampf(float(data.get("lifetime_xp", xp)), 0.0, MAX_NUMBER)
	lifetime_pitches = clampf(float(data.get("lifetime_pitches", 0.0)), 0.0, MAX_NUMBER)
	lifetime_field_taps = clampf(float(data.get("lifetime_field_taps", 0.0)), 0.0, MAX_NUMBER)
	lifetime_field_tap_seconds = clampf(float(data.get("lifetime_field_tap_seconds", 0.0)), 0.0, MAX_NUMBER)
	lifetime_saved_hits = clampf(float(data.get("lifetime_saved_hits", 0.0)), 0.0, MAX_NUMBER)
	lifetime_max_pitch_speed_fps = clampf(float(data.get("lifetime_max_pitch_speed_fps", 1.0)), 1.0, MAX_NUMBER)
	lifetime_max_distance_index = clampi(int(data.get("lifetime_max_distance_index", 0)), 0, Content.DISTANCE_TIERS.size() - 1)
	lifetime_max_loot_rarity = clampi(int(data.get("lifetime_max_loot_rarity", -1)), -1, Content.LOOT_RARITIES.size() - 1)
	lifetime_strikeouts = clampf(float(data.get("lifetime_strikeouts", 0.0)), 0.0, MAX_NUMBER)
	current_body_strikeouts = clampf(float(data.get("current_body_strikeouts", 0.0)), 0.0, MAX_NUMBER)
	if saved_version >= 17:
		frustration_points = clampf(float(data.get("frustration_points", 0.0)), 0.0, MAX_NUMBER)
	else:
		var legacy_seconds := clampf(float(data.get("seconds_since_strikeout", 0.0)), 0.0, MAX_NUMBER)
		frustration_points = minf(
			MAX_NUMBER,
			legacy_seconds / LEGACY_FRUSTRATION_INTERVAL_SECONDS * FRUSTRATION_REFERENCE_POINTS
		)
	lifetime_loot_found = clampf(float(data.get("lifetime_loot_found", 0.0)), 0.0, MAX_NUMBER)
	current_body_loot_found = clampf(float(data.get("current_body_loot_found", 0.0)), 0.0, MAX_NUMBER)
	loot_overflow_discarded = clampf(float(data.get("loot_overflow_discarded", 0.0)), 0.0, MAX_NUMBER)
	scrap = clampf(float(data.get("scrap", 0.0)), 0.0, MAX_NUMBER)
	loot_dry_streak = clampi(int(data.get("loot_dry_streak", 0)), 0, LOOT_PITY_ROLLS - 1)
	loot_roll_cooldown_remaining = clampf(float(data.get("loot_roll_cooldown_remaining", 0.0)), 0.0, LOOT_ROLL_INTERVAL_SECONDS)
	next_loot_id = maxi(int(data.get("next_loot_id", 1)), 1)
	highest_unlocked = clampi(int(data.get("highest_unlocked", 0)), 0, opponents.size() - 1)
	current_opponent = clampi(int(data.get("current_opponent", 0)), 0, highest_unlocked)
	plate_strikes = clampi(int(data.get("plate_strikes", 0)), 0, maxi(get_strikes_required(current_opponent) - 1, 0))
	plate_balls = clampi(int(data.get("plate_balls", 0)), 0, maxi(get_balls_required(current_opponent) - 1, 0))
	batter_cooldown_remaining = clampf(float(data.get("batter_cooldown_remaining", 0.0)), 0.0, MAX_BATTER_DOWNTIME_SECONDS)
	batter_generation = clampi(int(data.get("batter_generation", 0)), 0, 999999999)
	batter_replacement_pending = bool(data.get(
		"batter_replacement_pending",
		batter_cooldown_remaining > 0.0
	))
	_refresh_batter_variant()
	selected_distance_index = clampi(
		int(data.get("selected_distance_index", 0)),
		0,
		get_max_distance_index()
	)
	dna = maxi(int(data.get("dna", data.get("rings", 0))), 0)
	arcana = maxi(int(data.get("arcana", 0)), 0)
	genetic_rebirths = maxi(int(data.get("genetic_rebirths", data.get("seasons_completed", 0))), 0)
	eldritch_ascensions = maxi(int(data.get("eldritch_ascensions", 0)), 0)
	divine_ascensions = maxi(int(data.get("divine_ascensions", 0)), 0)
	divine_halos = maxi(int(data.get("divine_halos", 0)), 0)
	lifetime_genetic_rebirths = maxi(int(data.get("lifetime_genetic_rebirths", genetic_rebirths)), genetic_rebirths)
	lifetime_eldritch_ascensions = maxi(int(data.get("lifetime_eldritch_ascensions", eldritch_ascensions)), eldritch_ascensions)
	reality_dna_earned = clampf(float(data.get("reality_dna_earned", dna)), 0.0, MAX_NUMBER)
	lifetime_dna_earned = clampf(float(data.get("lifetime_dna_earned", dna)), 0.0, MAX_NUMBER)
	lifetime_arcana_earned = clampf(float(data.get("lifetime_arcana_earned", arcana)), 0.0, MAX_NUMBER)
	genetic_offer_unlocked = bool(data.get("genetic_offer_unlocked", highest_unlocked >= Content.ALIEN_EXHIBITION_INDEX))
	eldritch_offer_unlocked = bool(data.get("eldritch_offer_unlocked", highest_unlocked >= Content.ELDRITCH_EXHIBITION_INDEX))
	alien_exhibition_seconds = clampf(float(data.get("alien_exhibition_seconds", EXHIBITION_SECONDS if genetic_offer_unlocked else 0.0)), 0.0, EXHIBITION_SECONDS)
	eldritch_exhibition_seconds = clampf(float(data.get("eldritch_exhibition_seconds", EXHIBITION_SECONDS if eldritch_offer_unlocked else 0.0)), 0.0, EXHIBITION_SECONDS)
	cosmos_conquered = bool(data.get("cosmos_conquered", false))
	# v15 and earlier never recorded enough per-universe history to prove a
	# campaign-wide no-hitter, so their next divine restoration starts the first
	# eligible attempt without incorrectly granting one during migration.
	no_hitter_attempt_valid = (
		bool(data.get("no_hitter_attempt_valid", false))
		if saved_version >= 16
		else false
	)
	var saved_auto_advance := bool(data.get("auto_advance_enabled", false))
	var saved_auto_train := bool(data.get("auto_train_enabled", false))
	var saved_auto_farm := bool(data.get("auto_farm_enabled", false))
	var saved_catalog_filters: Dictionary = data.get("catalog_hide_purchased", {})
	for catalog_id in catalog_hide_purchased.keys():
		catalog_hide_purchased[catalog_id] = bool(saved_catalog_filters.get(catalog_id, false))

	var saved_training: Dictionary = data.get("training_levels", {})
	if saved_version < 12:
		# Spin and Deception used to be separate additive quality buttons. Fold
		# their exact quality contribution into the one Command axis.
		var migrated_quality := (
			float(saved_training.get("command", 0)) * 0.12
			+ float(saved_training.get("spin", 0)) * 0.10
			+ float(saved_training.get("deception", 0)) * 0.11
		)
		saved_training = saved_training.duplicate(true)
		saved_training["command"] = maxi(int(round(migrated_quality / 0.12)), 0)
	if saved_version < 13:
		# v0.8 turns Training into additive base stats. Preserve approximately the
		# same pre-facility values, and split the former universal Turnover rank
		# across the new Lineup and Hit Delay axes.
		saved_training = saved_training.duplicate(true)
		var old_velocity_rank := maxi(int(saved_training.get("velocity", 0)), 0)
		var old_command_rank := maxi(int(saved_training.get("command", 0)), 0)
		var old_recovery_rank := maxi(int(saved_training.get("recovery", 0)), 0)
		var old_turnover_rank := maxi(int(saved_training.get("turnover", 0)), 0)
		var old_calling_rank := maxi(int(saved_training.get("pitch_calling", 0)), 0)
		var old_distance_rank := maxi(int(saved_training.get("distance_control", 0)), 0)
		var old_turnover_factor := pow(0.93, float(old_turnover_rank))
		saved_training["velocity"] = maxi(int(round((pow(1.045, float(old_velocity_rank)) - 1.0) / VELOCITY_PER_RANK_FPS)), 0)
		saved_training["command"] = maxi(int(round(float(old_command_rank) * 0.12 / QUALITY_PER_RANK)), 0)
		saved_training["recovery"] = maxi(int(round((BASE_RECOVERY_RATE * pow(1.06, float(old_recovery_rank)) - BASE_RECOVERY_RATE) / RECOVERY_PER_RANK)), 0)
		saved_training["turnover"] = maxi(int(round((BASE_BATTER_TURNOVER_SECONDS - BASE_BATTER_TURNOVER_SECONDS * old_turnover_factor) / LINEUP_SECONDS_PER_RANK)), 0)
		saved_training["hit_recovery"] = maxi(int(round((1.0 - old_turnover_factor) / HIT_DELAY_FACTOR_PER_RANK)), 0)
		saved_training["pitch_calling"] = maxi(int(round((pow(1.35, float(old_calling_rank)) - 1.0) / CALLING_BIAS_PER_RANK)), 0)
		saved_training["distance_control"] = maxi(int(round((1.0 - pow(0.97, float(old_distance_rank))) / DISTANCE_FACTOR_PER_RANK)), 0)
	for id in training_levels.keys():
		var saved_rank := maxi(int(saved_training.get(id, 0)), 0)
		var definition := Content.training_by_id(str(id))
		if definition.has("max_level"):
			saved_rank = mini(saved_rank, int(definition.max_level))
		training_levels[id] = saved_rank
	scale_levels = {}
	_reset_genetic_levels()
	var saved_genetic: Dictionary = data.get("genetic_levels", {})
	for id in genetic_levels.keys():
		var definition := Content.genetic_by_id(str(id))
		genetic_levels[id] = clampi(int(saved_genetic.get(id, 0)), 0, int(definition.max_level))
	_reset_eldritch_levels()
	var saved_eldritch: Dictionary = data.get("eldritch_levels", {})
	for id in eldritch_levels.keys():
		var definition := Content.eldritch_by_id(str(id))
		eldritch_levels[id] = clampi(int(saved_eldritch.get(id, 0)), 0, int(definition.max_level))
	if saved_version == 6:
		genetic_levels.compressed_strike_genome = clampi(int(saved_genetic.get("expanded_strike_genome", 0)), 0, 3)
		eldritch_levels.portal_outfield = clampi(int(saved_eldritch.get("impossible_count", 0)), 0, 4)
	divine_blessings.clear()
	for id in data.get("divine_blessings", []):
		if not Content.divine_by_id(str(id)).is_empty() and str(id) not in divine_blessings:
			divine_blessings.append(str(id))

	# v0.2.x migration: Rings become DNA, and already purchased physical scale
	# becomes the matching genetic or eldritch anatomy instead of disappearing.
	if saved_version < 6:
		var legacy_scale: Dictionary = data.get("scale_levels", {})
		genetic_levels.extra_arms = clampi(int(legacy_scale.get("arms", 0)), 0, 3)
		# The former upgrade made counts longer. Preserve its investment as the
		# inverse, newly useful post-human count compression.
		genetic_levels.compressed_strike_genome = clampi(int(legacy_scale.get("strike_capacity", 0)), 0, 3)
		eldritch_levels.mirror_clones = clampi(int(legacy_scale.get("clones", 0)), 0, 5)
		eldritch_levels.time_compression = clampi(int(legacy_scale.get("time", 0)), 0, 3)
		if dna >= 1:
			genetic_levels.migratory_instinct = 1
		if dna >= 5:
			genetic_levels.autonomic_coach = 1
		if dna >= 12:
			genetic_levels.predator_scouting = 1
		if highest_unlocked >= Content.ALIEN_EXHIBITION_INDEX:
			genetic_rebirths = maxi(genetic_rebirths, 1)
		if highest_unlocked >= Content.ELDRITCH_EXHIBITION_INDEX:
			eldritch_ascensions = maxi(eldritch_ascensions, 1)
	plate_strikes = mini(plate_strikes, maxi(get_strikes_required(current_opponent) - 1, 0))
	_clear_pitch_cycle()
	if saved_version >= 10 and batter_cooldown_remaining <= 0.0:
		var saved_pending_size := clampi(int(data.get("pending_volley_size", 0)), 0, 4096)
		var saved_flight := clampf(float(data.get("pitch_flight_remaining", 0.0)), 0.0, 5.0)
		if saved_pending_size > 0 and saved_flight > 0.0:
			pending_volley_size = saved_pending_size
			pitch_flight_remaining = saved_flight
			pending_volley_flight_duration = clampf(
				float(data.get("pending_volley_flight_duration", saved_flight)),
				saved_flight,
				5.0
			)
			pending_volley_outcome = clampi(
				int(data.get("pending_volley_outcome", Content.STRIKE_INDEX)),
				0,
				Content.OUTCOME_NAMES.size() - 1
			)
			if saved_version < 12 and pending_volley_outcome == 5:
				pending_volley_outcome = Content.STRIKE_INDEX
			pending_volley_saved = (
				bool(data.get("pending_volley_saved", false))
				and pending_volley_outcome < Content.HIT_OUTCOME_COUNT
				and pending_volley_outcome != Content.GRAND_SLAM_INDEX
			)
			pending_volley_pitch_id = str(data.get("pending_volley_pitch_id", "dead_fish"))
			if Content.pitch_by_id(pending_volley_pitch_id).is_empty():
				pending_volley_pitch_id = "dead_fish"
			pending_volley_speed_fps = maxf(float(data.get("pending_volley_speed_fps", get_representative_pitch_speed(pending_volley_pitch_id))), 0.000001)
			pending_volley_distance_index = clampi(int(data.get("pending_volley_distance_index", selected_distance_index)), 0, Content.DISTANCE_TIERS.size() - 1)
			pending_volley_opponent_index = clampi(int(data.get("pending_volley_opponent_index", current_opponent)), 0, highest_unlocked)
		else:
			pitch_credit = clampf(float(data.get("pitch_credit", 0.0)), 0.0, 0.999999)

	auto_advance_enabled = saved_auto_advance and has_genetic_upgrade("migratory_instinct")
	auto_train_enabled = saved_auto_train and has_genetic_upgrade("autonomic_coach")
	auto_farm_enabled = saved_auto_farm and has_genetic_upgrade("predator_scouting")

	unlocked_pitches.clear()
	for id in data.get("unlocked_pitches", ["dead_fish"]):
		if not Content.pitch_by_id(str(id)).is_empty() and str(id) not in unlocked_pitches:
			unlocked_pitches.append(str(id))
	if "dead_fish" not in unlocked_pitches:
		unlocked_pitches.push_front("dead_fish")

	purchased_ball_upgrades.clear()
	for id in data.get("purchased_ball_upgrades", []):
		if not Content.ball_upgrade_by_id(str(id)).is_empty() and str(id) not in purchased_ball_upgrades:
			purchased_ball_upgrades.append(str(id))

	purchased_milestones.clear()
	_invalidate_milestone_effect_cache()
	for id in data.get("purchased_milestones", []):
		if not Content.milestone_by_id(str(id)).is_empty() and str(id) not in purchased_milestones:
			purchased_milestones.append(str(id))

	loot_items.clear()
	var seen_loot_ids := {}
	for raw_item in data.get("loot_items", []):
		var migrated_raw_item: Variant = raw_item
		if saved_version < 9 and typeof(raw_item) == TYPE_DICTIONARY:
			migrated_raw_item = (raw_item as Dictionary).duplicate(true)
			if str(migrated_raw_item.get("slot", "")) == "belt":
				migrated_raw_item["slot"] = "jockstrap"
		var item := _sanitize_loot_item(migrated_raw_item)
		if item.is_empty() or seen_loot_ids.has(str(item.id)):
			continue
		seen_loot_ids[str(item.id)] = true
		loot_items.append(item)
	equipped_loot = _empty_equipped_loot()
	var saved_equipped: Dictionary = data.get("equipped_loot", {})
	for definition in Content.LOOT_SLOTS:
		var slot := str(definition.id)
		var saved_slot := "belt" if saved_version < 9 and slot == "jockstrap" else slot
		var item_id := str(saved_equipped.get(saved_slot, ""))
		var equipped_item := get_loot_item(item_id)
		if (
			not equipped_item.is_empty()
			and str(equipped_item.slot) == slot
			and is_loot_slot_unlocked(slot)
		):
			equipped_loot[slot] = item_id
	for definition in Content.LOOT_SLOTS:
		var slot := str(definition.id)
		var capacity_result := _enforce_loot_slot_capacity(slot)
		var removed: Array = capacity_result.get("removed", [])
		loot_overflow_discarded = minf(MAX_NUMBER, loot_overflow_discarded + float(removed.size()))
	for item in loot_items:
		lifetime_max_loot_rarity = maxi(lifetime_max_loot_rarity, int(item.get("rarity", -1)))
	if has_genetic_upgrade("autonomic_wardrobe"):
		auto_equip_highest_power(false)
	lifetime_loot_found = maxf(lifetime_loot_found, float(loot_items.size()))
	loot_revision += 1
	last_time_travel_retained_slots.clear()

	_reset_mastery()
	var saved_mastery: Array = data.get("opponent_mastery", [])
	for index in mini(saved_mastery.size(), opponent_mastery.size()):
		opponent_mastery[index] = clampf(float(saved_mastery[index]), 0.0, MAX_NUMBER)
	result_totals = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	var saved_results: Array = data.get("result_totals", [])
	if saved_version < 7 and saved_results.size() == 5:
		# v0.2 outcome order was HR, 3B, 2B, 1B, K. Insert Grand Slam at zero.
		for old_index in saved_results.size():
			var new_index := Content.STRIKE_INDEX if old_index == 4 else old_index + 1
			result_totals[new_index] = clampf(float(saved_results[old_index]), 0.0, MAX_NUMBER)
	elif saved_version < 12 and saved_results.size() == 6:
		# v0.6 inserted Grand Slam but predated Fouls and Balls.
		for old_index in 5:
			result_totals[old_index] = clampf(float(saved_results[old_index]), 0.0, MAX_NUMBER)
		result_totals[Content.STRIKE_INDEX] = clampf(float(saved_results[5]), 0.0, MAX_NUMBER)
	else:
		for index in mini(saved_results.size(), result_totals.size()):
			result_totals[index] = clampf(float(saved_results[index]), 0.0, MAX_NUMBER)
	unlocked_achievements.clear()
	for id in data.get("unlocked_achievements", []):
		var achievement_id := str(id)
		if (
			not Content.achievement_by_id(achievement_id).is_empty()
			and achievement_id not in unlocked_achievements
		):
			unlocked_achievements.append(achievement_id)
	lifetime_max_pitch_speed_fps = maxf(lifetime_max_pitch_speed_fps, get_velocity_fps())
	lifetime_max_distance_index = maxi(lifetime_max_distance_index, selected_distance_index)
	if not opponent_mastery.is_empty():
		cosmos_conquered = cosmos_conquered or (
			highest_unlocked == opponents.size() - 1
			and opponent_mastery.back() >= get_mastery_requirement(opponents.size() - 1)
		)
	# Older saves receive everything their persisted history proves, but loading
	# never floods the player with a backlog of toast notifications.
	check_achievements(false)
	achievement_revision += 1

func _sanitize_loot_item(value: Variant) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return {}
	var raw: Dictionary = value
	var item_id := str(raw.get("id", ""))
	var slot := str(raw.get("slot", ""))
	if item_id.is_empty() or Content.loot_slot_by_id(slot).is_empty():
		return {}
	var rarity := clampi(int(raw.get("rarity", 0)), 0, Content.LOOT_RARITIES.size() - 1)
	var item_level := clampi(int(raw.get("item_level", 1)), 1, opponents.size())
	var stats := {}
	var raw_stats: Dictionary = raw.get("stats", {})
	for definition in Content.LOOT_STATS:
		var stat_id := str(definition.id)
		if not raw_stats.has(stat_id):
			continue
		var maximum := 0.15 if stat_id == "quality_bonus" else 0.10
		stats[stat_id] = clampf(float(raw_stats[stat_id]), 0.0, maximum)
	if stats.is_empty():
		return {}
	var name := str(raw.get("name", "Unnamed Equipment")).substr(0, 120)
	var color_text := str(raw.get("color", "68d5ff"))
	if not Color.html_is_valid(color_text):
		color_text = "68d5ff"
	return {
		"id": item_id,
		"slot": slot,
		"item_level": item_level,
		"rarity": rarity,
		"name": name,
		"stats": stats,
		"roll_quality": clampf(float(raw.get("roll_quality", 0.70)), 0.0, 1.0),
		"color": color_text,
		"favorite": bool(raw.get("favorite", false)),
	}

func delete_save() -> bool:
	var success := true
	for path in [SAVE_PATH, SAVE_BACKUP_PATH, SAVE_TEMP_PATH, SAVE_CORRUPT_PATH]:
		if not FileAccess.file_exists(path):
			continue
		if DirAccess.remove_absolute(ProjectSettings.globalize_path(path)) != OK:
			success = false
	if success:
		save_writes_locked = false
	return success

func get_best_pitch() -> Dictionary:
	var best := Content.pitch_by_id("dead_fish")
	for id in unlocked_pitches:
		var definition := Content.pitch_by_id(id)
		if not definition.is_empty() and float(definition.bonus) > float(best.bonus):
			best = definition
	return best

func get_current_ball_name() -> String:
	var strongest_name := ""
	var strongest_potency := 0.0
	for id in purchased_ball_upgrades:
		var definition := Content.ball_upgrade_by_id(id)
		if not definition.is_empty() and float(definition.potency) > strongest_potency:
			strongest_potency = float(definition.potency)
			strongest_name = str(definition.name)
	if not strongest_name.is_empty():
		return strongest_name
	if has_milestone("regulation_ball"):
		return "Regulation Baseball"
	return "Dented Wiffle Ball"

func get_owned_equipment_summary() -> String:
	var names: Array[String] = []
	for id in purchased_milestones:
		var definition := Content.milestone_by_id(id)
		if not definition.is_empty():
			names.append(str(definition.name))
	for definition in Content.GENETIC_UPGRADES:
		var rank := int(genetic_levels.get(str(definition.id), 0))
		if rank > 0:
			names.append("%s r%d" % [definition.name, rank])
	for definition in Content.ELDRITCH_UPGRADES:
		var rank := int(eldritch_levels.get(str(definition.id), 0))
		if rank > 0:
			names.append("%s r%d" % [definition.name, rank])
	for id in divine_blessings:
		var definition := Content.divine_by_id(id)
		if not definition.is_empty():
			names.append(str(definition.name))
	if divine_halos > 0:
		names.append("Halo r%d" % divine_halos)
	if names.is_empty():
		return "No facilities owned yet"
	return " • ".join(names)

static func rounded_cost(value: float) -> float:
	if value <= 0.0:
		return 0.0
	if value >= MAX_NUMBER * 0.1:
		return MAX_NUMBER
	var exponent: float = floor(log(value) / log(10.0))
	var unit: float = pow(10.0, exponent)
	return minf(ceil(value / unit - 0.0000001) * unit, MAX_NUMBER)

static func format_cost(value: float) -> String:
	var rounded: float = rounded_cost(value)
	if rounded < 1000.0:
		return "%.0f" % rounded
	var suffixes: Array[Dictionary] = [
		{"value": 1.0e12, "text": "T"},
		{"value": 1.0e9, "text": "B"},
		{"value": 1.0e6, "text": "M"},
		{"value": 1.0e3, "text": "K"},
	]
	for suffix in suffixes:
		if rounded >= float(suffix.value) and rounded < float(suffix.value) * 1000.0:
			var scaled: float = rounded / float(suffix.value)
			return "%.0f%s" % [scaled, suffix.text]
	var exponent := int(floor(log(rounded) / log(10.0) + 0.000000001))
	var mantissa := int(round(rounded / pow(10.0, exponent)))
	if mantissa >= 10:
		mantissa = 1
		exponent += 1
	return "%de%d" % [mantissa, exponent]

static func format_number(value: float, decimals: int = 2) -> String:
	if is_nan(value):
		return "NaN"
	if is_inf(value) or value >= MAX_NUMBER:
		return "1e280+"
	var absolute := absf(value)
	if absolute < 1000.0:
		if decimals <= 0:
			return "%.0f" % value
		if absolute >= 100.0:
			return "%.0f" % value
		if absolute >= 10.0:
			return "%.1f" % value
		return ("%." + str(decimals) + "f") % value
	var suffixes := ["K", "M", "B", "T"]
	var scaled := absolute
	var suffix_index := -1
	while scaled >= 1000.0 and suffix_index < suffixes.size() - 1:
		scaled /= 1000.0
		suffix_index += 1
	if suffix_index >= 0 and absolute < 1.0e15:
		return "%s%.2f%s" % ["-" if value < 0.0 else "", scaled, suffixes[suffix_index]]
	var exponent := int(floor(log(absolute) / log(10.0)))
	var mantissa := absolute / pow(10.0, exponent)
	return "%s%.3fe%d" % ["-" if value < 0.0 else "", mantissa, exponent]

static func format_speed(feet_per_second: float) -> String:
	if feet_per_second < 88.0:
		return "%s ft/s" % format_number(feet_per_second, 2)
	var miles_per_hour := feet_per_second * 0.681818
	if feet_per_second < SPEED_OF_SOUND_FPS:
		return "%s mph" % format_number(miles_per_hour, 1)
	var light_ratio := feet_per_second / SPEED_OF_LIGHT_FPS
	if light_ratio < 0.01:
		return "Mach %s" % format_number(feet_per_second / SPEED_OF_SOUND_FPS, 2)
	return "%sc" % format_number(light_ratio, 3)

static func format_flight_time(seconds: float) -> String:
	var bounded := maxf(seconds, 0.0)
	if bounded < 10.0:
		return "%.2f s" % bounded
	if bounded < 60.0:
		return "%.1f s" % bounded
	if bounded < 7.0 * 24.0 * 60.0 * 60.0:
		return format_duration(bounded)
	var years := bounded / 31557600.0
	if years < 1.0:
		return "%s days" % format_number(bounded / 86400.0, 1)
	return "%s years" % format_number(years, 2)

static func format_duration(seconds: float) -> String:
	var whole := int(maxf(seconds, 0.0))
	if whole < 60:
		return "%ds" % whole
	if whole < 3600:
		return "%dm %02ds" % [whole / 60, whole % 60]
	if whole < 86400:
		return "%dh %02dm" % [whole / 3600, (whole % 3600) / 60]
	return "%dd %02dh" % [whole / 86400, (whole % 86400) / 3600]
