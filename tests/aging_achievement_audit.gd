extends SceneTree

const Content = preload("res://scripts/content.gd")
const GameStateScript = preload("res://scripts/game_state.gd")
const RunContent = preload("res://scripts/run_content.gd")

const SAMPLE_COUNT := 1024
const AUDIT_SEED_START := 1
const LEGACY_ACHIEVEMENT_ID_TEXT := """
first_pitch
first_field_tap
field_taps_100
first_strike
first_strikeout
strikeouts_10
strikeouts_100
strikeouts_1000
strikeouts_10000
pitches_100
pitches_1000
pitches_10000
pitches_100000
first_grand_slam
home_runs_25
fouls_100
balls_100
strikes_1000
reach_level_5
reach_level_10
reach_level_15
reach_level_20
reach_level_25
human_champion_toddler
complete_human_baseball
human_speedrun
distance_6ft
distance_30ft
distance_regulation
distance_outfield
speed_2fps
speed_10fps
speed_60fps
speed_100mph
speed_human_cap
velocity_rank_1
command_rank_1
puberty
field_hustle_rank_1
recovery_rank_10
offline_rank_10
arsenal_3
arsenal_6
arsenal_9
arsenal_15
ball_upgrades_5
ball_upgrades_10
ball_upgrades_16
facilities_5
facilities_15
facilities_30
facilities_50
facilities_75
first_loot
legendary_loot
fully_equipped
genetic_offer
illegal_pitch
genetic_rebirth_1
genetic_rebirth_5
dna_10
genetic_upgrades_5
arms_2
arms_4
arms_8
volley_2
volley_4
compressed_count
saved_hits_100
auto_advance
auto_advance_human_full
auto_coach
auto_scout
auto_wardrobe
first_relic
reach_four_armed_hitter
reach_moonballer
reach_plasma_slugger
reach_alien_champion
complete_alien_baseball
alien_speedrun
upper_management
is_this_fun
first_corrupted_perk
boss_perk_selected
speed_mach_1
speed_mach_3
speed_mach_12
born_again_bully
excessive_daycare_force
eight_arm_daycare
double_strike_volley
triple_strike_volley
hit_and_strike_volley
grand_slam_and_strike
triple_single_volley
mixed_hit_combo
bat_overload
multi_ball_strikeout
umpire_conference
posthuman_bambino
solved_human_baseball
saved_hit_and_strike
fourfold_overwhelmed
eldritch_offer
eldritch_ascension_1
eldritch_ascension_3
arcana_10
clones_2
clones_8
clones_32
time_layers_8
auto_advance_alien_full
volley_16
volley_256
volley_2048
first_portal
reverse_terminator
reach_phase_hitter
reach_nine_body_collective
reach_ball_rog
reach_octathulhu
speed_of_light
cosmos_conquered
cosmic_speedrun
rainbow_volley
box_score_bingo
octathulhu_overwhelmed
thousand_strike_volley
fielding_department_infinite
divine_ascension_1
divine_blessings_2
divine_ascension_3
all_divine_blessings
divine_halo_1
divine_halo_5
extra_innings_entered
extra_innings_10
extra_innings_100
no_hitter
"""

var failures := 0

func _initialize() -> void:
	print("No Hitter — aging and achievement audit")
	_test_achievement_catalog_contract()
	_test_age_offer_contract()
	_test_event_round_trip_and_metrics()
	var two_card := _audit_probability(0)
	var three_card := _audit_probability(1)
	print("AGE AUDIT • 2 cards finale %.4f%% • before final %.4f%% • 3 cards finale %.4f%%" % [
		float(two_card.finale) * 100.0,
		float(two_card.before_final) * 100.0,
		float(three_card.finale) * 100.0,
	])
	# 1,024 fixed deterministic seeds keep normal validation comfortably below a
	# minute while enforcing the authored 85–90% target exactly.
	_expect(float(two_card.finale) >= 0.85 and float(two_card.finale) <= 0.90, "Default two-card adulthood odds must remain in the authored 85–90%% band")
	_expect(float(two_card.before_final) >= 0.70, "A full adult should be meaningfully likely before the final human batter")
	_expect(float(three_card.finale) > float(two_card.finale) + 0.03, "Expanded Draft Board must materially improve full-adult odds")
	if failures > 0:
		push_error("FAIL: %d aging/achievement audit failure(s)" % failures)
		quit(1)
	else:
		print("PASS: aging and achievement audit")
		quit(0)

