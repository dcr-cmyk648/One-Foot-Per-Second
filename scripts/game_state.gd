class_name BaseballGameState
extends Node

signal batch_resolved(summary: Dictionary)
signal progression_changed(message: String)
signal save_status_changed(message: String)
signal achievement_unlocked(definition: Dictionary, total_unlocked: int)
signal automatic_field_tap_applied(result: Dictionary)

const Content = preload("res://scripts/content.gd")
const SAVE_PATH := "user://one_foot_per_second_save.json"
const SAVE_BACKUP_PATH := "user://one_foot_per_second_save.backup.json"
const SAVE_TEMP_PATH := "user://one_foot_per_second_save.pending.json"
const SAVE_CORRUPT_PATH := "user://one_foot_per_second_save.unreadable.json"
const SAVE_VERSION := 25
const MAX_IMPORTED_SAVE_CHARACTERS := 16 * 1024 * 1024
const SIMULATION_STEP := 0.10
const OFFLINE_AGGREGATE_CYCLE_THRESHOLD := 8.0
const MAX_NUMBER := 1.0e280
const MAX_OFFLINE_SECONDS := 7.0 * 24.0 * 60.0 * 60.0
const EXHIBITION_SECONDS := 60.0
const ALIEN_EXHIBITION_GRAND_SLAMS_REQUIRED := 12
const ALIEN_EXHIBITION_TAUNTS := [
	"HA!",
	"THAT WAS A PITCH?",
	"YOU'RE PATHETIC.",
	"MY BAT IS BORED.",
	"DO HUMANS TRY?",
	"IS THAT FULL SPEED?",
	"CALL YOUR COACH.",
	"I HAVE SEEN TEE-BALL.",
	"THE CROWD PITIES YOU.",
	"AGAIN.",
]
const FASTEST_RECORDED_PITCH_MPH := 105.8
const HUMAN_SPEED_CAP_MPH := 115.0
const HUMAN_SPEED_CAP_FPS := HUMAN_SPEED_CAP_MPH / 0.681818
# A mortal can train ahead, but cannot throw like an MLB closer while still in
# preschool. These are soft body-development ceilings keyed to the farthest
# human level reached; equipment remains the intentionally small exception.
const HUMAN_VELOCITY_CAP_MPH_BY_LEVEL := [
	15.0, 20.0, 25.0, 30.0, 35.0, 40.0, 45.0, 50.0, 55.0, 60.0,
	65.0, 70.0, 75.0, 80.0, 85.0, 88.0, 91.0, 94.0, 97.0, 100.0,
	101.0, 102.0, 103.0, 104.0, 105.0, 107.0, 109.0, 111.0, 113.0, 115.0,
]
const SPEED_OF_SOUND_FPS := 1125.33
const ALIEN_SPEED_CAP_FPS := SPEED_OF_SOUND_FPS * 12.0
const SPEED_OF_LIGHT_FPS := 983571056.0
const DNA_XP_THRESHOLD := 1.0e10
const STRIKEOUT_POINTS_PER_REQUIRED_STRIKE := 5.0
const OPENING_STRIKEOUT_BASE_POINTS := 5.0
const HUMAN_CALLED_STRIKE_FLOOR := 0.01
const BASE_VELOCITY_FPS := 1.0
# Speed is the inexpensive backbone of ordinary progression. Its built-in
# logarithmic quality contribution is strongest while the arm is slow, then
# naturally gives way to Command as velocity becomes respectable.
const VELOCITY_PER_RANK_FPS := 0.75
const VELOCITY_SOFT_CAP_START_FRACTION := 0.85
const QUALITY_PER_RANK := 0.018
const BASE_RECOVERY_RATE := 0.25
const RECOVERY_TRAINING_LIMIT := 0.48
const RECOVERY_REMAINING_PER_RANK := 0.90
# Training, age, ordinary BODY work, and facilities all land below this mortal
# wind-up ceiling before the small optional equipment sidegrade is applied.
# A complete mundane build therefore still takes at least 1.39 seconds to reset.
const HUMAN_BODY_RECOVERY_LIMIT := 0.72
const HUMAN_RECOVERY_SOFT_CAP_START := 0.60
const ELASTIC_UCL_RECOVERY_PER_RANK := 1.50
const ALTERNATING_LOBES_RECOVERY_PER_RANK := 2.0
const TIME_COMPRESSION_RECOVERY_PER_RANK := 2.0
const LINEUP_MIN_SECONDS := 1.25
const LINEUP_REMAINING_PER_RANK := 0.90
const HIT_DELAY_MIN_FACTOR := 0.35
const HIT_DELAY_REMAINING_PER_RANK := 0.90
const CALLING_LOG_BONUS := 0.85
const DISTANCE_MIN_FACTOR := 0.40
const DISTANCE_REMAINING_PER_RANK := 0.94
const BASE_OFFLINE_XP_EFFICIENCY := 0.01
const OFFLINE_XP_EFFICIENCY_LIMIT := 0.75
const OFFLINE_REMAINING_PER_RANK := 0.94
# Active input is deliberately modest: the displayed opening 1.7% and each
# Field Hustle increment are exactly one third of their original values.
const BASE_FIELD_TAP_FRACTION := 1.0 / 60.0
const FIELD_TAP_FRACTION_LIMIT := 0.04
const FIELD_TAP_REMAINING_PER_RANK := 0.92
# Long waits should respond more generously to active play without turning short
# late-game cycles into click spam. This curve adds exactly 3.333 percentage
# points at ten seconds (a fresh tap therefore advances 0.5 s), then approaches
# four extra points asymptotically.
const FIELD_TAP_DURATION_BONUS_LIMIT := 0.04
const FIELD_TAP_DURATION_EXPONENT := 0.7781512503836436
# A normal human rhythm is effectively free. Faster bursts build a quarter-second
# moving tap rate; effectiveness then approaches a finite sustained throughput
# instead of letting macro-speed input erase the idle game. Autonomic Clicking
# Finger ranks raise the soft tolerance logarithmically for later automation.
const FIELD_TAP_FATIGUE_TIME_CONSTANT_SECONDS := 0.25
const FIELD_TAP_FATIGUE_IMPULSE_PER_TAP := 1.0 / FIELD_TAP_FATIGUE_TIME_CONSTANT_SECONDS
const FIELD_TAP_FATIGUE_FREE_RATE := 4.0
const FIELD_TAP_FATIGUE_BASE_TOLERANCE := 8.0
const FIELD_TAP_FATIGUE_TOLERANCE_LOG_BONUS := 0.50
const AUTO_CLICK_RATE_PER_LOG2_RANK := 0.20
const AUTO_CLICK_PROCESS_LIMIT := 256
# Every completed plate appearance has a believable lineup-change baseline.
# Contact adds the displayed delay on top; a walk uses the Single bonus.
const BASE_BATTER_TURNOVER_SECONDS := 3.0
const OUTCOME_TURNOVER_BONUS_SECONDS := [9.0, 5.0, 3.0, 2.0, 1.0, 0.0, 1.0, 0.0]
const MAX_SAVED_VOLLEY_SIZE := 4096
const MAX_BATTER_DOWNTIME_SECONDS := BASE_BATTER_TURNOVER_SECONDS + OUTCOME_TURNOVER_BONUS_SECONDS[Content.GRAND_SLAM_INDEX] * MAX_SAVED_VOLLEY_SIZE
# The first ball assigned beyond the batter's visible bat count retains only
# 18% of its normal contact chance. Every additional uncovered ball compounds
# that factor again, quickly turning anatomical overload into called Strikes.
const BAT_OVERLOAD_CONTACT_REMAINING := 0.18
# Literal throws are deliberately finite: at the renderer's 0.16 second
# minimum travel time, this cap produces at most 3,200 simultaneous outbound
# balls. The idle game's larger numbers come from payload potency and rewards.
const MAX_PHYSICAL_PITCH_RATE := 20000.0
# Quality, Threat, Frustration-derived quality, and similar matchup ratings are
# stored in compact simulation units but shown as satisfying whole-number game
# ratings. This is presentation-only so old saves and probability balance remain
# exact: 0.039 internal displays as 39 and 6 displays as 6,000.
const DISPLAY_RATING_SCALE := 1000.0
const LOOT_DROP_CHANCE := 0.12
const LOOT_REMAINING_PER_RANK := 0.995
const LOOT_PITY_ROLLS := 10
const LOOT_ROLL_INTERVAL_SECONDS := 5.0
const LOOT_ITEMS_PER_SLOT := 10
const LOOT_EXACT_ROLL_LIMIT := 120
const LOOT_SCRAP_RARITY_MULTIPLIERS := [
	1.0, 3.0, 8.0, 20.0, 50.0,
	70.0, 100.0, 150.0, 230.0, 350.0,
	500.0, 750.0, 1100.0, 1700.0, 2500.0,
]
const OVERMASTERY_XP_PER_DOUBLING := 0.0125
const OVERMASTERY_LOOT_LUCK_PER_DOUBLING := 0.05
const MASTERY_REQUIREMENT_FACTOR_PER_RANK := 0.85
# Every point of opponent mastery makes that exact matchup a little easier.
# The logarithm deliberately has no hard ceiling: doubling an already enormous
# mastery total always helps, but by the same modest +quality step.
const MASTERY_MATCHUP_QUALITY_PER_DOUBLING := 0.12
# Bad results supply a second, temporary adaptation bonus. Every independently
# resolved ball contributes its own result severity. Four frustration points
# grant the first +0.08 quality step; every later step takes twice as many.
const FRUSTRATION_REFERENCE_POINTS := 4.0
const FRUSTRATION_QUALITY_PER_DOUBLING := 0.08
const PAYLOAD_TRAINING_PER_RANK := 0.01
const MASTERY_TRAINING_PER_RANK := 0.015
const DRAG_TRAINING_FACTOR_PER_RANK := 0.985
const XP_TRAINING_PER_RANK := 0.01
const FRUSTRATION_TRAINING_PER_RANK := 0.01
const FRUSTRATION_OUTCOME_POINTS := [12.0, 8.0, 5.0, 3.0, 1.0, 0.10, 0.20, 0.0]
const PREMIUM_HUMAN_MILESTONE_IDS := [
	"neighborhood_pitching_tutor",
	"backyard_mound_permit",
	"travel_team_family_package",
	"private_pitching_academy",
	"biomechanics_weekend",
	"varsity_development_endowment",
	"sports_science_retainer",
	"recruiting_consultancy",
	"nil_pitch_lab",
	"minor_league_complex",
	"organization_analytics_department",
	"mlb_performance_institute",
	"pharmaceutical_defense_fund",
	"world_series_pitching_campus",
	"personal_hall_of_fame_wing",
]
# One-time facilities should be deliberate savings decisions. Their effects are
# intentionally strong; the price lane is therefore separated from repeatable
# Training and premium capital projects sit another step above ordinary builds.
const MILESTONE_COST_MULTIPLIER := 4.0
const PREMIUM_HUMAN_MILESTONE_COST_MULTIPLIER := 2.0
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
const AUTO_TRAINING_STAT_IDS := [
	"velocity",
	"command",
	"field_hustle",
	"recovery",
	"offline_efficiency",
	"distance_control",
	"turnover",
	"hit_recovery",
	"pitch_calling",
	"payload_training",
	"mastery_training",
	"drag_training",
	"xp_training",
	"loot_training",
	"frustration_training",
]
const AUTO_CATALOG_IDS := ["pitch", "ball", "facility", "growth"]

var opponents: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()

var xp := 0.0
var run_xp := 0.0
var lifetime_xp := 0.0
var lifetime_pitches := 0.0
var lifetime_field_taps := 0.0
var lifetime_field_tap_seconds := 0.0
var lifetime_automatic_field_taps := 0.0
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
var alien_exhibition_grand_slams := 0
var alien_arrival_seen := false
var eldritch_exhibition_seconds := 0.0
var cosmos_conquered := false
var body_growth_level := 0
var human_league_completed_as_toddler := false
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
	"payload_training": 0,
	"mastery_training": 0,
	"drag_training": 0,
	"xp_training": 0,
	"loot_training": 0,
	"frustration_training": 0,
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
	"autonomic_clicking_finger": 0,
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
	"front_office_outside_time": 0,
	"interstellar_itinerary": 0,
	"hands_beyond_the_mouse": 0,
}
var divine_blessings: Array[String] = []
var unlocked_pitches: Array[String] = ["dead_fish"]
var purchased_ball_upgrades: Array[String] = []
var purchased_milestones: Array[String] = []
var purchased_body_modifiers: Array[String] = []
var unlocked_achievements: Array[String] = []
var achievement_event_totals := {}
var achievement_revision := 0
var catalog_hide_purchased := {
	"pitch": false,
	"ball": false,
	"facility": false,
	"body": false,
}
var achievement_hide_achieved := false
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
var at_bat_metrics_cache := {}
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
# v25 resolves every simultaneous projectile independently. The scalar pair is
# retained as the first-ball compatibility view for older saves and focused
# diagnostics; authoritative play uses the arrays.
var pending_volley_outcomes: Array[int] = []
var pending_volley_saved_flags: Array[bool] = []
var pending_volley_outcome := Content.STRIKE_INDEX
var pending_volley_saved := false
var pending_volley_pitch_id := "dead_fish"
var pending_volley_speed_fps := 1.0
var pending_volley_plate_speed_fps := 1.0
var pending_volley_drag_per_foot := 0.0
var pending_volley_distance_index := 0
var pending_volley_opponent_index := 0
var foreground_timer_serial := 0
var field_tap_phase_key := ""
var field_tap_phase_original_seconds := 0.0
var field_tap_advanced_seconds := 0.0
var field_tap_burst_rate := 0.0
var automatic_field_tap_credit := 0.0
var simulation_accumulator := 0.0
var last_batch: Dictionary = {}
var last_offline_seconds := 0.0
var auto_advance_enabled := false
# Kept as a compact compatibility flag for v18 saves. In v19 it mirrors whether
# at least one individually licensed Training stat is selected.
var auto_train_enabled := false
var auto_farm_enabled := false
var auto_training_stats := {
	"velocity": false,
	"command": false,
	"field_hustle": false,
	"recovery": false,
	"offline_efficiency": false,
	"distance_control": false,
	"turnover": false,
	"hit_recovery": false,
	"pitch_calling": false,
	"payload_training": false,
	"mastery_training": false,
	"drag_training": false,
	"xp_training": false,
	"loot_training": false,
	"frustration_training": false,
}
var auto_catalog_settings := {
	"pitch": false,
	"ball": false,
	"facility": false,
	"growth": false,
}
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
	var bounded := clampi(opponent_index, 0, opponents.size() - 1)
	if bounded <= 0:
		return 0
	# Every league adds a five-rarity family. Older families remain in the
	# sample, so an alien can still turn up in a perfectly ordinary Rare cap.
	# League champions are authored showcases: every item they wear is the top
	# tier currently available.
	if bounded == Content.HUMAN_FINAL_INDEX:
		return 4
	if bounded == Content.ALIEN_FINAL_INDEX:
		return 9
	if bounded == Content.FINAL_BOSS_INDEX:
		return 14
	var center := 0.0
	var deviation := 0.55
	var maximum := 4
	if bounded <= Content.HUMAN_FINAL_INDEX:
		center = 4.0 * float(bounded) / float(Content.HUMAN_FINAL_INDEX)
	elif bounded <= Content.ALIEN_FINAL_INDEX:
		var alien_progress := float(bounded - Content.ALIEN_EXHIBITION_INDEX) / float(
			maxi(Content.ALIEN_FINAL_INDEX - Content.ALIEN_EXHIBITION_INDEX, 1)
		)
		center = lerpf(5.0, 9.0, alien_progress)
		deviation = 1.65
		maximum = 9
	else:
		var eldritch_progress := float(bounded - Content.ELDRITCH_EXHIBITION_INDEX) / float(
			maxi(Content.FINAL_BOSS_INDEX - Content.ELDRITCH_EXHIBITION_INDEX, 1)
		)
		center = lerpf(9.2, 14.0, eldritch_progress)
		deviation = 2.45
		maximum = 14
	return clampi(int(round(local_rng.randfn(center, deviation))), 0, maximum)

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

	# Little Timmy owns the tutorial cap, and later batters gradually fill every
	# mundane slot. By professional baseball the whole visible loadout can be a
	# real drop source; Relics join only after human baseball.
	var extra_count := clampi(1 + int(floor(float(bounded) / 4.0)), 1, 6)
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

func _get_opponent_variant_for_loot(opponent_index: int) -> Dictionary:
	var bounded := clampi(opponent_index, 0, opponents.size() - 1)
	if (
		bounded == current_opponent
		and int(get_current_batter_variant().get("opponent_index", -1)) == bounded
	):
		return get_current_batter_variant()
	return _generate_opponent_variant(bounded, 0)

func get_opponent_drop_sources(opponent_index: int = current_opponent) -> Array[Dictionary]:
	# A parcel is a copy of one visible, player-wearable item on this batter.
	# Body and bat affect threat but are intentionally not player equipment slots.
	var bounded := clampi(opponent_index, 0, opponents.size() - 1)
	var result: Array[Dictionary] = []
	var variant := _get_opponent_variant_for_loot(bounded)
	for entry_value in variant.get("loadout", []):
		var entry: Dictionary = entry_value
		var slot_id := str(entry.get("id", ""))
		var slot := Content.loot_slot_by_id(slot_id)
		if slot.is_empty() or bounded < int(slot.get("required_level", 0)):
			continue
		result.append(entry.duplicate(true))
	return result

func _opponent_drop_source_weight(entry: Dictionary, opponent_index: int) -> float:
	# Excess mastery cannot create a rarity the batter is not wearing. It only
	# makes the better visible pieces a little likelier to be the selected drop.
	var rarity_index := clampi(int(entry.get("rarity", 0)), 0, Content.LOOT_RARITIES.size() - 1)
	return 1.0 + get_opponent_loot_luck(opponent_index) * float(rarity_index)

func _sample_opponent_drop_source(opponent_index: int) -> Dictionary:
	var sources := get_opponent_drop_sources(opponent_index)
	if sources.is_empty():
		return {}
	var total_weight := 0.0
	for entry in sources:
		total_weight += _opponent_drop_source_weight(entry, opponent_index)
	var roll := rng.randf() * maxf(total_weight, 0.000001)
	var cumulative := 0.0
	for entry in sources:
		cumulative += _opponent_drop_source_weight(entry, opponent_index)
		if roll <= cumulative:
			return entry
	return sources.back()

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
		"autonomic_clicking_finger": 0,
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
		"front_office_outside_time": 0,
		"interstellar_itinerary": 0,
		"hands_beyond_the_mouse": 0,
	}

func _empty_auto_training_stats() -> Dictionary:
	var result := {}
	for id in AUTO_TRAINING_STAT_IDS:
		result[str(id)] = false
	return result

func _empty_auto_catalog_settings() -> Dictionary:
	var result := {}
	for id in AUTO_CATALOG_IDS:
		result[str(id)] = false
	return result

func _reset_auto_training_stats() -> void:
	auto_training_stats = _empty_auto_training_stats()
	auto_train_enabled = false

func _reset_auto_catalog_settings() -> void:
	auto_catalog_settings = _empty_auto_catalog_settings()

func get_auto_training_license_count() -> int:
	return clampi(
		int(genetic_levels.get("autonomic_coach", 0)),
		0,
		AUTO_TRAINING_STAT_IDS.size()
	)

func get_auto_training_selection_count() -> int:
	var count := 0
	for id in AUTO_TRAINING_STAT_IDS:
		if bool(auto_training_stats.get(str(id), false)):
			count += 1
	return count

func is_auto_training_stat_selected(id: String) -> bool:
	return id in AUTO_TRAINING_STAT_IDS and bool(auto_training_stats.get(id, false))

func set_auto_training_stat(id: String, enabled: bool) -> bool:
	if id not in AUTO_TRAINING_STAT_IDS:
		return false
	var was_enabled := bool(auto_training_stats.get(id, false))
	if enabled and not was_enabled:
		if get_auto_training_selection_count() >= get_auto_training_license_count():
			return false
	auto_training_stats[id] = enabled
	auto_train_enabled = get_auto_training_selection_count() > 0
	return true

func is_auto_catalog_selected(id: String) -> bool:
	return id in AUTO_CATALOG_IDS and bool(auto_catalog_settings.get(id, false))

func set_auto_catalog_setting(id: String, enabled: bool) -> bool:
	if id not in AUTO_CATALOG_IDS:
		return false
	if enabled and not has_eldritch_upgrade("front_office_outside_time"):
		return false
	auto_catalog_settings[id] = enabled
	return true

func _sanitize_automation_settings() -> void:
	var sanitized_training := _empty_auto_training_stats()
	var remaining_licenses := get_auto_training_license_count()
	for id in AUTO_TRAINING_STAT_IDS:
		var selected := bool(auto_training_stats.get(str(id), false)) and remaining_licenses > 0
		sanitized_training[str(id)] = selected
		if selected:
			remaining_licenses -= 1
	auto_training_stats = sanitized_training
	auto_train_enabled = get_auto_training_selection_count() > 0

	var sanitized_catalogs := _empty_auto_catalog_settings()
	if has_eldritch_upgrade("front_office_outside_time"):
		for id in AUTO_CATALOG_IDS:
			sanitized_catalogs[str(id)] = bool(auto_catalog_settings.get(str(id), false))
	auto_catalog_settings = sanitized_catalogs

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

func is_alien_help_available() -> bool:
	return (
		is_alien_exhibition_blocked()
		and not genetic_offer_unlocked
		and alien_exhibition_grand_slams >= ALIEN_EXHIBITION_GRAND_SLAMS_REQUIRED
	)

func get_alien_exhibition_progress_ratio() -> float:
	return clampf(
		float(alien_exhibition_grand_slams)
		/ float(maxi(ALIEN_EXHIBITION_GRAND_SLAMS_REQUIRED, 1)),
		0.0,
		1.0
	)

func get_alien_exhibition_taunt(grand_slam_number: int = alien_exhibition_grand_slams) -> String:
	if ALIEN_EXHIBITION_TAUNTS.is_empty():
		return "HA!"
	return str(ALIEN_EXHIBITION_TAUNTS[
		posmod(maxi(grand_slam_number, 1) - 1, ALIEN_EXHIBITION_TAUNTS.size())
	])

func should_show_alien_arrival() -> bool:
	return (
		current_opponent == Content.ALIEN_EXHIBITION_INDEX
		and genetic_rebirths <= 0
		and not alien_arrival_seen
	)

func mark_alien_arrival_seen() -> bool:
	if not should_show_alien_arrival():
		return false
	alien_arrival_seen = true
	return true

func accept_alien_help() -> bool:
	if not is_alien_help_available():
		return false
	genetic_offer_unlocked = true
	progression_changed.emit(
		"TIME TRAVEL UNLOCKED: A portal stranger has a deeply irresponsible baseball plan."
	)
	check_achievements()
	return true

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
			return "VELOCITY TRIAL • Approach the human limit: %s mph." % format_number(HUMAN_SPEED_CAP_MPH, 0)
		Content.ALIEN_FINAL_INDEX:
			return "INTERSTELLAR LICENSE • Reach Mach 3."
		Content.FINAL_BOSS_INDEX:
			return "CAUSALITY ARMOR • Only a pitch at 1c can count."
		_:
			return ""

func _advance_story_encounters(seconds: float, _alien_witnessed: bool) -> void:
	# The first alien lesson is advanced by visible Grand Slams at the plate, not
	# by an invisible wall-clock countdown. The eldritch encounter deliberately
	# keeps its time-based revelation because its whole joke is waiting on a god.
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
			return "TIME TRAVEL READY • Open BODY when you are ready to be born again."
		if is_alien_help_available():
			return "IMPOSSIBLE EXHIBITION • GRAND SLAM 100%"
		return "IMPOSSIBLE EXHIBITION • GRAND SLAM 100%% • HUMILIATION %d / %d" % [
			alien_exhibition_grand_slams,
			ALIEN_EXHIBITION_GRAND_SLAMS_REQUIRED,
		]
	if is_eldritch_exhibition_blocked():
		if eldritch_offer_unlocked:
			return "ELDRITCH OFFER READY • Open BODY and abandon this reality."
		return "IMPOSSIBLE EXHIBITION • 100% GRAND SLAMS • Revelation in %ds" % int(ceil(EXHIBITION_SECONDS - eldritch_exhibition_seconds))
	return ""

func reset_fresh() -> void:
	xp = 0.0
	run_xp = 0.0
	lifetime_xp = 0.0
	lifetime_pitches = 0.0
	lifetime_field_taps = 0.0
	lifetime_field_tap_seconds = 0.0
	lifetime_automatic_field_taps = 0.0
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
	alien_exhibition_grand_slams = 0
	alien_arrival_seen = false
	eldritch_exhibition_seconds = 0.0
	cosmos_conquered = false
	body_growth_level = 0
	human_league_completed_as_toddler = false
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
		"payload_training": 0,
		"mastery_training": 0,
		"drag_training": 0,
		"xp_training": 0,
		"loot_training": 0,
		"frustration_training": 0,
	}
	scale_levels = {}
	_reset_genetic_levels()
	_reset_eldritch_levels()
	divine_blessings.clear()
	unlocked_pitches = ["dead_fish"]
	purchased_ball_upgrades.clear()
	purchased_milestones.clear()
	purchased_body_modifiers.clear()
	unlocked_achievements.clear()
	achievement_event_totals.clear()
	achievement_revision += 1
	catalog_hide_purchased = {
		"pitch": false,
		"ball": false,
		"facility": false,
		"body": false,
	}
	achievement_hide_achieved = false
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
	auto_farm_enabled = false
	_reset_auto_training_stats()
	_reset_auto_catalog_settings()
	automation_accumulator = 0.0
	field_tap_burst_rate = 0.0
	automatic_field_tap_credit = 0.0
	_reset_mastery()

func _clear_pitch_cycle() -> void:
	pitch_credit = 0.0
	pitch_flight_remaining = 0.0
	pending_volley_flight_duration = 0.0
	pending_volley_size = 0
	pending_volley_outcomes.clear()
	pending_volley_saved_flags.clear()
	pending_volley_outcome = Content.STRIKE_INDEX
	pending_volley_saved = false
	pending_volley_pitch_id = "dead_fish"
	pending_volley_speed_fps = 1.0
	pending_volley_plate_speed_fps = 1.0
	pending_volley_drag_per_foot = 0.0
	pending_volley_distance_index = selected_distance_index
	pending_volley_opponent_index = current_opponent
	_start_new_foreground_timer_phase()

func _start_new_foreground_timer_phase() -> void:
	foreground_timer_serial = (foreground_timer_serial + 1) % 1000000000
	field_tap_phase_key = ""
	field_tap_phase_original_seconds = 0.0
	field_tap_advanced_seconds = 0.0

func get_field_tap_fraction() -> float:
	var rank := maxi(int(training_levels.get("field_hustle", 0)), 0)
	return FIELD_TAP_FRACTION_LIMIT - (
		FIELD_TAP_FRACTION_LIMIT - BASE_FIELD_TAP_FRACTION
	) * pow(FIELD_TAP_REMAINING_PER_RANK, float(rank))

func get_field_tap_duration_bonus(timer_seconds: float) -> float:
	var duration := maxf(timer_seconds, 1.0)
	return FIELD_TAP_DURATION_BONUS_LIMIT * (
		1.0 - pow(duration, -FIELD_TAP_DURATION_EXPONENT)
	)

func get_field_tap_fraction_for_duration(timer_seconds: float) -> float:
	return get_field_tap_fraction() + get_field_tap_duration_bonus(timer_seconds)

func get_field_tap_fatigue_tolerance_for_rank(rank: int) -> float:
	rank = maxi(rank, 0)
	return FIELD_TAP_FATIGUE_BASE_TOLERANCE * (
		1.0
		+ FIELD_TAP_FATIGUE_TOLERANCE_LOG_BONUS
		* log(float(rank + 1)) / log(2.0)
	)

func get_field_tap_fatigue_tolerance() -> float:
	return get_field_tap_fatigue_tolerance_for_rank(
		int(genetic_levels.get("autonomic_clicking_finger", 0))
	)

func get_field_tap_fatigue_multiplier_for_burst_rate(
	burst_rate: float,
	genetic_rank := -1
) -> float:
	var excess_rate := maxf(burst_rate - FIELD_TAP_FATIGUE_FREE_RATE, 0.0)
	if excess_rate <= 0.0:
		return 1.0
	var rank := (
		int(genetic_levels.get("autonomic_clicking_finger", 0))
		if genetic_rank < 0
		else genetic_rank
	)
	var tolerance := maxf(get_field_tap_fatigue_tolerance_for_rank(rank), 0.000001)
	var load := excess_rate / tolerance
	return 1.0 / sqrt(1.0 + load * load)

func get_field_tap_fatigue_multiplier() -> float:
	return get_field_tap_fatigue_multiplier_for_burst_rate(field_tap_burst_rate)

func _decay_field_tap_fatigue(elapsed: float) -> void:
	if field_tap_burst_rate <= 0.0 or elapsed <= 0.0:
		return
	field_tap_burst_rate *= exp(
		-maxf(elapsed, 0.0) / FIELD_TAP_FATIGUE_TIME_CONSTANT_SECONDS
	)
	if field_tap_burst_rate < 0.000001:
		field_tap_burst_rate = 0.0

func _record_field_tap_fatigue() -> void:
	field_tap_burst_rate = minf(
		MAX_NUMBER,
		field_tap_burst_rate + FIELD_TAP_FATIGUE_IMPULSE_PER_TAP
	)

func get_automatic_click_rate_per_clicker_for_rank(rank: int) -> float:
	rank = maxi(rank, 0)
	if rank <= 0:
		return 0.0
	return AUTO_CLICK_RATE_PER_LOG2_RANK * log(float(rank + 1)) / log(2.0)

func get_automatic_click_rate_per_clicker() -> float:
	return get_automatic_click_rate_per_clicker_for_rank(
		int(genetic_levels.get("autonomic_clicking_finger", 0))
	)

func get_automatic_clicker_count() -> int:
	if int(genetic_levels.get("autonomic_clicking_finger", 0)) <= 0:
		return 0
	return 1 + maxi(int(eldritch_levels.get("hands_beyond_the_mouse", 0)), 0)

func get_automatic_field_tap_rate() -> float:
	return get_automatic_click_rate_per_clicker() * float(get_automatic_clicker_count())

func get_automatic_field_tap_fatigue_multiplier() -> float:
	var click_rate := get_automatic_field_tap_rate()
	if click_rate <= 0.0:
		return 1.0
	var decay_exponent := 1.0 / (
		click_rate * FIELD_TAP_FATIGUE_TIME_CONSTANT_SECONDS
	)
	var steady_burst_rate := 0.0
	if decay_exponent < 0.000001:
		steady_burst_rate = click_rate
	elif decay_exponent < 60.0:
		steady_burst_rate = FIELD_TAP_FATIGUE_IMPULSE_PER_TAP / (
			exp(decay_exponent) - 1.0
		)
	return get_field_tap_fatigue_multiplier_for_burst_rate(steady_burst_rate)

func get_effective_automatic_field_tap_rate() -> float:
	return get_automatic_field_tap_rate() * get_automatic_field_tap_fatigue_multiplier()

func get_automatic_timer_seconds(timer_seconds: float) -> float:
	var duration := maxf(timer_seconds, 0.0)
	var click_rate := get_effective_automatic_field_tap_rate()
	if duration <= 0.0 or click_rate <= 0.0:
		return duration
	# Each click advances a fraction of the part of this phase that input has not
	# already supplied. Natural time and active input therefore meet smoothly:
	# there is no arbitrary 50% wall, but repeated clicks asymptotically lose bite.
	# Solve t + D(1-e^(-rft)) = D for the real time t spent in the phase.
	var fraction := get_field_tap_fraction_for_duration(duration)
	var lower := 0.0
	var upper := duration
	for _iteration in 40:
		var candidate := (lower + upper) * 0.5
		var input_advance := duration * (
			1.0 - exp(-click_rate * fraction * candidate)
		)
		if candidate + input_advance >= duration:
			upper = candidate
		else:
			lower = candidate
	return upper

func apply_field_tap(automatic := false) -> Dictionary:
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
	var phase_multiplier := clampf(
		1.0 - field_tap_advanced_seconds / original,
		0.0,
		1.0
	)
	var maximum_without_skipping_resolution := timer_remaining
	if phase == "flight":
		# Keep the immutable volley alive for one normal simulation tick so its
		# authoritative impact event and the visual ball reach the plate together.
		maximum_without_skipping_resolution = maxf(timer_remaining - 0.000001, 0.0)
	var fresh_tap_fraction := get_field_tap_fraction_for_duration(original)
	var fatigue_multiplier := get_field_tap_fatigue_multiplier()
	var advance_seconds := minf(
		original * fresh_tap_fraction * fatigue_multiplier * phase_multiplier,
		maximum_without_skipping_resolution
	)
	if advance_seconds <= 0.000001:
		return {
			"applied": false,
			"phase": phase,
			"reason": "diminishing_return",
			"phase_multiplier": phase_multiplier,
		}

	field_tap_advanced_seconds += advance_seconds
	_record_field_tap_fatigue()
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
	if automatic:
		lifetime_automatic_field_taps = minf(MAX_NUMBER, lifetime_automatic_field_taps + 1.0)
	else:
		lifetime_field_taps = minf(MAX_NUMBER, lifetime_field_taps + 1.0)
	lifetime_field_tap_seconds = minf(
		MAX_NUMBER,
		lifetime_field_tap_seconds + advance_seconds
	)
	if not automatic:
		check_achievements()
	return {
		"applied": true,
		"automatic": automatic,
		"phase": phase,
		"seconds": advance_seconds,
		"fraction": advance_seconds / original,
		"tap_fraction": advance_seconds / original,
		"fresh_tap_fraction": fresh_tap_fraction,
		"phase_multiplier": phase_multiplier,
		"fatigue_multiplier": fatigue_multiplier,
		"burst_rate": field_tap_burst_rate,
		"fatigue_tolerance": get_field_tap_fatigue_tolerance(),
		"timer_seconds": original,
	}

func _run_automatic_field_taps(elapsed: float) -> void:
	var click_rate := get_automatic_field_tap_rate()
	if click_rate <= 0.0:
		automatic_field_tap_credit = 0.0
		return
	automatic_field_tap_credit += maxf(elapsed, 0.0) * click_rate
	var clicks_due := mini(int(floor(automatic_field_tap_credit)), AUTO_CLICK_PROCESS_LIMIT)
	if clicks_due <= 0:
		return
	# Scheduled clicks are consumed even after their marginal effect becomes tiny.
	# They never bank up into an instant burst on the next ball.
	automatic_field_tap_credit -= float(clicks_due)
	if automatic_field_tap_credit >= 1.0:
		automatic_field_tap_credit = fmod(automatic_field_tap_credit, 1.0)
	for _click in clicks_due:
		var result := apply_field_tap(true)
		if bool(result.get("applied", false)):
			automatic_field_tap_applied.emit(result)

func is_pitch_in_flight() -> bool:
	return pending_volley_size > 0 and pitch_flight_remaining > 0.0

func advance(delta: float) -> void:
	_decay_field_tap_fatigue(maxf(delta, 0.0))
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
	_advance_story_encounters(elapsed, true)
	_run_automatic_field_taps(elapsed)
	_resolve_elapsed(elapsed, true, true)
	_run_automation(elapsed)