func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	failures += 1
	push_error(message)

func _test_achievement_catalog_contract() -> void:
	var ids := {}
	for definition_value in Content.ACHIEVEMENTS:
		var definition: Dictionary = definition_value
		var id := str(definition.get("id", ""))
		_expect(not id.is_empty() and not ids.has(id), "Achievement IDs must be nonempty and unique: %s" % id)
		ids[id] = true
	var legacy_ids: PackedStringArray = LEGACY_ACHIEVEMENT_ID_TEXT.strip_edges().split("\n")
	_expect(legacy_ids.size() == 140, "The frozen pre-M2 achievement set must contain 140 IDs")
	for id in legacy_ids:
		_expect(ids.has(id), "M2 must preserve legacy achievement ID: %s" % id)
	_expect(Content.ACHIEVEMENTS.size() >= legacy_ids.size() + 24, "M2 must add at least 24 distinct achievements")
	for required_id in [
		"first_run_perk", "run_perks_10", "run_perks_25", "first_pitch_draft", "pitch_drafts_10",
		"little_kid", "big_kid", "preteen", "puberty", "young_adult", "regular_ol_guy",
		"adult_human_finale", "late_bloomer", "first_body_adjective", "body_adjectives_3",
		"all_body_adjectives", "suspiciously_buff_toned_toddler", "supplement_stack", "roided_toddler",
		"first_story_chapter", "story_chapters_5", "story_chapters_all", "legendary_run_perk",
		"pitch_specialist_3", "first_boss_pitch", "declined_age_card",
	]:
		_expect(ids.has(required_id), "Required M2 achievement missing: %s" % required_id)

func _new_seeded_game(seed: int, expanded_rank := 0) -> Node:
	var game = GameStateScript.new()
	game.run_seed = seed
	game.run_choice_serial = 0
	game.genetic_levels.expanded_draft_board = expanded_rank
	return game

func _first_next_age_option_index(choice: Dictionary, expected_age_order: int) -> int:
	var options: Array = choice.get("options", [])
	for index in options.size():
		var option: Dictionary = options[index]
		var definition := RunContent.perk_by_id(str(option.get("definition_id", "")))
		if int(definition.get("age_order", 0)) == expected_age_order:
			return index
	return -1

func _first_non_age_option_index(choice: Dictionary) -> int:
	var options: Array = choice.get("options", [])
	for index in options.size():
		var option: Dictionary = options[index]
		var definition := RunContent.perk_by_id(str(option.get("definition_id", "")))
		if str(definition.get("stat", "")) != "body_age":
			return index
	return 0

func _resolve_rewards_with_age_policy(game: Node, level_index: int) -> void:
	game.queue_level_clear_rewards(level_index)
	while game.has_pending_run_choices():
		var choice: Dictionary = game.get_next_pending_run_choice()
		var choice_type := str(choice.get("type", ""))
		var option_index := 0
		if choice_type == "perk":
			var age_index := _first_next_age_option_index(choice, game.get_run_body_age_order() + 1)
			option_index = age_index if age_index >= 0 else _first_non_age_option_index(choice)
		game.resolve_run_choice(str(choice.get("id", "")), option_index, false)

func _audit_probability(expanded_rank: int) -> Dictionary:
	var adult_before_final := 0
	var adult_after_final_reward := 0
	for seed in range(AUDIT_SEED_START, AUDIT_SEED_START + SAMPLE_COUNT):
		var game = _new_seeded_game(seed, expanded_rank)
		for level_index in 33:
			_resolve_rewards_with_age_policy(game, level_index)
			if level_index == 31 and game.get_run_body_age_order() >= 6:
				adult_before_final += 1
		if game.get_run_body_age_order() >= 6:
			adult_after_final_reward += 1
		game.free()
	return {
		"before_final": float(adult_before_final) / float(SAMPLE_COUNT),
		"finale": float(adult_after_final_reward) / float(SAMPLE_COUNT),
	}