func _run_automation(elapsed: float) -> void:
	automation_accumulator += elapsed
	if automation_accumulator < 0.50:
		return
	automation_accumulator = 0.0
	_sanitize_automation_settings()
	if auto_train_enabled and get_auto_training_license_count() > 0:
		var purchases := 0
		for _purchase in 20:
			var cheapest_id := ""
			var cheapest_cost := MAX_NUMBER
			for id_value in AUTO_TRAINING_STAT_IDS:
				var id := str(id_value)
				if not is_auto_training_stat_selected(id):
					continue
				var cost := get_training_cost(str(id))
				if cost < cheapest_cost:
					cheapest_cost = cost
					cheapest_id = str(id)
			if cheapest_id.is_empty() or cheapest_cost >= MAX_NUMBER or cheapest_cost > xp:
				break
			xp -= cheapest_cost
			training_levels[cheapest_id] = int(training_levels[cheapest_id]) + 1
			purchases += 1
		if purchases > 0:
			progression_changed.emit("Licensed auto-coach purchased %d Training ranks." % purchases)
			check_achievements()
	if has_eldritch_upgrade("front_office_outside_time"):
		var catalog_purchases := 0
		for _purchase in 20:
			var candidate := _get_auto_catalog_candidate()
			if candidate.is_empty():
				break
			var purchased := false
			match str(candidate.kind):
				"pitch":
					purchased = buy_pitch(str(candidate.id))
				"ball":
					purchased = buy_ball_upgrade(str(candidate.id))
				"facility":
					purchased = buy_milestone(str(candidate.id))
				"growth":
					purchased = buy_body_growth(str(candidate.id))
				"body_modifier":
					purchased = buy_body_modifier(str(candidate.id))
			if not purchased:
				break
			catalog_purchases += 1
		if catalog_purchases > 0:
			progression_changed.emit(
				"The front office purchased %d one-time upgrades outside normal time."
				% catalog_purchases
			)
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
		var best_rate := get_estimated_xp_per_second(current_opponent)
		var original_opponent := current_opponent
		var original_distance := selected_distance_index
		for opponent_index in highest_unlocked + 1:
			current_opponent = opponent_index
			selected_distance_index = get_prescribed_distance_index(opponent_index)
			var candidate_rate := get_estimated_xp_per_second(opponent_index)
			if candidate_rate > best_rate * 1.02:
				best_rate = candidate_rate
				best_opponent = opponent_index
		current_opponent = original_opponent
		selected_distance_index = original_distance
		if best_opponent != current_opponent:
			current_opponent = best_opponent
			_sync_distance_to_current_opponent()
			_clear_pitch_cycle()
			plate_strikes = 0
			plate_balls = 0
			batter_cooldown_remaining = 0.0
			_reset_batter_identity()
			consecutive_home_runs = 0
			progression_changed.emit(
				"Auto-scout moved to %s at %s."
				% [opponents[best_opponent].name, get_current_distance().label]
			)

func _get_auto_catalog_candidate() -> Dictionary:
	var result := {}
	var cheapest_cost := MAX_NUMBER
	if is_auto_catalog_selected("pitch"):
		for definition_value in Content.PITCHES:
			var definition: Dictionary = definition_value
			var id := str(definition.id)
			var cost := get_pitch_cost(id)
			if can_buy_pitch(id) and cost < cheapest_cost:
				cheapest_cost = cost
				result = {"kind": "pitch", "id": id, "cost": cost}
	if is_auto_catalog_selected("ball"):
		for definition_value in Content.BALL_UPGRADES:
			var definition: Dictionary = definition_value
			var id := str(definition.id)
			var cost := get_ball_upgrade_cost(id)
			if can_buy_ball_upgrade(id) and cost < cheapest_cost:
				cheapest_cost = cost
				result = {"kind": "ball", "id": id, "cost": cost}
	if is_auto_catalog_selected("facility"):
		for definition_value in Content.MILESTONES:
			var definition: Dictionary = definition_value
			var id := str(definition.id)
			var cost := get_milestone_cost(id)
			if can_buy_milestone(id) and cost < cheapest_cost:
				cheapest_cost = cost
				result = {"kind": "facility", "id": id, "cost": cost}
	if is_auto_catalog_selected("growth"):
		for stage_index in range(1, Content.BODY_GROWTH_STAGES.size()):
			var definition: Dictionary = Content.BODY_GROWTH_STAGES[stage_index]
			var id := str(definition.id)
			var cost := get_body_growth_cost(id)
			if can_buy_body_growth(id) and cost < cheapest_cost:
				cheapest_cost = cost
				result = {"kind": "growth", "id": id, "cost": cost}
		for definition_value in Content.BODY_MODIFIERS:
			var definition: Dictionary = definition_value
			var id := str(definition.id)
			var cost := get_body_modifier_cost(id)
			if can_buy_body_modifier(id) and cost < cheapest_cost:
				cheapest_cost = cost
				result = {"kind": "body_modifier", "id": id, "cost": cost}
	return result

func simulate_offline(seconds: float) -> Dictionary:
	var bounded_seconds := clampf(seconds, 0.0, MAX_OFFLINE_SECONDS)
	last_offline_seconds = bounded_seconds
	if bounded_seconds < 1.0:
		return {}
	_decay_field_tap_fatigue(bounded_seconds)
	# The first impossible alien is a witnessed story beat. Closing or
	# suspending the game cannot quietly reveal its escape hatch.
	_advance_story_encounters(bounded_seconds, false)
	var efficiency := get_offline_xp_efficiency()
	var summary := _resolve_elapsed(bounded_seconds, false, false, efficiency)
	summary["offline_seconds"] = bounded_seconds
	summary["offline_xp_efficiency"] = efficiency
	summary["offline_reward_efficiency"] = efficiency
	last_batch = summary
	return summary

# Deterministic pacing audits use the same closed-form at-bat math at the full
# foreground reward rate. It is intentionally separate from offline catch-up so
# test acceleration cannot silently bypass the player's offline-efficiency stat.
func simulate_active_time(seconds: float) -> Dictionary:
	var bounded_seconds := clampf(seconds, 0.0, MAX_OFFLINE_SECONDS)
	if bounded_seconds <= 0.0:
		return {}
	_decay_field_tap_fatigue(bounded_seconds)
	_advance_story_encounters(bounded_seconds, true)
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
		"raw_mastery_gained": 0.0,
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
	offline_reward_multiplier := 1.0
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
		_apply_resolution(summary, should_emit, offline_reward_multiplier)
		return summary
	# Repeat universes remember both prestige offers. Once their exhibition
	# batter is reached, hold the ball until the player takes the already-known
	# reset instead of manufacturing unavoidable Grand Slams into a clean run.
	if is_story_offer_ready() and not is_pitch_in_flight():
		pitch_credit = 0.0
		_apply_resolution(summary, should_emit, offline_reward_multiplier)
		return summary
	var elapsed_offset := 0.0
	var recovery_rate := maxf(get_recovery_rate(), 0.000001)
	var active_cycle_seconds := (
		get_automatic_timer_seconds(1.0 / recovery_rate)
		+ get_automatic_timer_seconds(get_resolved_flight_seconds())
	)
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
			_resolve_aggregate_time(
				remaining,
				summary,
				stochastic,
				offline_reward_multiplier >= 0.999999
			)
			_apply_resolution(summary, should_emit, offline_reward_multiplier)
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
	_apply_resolution(summary, should_emit, offline_reward_multiplier)
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
	pending_volley_drag_per_foot = get_ball_drag_per_foot(current_opponent)
	pending_volley_plate_speed_fps = get_plate_speed_for_release(
		pending_volley_speed_fps,
		pending_volley_distance_index,
		pending_volley_drag_per_foot
	)
	lifetime_max_pitch_speed_fps = maxf(lifetime_max_pitch_speed_fps, pending_volley_speed_fps)
	lifetime_max_distance_index = maxi(lifetime_max_distance_index, pending_volley_distance_index)
	pending_volley_opponent_index = current_opponent
	_sample_pending_volley_interactions(pending_volley_opponent_index)
	pending_volley_flight_duration = get_resolved_flight_seconds_for_speed(
		pending_volley_speed_fps,
		pending_volley_distance_index,
		pending_volley_drag_per_foot
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
		"plate_speed_fps": pending_volley_plate_speed_fps,
		"drag_per_foot": pending_volley_drag_per_foot,
		"distance_index": pending_volley_distance_index,
		"opponent_index": pending_volley_opponent_index,
	})

func _resolve_pending_volley(summary: Dictionary, elapsed_offset: float) -> void:
	var ball_count := maxi(pending_volley_size, 1)
	var outcomes: Array[int] = pending_volley_outcomes.duplicate()
	var saved_flags: Array[bool] = pending_volley_saved_flags.duplicate()
	# Save v24 represented a simultaneous volley with one shared result. Preserve
	# that exact unresolved interaction if an old generation is loaded.
	if outcomes.is_empty():
		for _ball in ball_count:
			outcomes.append(pending_volley_outcome)
			saved_flags.append(pending_volley_saved)
	var release_distance := pending_volley_distance_index
	# If the player selected another batter during flight, that batter owns the
	# impact. Distance remains release-time immutable so moving the mound never
	# teleports a ball or changes its payout after it leaves the hand.
	var resolved_opponent := current_opponent
	pending_volley_size = 0
	pending_volley_outcomes.clear()
	pending_volley_saved_flags.clear()
	pitch_flight_remaining = 0.0
	pending_volley_flight_duration = 0.0
	pending_volley_outcome = Content.STRIKE_INDEX
	pending_volley_saved = false
	pending_volley_pitch_id = "dead_fish"
	pending_volley_speed_fps = get_representative_pitch_speed("dead_fish")
	pending_volley_plate_speed_fps = pending_volley_speed_fps
	pending_volley_drag_per_foot = 0.0
	_start_new_foreground_timer_phase()
	_apply_volley_outcomes(
		summary,
		outcomes,
		saved_flags,
		elapsed_offset,
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
	var outcomes: Array[int] = []
	var saved_flags: Array[bool] = []
	var outcome := clampi(requested_outcome, 0, Content.OUTCOME_NAMES.size() - 1)
	for _ball in maxi(ball_count, 1):
		outcomes.append(outcome)
		saved_flags.append(
			bool(saved_override)
			if saved_override != null
			else (
				outcome < Content.HIT_OUTCOME_COUNT
				and rng.randf() < get_hit_save_chance(outcome, resolved_opponent)
			)
		)
	_apply_volley_outcomes(
		summary,
		outcomes,
		saved_flags,
		elapsed_offset,
		resolved_opponent,
		resolved_distance
	)

static func _outcome_multiplicity_prefix(count: int) -> String:
	match count:
		2:
			return "DOUBLE"
		3:
			return "TRIPLE"
		4:
			return "QUADRUPLE"
		5:
			return "QUINTUPLE"
		6:
			return "SEXTUPLE"
		7:
			return "SEPTUPLE"
		8:
			return "OCTUPLE"
		var larger:
			return "%d×" % larger

static func _format_outcome_group(outcome: int, count: int) -> String:
	var name := str(Content.OUTCOME_NAMES[clampi(outcome, 0, Content.OUTCOME_NAMES.size() - 1)])
	return name if count <= 1 else "%s %s" % [_outcome_multiplicity_prefix(count), name]

func _get_combined_hit_call(unsaved_hit_counts: Array[int]) -> String:
	var total_hits := 0
	var distinct_hits := 0
	var total_bases := 0
	var base_values := [4, 4, 3, 2, 1]
	for outcome in Content.HIT_OUTCOME_COUNT:
		var count := maxi(int(unsaved_hit_counts[outcome]), 0)
		total_hits += count
		total_bases += count * int(base_values[outcome])
		if count > 0:
			distinct_hits += 1
	if total_hits <= 1 or distinct_hits <= 1:
		return ""
	if int(unsaved_hit_counts[Content.GRAND_SLAM_INDEX]) > 0:
		var grand_slam_bases := int(unsaved_hit_counts[Content.GRAND_SLAM_INDEX]) * 4
		return "+%d GRAND SLAM" % maxi(total_bases - grand_slam_bases, 0)
	if int(unsaved_hit_counts[1]) > 0:
		var home_run_bases := int(unsaved_hit_counts[1]) * 4
		return "+%d HOME RUN" % maxi(total_bases - home_run_bases, 0)
	match total_bases:
		1:
			return "SINGLE"
		2:
			return "DOUBLE"
		3:
			return "TRIPLE"
		var bases:
			return "%d-BASE HIT" % bases

func _build_volley_call_lines(
	outcome_counts: Array[int],
	unsaved_hit_counts: Array[int],
	struck_out: bool,
	walked: bool
) -> Array[Dictionary]:
	var total_outcomes := 0
	var distinct_outcomes := 0
	for count in outcome_counts:
		total_outcomes += count
		if count > 0:
			distinct_outcomes += 1
	if total_outcomes == 1 and struck_out:
		return [{"outcome": Content.STRIKE_INDEX, "text": "STRIKEOUT"}]
	if total_outcomes == 1 and walked:
		return [{"outcome": Content.BALL_INDEX, "text": "WALK"}]
	var result: Array[Dictionary] = []
	for outcome in outcome_counts.size():
		var count := int(outcome_counts[outcome])
		if count > 0:
			result.append({
				"outcome": outcome,
				"text": _format_outcome_group(outcome, count),
			})
	var combined_hit_call := _get_combined_hit_call(unsaved_hit_counts)
	if not combined_hit_call.is_empty():
		var combined_outcome := Content.GRAND_SLAM_INDEX
		for outcome in Content.HIT_OUTCOME_COUNT:
			if int(unsaved_hit_counts[outcome]) > 0:
				combined_outcome = outcome
				break
		result.append({"outcome": combined_outcome, "text": "= %s" % combined_hit_call})
	if struck_out:
		result.append({"outcome": Content.STRIKE_INDEX, "text": "STRIKEOUT"})
	elif walked:
		result.append({"outcome": Content.BALL_INDEX, "text": "WALK"})
	return result

func get_combined_hit_downtime(unsaved_hit_counts: Array[int]) -> float:
	var result := get_base_batter_turnover_seconds()
	for outcome in mini(unsaved_hit_counts.size(), Content.HIT_OUTCOME_COUNT):
		result += float(maxi(int(unsaved_hit_counts[outcome]), 0)) * get_outcome_turnover_bonus(outcome)
	return clampf(result, 0.0, MAX_BATTER_DOWNTIME_SECONDS)

func _apply_volley_outcomes(
	summary: Dictionary,
	requested_outcomes: Array[int],
	requested_saved_flags: Array[bool],
	elapsed_offset := -1.0,
	resolved_opponent: int = current_opponent,
	resolved_distance: int = selected_distance_index
) -> void:
	var opening_plate_balls := plate_balls
	var outcomes: Array[int] = requested_outcomes.duplicate()
	if outcomes.is_empty():
		outcomes.append(Content.STRIKE_INDEX)
	var outcome_counts: Array[int] = []
	outcome_counts.resize(Content.OUTCOME_NAMES.size())
	outcome_counts.fill(0)
	var unsaved_hit_counts: Array[int] = []
	unsaved_hit_counts.resize(Content.HIT_OUTCOME_COUNT)
	unsaved_hit_counts.fill(0)
	var normalized_saved_flags: Array[bool] = []
	var saved_hit_count := 0
	var unsaved_hit_count := 0
	var counts: Array = summary.counts
	for ball_index in outcomes.size():
		var outcome := clampi(outcomes[ball_index], 0, Content.OUTCOME_NAMES.size() - 1)
		outcomes[ball_index] = outcome
		var saved := (
			ball_index < requested_saved_flags.size()
			and bool(requested_saved_flags[ball_index])
			and outcome < Content.HIT_OUTCOME_COUNT
			and outcome != Content.GRAND_SLAM_INDEX
		)
		normalized_saved_flags.append(saved)
		outcome_counts[outcome] += 1
		counts[outcome] = float(counts[outcome]) + 1.0
		if outcome < Content.HIT_OUTCOME_COUNT:
			no_hitter_attempt_valid = false
			if saved:
				saved_hit_count += 1
			else:
				unsaved_hit_counts[outcome] += 1
				unsaved_hit_count += 1
	summary.pitches = float(summary.pitches) + float(outcomes.size())
	summary.saved_hits = float(summary.saved_hits) + float(saved_hit_count)

	var struck_out := false
	var walked := false
	var holds_batter := (
		resolved_opponent == Content.ALIEN_EXHIBITION_INDEX
		and genetic_rebirths <= 0
		and int(unsaved_hit_counts[Content.GRAND_SLAM_INDEX]) > 0
	)
	var story_taunt := ""
	var primary_outcome := Content.STRIKE_INDEX
	var resolved_downtime := 0.0
	if unsaved_hit_count > 0:
		for outcome in Content.HIT_OUTCOME_COUNT:
			if int(unsaved_hit_counts[outcome]) > 0:
				primary_outcome = outcome
				break
		if holds_batter:
			# Xylophax is not a normal plate appearance. He stays put, resets the
			# count, and turns every impossible Grand Slam into visible HELP progress.
			plate_strikes = 0
			plate_balls = 0
			batter_cooldown_remaining = 0.0
			batter_replacement_pending = false
			var exhibition_grand_slams := maxi(
				int(unsaved_hit_counts[Content.GRAND_SLAM_INDEX]),
				1
			)
			consecutive_home_runs = mini(consecutive_home_runs + exhibition_grand_slams, 20)
			var previous_grand_slams := alien_exhibition_grand_slams
			alien_exhibition_grand_slams = mini(
				alien_exhibition_grand_slams + exhibition_grand_slams,
				ALIEN_EXHIBITION_GRAND_SLAMS_REQUIRED
			)
			alien_exhibition_seconds = get_alien_exhibition_progress_ratio() * EXHIBITION_SECONDS
			story_taunt = get_alien_exhibition_taunt(alien_exhibition_grand_slams)
			if (
				previous_grand_slams < ALIEN_EXHIBITION_GRAND_SLAMS_REQUIRED
				and alien_exhibition_grand_slams >= ALIEN_EXHIBITION_GRAND_SLAMS_REQUIRED
			):
				progression_changed.emit("Something red has appeared beside the impossible exhibition.")
		else:
			plate_strikes = 0
			plate_balls = 0
			resolved_downtime = get_combined_hit_downtime(unsaved_hit_counts)
			batter_cooldown_remaining = resolved_downtime
			batter_replacement_pending = true
			consecutive_home_runs = mini(
				consecutive_home_runs
				+ int(unsaved_hit_counts[Content.GRAND_SLAM_INDEX])
				+ int(unsaved_hit_counts[1]),
				20
			)
	else:
		var foul_count := int(outcome_counts[Content.FOUL_INDEX])
		var called_strike_count := int(outcome_counts[Content.STRIKE_INDEX])
		var called_ball_count := int(outcome_counts[Content.BALL_INDEX])
		if foul_count > 0:
			plate_strikes = mini(
				plate_strikes + foul_count,
				maxi(get_strikes_required(resolved_opponent) - 1, 0)
			)
		plate_strikes += called_strike_count
		plate_balls += called_ball_count
		if called_strike_count > 0:
			primary_outcome = Content.STRIKE_INDEX
		elif called_ball_count > 0:
			primary_outcome = Content.BALL_INDEX
		elif foul_count > 0:
			primary_outcome = Content.FOUL_INDEX
		elif saved_hit_count > 0:
			for outcome in Content.HIT_OUTCOME_COUNT:
				if int(outcome_counts[outcome]) > 0:
					primary_outcome = outcome
					break
		# Called Strikes win a simultaneous count race against a walk. Any fair
		# hit already took priority above both of them.
		if plate_strikes >= get_strikes_required(resolved_opponent):
			struck_out = true
			plate_strikes = 0
			plate_balls = 0
			resolved_downtime = get_batter_downtime(Content.STRIKE_INDEX)
			batter_cooldown_remaining = resolved_downtime
			batter_replacement_pending = true
			summary.strikeouts = float(summary.strikeouts) + 1.0
			consecutive_home_runs = 0
		elif plate_balls >= get_balls_required(resolved_opponent):
			walked = true
			plate_strikes = 0
			plate_balls = 0
			resolved_downtime = get_batter_downtime(Content.BALL_INDEX)
			batter_cooldown_remaining = resolved_downtime
			batter_replacement_pending = true
			consecutive_home_runs = 0
	_record_volley_achievement_events(
		outcome_counts,
		unsaved_hit_counts,
		saved_hit_count,
		struck_out,
		resolved_opponent,
		opening_plate_balls
	)
	var call_lines := _build_volley_call_lines(
		outcome_counts,
		unsaved_hit_counts,
		struck_out,
		walked
	)
	var call_text_parts: Array[String] = []
	for line in call_lines:
		call_text_parts.append(str(line.text))
	var call_text := " • ".join(call_text_parts)
	summary.visual_outcome = primary_outcome
	summary.visual_strikeout = struck_out
	summary.visual_saved = saved_hit_count > 0 and unsaved_hit_count == 0
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
		for outcome in outcomes:
			frustration_events.append({"outcome": outcome, "strikeout": false})
		if struck_out:
			frustration_events.append({"outcome": Content.STRIKE_INDEX, "strikeout": true})
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
			"outcome": primary_outcome,
			"outcomes": outcomes,
			"saved_flags": normalized_saved_flags,
			"outcome_counts": outcome_counts,
			"call_lines": call_lines,
			"call_text": call_text,
			"strikeout": struck_out,
			"walk": walked,
			"saved": summary.visual_saved,
			"xp": summary.visual_xp,
			"strike_count": plate_strikes,
			"plate_ball_count": plate_balls,
			"strike_requirement": get_strikes_required(),
			"ball_requirement": get_balls_required(),
			"opponent_index": resolved_opponent,
			"distance_index": resolved_distance,
			"ball_count": outcomes.size(),
			"opponent_bat_count": get_opponent_bat_count(resolved_opponent),
			"batter_downtime": resolved_downtime,
				"holds_batter": holds_batter,
				"story_taunt": story_taunt,
			"alien_exhibition_grand_slams": alien_exhibition_grand_slams,
			})

func _increment_achievement_event(id: String, amount := 1.0) -> void:
	achievement_event_totals[id] = minf(
		float(achievement_event_totals.get(id, 0.0)) + maxf(amount, 0.0),
		MAX_NUMBER
	)

func _record_volley_achievement_events(
	outcome_counts: Array[int],
	unsaved_hit_counts: Array[int],
	saved_hit_count: int,
	struck_out: bool,
	resolved_opponent: int,
	opening_plate_balls: int
) -> void:
	var volley_size := 0
	var distinct_outcomes := 0
	for count in outcome_counts:
		volley_size += maxi(int(count), 0)
		if int(count) > 0:
			distinct_outcomes += 1
	var called_strikes := int(outcome_counts[Content.STRIKE_INDEX])
	var called_balls := int(outcome_counts[Content.BALL_INDEX])
	var unsaved_hits := 0
	var distinct_unsaved_hits := 0
	for count in unsaved_hit_counts:
		unsaved_hits += maxi(int(count), 0)
		if int(count) > 0:
			distinct_unsaved_hits += 1
	if volley_size > get_opponent_bat_count(resolved_opponent):
		_increment_achievement_event("bat_overload")
	if called_strikes >= 2:
		_increment_achievement_event("double_strike_volley")
	if called_strikes >= 3:
		_increment_achievement_event("triple_strike_volley")
	if called_strikes >= 1000:
		_increment_achievement_event("thousand_strike_volley")
	if called_strikes > 0 and unsaved_hits > 0:
		_increment_achievement_event("hit_and_strike_volley")
	if called_strikes > 0 and int(unsaved_hit_counts[Content.GRAND_SLAM_INDEX]) > 0:
		_increment_achievement_event("grand_slam_and_strike")
	if int(unsaved_hit_counts[4]) >= 3:
		_increment_achievement_event("triple_single_volley")
	if distinct_unsaved_hits >= 2:
		_increment_achievement_event("mixed_hit_combo")
	if called_strikes > 0 and saved_hit_count > 0:
		_increment_achievement_event("saved_hit_and_strike")
	if saved_hit_count >= 8:
		_increment_achievement_event("eight_saved_hits_volley")
	if distinct_outcomes >= 4:
		_increment_achievement_event("rainbow_volley")
	if distinct_outcomes >= Content.OUTCOME_NAMES.size():
		_increment_achievement_event("all_outcome_volley")
	if not struck_out:
		return
	if volley_size > 1:
		_increment_achievement_event("multi_ball_strikeout")
	if opening_plate_balls + called_balls >= get_balls_required(resolved_opponent):
		_increment_achievement_event("simultaneous_walk_strikeout")
	if resolved_opponent == 0 and genetic_rebirths > 0:
		_increment_achievement_event("post_rebirth_toddler_strikeout")
		if get_arm_count() >= 2.0:
			_increment_achievement_event("multi_arm_toddler_strikeout")
		if get_arm_count() >= 8.0:
			_increment_achievement_event("eight_arm_toddler_strikeout")
	if resolved_opponent == Content.HUMAN_FINAL_INDEX and genetic_rebirths > 0:
		_increment_achievement_event("posthuman_human_champion_strikeout")
	if (
		resolved_opponent == 33
		and volley_size > get_opponent_bat_count(resolved_opponent)
	):
		_increment_achievement_event("fourfold_overwhelmed")
	if (
		resolved_opponent == Content.FINAL_BOSS_INDEX
		and volley_size > get_opponent_bat_count(resolved_opponent)
	):
		_increment_achievement_event("octathulhu_overwhelmed")

func _resolve_aggregate_time(
	seconds: float,
	summary: Dictionary,
	stochastic: bool,
	story_witnessed := true
) -> void:
	var metrics := get_at_bat_metrics()
	var alien_story_hold := (
		is_alien_exhibition_blocked()
		and not genetic_offer_unlocked
		and story_witnessed
	)
	lifetime_max_pitch_speed_fps = maxf(
		lifetime_max_pitch_speed_fps,
		get_representative_pitch_speed()
	)
	lifetime_max_distance_index = maxi(lifetime_max_distance_index, selected_distance_index)
	var cycle_seconds := maxf(
		(
			get_automatic_timer_seconds(get_pitch_cooldown_seconds())
			+ get_automatic_timer_seconds(get_resolved_flight_seconds())
		)
		if alien_story_hold
		else float(metrics.cycle_seconds),
		0.000001
	)
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
			+ active_pitches * float(probabilities[index]) * get_outcome_frustration_points(index)
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
	if alien_story_hold:
		var witnessed_grand_slams := mini(
			int(floor(active_volleys)),
			ALIEN_EXHIBITION_GRAND_SLAMS_REQUIRED - alien_exhibition_grand_slams
		)
		alien_exhibition_grand_slams += maxi(witnessed_grand_slams, 0)
		alien_exhibition_seconds = get_alien_exhibition_progress_ratio() * EXHIBITION_SECONDS
		plate_strikes = 0
		plate_balls = 0
		batter_cooldown_remaining = 0.0
		batter_replacement_pending = false
		_clear_pitch_cycle()
	else:
		plate_strikes = int(floor(active_pitches * (
			float(probabilities[Content.STRIKE_INDEX])
				+ float(probabilities[Content.FOUL_INDEX]) * 0.5
		))) % maxi(requirement, 1)
		plate_balls = int(floor(
			active_pitches * float(probabilities[Content.BALL_INDEX])
		)) % maxi(get_balls_required(), 1)
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

func _apply_resolution(summary: Dictionary, should_emit: bool, reward_multiplier := 1.0) -> void:
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
	var base_score := minf(strikeouts * get_strikeout_base_points(reward_opponent), MAX_NUMBER)
	var called_strikes := maxf(float(counts[Content.STRIKE_INDEX]), 0.0)
	# A normal completed count is worth the same mastery it was before, but its
	# value now arrives one called Strike at a time. Reduced post-human counts
	# preserve the old per-strikeout progression benefit of count compression.
	var mastery_per_strike := (
		get_strikeout_base_points(reward_opponent)
		/ float(maxi(get_strikes_required(reward_opponent), 1))
	)
	var raw_mastery_gained := minf(
		called_strikes * mastery_per_strike * get_mastery_multiplier(),
		MAX_NUMBER
	)
	var mastery_gained := minf(raw_mastery_gained * maxf(reward_multiplier, 0.0), MAX_NUMBER)
	var raw_earned_xp := minf(base_score * get_xp_multiplier(reward_opponent), MAX_NUMBER)
	var earned_xp := minf(raw_earned_xp * maxf(reward_multiplier, 0.0), MAX_NUMBER)
	summary.base_score = base_score
	summary.raw_mastery_gained = raw_mastery_gained
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
	_resolve_strikeout_loot(strikeouts, float(summary.elapsed_seconds), summary, reward_opponent)
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

func _resolve_strikeout_loot(
	strikeouts: float,
	elapsed_seconds: float,
	summary: Dictionary,
	opponent_index: int = current_opponent
) -> void:
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

	var reward_opponent := clampi(opponent_index, 0, opponents.size() - 1)
	if first_career_drop and reward_opponent == 0:
		var first_item := _generate_loot_item(reward_opponent, 0, 0)
		first_item.name = "Little Timmy's Oversized Cap"
		_store_generated_loot(first_item, summary)
		successes -= 1
	if successes <= 0:
		return
	if successes <= LOOT_EXACT_ROLL_LIMIT:
		for _drop in successes:
			_store_generated_loot(_generate_loot_item(reward_opponent), summary)
	else:
		_generate_bulk_loot(successes, reward_opponent, summary)

func _roll_loot_success_count(opportunities: int, guarantee_first: bool) -> int:
	var remaining := maxi(opportunities, 0)
	var successes := 0
	if guarantee_first and remaining > 0:
		successes += 1
		remaining -= 1
		loot_dry_streak = 0
	if remaining <= LOOT_EXACT_ROLL_LIMIT:
		var drop_chance := get_loot_drop_chance()
		for _roll in remaining:
			var guaranteed := loot_dry_streak >= LOOT_PITY_ROLLS - 1
			if guaranteed or rng.randf() < drop_chance:
				successes += 1
				loot_dry_streak = 0
			else:
				loot_dry_streak += 1
		return successes

	# Truncated geometric expectation for a 12% roll with a guarantee on roll 10.
	# Bulk offline simulation samples around that exact long-run cadence instead
	# of looping once for every eligible eldritch strikeout.
	var drop_chance := get_loot_drop_chance()
	var miss_chance := 1.0 - drop_chance
	var expected_cycle := (1.0 - pow(miss_chance, LOOT_PITY_ROLLS)) / drop_chance
	var mean_successes := float(remaining) / expected_cycle
	var deviation := sqrt(maxf(mean_successes * 0.45, 1.0))
	var bulk_successes := clampi(int(round(rng.randfn(mean_successes, deviation))), 0, remaining)
	successes += bulk_successes
	loot_dry_streak = rng.randi_range(0, LOOT_PITY_ROLLS - 1)
	return successes

func get_loot_drop_chance() -> float:
	var rank := maxi(int(training_levels.get("loot_training", 0)), 0)
	return 1.0 - (1.0 - LOOT_DROP_CHANCE) * pow(LOOT_REMAINING_PER_RANK, float(rank))