func _test_age_offer_contract() -> void:
	var game = _new_seeded_game(424242)
	var little := RunContent.perk_by_id("age_little_kid")
	var adult := RunContent.perk_by_id("age_regular_guy")
	_expect(int(little.get("normal_by_level", 0)) == 4 and int(adult.get("normal_by_level", 0)) == 30, "Age definitions must expose authored normal-by timing")
	_expect(game._perk_definition_is_offerable(little, {}), "The next sequential age must be eligible")
	_expect(not game._perk_definition_is_offerable(adult, {}), "Future ages must remain sequentially ineligible")
	_expect(game.get_perk_definition_offer_weight(little, 3) == 1.0, "An age card must retain baseline weight at its normal level")
	_expect(game.get_perk_definition_offer_weight(little, 9) > game.get_perk_definition_offer_weight(little, 3), "An overdue age card must gain weight")
	var first: Dictionary = game.create_perk_choice(14, false, false, false)
	var second_game = _new_seeded_game(424242)
	var second: Dictionary = second_game.create_perk_choice(14, false, false, false)
	_expect(first == second, "Same seed and serial must produce identical weighted offers")
	var declined_choice := {
		"id": "audit_declined_age",
		"type": "perk",
		"source_level": 10,
		"source_level_number": 11,
		"created_serial": 99,
		"options": [
			{
				"definition_id": "age_little_kid",
				"rarity_rank": 0,
				"effect": {"stat": "body_age", "operation": "body", "age_order": 1},
			},
			{
				"definition_id": "pool_noodle_ligament",
				"rarity_rank": 0,
				"effect": {"stat": "speed", "operation": "multiplier", "value": 1.04},
			},
		],
	}
	game.pending_run_choices.append(declined_choice)
	game.resolve_run_choice("audit_declined_age", 1)
	_expect(float(game.achievement_event_totals.get("age_offers_declined", 0.0)) == 1.0, "Declining an age option must persist a durable event")
	_expect(game.get_run_body_age_order() == 0, "Declining an age option must not silently advance body age")
	_expect(game._perk_definition_is_offerable(little, {}), "The declined next age must remain eligible for a later offer")
	game.free()
	second_game.free()

func _test_event_round_trip_and_metrics() -> void:
	var game = _new_seeded_game(71)
	game.achievement_event_totals = {
		"run_perks_selected": 25.0,
		"pitch_drafts_selected": 10.0,
		"adult_first_human_finale": 1.0,
		"legendary_run_perk": 1.0,
	}
	game.story_seen.clear()
	for story_id in ["prologue_little_timmy", "arrive_tee_ball", "arrive_coach_pitch", "arrive_little_league", "arrive_middle_school"]:
		game.story_seen.append(story_id)
	game.pitch_levels = {"dead_fish": 3}
	var encoded: String = game.get_save_json()
	var restored = GameStateScript.new()
	var parser := JSON.new()
	_expect(parser.parse(encoded) == OK, "The generated save JSON must parse for the event round trip")
	restored.apply_save_data(parser.data as Dictionary)
	_expect(restored._achievement_metric_value(Content.achievement_by_id("run_perks_25")) == 25.0, "Run-perk achievement metric must read durable events")
	_expect(restored._achievement_metric_value(Content.achievement_by_id("pitch_drafts_10")) == 10.0, "Pitch-draft achievement metric must read durable events")
	_expect(restored._achievement_metric_value(Content.achievement_by_id("story_chapters_5")) == 5.0, "Story chapter metric must derive from saved story discovery")
	_expect(restored._achievement_metric_value(Content.achievement_by_id("pitch_specialist_3")) == 3.0, "Pitch-specialization metric must derive from saved pitch levels")
	restored.check_achievements(false)
	for id in ["run_perks_25", "pitch_drafts_10", "story_chapters_5", "pitch_specialist_3", "adult_human_finale", "legendary_run_perk"]:
		_expect(restored.has_achievement(id), "New achievement should unlock from its saved metric/event: %s" % id)
	game.free()
	restored.free()