func _generate_bulk_loot(successes: int, opponent_index: int, summary: Dictionary) -> void:
	var generated := 0
	var prefiltered_scrap := 0.0
	var sources := get_opponent_drop_sources(opponent_index)
	if sources.is_empty():
		return
	var total_weight := 0.0
	for source in sources:
		total_weight += _opponent_drop_source_weight(source, opponent_index)
	var cumulative_exact := 0.0
	var cumulative_assigned := 0
	for source_index in sources.size():
		var source: Dictionary = sources[source_index]
		var source_weight := _opponent_drop_source_weight(source, opponent_index)
		cumulative_exact += float(successes) * source_weight / maxf(total_weight, 0.000001)
		var target_assigned := (
			successes
			if source_index == sources.size() - 1
			else int(floor(cumulative_exact))
		)
		var drops_for_source := maxi(target_assigned - cumulative_assigned, 0)
		cumulative_assigned = target_assigned
		if drops_for_source <= 0:
			continue
		var slot_id := str(source.get("id", ""))
		var slot_index := _loot_slot_index_by_id(slot_id)
		var rarity_index := clampi(int(source.get("rarity", 0)), 0, Content.LOOT_RARITIES.size() - 1)
		var count_to_generate := mini(drops_for_source, LOOT_ITEMS_PER_SLOT)
		lifetime_max_loot_rarity = maxi(lifetime_max_loot_rarity, rarity_index)
		for _candidate in count_to_generate:
			_store_generated_loot(
				_generate_loot_item(opponent_index, slot_index, rarity_index),
				summary
			)
		generated += count_to_generate
		var discarded_for_source := drops_for_source - count_to_generate
		prefiltered_scrap += float(discarded_for_source) * get_loot_scrap_value_for_level(
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

func _loot_slot_index_by_id(slot_id: String) -> int:
	for index in Content.LOOT_SLOTS.size():
		if str(Content.LOOT_SLOTS[index].id) == slot_id:
			return index
	return 0

func _generate_loot_item(opponent_index: int, forced_slot := -1, forced_rarity := -1) -> Dictionary:
	var available_slots := _available_loot_slot_indices(opponent_index)
	if available_slots.is_empty():
		available_slots.append(0)
	var drop_source := {}
	if forced_slot < 0 or forced_rarity < 0:
		drop_source = _sample_opponent_drop_source(opponent_index)
	var slot_index: int
	var bounded_forced_slot := clampi(forced_slot, 0, Content.LOOT_SLOTS.size() - 1)
	if forced_slot >= 0 and bounded_forced_slot in available_slots:
		slot_index = bounded_forced_slot
	elif not drop_source.is_empty():
		slot_index = _loot_slot_index_by_id(str(drop_source.get("id", "hat")))
	else:
		slot_index = available_slots[rng.randi_range(0, available_slots.size() - 1)]
	var rarity_index := (
		clampi(forced_rarity, 0, Content.LOOT_RARITIES.size() - 1)
		if forced_rarity >= 0
		else clampi(int(drop_source.get("rarity", 0)), 0, Content.LOOT_RARITIES.size() - 1)
	)
	if drop_source.is_empty():
		var forced_slot_id := str(Content.LOOT_SLOTS[slot_index].id)
		for source in get_opponent_drop_sources(opponent_index):
			if str(source.get("id", "")) == forced_slot_id and int(source.get("rarity", -1)) == rarity_index:
				drop_source = source
				break
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
	var family_rank := int(rarity.get("family_rank", rarity_index))
	var hue := fmod(float(slot_index) / float(Content.LOOT_SLOTS.size()) + float(rarity_index) * 0.055 + rng.randf_range(-0.025, 0.025), 1.0)
	if hue < 0.0:
		hue += 1.0
	var visual_color := Color.from_hsv(
		hue,
		clampf(0.40 + float(family_rank) * 0.10, 0.0, 0.92),
		clampf(0.82 + float(family_rank) * 0.035, 0.0, 1.0)
	)
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
		"source_name": str(drop_source.get("name", "")),
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
	var family_rank := int(rarity.get("family_rank", rarity_index))
	if rarity_index == 0:
		return base_name
	var prefixes: Array = Content.LOOT_PREFIXES[rarity_index]
	var prefix := str(prefixes[rng.randi_range(0, prefixes.size() - 1)])
	var suffix_stat: String = selected_stats.back()
	var suffix_options: Array = Content.LOOT_SUFFIXES[suffix_stat]
	var suffix := str(suffix_options[rng.randi_range(0, suffix_options.size() - 1)])
	if family_rank <= 1:
		return "%s %s" % [prefix, base_name]
	if family_rank >= 4:
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
			lines.append("%s %s" % [definition.name, format_rating(value, true)])
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
	return "Speed ×%.3f • Recovery ×%.3f • Quality %s • XP ×%.3f • Mastery ×%.3f • Distance threat ×%.3f" % [
		1.0 + float(bonuses.speed_bonus),
		1.0 + float(bonuses.rate_bonus),
		format_rating(float(bonuses.quality_bonus), true),
		1.0 + float(bonuses.xp_bonus),
		1.0 + float(bonuses.mastery_bonus),
		1.0 / (1.0 + float(bonuses.distance_bonus)),
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

func get_opponent_bat_count(opponent_index: int = current_opponent) -> int:
	var bounded := clampi(opponent_index, 0, Content.OPPONENT_BAT_COUNTS.size() - 1)
	return maxi(int(Content.OPPONENT_BAT_COUNTS[bounded]), 1)

func _apply_bat_overload_penalty(
	base_probabilities: Array[float],
	ball_index: int,
	opponent_index: int = current_opponent
) -> Array[float]:
	var result: Array[float] = base_probabilities.duplicate()
	var uncovered_depth := ball_index - get_opponent_bat_count(opponent_index) + 1
	if uncovered_depth <= 0:
		return result
	var contact_multiplier := pow(
		BAT_OVERLOAD_CONTACT_REMAINING,
		float(uncovered_depth)
	)
	var removed_contact := 0.0
	for outcome in Content.HIT_OUTCOME_COUNT:
		var original := float(result[outcome])
		result[outcome] = original * contact_multiplier
		removed_contact += original - float(result[outcome])
	var original_foul := float(result[Content.FOUL_INDEX])
	result[Content.FOUL_INDEX] = original_foul * contact_multiplier
	removed_contact += original_foul - float(result[Content.FOUL_INDEX])
	result[Content.STRIKE_INDEX] = float(result[Content.STRIKE_INDEX]) + removed_contact
	return result

func get_outcome_probabilities_for_volley_ball(
	pitch_id: String,
	pitch_speed_fps: float,
	ball_index: int,
	opponent_index: int = current_opponent,
	distance_index: int = -1
) -> Array[float]:
	return _apply_bat_overload_penalty(
		get_outcome_probabilities_for_pitch(
			pitch_id,
			pitch_speed_fps,
			opponent_index,
			distance_index
		),
		maxi(ball_index, 0),
		opponent_index
	)

func _sample_pending_volley_interactions(opponent_index: int) -> void:
	pending_volley_outcomes.clear()
	pending_volley_saved_flags.clear()
	for ball_index in maxi(pending_volley_size, 1):
		var outcome := _sample_outcome(get_outcome_probabilities_for_volley_ball(
			pending_volley_pitch_id,
			pending_volley_speed_fps,
			ball_index,
			opponent_index,
			pending_volley_distance_index
		))
		var saved := (
			outcome < Content.HIT_OUTCOME_COUNT
			and rng.randf() < get_hit_save_chance(outcome, opponent_index)
		)
		pending_volley_outcomes.append(outcome)
		pending_volley_saved_flags.append(saved)
	pending_volley_outcome = (
		pending_volley_outcomes[0]
		if not pending_volley_outcomes.is_empty()
		else Content.STRIKE_INDEX
	)
	pending_volley_saved = (
		pending_volley_saved_flags[0]
		if not pending_volley_saved_flags.is_empty()
		else false
	)

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
	var rank := maxi(int(training_levels.get("pitch_calling", 0)), 0)
	return (
		1.0 + log(1.0 + float(rank)) * CALLING_LOG_BONUS
	) * get_body_growth_effect_multiplier("calling")

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
	# Ordinary human mechanics should never become a secretly solved matchup from
	# raw repeatable stats alone. Adaptation can keep lifting this ceiling, but a
	# fresh human opponent always retains a visible chance to foul, take a Ball,
	# or make weak contact. Post-human baseball deliberately removes this guard.
	if opponent_index <= Content.HUMAN_FINAL_INDEX:
		var adaptation := maxf(
			get_opponent_mastery_quality_bonus(opponent_index)
			+ get_frustration_quality_bonus(),
			0.0
		)
		var strike_cap := 0.64 + 0.30 * (1.0 - exp(-adaptation / 1.25))
		var excess := maxf(float(result[Content.STRIKE_INDEX]) - strike_cap, 0.0)
		if excess > 0.0:
			result[Content.STRIKE_INDEX] = strike_cap
			result[Content.FOUL_INDEX] = float(result[Content.FOUL_INDEX]) + excess * 0.45
			result[Content.BALL_INDEX] = float(result[Content.BALL_INDEX]) + excess * 0.35
			result[4] = float(result[4]) + excess * 0.20
		# A badly underprepared human matchup may be miserable, but it is never a
		# fake choice with a rounding-error chance to advance. Preserve the punishing
		# contact distribution while moving only enough fair contact into called
		# Strikes to maintain an honest one-percent floor. Post-human opponents have
		# no such mercy.
		var strike_deficit := maxf(
			HUMAN_CALLED_STRIKE_FLOOR - float(result[Content.STRIKE_INDEX]),
			0.0
		)
		if strike_deficit > 0.0:
			var fair_contact := 0.0
			for hit_index in Content.HIT_OUTCOME_COUNT:
				fair_contact += float(result[hit_index])
			var retained_contact_ratio := maxf(
				(fair_contact - strike_deficit) / maxf(fair_contact, 0.000001),
				0.0
			)
			for hit_index in Content.HIT_OUTCOME_COUNT:
				result[hit_index] = float(result[hit_index]) * retained_contact_ratio
			result[Content.STRIKE_INDEX] = HUMAN_CALLED_STRIKE_FLOOR
	return result

func _get_covered_ball_outcome_probabilities(opponent_index: int) -> Array[float]:
	var result: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	for entry in get_pitch_selection_entries():
		var pitch_id := str(entry.id)
		var pitch_speed := get_representative_pitch_speed(pitch_id)
		var pitch_probabilities := get_outcome_probabilities_for_pitch(
			pitch_id,
			pitch_speed,
			opponent_index,
			selected_distance_index
		)
		for index in result.size():
			result[index] += float(pitch_probabilities[index]) * float(entry.probability)
	return result

func get_outcome_probabilities(opponent_index: int = current_opponent) -> Array[float]:
	var result: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	var volley_size := maxi(get_volley_size(), 1)
	var covered_probabilities := _get_covered_ball_outcome_probabilities(opponent_index)
	for ball_index in volley_size:
		var ball_probabilities := _apply_bat_overload_penalty(
			covered_probabilities,
			ball_index,
			opponent_index
		)
		for index in result.size():
			result[index] += float(ball_probabilities[index]) / float(volley_size)
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
	var training_multiplier := 1.0 + (
		float(maxi(int(training_levels.get("frustration_training", 0)), 0))
		* FRUSTRATION_TRAINING_PER_RANK
	)
	return FRUSTRATION_QUALITY_PER_DOUBLING * training_multiplier * log(1.0 + intervals) / log(2.0)

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
	var rank := maxi(int(training_levels.get("turnover", 0)), 0)
	return LINEUP_MIN_SECONDS + (
		BASE_BATTER_TURNOVER_SECONDS - LINEUP_MIN_SECONDS
	) * pow(LINEUP_REMAINING_PER_RANK, float(rank))

func get_base_batter_turnover_seconds() -> float:
	return (
		get_trained_lineup_seconds()
		* get_milestone_effect_multiplier("lineup")
		* get_body_growth_effect_multiplier("lineup")
		/ get_time_multiplier()
	)

func get_hit_delay_factor() -> float:
	var rank := maxi(int(training_levels.get("hit_recovery", 0)), 0)
	return (
		HIT_DELAY_MIN_FACTOR
		+ (1.0 - HIT_DELAY_MIN_FACTOR) * pow(HIT_DELAY_REMAINING_PER_RANK, float(rank))
	) * get_milestone_effect_multiplier("hit_delay") * get_body_growth_effect_multiplier("hit_delay")

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
	var strike_requirement := get_strikes_required(opponent_index)
	var ball_requirement := get_balls_required(opponent_index)
	var volley_size := maxi(get_volley_size(), 1)
	var covered_probabilities := _get_covered_ball_outcome_probabilities(opponent_index)
	var per_ball_probabilities: Array[Array] = []
	var probabilities: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	var save_chances: Array[float] = []
	for outcome in Content.HIT_OUTCOME_COUNT:
		save_chances.append(get_hit_save_chance(outcome, opponent_index))
	var expected_saved_hits_per_volley := 0.0
	var no_unsaved_hit_probability := 1.0
	# Primary hit calls use baseball severity order. The difference between two
	# adjacent "none of these hit types occurred" products is the probability
	# that this outcome is the strongest unsaved contact in the volley.
	var no_stronger_hit_products: Array[float] = []
	no_stronger_hit_products.resize(Content.HIT_OUTCOME_COUNT + 1)
	no_stronger_hit_products.fill(1.0)
	var expected_hit_bonus_per_volley := 0.0
	for ball_index in volley_size:
		var ball_probabilities := _apply_bat_overload_penalty(
			covered_probabilities,
			ball_index,
			opponent_index
		)
		per_ball_probabilities.append(ball_probabilities)
		for outcome in probabilities.size():
			probabilities[outcome] += float(ball_probabilities[outcome]) / float(volley_size)
		var cumulative_unsaved_hit := 0.0
		for outcome in Content.HIT_OUTCOME_COUNT:
			var unsaved_probability := (
				float(ball_probabilities[outcome])
				* (1.0 - float(save_chances[outcome]))
			)
			var saved_probability := float(ball_probabilities[outcome]) - unsaved_probability
			expected_saved_hits_per_volley += saved_probability
			expected_hit_bonus_per_volley += (
				unsaved_probability * get_outcome_turnover_bonus(outcome)
			)
			cumulative_unsaved_hit += unsaved_probability
			no_stronger_hit_products[outcome + 1] *= maxf(1.0 - cumulative_unsaved_hit, 0.0)
		no_unsaved_hit_probability *= maxf(1.0 - cumulative_unsaved_hit, 0.0)

	var cache_parts: Array[String] = [
		str(opponent_index), str(strike_requirement), str(ball_requirement),
		str(volley_size), str(get_opponent_bat_count(opponent_index)),
		str(get_automatic_timer_seconds(get_pitch_cooldown_seconds())),
		str(get_automatic_timer_seconds(get_resolved_flight_seconds())),
	]
	for value in covered_probabilities:
		cache_parts.append(str(float(value)))
	for value in save_chances:
		cache_parts.append(str(float(value)))
	for outcome in Content.OUTCOME_NAMES.size():
		cache_parts.append(str(get_automatic_timer_seconds(get_batter_downtime(outcome))))
	var cache_key := "|".join(cache_parts)
	if str(at_bat_metrics_cache.get("key", "")) == cache_key:
		return (at_bat_metrics_cache.get("value", {}) as Dictionary).duplicate(true)

	var hit_terminal_probabilities: Array[float] = []
	hit_terminal_probabilities.resize(Content.HIT_OUTCOME_COUNT)
	hit_terminal_probabilities.fill(0.0)
	for outcome in Content.HIT_OUTCOME_COUNT:
		hit_terminal_probabilities[outcome] = maxf(
			float(no_stronger_hit_products[outcome])
				- float(no_stronger_hit_products[outcome + 1]),
			0.0
		)

	# Conditional on no unsaved fair hit, reduce a whole volley to the only count
	# information that matters: total Foul/Strike advances, whether at least one
	# called Strike exists (Fouls alone cannot strike out), and Balls. This stays
	# compact even for the final 2,048-ball salvos.
	var increment_distribution := {"0:0:0": 1.0}
	if no_unsaved_hit_probability > 1.0e-300:
		for ball_probabilities in per_ball_probabilities:
			var unsaved_hit_probability := 0.0
			var saved_hit_probability := 0.0
			for outcome in Content.HIT_OUTCOME_COUNT:
				var outcome_probability := float(ball_probabilities[outcome])
				var saved_probability := outcome_probability * float(save_chances[outcome])
				saved_hit_probability += saved_probability
				unsaved_hit_probability += outcome_probability - saved_probability
			var non_hit_probability := maxf(1.0 - unsaved_hit_probability, 0.0)
			if non_hit_probability <= 1.0e-15:
				increment_distribution.clear()
				break
			var no_op_probability := saved_hit_probability / non_hit_probability
			var foul_probability := float(ball_probabilities[Content.FOUL_INDEX]) / non_hit_probability
			var ball_probability := float(ball_probabilities[Content.BALL_INDEX]) / non_hit_probability
			var strike_probability := float(ball_probabilities[Content.STRIKE_INDEX]) / non_hit_probability
			var next_distribution := {}
			for key_value in increment_distribution:
				var key := str(key_value)
				var parts := key.split(":")
				var total_advances := int(parts[0])
				var has_called_strike := int(parts[1])
				var ball_advances := int(parts[2])
				var state_probability := float(increment_distribution[key])
				_add_probability(next_distribution, key, state_probability * no_op_probability)
				_add_probability(
					next_distribution,
					"%d:%d:%d" % [mini(total_advances + 1, strike_requirement), has_called_strike, ball_advances],
					state_probability * foul_probability
				)
				_add_probability(
					next_distribution,
					"%d:1:%d" % [mini(total_advances + 1, strike_requirement), ball_advances],
					state_probability * strike_probability
				)
				_add_probability(
					next_distribution,
					"%d:%d:%d" % [total_advances, has_called_strike, mini(ball_advances + 1, ball_requirement)],
					state_probability * ball_probability
				)
			increment_distribution = next_distribution

	# Exact absorbing count model. Every transient state is (strikes, Balls), and
	# every transition represents one independently rolled simultaneous volley.
	var states := {}
	for strike_count in range(strike_requirement - 1, -1, -1):
		for ball_count in range(ball_requirement - 1, -1, -1):
			var absorption: Array[float] = []
			absorption.resize(Content.OUTCOME_NAMES.size())
			absorption.fill(0.0)
			for outcome in Content.HIT_OUTCOME_COUNT:
				absorption[outcome] = hit_terminal_probabilities[outcome]
			var self_probability := 0.0
			var expected_volleys_numerator := 1.0
			for increment_key_value in increment_distribution:
				var increment_key := str(increment_key_value)
				var parts := increment_key.split(":")
				var total_advances := int(parts[0])
				var has_called_strike := int(parts[1]) > 0
				var ball_advances := int(parts[2])
				var transition_probability := (
					float(increment_distribution[increment_key])
					* no_unsaved_hit_probability
				)
				if transition_probability <= 1.0e-18:
					continue
				var strikes_after := (
					strike_count + total_advances
					if has_called_strike
					else mini(strike_count + total_advances, strike_requirement - 1)
				)
				var balls_after := ball_count + ball_advances
				if has_called_strike and strikes_after >= strike_requirement:
					absorption[Content.STRIKE_INDEX] += transition_probability
					continue
				if balls_after >= ball_requirement:
					absorption[Content.BALL_INDEX] += transition_probability
					continue
				strikes_after = mini(strikes_after, strike_requirement - 1)
				balls_after = mini(balls_after, ball_requirement - 1)
				if strikes_after == strike_count and balls_after == ball_count:
					self_probability += transition_probability
					continue
				var next_state: Dictionary = states["%d:%d" % [strikes_after, balls_after]]
				expected_volleys_numerator += transition_probability * float(next_state.expected_volleys)
				for outcome in absorption.size():
					absorption[outcome] += transition_probability * float((next_state.absorption as Array)[outcome])

			var escape_probability := 1.0 - self_probability
			if escape_probability <= 1.0e-15:
				states["%d:%d" % [strike_count, ball_count]] = {
					"absorption": absorption,
					"expected_volleys": MAX_NUMBER,
				}
				continue
			for outcome in absorption.size():
				absorption[outcome] = clampf(absorption[outcome] / escape_probability, 0.0, 1.0)
			states["%d:%d" % [strike_count, ball_count]] = {
				"absorption": absorption,
				"expected_volleys": minf(expected_volleys_numerator / escape_probability, MAX_NUMBER),
			}

	var opening_state: Dictionary = states.get("0:0", {})
	if opening_state.is_empty() or float(opening_state.get("expected_volleys", MAX_NUMBER)) >= MAX_NUMBER:
		var impossible_terminal_probabilities: Array[float] = []
		impossible_terminal_probabilities.resize(Content.OUTCOME_NAMES.size())
		impossible_terminal_probabilities.fill(0.0)
		var impossible_result := {
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
		at_bat_metrics_cache = {"key": cache_key, "value": impossible_result.duplicate(true)}
		return impossible_result
	var terminal_probabilities: Array = opening_state.absorption
	var strikeout_probability := float(terminal_probabilities[Content.STRIKE_INDEX])
	var terminal_hit_probability := 0.0
	for outcome in Content.HIT_OUTCOME_COUNT:
		terminal_hit_probability += float(terminal_probabilities[outcome])
	var active_volleys := float(opening_state.expected_volleys)
	var active_pitches := minf(active_volleys * float(volley_size), MAX_NUMBER)
	var saved_hit_probability := clampf(
		expected_saved_hits_per_volley / float(volley_size),
		0.0,
		1.0
	)
	var conditional_hit_downtime := 0.0
	var per_volley_hit_probability := 1.0 - no_unsaved_hit_probability
	if per_volley_hit_probability > 1.0e-15:
		conditional_hit_downtime = (
			get_base_batter_turnover_seconds()
			+ expected_hit_bonus_per_volley / per_volley_hit_probability
		)
	var expected_downtime := (
		terminal_hit_probability
			* get_automatic_timer_seconds(conditional_hit_downtime)
		+ strikeout_probability
			* get_automatic_timer_seconds(get_batter_downtime(Content.STRIKE_INDEX))
		+ float(terminal_probabilities[Content.BALL_INDEX])
			* get_automatic_timer_seconds(get_batter_downtime(Content.BALL_INDEX))
	)
	var active_volley_seconds := (
		get_automatic_timer_seconds(get_pitch_cooldown_seconds())
		+ get_automatic_timer_seconds(get_resolved_flight_seconds())
	)
	var cycle_seconds := active_volleys * active_volley_seconds + expected_downtime
	var result := {
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
	at_bat_metrics_cache = {"key": cache_key, "value": result.duplicate(true)}
	return result

static func _add_probability(target: Dictionary, key: String, amount: float) -> void:
	if amount <= 1.0e-18:
		return
	target[key] = float(target.get(key, 0.0)) + amount

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

func get_body_growth_stage() -> Dictionary:
	var index := clampi(body_growth_level, 0, Content.BODY_GROWTH_STAGES.size() - 1)
	return Content.BODY_GROWTH_STAGES[index]

func _get_body_modifier_adjectives() -> Array[String]:
	# Keep the composed body name funny but readable. Later purchases replace the
	# weaker adjective from their own lane rather than producing a twelve-word UI.
	var adjectives: Array[String] = []
	if has_body_modifier("steroids"):
		adjectives.append("Roided-Out")
	if has_body_modifier("advanced_strength"):
		adjectives.append("Very Buff")
	elif has_body_modifier("pushup_phase"):
		adjectives.append("Buff")
	elif has_body_modifier("playground_conditioning"):
		adjectives.append("Sturdy")
	if has_body_modifier("altitude_cardio"):
		adjectives.append("Very Toned")
	elif has_body_modifier("running_laps"):
		adjectives.append("Toned")
	elif has_body_modifier("cardio_basics"):
		adjectives.append("Spry")
	if adjectives.size() < 3 and has_body_modifier("suspicious_vitamins"):
		adjectives.append("Suspiciously Vital")
	elif adjectives.size() < 3 and has_body_modifier("creatine"):
		adjectives.append("Creatine-Fueled")
	elif adjectives.size() < 3 and has_body_modifier("professional_rehab"):
		adjectives.append("Rebuilt")
	return adjectives

func get_body_growth_name() -> String:
	var stage := get_body_growth_stage()
	var base_name := str(stage.get("body_name", stage.get("name", "Regular Ol’ Toddler")))
	var adjectives := _get_body_modifier_adjectives()
	if adjectives.is_empty():
		return base_name
	var prefix := ""
	if base_name.begins_with("Regular Ol’ "):
		prefix = "Regular Ol’ "
		base_name = base_name.trim_prefix(prefix)
	return "%s%s %s" % [prefix, ", ".join(adjectives), base_name]

func get_body_growth_noun() -> String:
	var noun := str(get_body_growth_stage().get("noun", "pitcher"))
	var adjectives := _get_body_modifier_adjectives()
	if adjectives.is_empty():
		return noun
	var lowered: Array[String] = []
	for adjective in adjectives:
		lowered.append(adjective.to_lower())
	return "%s %s" % [", ".join(lowered), noun]

func get_body_growth_visual_size() -> float:
	return minf(
		float(get_body_growth_stage().get("visual_size", 1.0))
		* get_body_modifier_effect_multiplier("visual_size"),
		1.48
	)

func get_body_modifier_effect_multiplier(effect_id: String) -> float:
	var multiplier := 1.0
	for id in purchased_body_modifiers:
		var definition := Content.body_modifier_by_id(id)
		if definition.is_empty():
			continue
		var effects: Dictionary = definition.get("effects", {})
		multiplier *= float(effects.get(effect_id, 1.0))
	return minf(multiplier, MAX_NUMBER)

func get_body_growth_effect_multiplier(effect_id: String) -> float:
	var multiplier := 1.0
	for index in range(1, clampi(body_growth_level, 0, Content.BODY_GROWTH_STAGES.size() - 1) + 1):
		var effects: Dictionary = Content.BODY_GROWTH_STAGES[index].get("effects", {})
		multiplier *= float(effects.get(effect_id, 1.0))
	return minf(multiplier * get_body_modifier_effect_multiplier(effect_id), MAX_NUMBER)

func get_body_growth_quality_bonus() -> float:
	var bonus := 0.0
	for index in range(1, clampi(body_growth_level, 0, Content.BODY_GROWTH_STAGES.size() - 1) + 1):
		var effects: Dictionary = Content.BODY_GROWTH_STAGES[index].get("effects", {})
		bonus += float(effects.get("quality", 0.0))
	for id in purchased_body_modifiers:
		var definition := Content.body_modifier_by_id(id)
		bonus += float((definition.get("effects", {}) as Dictionary).get("quality_add", 0.0))
	return bonus

func get_body_growth_cost(id: String) -> float:
	var definition := Content.body_growth_by_id(id)
	if definition.is_empty():
		return MAX_NUMBER
	return rounded_cost(float(definition.get("cost", 0.0)))

func can_buy_body_growth(id: String) -> bool:
	var definition := Content.body_growth_by_id(id)
	if definition.is_empty():
		return false
	var stage_index := Content.BODY_GROWTH_STAGES.find(definition)
	return (
		stage_index == body_growth_level + 1
		and highest_unlocked >= int(definition.get("required_level", 0))
		and xp >= get_body_growth_cost(id)
	)

func buy_body_growth(id: String) -> bool:
	if not can_buy_body_growth(id):
		return false
	var definition := Content.body_growth_by_id(id)
	xp -= get_body_growth_cost(id)
	body_growth_level += 1
	progression_changed.emit("GREW UP: %s" % get_body_growth_name())
	check_achievements()
	return true

func has_body_modifier(id: String) -> bool:
	return id in purchased_body_modifiers

func get_body_modifier_cost(id: String) -> float:
	var definition := Content.body_modifier_by_id(id)
	if definition.is_empty():
		return MAX_NUMBER
	return rounded_cost(float(definition.get("cost", 0.0)))

func get_body_modifier_unmet_requirements(definition: Dictionary) -> Array[String]:
	var requirements: Array[String] = []
	var required_level := int(definition.get("required_level", 0))
	if highest_unlocked < required_level:
		requirements.append("REACH LEVEL %d" % (required_level + 1))
	var required_speed := float(definition.get("required_speed_fps", 0.0))
	if required_speed > 0.0 and get_velocity_fps() + 0.000001 < required_speed:
		requirements.append("THROW AT %s" % format_speed(required_speed).to_upper())
	return requirements

func can_buy_body_modifier(id: String) -> bool:
	var definition := Content.body_modifier_by_id(id)
	return (
		not definition.is_empty()
		and not has_body_modifier(id)
		and get_body_modifier_unmet_requirements(definition).is_empty()
		and xp >= get_body_modifier_cost(id)
	)

func buy_body_modifier(id: String) -> bool:
	if not can_buy_body_modifier(id):
		return false
	var definition := Content.body_modifier_by_id(id)
	xp -= get_body_modifier_cost(id)
	purchased_body_modifiers.append(id)
	progression_changed.emit("BODY MODIFIED: %s." % str(definition.name))
	check_achievements()
	return true

static func _asymptotic_upper_limit(value: float, limit: float, soft_cap_start: float) -> float:
	# Preserve the authored stat exactly below the knee, then bend smoothly into
	# its physical ceiling. The value and first derivative are continuous at the
	# knee, and no finite purchase is rejected as a hard maximum.
	if value <= soft_cap_start or limit <= soft_cap_start:
		return minf(value, limit)
	var remaining_span := limit - soft_cap_start
	return limit - remaining_span * exp(-(value - soft_cap_start) / remaining_span)

func get_body_velocity_fps() -> float:
	var velocity := get_trained_base_velocity_fps()
	if has_divine_blessing("let_there_be_fastballs"):
		velocity *= 10.0
	velocity *= get_body_growth_effect_multiplier("speed")
	velocity *= get_milestone_effect_multiplier("speed")
	velocity *= pow(1.80, int(genetic_levels.fast_twitch_everything))
	velocity *= pow(12.0, int(eldritch_levels.velocity_without_distance))
	var body_limit := get_velocity_cap_fps()
	return _asymptotic_upper_limit(
		velocity,
		body_limit,
		body_limit * VELOCITY_SOFT_CAP_START_FRACTION
	)

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
	return get_human_velocity_cap_fps()

func get_human_velocity_cap_fps() -> float:
	var development_index := clampi(
		highest_unlocked,
		0,
		HUMAN_VELOCITY_CAP_MPH_BY_LEVEL.size() - 1
	)
	return float(HUMAN_VELOCITY_CAP_MPH_BY_LEVEL[development_index]) / 0.681818

func get_velocity_stage_name() -> String:
	if eldritch_ascensions > 0:
		return "ELDRITCH LIMIT • 1c"
	if genetic_rebirths > 0:
		return "GENETIC LIMIT • MACH 12"
	return "HUMAN DEVELOPMENT LIMIT • %s MPH" % format_number(
		get_human_velocity_cap_fps() * 0.681818,
		1
	)

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
	# Every purchased arm can immediately throw its own real ball. Eldritch
	# geometry later makes room for cloned and time-layered sources beyond the
	# pitcher's personal arm count without turning recovery into phantom balls.
	if genetic_rebirths <= 0:
		return 1
	var capacity := int(round(get_arm_count()))
	if eldritch_ascensions > 0:
		capacity *= int(pow(4.0, clampi(int(eldritch_levels.non_euclidean_bullpen), 0, 4)))
	return maxi(capacity, 1)

func get_volley_size() -> int:
	return mini(get_throwing_source_count(), get_simultaneous_ball_cap())

func get_pitcher_size_multiplier() -> float:
	# Visual growth is intentionally saturating: every kind of real pitching
	# strength contributes, but no build can become an unreadable field-sized
	# circle. The fresh body is ×1; the complete cosmic build approaches ×2.
	# Human bodies are authored by age and physical development only—Command,
	# payload, and a quick wind-up do not make a person six feet wide.
	var growth_floor := clampf(get_body_growth_visual_size(), 1.0, 2.0)
	if genetic_rebirths <= 0:
		return growth_floor
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
	return growth_floor + (2.0 - growth_floor) * (1.0 - exp(-strength / 70.0))

func get_recovery_rate() -> float:
	var recovery_rank := maxi(int(training_levels.recovery), 0)
	var rate := RECOVERY_TRAINING_LIMIT - (
		RECOVERY_TRAINING_LIMIT - BASE_RECOVERY_RATE
	) * pow(RECOVERY_REMAINING_PER_RANK, float(recovery_rank))
	rate *= get_body_growth_effect_multiplier("recovery")
	rate *= get_milestone_effect_multiplier("recovery")
	if genetic_rebirths <= 0:
		rate = _asymptotic_upper_limit(
			rate,
			HUMAN_BODY_RECOVERY_LIMIT,
			HUMAN_RECOVERY_SOFT_CAP_START
		)
	rate *= pow(
		ELASTIC_UCL_RECOVERY_PER_RANK,
		maxi(int(genetic_levels.elastic_ucl_colony), 0)
	)
	rate *= pow(
		ALTERNATING_LOBES_RECOVERY_PER_RANK,
		maxi(int(genetic_levels.parallel_pitching_lobes), 0)
	)
	rate *= pow(
		TIME_COMPRESSION_RECOVERY_PER_RANK,
		maxi(int(eldritch_levels.time_compression), 0)
	)
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
	potency *= get_body_growth_effect_multiplier("payload")
	potency *= 1.0 + float(maxi(int(training_levels.get("payload_training", 0)), 0)) * PAYLOAD_TRAINING_PER_RANK
	potency *= pow(2.50, int(genetic_levels.ball_gland))
	potency *= pow(10.0, int(eldritch_levels.causal_seams))
	if has_divine_blessing("loaves_and_baseballs"):
		potency *= 25.0
	return minf(potency, MAX_NUMBER)

func get_mastery_multiplier() -> float:
	var multiplier := get_milestone_effect_multiplier("mastery")
	multiplier *= get_body_growth_effect_multiplier("mastery")
	multiplier *= 1.0 + float(maxi(int(training_levels.get("mastery_training", 0)), 0)) * MASTERY_TRAINING_PER_RANK
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

func get_xp_multiplier(opponent_index: int = current_opponent, _distance_index: int = -1) -> float:
	var bounded_index := clampi(opponent_index, 0, opponents.size() - 1)
	var equipment := get_equipment_bonuses()
	return minf(
		MAX_NUMBER,
		float(opponents[bounded_index].reward)
		* get_prestige_income_multiplier()
		* get_pitch_potency()
		* get_opponent_farm_xp_multiplier(bounded_index)
		* get_body_growth_effect_multiplier("xp")
		* (1.0 + float(maxi(int(training_levels.get("xp_training", 0)), 0)) * XP_TRAINING_PER_RANK)
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
		"body_growth":
			return float(body_growth_level)
		"pitches_owned":
			return float(unlocked_pitches.size())
		"illegal_pitch":
			for pitch_id in unlocked_pitches:
				if bool(Content.pitch_by_id(str(pitch_id)).get("illegal", false)):
					return 1.0
			return 0.0
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
		"human_champion_toddler":
			return 1.0 if human_league_completed_as_toddler else 0.0
		"event":
			return float(achievement_event_totals.get(str(key), 0.0))
		"human_final_strikeout_certainty":
			return (
				1.0
				if genetic_rebirths > 0
				and current_opponent == Content.HUMAN_FINAL_INDEX
				and get_strikeout_chance_per_at_bat(Content.HUMAN_FINAL_INDEX) >= 0.99
				else 0.0
			)
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
		"training", "body_growth", "genetic_upgrade", "eldritch_upgrade":
			progress_text = "Rank %d / %d" % [int(current), int(threshold)]
		"genetic_offer", "eldritch_offer", "relic_owned", "illegal_pitch", "cosmos", "human_champion_toddler", "no_hitter", "event", "human_final_strikeout_certainty":
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
	# Keep the literal 1 ft/s opening at its established 0.70 velocity score, then
	# reward every doubling above it. This makes a believable fastball a real
	# alternative to pumping Command forever without making the first toddler an
	# automatic strikeout or letting repeatable Speed scale linearly into space.
	var velocity_score := 0.70 + maxf(
		log(maxf(pitch_speed_fps, 1.0)) / log(2.0),
		0.0
	) * 0.90
	var command_score := float(training_levels.command) * QUALITY_PER_RANK
	var diversity_bonus := maxf(float(unlocked_pitches.size() - 1) * 0.08, 0.0)
	var trained_quality := (
		velocity_score + command_score + diversity_bonus + get_body_growth_quality_bonus()
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

func get_player_power_rating(opponent_index: int = current_opponent) -> float:
	# Power is a readable synthesis, not a second combat system. The same quality,
	# adaptation, speed, recovery, payload, and turnover values that already drive
	# baseball determine this number.
	var matchup_quality := (
		get_pitch_quality()
		+ get_opponent_mastery_quality_bonus(opponent_index)
		+ get_frustration_quality_bonus()
	)
	var support := (
		log(1.0 + get_velocity_fps()) / log(2.0) * 0.16
		+ log(1.0 + get_pitch_potency()) / log(2.0) * 0.22
		+ log(1.0 + get_recovery_rate() / BASE_RECOVERY_RATE) / log(2.0) * 0.18
		+ log(1.0 + BASE_BATTER_TURNOVER_SECONDS / maxf(get_base_batter_turnover_seconds(), 0.001)) / log(2.0) * 0.12
	)
	# Keep display-only Power below the shared numeric ceiling so scripted bosses
	# can still visibly exceed even malformed or very old overpowered saves.
	return minf(MAX_NUMBER / 1000000.0, 100.0 * pow(2.0, maxf(matchup_quality + support, -8.0) / 2.0))

func get_opponent_power_rating(opponent_index: int = current_opponent) -> float:
	var bounded := clampi(opponent_index, 0, opponents.size() - 1)
	var resistance := get_effective_opponent_difficulty(bounded)
	var rule_pressure := (
		log(float(get_base_strikes_required(bounded)) / 3.0 + 1.0) / log(2.0) * 0.24
		+ log(5.0 / float(get_balls_required(bounded)) + 1.0) / log(2.0) * 0.12
	)
	var rating := minf(
		MAX_NUMBER,
		100.0 * pow(2.0, maxf(resistance + rule_pressure, -8.0) / 2.0)
	)
	if bounded == Content.ALIEN_EXHIBITION_INDEX and genetic_rebirths <= 0:
		# The opening alien is a scripted, literally unwinnable mismatch. Its Power
		# bar should communicate that joke instead of understating it with the normal
		# league formula—especially for inherited saves with absurd human stats.
		rating = maxf(rating, minf(get_player_power_rating(bounded) * 1000.0, MAX_NUMBER))
	return rating

func get_current_opponent() -> Dictionary:
	return opponents[current_opponent]

func get_current_distance() -> Dictionary:
	return Content.DISTANCE_TIERS[clampi(selected_distance_index, 0, Content.DISTANCE_TIERS.size() - 1)]

func get_prescribed_distance_index(opponent_index: int = current_opponent) -> int:
	var bounded_opponent := clampi(opponent_index, 0, opponents.size() - 1)
	var result := 0
	for index in Content.DISTANCE_TIERS.size():
		if bounded_opponent >= int(Content.DISTANCE_TIERS[index].required_level):
			result = index
	return result

func get_max_distance_index() -> int:
	return get_prescribed_distance_index(highest_unlocked)

func _sync_distance_to_current_opponent() -> bool:
	var prescribed := get_prescribed_distance_index(current_opponent)
	if prescribed == selected_distance_index:
		return false
	selected_distance_index = prescribed
	lifetime_max_distance_index = maxi(lifetime_max_distance_index, prescribed)
	return true

func set_distance_index(_index: int) -> bool:
	# Range is campaign-authored rather than a permanent "move closer for more
	# income" optimization. Retain this method as a safe compatibility shim for
	# older callers and imported saves, but always restore the level's range.
	return _sync_distance_to_current_opponent()

func get_distance_xp_multiplier_for_index(_distance_index: int = -1) -> float:
	# Kept as a source/save compatibility shim for older UI and tests. Range is
	# now prescribed by the level and never changes XP.
	return 1.0

func get_distance_xp_multiplier() -> float:
	return get_distance_xp_multiplier_for_index(selected_distance_index)

func get_distance_penalty_multiplier() -> float:
	var rank := maxi(int(training_levels.get("distance_control", 0)), 0)
	var trained_factor := DISTANCE_MIN_FACTOR + (
		1.0 - DISTANCE_MIN_FACTOR
	) * pow(DISTANCE_REMAINING_PER_RANK, float(rank))
	var equipment_control := maxf(float(get_equipment_bonuses().distance_bonus), 0.0)
	return maxf(trained_factor / (1.0 + equipment_control), 0.0)

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

func get_ball_drag_per_foot(opponent_index: int = current_opponent) -> float:
	# Human baseball happens in air. The untouched opening Wiffle Ball stays at
	# the title's literal 1 ft/s for 3 ft; purchased lightweight shells visibly
	# bleed speed, while regulation leather approaches real-baseball retention.
	# Alien and eldritch fields are effectively vacuum, so drag becomes zero there.
	if opponent_index > Content.HUMAN_FINAL_INDEX:
		return 0.0
	var shell_count := purchased_ball_upgrades.size()
	var base_drag := 0.0
	if shell_count <= 0:
		return 0.0
	if shell_count == 1:
		base_drag = 0.012
	elif shell_count == 2:
		base_drag = 0.009
	elif shell_count == 3:
		base_drag = 0.005
	else:
		var leather_progress := clampf(float(shell_count - 4) / 12.0, 0.0, 1.0)
		base_drag = lerpf(0.0019, 0.00075, leather_progress)
	var training_factor := pow(
		DRAG_TRAINING_FACTOR_PER_RANK,
		float(maxi(int(training_levels.get("drag_training", 0)), 0))
	)
	return base_drag * training_factor * get_body_growth_effect_multiplier("drag")

func get_plate_speed_for_release(
	release_speed_fps: float,
	distance_index: int = -1,
	drag_per_foot: float = -1.0
) -> float:
	var drag := get_ball_drag_per_foot() if drag_per_foot < 0.0 else maxf(drag_per_foot, 0.0)
	var distance := get_pitch_distance_feet_for_index(distance_index)
	return maxf(release_speed_fps, 0.000001) * exp(-drag * distance)

func get_representative_plate_speed() -> float:
	return get_plate_speed_for_release(
		get_representative_pitch_speed(),
		selected_distance_index,
		get_ball_drag_per_foot()
	)

func get_pitch_drag_loss_fraction() -> float:
	var release_speed := maxf(get_representative_pitch_speed(), 0.000001)
	return clampf(1.0 - get_representative_plate_speed() / release_speed, 0.0, 1.0)

func get_physical_flight_seconds() -> float:
	return get_physical_flight_seconds_for_speed(
		get_representative_pitch_speed(),
		selected_distance_index,
		get_ball_drag_per_foot()
	)

func get_physical_flight_seconds_for_speed(
	release_speed_fps: float,
	distance_index: int = -1,
	drag_per_foot: float = -1.0
) -> float:
	var speed := maxf(release_speed_fps, 0.000001)
	var distance := get_pitch_distance_feet_for_index(distance_index)
	var drag := get_ball_drag_per_foot() if drag_per_foot < 0.0 else maxf(drag_per_foot, 0.0)
	if drag <= 0.000000001:
		return distance / speed
	# With v(x)=v0*e^(-kx), integrating dx/v(x) gives this exact travel time.
	# Clamp the exponent for numerical safety; non-human astronomical play has
	# zero drag and therefore never enters this branch.
	var exponent := minf(drag * distance, 40.0)
	return (exp(exponent) - 1.0) / (drag * speed)

func get_resolved_flight_seconds() -> float:
	return get_resolved_flight_seconds_for_speed(get_representative_pitch_speed(), selected_distance_index)

func get_resolved_flight_seconds_for_speed(
	pitch_speed_fps: float,
	distance_index: int = -1,
	drag_per_foot: float = -1.0
) -> float:
	# Opening physics are literal: three feet at one foot/second takes three
	# seconds. Astronomical distances compress logarithmically so galaxy baseball
	# remains playable, while every released volley still owns a real flight phase.
	var physical_seconds := get_physical_flight_seconds_for_speed(
		pitch_speed_fps,
		distance_index,
		drag_per_foot
	)
	if physical_seconds <= 3.0:
		return clampf(physical_seconds, 0.16, 3.0)
	return minf(3.0 + log(physical_seconds / 3.0) * 0.35, 5.0)

func set_current_opponent(index: int) -> bool:
	if index < 0 or index > highest_unlocked or index == current_opponent:
		return false
	current_opponent = index
	_sync_distance_to_current_opponent()
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
		_sample_pending_volley_interactions(current_opponent)
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
	if highest_unlocked == Content.HUMAN_FINAL_INDEX and body_growth_level == 0:
		human_league_completed_as_toddler = true
	highest_unlocked += 1
	var message := "UNLOCKED: %s" % opponents[highest_unlocked].name
	if auto_advance_enabled and can_auto_advance_to(highest_unlocked):
		current_opponent = highest_unlocked
		_sync_distance_to_current_opponent()
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
	# The distribution is the batter's actual visible wardrobe. Excess mastery
	# gently favors its better pieces, but cannot roll a tier the batter is not
	# wearing or change the slot attached to that tier.
	var result: Array[float] = []
	result.resize(Content.LOOT_RARITIES.size())
	result.fill(0.0)
	var sources := get_opponent_drop_sources(index)
	var total_weight := 0.0
	for source in sources:
		total_weight += _opponent_drop_source_weight(source, index)
	if total_weight <= 0.0:
		result[0] = 1.0
		return result
	for source in sources:
		var rarity_index := clampi(int(source.get("rarity", 0)), 0, result.size() - 1)
		result[rarity_index] += _opponent_drop_source_weight(source, index) / total_weight
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
	var rank := maxi(int(training_levels.get("offline_efficiency", 0)), 0)
	return OFFLINE_XP_EFFICIENCY_LIMIT - (
		OFFLINE_XP_EFFICIENCY_LIMIT - BASE_OFFLINE_XP_EFFICIENCY
	) * pow(OFFLINE_REMAINING_PER_RANK, float(rank))

func _get_velocity_pre_cap_multiplier() -> float:
	var multiplier := 10.0 if has_divine_blessing("let_there_be_fastballs") else 1.0
	multiplier *= get_body_growth_effect_multiplier("speed")
	multiplier *= get_milestone_effect_multiplier("speed")
	multiplier *= pow(1.80, int(genetic_levels.fast_twitch_everything))
	multiplier *= pow(12.0, int(eldritch_levels.velocity_without_distance))
	return minf(multiplier, MAX_NUMBER)

func _get_velocity_training_delta_log10_for_rank(rank: int) -> float:
	# Subtracting two numbers that are both one floating-point step below a body
	# limit eventually rounds to zero. Work in log space on the exact exponential
	# tail so the UI can still report the real (vanishingly small) next gain.
	var multiplier := maxf(_get_velocity_pre_cap_multiplier(), 0.000001)
	var body_limit := maxf(get_velocity_cap_fps(), 0.000001)
	var knee := body_limit * VELOCITY_SOFT_CAP_START_FRACTION
	var span := maxf(body_limit - knee, 0.000001)
	var raw_before := (
		BASE_VELOCITY_FPS + float(maxi(rank, 0)) * VELOCITY_PER_RANK_FPS
	) * multiplier
	var raw_step := VELOCITY_PER_RANK_FPS * multiplier
	var gear_multiplier := maxf(1.0 + float(get_equipment_bonuses().speed_bonus), 0.000001)
	if raw_before < knee:
		var mapped_before := minf(raw_before, body_limit)
		var mapped_after := _asymptotic_upper_limit(
			raw_before + raw_step,
			body_limit,
			knee
		)
		var direct_delta := maxf((mapped_after - mapped_before) * gear_multiplier, 0.0)
		if direct_delta > 0.0:
			return log(direct_delta) / log(10.0)
	# Above the knee, delta = span*e^-distance*(1-e^-step). Keeping the
	# multiplication in logarithms avoids underflow even on fantastical old saves.
	var one_minus_step_tail := 1.0 - exp(-raw_step / span)
	if one_minus_step_tail <= 0.0:
		return -MAX_NUMBER
	var natural_log_delta := (
		log(span)
		- maxf(raw_before - knee, 0.0) / span
		+ log(one_minus_step_tail)
		+ log(gear_multiplier)
	)
	return natural_log_delta / log(10.0)

func _get_training_effect_value(id: String) -> float:
	# These are the same effective values shown in CURRENT STATS. Keeping the
	# mapping here lets every client describe a rank by its real, current impact
	# instead of repeating an asymptotic target that may be many ranks away.
	match id:
		"velocity":
			return get_velocity_fps()
		"command":
			return get_pitch_quality()
		"field_hustle":
			return get_field_tap_fraction()
		"recovery":
			return get_recovery_rate()
		"offline_efficiency":
			return get_offline_xp_efficiency()
		"distance_control":
			return get_distance_penalty_multiplier()
		"turnover":
			return get_base_batter_turnover_seconds()
		"hit_recovery":
			return get_hit_delay_factor()
		"pitch_calling":
			return get_pitch_calling_bias()
		"payload_training":
			return get_pitch_potency()
		"mastery_training":
			return get_mastery_multiplier()
		"drag_training":
			return get_pitch_drag_loss_fraction()
		"xp_training":
			return (
				get_body_growth_effect_multiplier("xp")
				* (1.0 + float(maxi(int(training_levels.get("xp_training", 0)), 0)) * XP_TRAINING_PER_RANK)
			)
		"loot_training":
			return get_loot_drop_chance()
		"frustration_training":
			# Frustration itself resets on a strikeout. The stable trainable stat is
			# the Quality granted by each logarithmic doubling, not today's meter.
			return FRUSTRATION_QUALITY_PER_DOUBLING * (
				1.0
				+ float(maxi(int(training_levels.get("frustration_training", 0)), 0))
				* FRUSTRATION_TRAINING_PER_RANK
			)
	return 0.0

func _get_training_next_rank_effect_at_rank(id: String, current_rank: int) -> Dictionary:
	if not training_levels.has(id):
		return {}
	var stored_rank = training_levels[id]
	current_rank = maxi(current_rank, 0)
	training_levels[id] = current_rank
	var before := _get_training_effect_value(id)
	training_levels[id] = current_rank + 1
	var after := _get_training_effect_value(id)
	training_levels[id] = stored_rank
	var delta := after - before
	var result := {
		"rank": current_rank + 1,
		"before": before,
		"after": after,
		"delta": delta,
	}
	if id == "velocity":
		var delta_log10 := _get_velocity_training_delta_log10_for_rank(current_rank)
		result["delta_log10"] = delta_log10
		if delta_log10 > -300.0 and delta_log10 < 280.0:
			result.delta = pow(10.0, delta_log10)
		elif delta_log10 <= -300.0:
			# The display uses delta_log10; keeping delta at zero honestly reflects
			# that this change is below the runtime's representable precision.
			result.delta = 0.0
	return result

func get_training_next_rank_effect(id: String) -> Dictionary:
	if not training_levels.has(id):
		return {}
	var current_rank := maxi(int(training_levels[id]), 0)
	var result := _get_training_next_rank_effect_at_rank(id, current_rank)
	var fresh := _get_training_next_rank_effect_at_rank(id, 0)
	var efficiency := 1.0
	if id == "velocity" and result.has("delta_log10") and fresh.has("delta_log10"):
		efficiency = clampf(pow(
			10.0,
			clampf(float(result.delta_log10) - float(fresh.delta_log10), -300.0, 0.0)
		), 0.0, 1.0)
	else:
		var fresh_delta := absf(float(fresh.get("delta", 0.0)))
		if fresh_delta > 0.0:
			efficiency = clampf(absf(float(result.get("delta", 0.0))) / fresh_delta, 0.0, 1.0)
	result["marginal_efficiency"] = efficiency
	return result

func get_training_marginal_efficiency(id: String) -> float:
	return float(get_training_next_rank_effect(id).get("marginal_efficiency", 1.0))

func get_training_cost(id: String) -> float:
	var definition := Content.training_by_id(id)
	if definition.is_empty():
		return MAX_NUMBER
	if highest_unlocked < int(definition.get("required_level", 0)):
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
	if required_distance >= 0:
		var bounded := clampi(required_distance, 0, Content.DISTANCE_TIERS.size() - 1)
		var range_level := int(Content.DISTANCE_TIERS[bounded].required_level)
		if highest_unlocked < range_level:
			requirements.append(
				"REACH LEVEL %d FOR %s RANGE"
				% [range_level + 1, str(Content.DISTANCE_TIERS[bounded].label).to_upper()]
			)
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
	var premium_multiplier := (
		PREMIUM_HUMAN_MILESTONE_COST_MULTIPLIER
		if id in PREMIUM_HUMAN_MILESTONE_IDS
		else 1.0
	)
	return rounded_cost(
		float(definition.cost)
		* MILESTONE_COST_MULTIPLIER
		* premium_multiplier
	)

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

func get_human_auto_advance_capacity() -> int:
	return clampi(int(genetic_levels.get("migratory_instinct", 0)), 0, Content.HUMAN_FINAL_INDEX)

func get_alien_auto_advance_capacity() -> int:
	return clampi(
		int(eldritch_levels.get("interstellar_itinerary", 0)),
		0,
		Content.ALIEN_FINAL_INDEX - Content.ALIEN_EXHIBITION_INDEX + 1
	)

func has_auto_advance_capacity() -> bool:
	return get_human_auto_advance_capacity() > 0 or get_alien_auto_advance_capacity() > 0

func can_auto_advance_to(opponent_index: int) -> bool:
	# Genetic rank N covers destination human opponent N. Eldritch rank one
	# starts with the alien exhibition, allowing a repeat universe to cross the
	# human/alien boundary only after that second prestige layer is earned.
	if opponent_index >= 1 and opponent_index <= Content.HUMAN_FINAL_INDEX:
		return opponent_index <= get_human_auto_advance_capacity()
	if opponent_index >= Content.ALIEN_EXHIBITION_INDEX and opponent_index <= Content.ALIEN_FINAL_INDEX:
		return (
			opponent_index - Content.ALIEN_EXHIBITION_INDEX + 1
			<= get_alien_auto_advance_capacity()
		)
	return false

func get_auto_advance_capacity_text() -> String:
	return "Human %d/%d  •  Alien %d/%d" % [
		get_human_auto_advance_capacity(),
		Content.HUMAN_FINAL_INDEX,
		get_alien_auto_advance_capacity(),
		Content.ALIEN_FINAL_INDEX - Content.ALIEN_EXHIBITION_INDEX + 1,
	]

func has_divine_blessing(id: String) -> bool:
	return id in divine_blessings

func get_genetic_cost(id: String) -> int:
	var definition := Content.genetic_by_id(id)
	if definition.is_empty():
		return 2147483647
	var rank := int(genetic_levels.get(id, 0))
	if definition.has("max_level") and rank >= int(definition.max_level):
		return 2147483647
	var raw_cost := float(definition.base_cost) * pow(float(definition.growth), rank)
	if not is_finite(raw_cost) or raw_cost >= 2147483647.0:
		return 2147483647
	return maxi(int(round(raw_cost)), 1)

func can_buy_genetic(id: String) -> bool:
	var definition := Content.genetic_by_id(id)
	return (
		genetic_offer_unlocked
		and not definition.is_empty()
		and (
			not definition.has("max_level")
			or int(genetic_levels.get(id, 0)) < int(definition.max_level)
		)
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
	if definition.has("max_level") and rank >= int(definition.max_level):
		return 2147483647
	var raw_cost := float(definition.base_cost) * pow(float(definition.growth), rank)
	if not is_finite(raw_cost) or raw_cost >= 2147483647.0:
		return 2147483647
	return maxi(int(round(raw_cost)), 1)

func can_buy_eldritch(id: String) -> bool:
	var definition := Content.eldritch_by_id(id)
	return (
		eldritch_offer_unlocked
		and not definition.is_empty()
		and (
			not definition.has("max_level")
			or int(eldritch_levels.get(id, 0)) < int(definition.max_level)
		)
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
		"payload_training": 0,
		"mastery_training": 0,
		"drag_training": 0,
		"xp_training": 0,
		"loot_training": 0,
		"frustration_training": 0,
	}
	scale_levels = {}
	unlocked_pitches = ["dead_fish"]
	purchased_ball_upgrades.clear()
	purchased_milestones.clear()
	purchased_body_modifiers.clear()
	_invalidate_milestone_effect_cache()
	current_opponent = 0
	highest_unlocked = 0
	body_growth_level = 0
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
	field_tap_burst_rate = 0.0
	automatic_field_tap_credit = 0.0
	cosmos_conquered = false
	auto_advance_enabled = auto_advance_enabled and has_auto_advance_capacity()
	auto_farm_enabled = auto_farm_enabled and has_genetic_upgrade("predator_scouting")
	_sanitize_automation_settings()
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
	alien_exhibition_grand_slams = ALIEN_EXHIBITION_GRAND_SLAMS_REQUIRED
	alien_arrival_seen = true
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
	_reset_auto_training_stats()
	genetic_offer_unlocked = true
	alien_exhibition_seconds = EXHIBITION_SECONDS
	alien_exhibition_grand_slams = ALIEN_EXHIBITION_GRAND_SLAMS_REQUIRED
	alien_arrival_seen = true
	eldritch_offer_unlocked = true
	eldritch_exhibition_seconds = EXHIBITION_SECONDS
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
	_reset_auto_training_stats()
	_reset_auto_catalog_settings()
	# God resets the universe, not the pitcher's memory of the two mandatory
	# prestige offers. Repeat campaigns therefore pause at each known exhibition
	# instead of forcing another minute of scripted Grand Slams.
	genetic_offer_unlocked = true
	eldritch_offer_unlocked = true
	alien_exhibition_seconds = EXHIBITION_SECONDS
	alien_exhibition_grand_slams = ALIEN_EXHIBITION_GRAND_SLAMS_REQUIRED
	alien_arrival_seen = true
	eldritch_exhibition_seconds = EXHIBITION_SECONDS
	auto_advance_enabled = false
	auto_farm_enabled = false
	_clear_all_loot_for_reset()
	_reset_body_progress()
	no_hitter_attempt_valid = true
	var reward_name := "Another Halo" if id == "halo" else str(Content.divine_by_id(id).name)
	progression_changed.emit(
		"GOD PRESTIGE: Thanks for saving the universe. God restored it so you can do it all again, and granted %s." % reward_name
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
		"catalog_hide_purchased", "achievement_event_totals",
	]
	for field in dictionary_fields:
		if data.has(field) and typeof(data[field]) != TYPE_DICTIONARY:
			return {"ok": false, "message": "The save contains an invalid %s section." % str(field)}
	var array_fields := [
		"loot_items", "divine_blessings", "unlocked_pitches", "purchased_ball_upgrades",
		"purchased_milestones", "purchased_body_modifiers", "opponent_mastery", "result_totals", "unlocked_achievements",
		"pending_volley_outcomes", "pending_volley_saved_flags",
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
		"lifetime_automatic_field_taps": lifetime_automatic_field_taps,
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
		"pending_volley_outcomes": pending_volley_outcomes,
		"pending_volley_saved_flags": pending_volley_saved_flags,
		"pending_volley_outcome": pending_volley_outcome,
		"pending_volley_saved": pending_volley_saved,
		"pending_volley_pitch_id": pending_volley_pitch_id,
		"pending_volley_speed_fps": pending_volley_speed_fps,
		"pending_volley_plate_speed_fps": pending_volley_plate_speed_fps,
		"pending_volley_drag_per_foot": pending_volley_drag_per_foot,
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
		"alien_exhibition_grand_slams": alien_exhibition_grand_slams,
		"alien_arrival_seen": alien_arrival_seen,
		"eldritch_exhibition_seconds": eldritch_exhibition_seconds,
		"cosmos_conquered": cosmos_conquered,
		"body_growth_level": body_growth_level,
		"purchased_body_modifiers": purchased_body_modifiers,
		"human_league_completed_as_toddler": human_league_completed_as_toddler,
		"no_hitter_attempt_valid": no_hitter_attempt_valid,
		"auto_advance_enabled": auto_advance_enabled,
		"auto_train_enabled": auto_train_enabled,
		"auto_farm_enabled": auto_farm_enabled,
		"auto_training_stats": auto_training_stats,
		"auto_catalog_settings": auto_catalog_settings,
		"training_levels": training_levels,
		"scale_levels": scale_levels,
		"genetic_levels": genetic_levels,
		"eldritch_levels": eldritch_levels,
		"divine_blessings": divine_blessings,
		"unlocked_pitches": unlocked_pitches,
		"purchased_ball_upgrades": purchased_ball_upgrades,
		"purchased_milestones": purchased_milestones,
		"unlocked_achievements": unlocked_achievements,
		"achievement_event_totals": achievement_event_totals,
		"catalog_hide_purchased": catalog_hide_purchased,
		"achievement_hide_achieved": achievement_hide_achieved,
		"opponent_mastery": opponent_mastery,
		"result_totals": result_totals,
	}

func apply_save_data(data: Dictionary) -> void:
	var saved_version := int(data.get("version", 0))
	# Tap fatigue is deliberately a brief input condition, not permanent progress.
	# Loading or importing a run always begins with rested fingers.
	field_tap_burst_rate = 0.0
	xp = clampf(float(data.get("xp", 0.0)), 0.0, MAX_NUMBER)
	run_xp = clampf(float(data.get("run_xp", 0.0)), 0.0, MAX_NUMBER)
	lifetime_xp = clampf(float(data.get("lifetime_xp", xp)), 0.0, MAX_NUMBER)
	lifetime_pitches = clampf(float(data.get("lifetime_pitches", 0.0)), 0.0, MAX_NUMBER)
	lifetime_field_taps = clampf(float(data.get("lifetime_field_taps", 0.0)), 0.0, MAX_NUMBER)
	lifetime_field_tap_seconds = clampf(float(data.get("lifetime_field_tap_seconds", 0.0)), 0.0, MAX_NUMBER)
	lifetime_automatic_field_taps = clampf(float(data.get("lifetime_automatic_field_taps", 0.0)), 0.0, MAX_NUMBER)
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
	if saved_version >= 18:
		var saved_body_level := int(data.get("body_growth_level", 0))
		if saved_version < 22:
			# v0.14 had six much broader age bands. Map by biological meaning,
			# not raw array index, so an established adult never becomes a teen.
			var legacy_body_map := [0, 2, 3, 5, 7, Content.BODY_GROWTH_STAGES.size() - 1]
			saved_body_level = int(legacy_body_map[clampi(saved_body_level, 0, legacy_body_map.size() - 1)])
		body_growth_level = clampi(saved_body_level, 0, Content.BODY_GROWTH_STAGES.size() - 1)
		human_league_completed_as_toddler = bool(data.get("human_league_completed_as_toddler", false))
	else:
		# Aging did not exist in older saves. Infer a sensible body from the
		# campaign level so established players do not suddenly become toddlers,
		# but never infer the secret toddler-clear achievement.
		body_growth_level = 0
		for stage_index in range(1, Content.BODY_GROWTH_STAGES.size()):
			if highest_unlocked >= int(Content.BODY_GROWTH_STAGES[stage_index].required_level):
				body_growth_level = stage_index
		human_league_completed_as_toddler = false
	plate_strikes = clampi(int(data.get("plate_strikes", 0)), 0, maxi(get_strikes_required(current_opponent) - 1, 0))
	plate_balls = clampi(int(data.get("plate_balls", 0)), 0, maxi(get_balls_required(current_opponent) - 1, 0))
	batter_cooldown_remaining = clampf(float(data.get("batter_cooldown_remaining", 0.0)), 0.0, MAX_BATTER_DOWNTIME_SECONDS)
	batter_generation = clampi(int(data.get("batter_generation", 0)), 0, 999999999)
	batter_replacement_pending = bool(data.get(
		"batter_replacement_pending",
		batter_cooldown_remaining > 0.0
	))
	_refresh_batter_variant()
	# v0.13.2 assigns the mound from the selected opponent. Old manual choices
	# remain represented by lifetime_max_distance_index, while any released pitch
	# restores its own immutable distance snapshot below.
	selected_distance_index = get_prescribed_distance_index(current_opponent)
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
	if saved_version >= 24:
		alien_exhibition_grand_slams = clampi(
			int(data.get("alien_exhibition_grand_slams", 0)),
			0,
			ALIEN_EXHIBITION_GRAND_SLAMS_REQUIRED
		)
		alien_arrival_seen = bool(data.get(
			"alien_arrival_seen",
			genetic_rebirths > 0 or lifetime_genetic_rebirths > 0
		))
	else:
		alien_exhibition_grand_slams = (
			ALIEN_EXHIBITION_GRAND_SLAMS_REQUIRED
			if genetic_offer_unlocked
			else clampi(
				int(round(
					alien_exhibition_seconds / EXHIBITION_SECONDS
					* float(ALIEN_EXHIBITION_GRAND_SLAMS_REQUIRED)
				)),
				0,
				ALIEN_EXHIBITION_GRAND_SLAMS_REQUIRED
			)
		)
		# A pre-v24 player parked at the first impossible opponent has not seen the
		# new arrival scene. Everyone who already time-traveled keeps that history.
		alien_arrival_seen = genetic_rebirths > 0 or lifetime_genetic_rebirths > 0
	alien_exhibition_seconds = get_alien_exhibition_progress_ratio() * EXHIBITION_SECONDS
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
	var saved_auto_training_stats: Dictionary = data.get("auto_training_stats", {})
	var saved_auto_catalog_settings: Dictionary = data.get("auto_catalog_settings", {})
	var saved_catalog_filters: Dictionary = data.get("catalog_hide_purchased", {})
	for catalog_id in catalog_hide_purchased.keys():
		catalog_hide_purchased[catalog_id] = bool(saved_catalog_filters.get(catalog_id, false))
	achievement_hide_achieved = bool(data.get("achievement_hide_achieved", false))

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
		var old_recovery_value := minf(BASE_RECOVERY_RATE * pow(1.06, float(old_recovery_rank)), RECOVERY_TRAINING_LIMIT - 0.000001)
		var recovery_ratio := maxf((RECOVERY_TRAINING_LIMIT - old_recovery_value) / (RECOVERY_TRAINING_LIMIT - BASE_RECOVERY_RATE), 0.000001)
		saved_training["recovery"] = maxi(int(round(log(recovery_ratio) / log(RECOVERY_REMAINING_PER_RANK))), 0)
		var old_lineup_value := maxf(BASE_BATTER_TURNOVER_SECONDS * old_turnover_factor, LINEUP_MIN_SECONDS + 0.000001)
		var lineup_ratio := maxf((old_lineup_value - LINEUP_MIN_SECONDS) / (BASE_BATTER_TURNOVER_SECONDS - LINEUP_MIN_SECONDS), 0.000001)
		saved_training["turnover"] = maxi(int(round(log(lineup_ratio) / log(LINEUP_REMAINING_PER_RANK))), 0)
		var old_hit_value := maxf(old_turnover_factor, HIT_DELAY_MIN_FACTOR + 0.000001)
		var hit_ratio := maxf((old_hit_value - HIT_DELAY_MIN_FACTOR) / (1.0 - HIT_DELAY_MIN_FACTOR), 0.000001)
		saved_training["hit_recovery"] = maxi(int(round(log(hit_ratio) / log(HIT_DELAY_REMAINING_PER_RANK))), 0)
		var old_calling_value := pow(1.35, float(old_calling_rank))
		saved_training["pitch_calling"] = maxi(int(round(exp((old_calling_value - 1.0) / CALLING_LOG_BONUS) - 1.0)), 0)
		var old_distance_value := pow(0.97, float(old_distance_rank))
		var distance_ratio := maxf((old_distance_value - DISTANCE_MIN_FACTOR) / (1.0 - DISTANCE_MIN_FACTOR), 0.000001)
		saved_training["distance_control"] = maxi(int(round(log(distance_ratio) / log(DISTANCE_REMAINING_PER_RANK))), 0)
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
		var genetic_saved_rank := maxi(int(saved_genetic.get(id, 0)), 0)
		if definition.has("max_level"):
			genetic_saved_rank = mini(genetic_saved_rank, int(definition.max_level))
		genetic_levels[id] = genetic_saved_rank
	_reset_eldritch_levels()
	var saved_eldritch: Dictionary = data.get("eldritch_levels", {})
	for id in eldritch_levels.keys():
		var definition := Content.eldritch_by_id(str(id))
		var eldritch_saved_rank := maxi(int(saved_eldritch.get(id, 0)), 0)
		if definition.has("max_level"):
			eldritch_saved_rank = mini(eldritch_saved_rank, int(definition.max_level))
		eldritch_levels[id] = eldritch_saved_rank
	if saved_version == 6:
		genetic_levels.compressed_strike_genome = clampi(int(saved_genetic.get("expanded_strike_genome", 0)), 0, 3)
		eldritch_levels.portal_outfield = clampi(int(saved_eldritch.get("impossible_count", 0)), 0, 4)
	# Auto-advance was one all-human purchase through save v20. Convert that
	# purchase into every human license so updating never removes its old value.
	if saved_version < 21 and int(genetic_levels.get("migratory_instinct", 0)) > 0:
		genetic_levels.migratory_instinct = Content.HUMAN_FINAL_INDEX
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
		var saved_pending_size := clampi(
			int(data.get("pending_volley_size", 0)),
			0,
			MAX_SAVED_VOLLEY_SIZE
		)
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
			var saved_outcomes: Array = data.get("pending_volley_outcomes", [])
			var saved_flags: Array = data.get("pending_volley_saved_flags", [])
			for ball_index in saved_pending_size:
				var ball_outcome := pending_volley_outcome
				var ball_saved := pending_volley_saved
				if saved_version >= 25 and ball_index < saved_outcomes.size():
					ball_outcome = clampi(
						int(saved_outcomes[ball_index]),
						0,
						Content.OUTCOME_NAMES.size() - 1
					)
					ball_saved = ball_index < saved_flags.size() and bool(saved_flags[ball_index])
				ball_saved = (
					ball_saved
					and ball_outcome < Content.HIT_OUTCOME_COUNT
					and ball_outcome != Content.GRAND_SLAM_INDEX
				)
				pending_volley_outcomes.append(ball_outcome)
				pending_volley_saved_flags.append(ball_saved)
			# Keep the scalar compatibility view synchronized with the first real ball.
			if not pending_volley_outcomes.is_empty():
				pending_volley_outcome = pending_volley_outcomes[0]
				pending_volley_saved = pending_volley_saved_flags[0]
			pending_volley_pitch_id = str(data.get("pending_volley_pitch_id", "dead_fish"))
			if Content.pitch_by_id(pending_volley_pitch_id).is_empty():
				pending_volley_pitch_id = "dead_fish"
			pending_volley_speed_fps = maxf(float(data.get("pending_volley_speed_fps", get_representative_pitch_speed(pending_volley_pitch_id))), 0.000001)
			pending_volley_distance_index = clampi(int(data.get("pending_volley_distance_index", selected_distance_index)), 0, Content.DISTANCE_TIERS.size() - 1)
			pending_volley_drag_per_foot = maxf(float(data.get(
				"pending_volley_drag_per_foot",
				get_ball_drag_per_foot(current_opponent)
			)), 0.0)
			pending_volley_plate_speed_fps = maxf(float(data.get(
				"pending_volley_plate_speed_fps",
				get_plate_speed_for_release(
					pending_volley_speed_fps,
					pending_volley_distance_index,
					pending_volley_drag_per_foot
				)
			)), 0.000001)
			pending_volley_opponent_index = clampi(int(data.get("pending_volley_opponent_index", current_opponent)), 0, highest_unlocked)
		else:
			pitch_credit = clampf(float(data.get("pitch_credit", 0.0)), 0.0, 0.999999)

	auto_advance_enabled = saved_auto_advance and has_auto_advance_capacity()
	auto_farm_enabled = saved_auto_farm and has_genetic_upgrade("predator_scouting")
	_reset_auto_training_stats()
	if saved_version >= 19:
		for id in AUTO_TRAINING_STAT_IDS:
			auto_training_stats[str(id)] = bool(saved_auto_training_stats.get(str(id), false))
	elif saved_auto_train and get_auto_training_license_count() > 0:
		# The old all-stat Auto-coach becomes one explicit Speed Training license.
		# Existing players keep useful automation without silently receiving eight
		# additional licenses that the new prestige economy expects them to earn.
		auto_training_stats.velocity = true
	auto_catalog_settings = _empty_auto_catalog_settings()
	if saved_version >= 19:
		for id in AUTO_CATALOG_IDS:
			auto_catalog_settings[str(id)] = bool(saved_auto_catalog_settings.get(str(id), false))
	_sanitize_automation_settings()

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

	purchased_body_modifiers.clear()
	for id in data.get("purchased_body_modifiers", []):
		if not Content.body_modifier_by_id(str(id)).is_empty() and str(id) not in purchased_body_modifiers:
			purchased_body_modifiers.append(str(id))
	# Suspicious Vitamins and Steroids lived in FACILITY through v0.14. Move
	# them into BODY without charging an existing player twice.
	if saved_version < 22:
		for legacy_id in data.get("purchased_milestones", []):
			if not Content.body_modifier_by_id(str(legacy_id)).is_empty() and str(legacy_id) not in purchased_body_modifiers:
				purchased_body_modifiers.append(str(legacy_id))
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
	achievement_event_totals.clear()
	var saved_achievement_events: Dictionary = data.get("achievement_event_totals", {})
	for event_id_value in saved_achievement_events:
		var event_id := str(event_id_value)
		if event_id.length() > 80:
			continue
		achievement_event_totals[event_id] = clampf(
			float(saved_achievement_events[event_id_value]),
			0.0,
			MAX_NUMBER
		)
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

static func format_scientific(value: float, significant_digits: int = 3) -> String:
	if is_nan(value):
		return "NaN"
	if is_inf(value) or absf(value) >= MAX_NUMBER:
		return "-1e280+" if value < 0.0 else "1e280+"
	if value == 0.0:
		return "0"
	var absolute := absf(value)
	var exponent := int(floor(log(absolute) / log(10.0)))
	var mantissa := absolute / pow(10.0, exponent)
	var decimal_places := maxi(significant_digits - 1, 0)
	var rounded_mantissa := snappedf(mantissa, pow(10.0, -decimal_places))
	if rounded_mantissa >= 10.0:
		rounded_mantissa /= 10.0
		exponent += 1
	var rendered := ("%." + str(decimal_places) + "f") % rounded_mantissa
	while "." in rendered and rendered.ends_with("0"):
		rendered = rendered.trim_suffix("0")
	rendered = rendered.trim_suffix(".")
	return "%s%se%d" % ["-" if value < 0.0 else "", rendered, exponent]

static func format_scientific_from_log10(
	log10_absolute_value: float,
	significant_digits: int = 3
) -> String:
	if is_nan(log10_absolute_value):
		return "NaN"
	if is_inf(log10_absolute_value):
		return "0" if log10_absolute_value < 0.0 else "1e280+"
	var exponent := int(floor(log10_absolute_value))
	var mantissa := pow(10.0, log10_absolute_value - float(exponent))
	var decimal_places := maxi(significant_digits - 1, 0)
	var rounded_mantissa := snappedf(mantissa, pow(10.0, -decimal_places))
	if rounded_mantissa >= 10.0:
		rounded_mantissa /= 10.0
		exponent += 1
	var rendered := ("%." + str(decimal_places) + "f") % rounded_mantissa
	while "." in rendered and rendered.ends_with("0"):
		rendered = rendered.trim_suffix("0")
	rendered = rendered.trim_suffix(".")
	return "%se%d" % [rendered, exponent]

static func format_number(value: float, decimals: int = 2) -> String:
	if is_nan(value):
		return "NaN"
	if is_inf(value) or value >= MAX_NUMBER:
		return "1e280+"
	var absolute := absf(value)
	if absolute > 0.0 and decimals > 0 and absolute < 0.5 * pow(10.0, -decimals):
		return format_scientific(value, maxi(decimals + 1, 2))
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
		if decimals <= 0:
			if round(scaled) >= 1000.0 and suffix_index < suffixes.size() - 1:
				scaled /= 1000.0
				suffix_index += 1
			return "%s%.0f%s" % ["-" if value < 0.0 else "", scaled, suffixes[suffix_index]]
		return "%s%.2f%s" % ["-" if value < 0.0 else "", scaled, suffixes[suffix_index]]
	return format_scientific(value, 1 if decimals <= 0 else 4)

static func format_rating(value: float, include_sign := false) -> String:
	var scaled := value * DISPLAY_RATING_SCALE
	var absolute := absf(scaled)
	# Ratings deliberately remain literal whole numbers through the range players
	# can comfortably read: 0.039 becomes 39 and 6 becomes 6000, not 6K. Only
	# genuinely unwieldy or sub-unit ratings switch to scientific notation.
	var rendered := "%.0f" % scaled
	if absolute > 0.0 and (absolute < 0.5 or absolute >= 1.0e7):
		rendered = format_scientific(scaled, 3)
	if include_sign and scaled > 0.0:
		return "+%s" % rendered
	return rendered

static func format_xp_total(value: float) -> String:
	# Fractions matter while the first point is being earned and whole XP remains
	# clearest before suffixes begin. Compact totals keep roughly three useful
	# digits, so spending 400K from a 2M balance is visibly reflected.
	var absolute := absf(value)
	if absolute < 1.0:
		return format_number(value, 2)
	if absolute < 1000.0:
		return "%.0f" % value
	if absolute >= MAX_NUMBER or is_inf(value):
		return "1e280+"
	var suffixes := ["K", "M", "B", "T"]
	var scaled := absolute
	var suffix_index := -1
	while scaled >= 1000.0 and suffix_index < suffixes.size() - 1:
		scaled /= 1000.0
		suffix_index += 1
	if absolute < 1.0e15:
		var decimal_places := 2 if scaled < 10.0 else (1 if scaled < 100.0 else 0)
		var rounded_scaled := snappedf(scaled, pow(10.0, -decimal_places))
		if rounded_scaled >= 1000.0 and suffix_index < suffixes.size() - 1:
			rounded_scaled /= 1000.0
			suffix_index += 1
			decimal_places = 2
		var rendered := ("%." + str(decimal_places) + "f") % rounded_scaled
		if "." in rendered:
			rendered = rendered.trim_suffix("0").trim_suffix("0").trim_suffix(".")
		return "%s%s%s" % ["-" if value < 0.0 else "", rendered, suffixes[suffix_index]]
	var exponent := int(floor(log(absolute) / log(10.0)))
	var mantissa := absolute / pow(10.0, exponent)
	var rendered_mantissa := "%.2f" % mantissa
	rendered_mantissa = rendered_mantissa.trim_suffix("0").trim_suffix("0").trim_suffix(".")
	return "%s%se%d" % ["-" if value < 0.0 else "", rendered_mantissa, exponent]

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
