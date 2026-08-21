extends SceneTree

const Content = preload("res://scripts/content.gd")
const GameState = preload("res://scripts/game_state.gd")

var failures := 0

func _expect(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func _fresh_game():
	var game = GameState.new()
	game.reset_fresh()
	# Story is not under test here; it must not block a mechanics fixture.
	game.pending_story_dialogs.clear()
	return game

func _resolve_outcome(game, outcome: int, ball_count: int, live_resolution: bool, resolved_opponent: int = 0) -> Dictionary:
	var summary: Dictionary = game._empty_resolution_summary()
	summary["live_resolution"] = live_resolution
	if live_resolution:
		summary["released_pitches"] = float(ball_count)
		summary["released_volleys"] = 1
		var events: Array = summary.pitch_events
		events.append({"phase": "release", "ball_count": ball_count})
	game._apply_pitch_outcome(summary, outcome, -1.0, ball_count, false, resolved_opponent)
	game._apply_resolution(summary, live_resolution)
	return summary

func _profile_axis_changes(before: Dictionary, after: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for axis in ["payload", "speed", "quality", "drag"]:
		if not is_equal_approx(float(before[axis]), float(after[axis])):
			result.append(axis)
	return result

func _test_ball_profiles() -> void:
	var game = _fresh_game()
	var expected_ids := ["fresh_wiffle", "taped_seams", "backyard_rubber", "real_leather", "youth_cork", "cork_core", "raised_seams", "superball_core", "college_hide", "tungsten_winding", "mud_rubbed", "triple_a_winding", "juiced_ball", "derby_overrun", "commissioner_denied", "world_series_ball", "dragonhide_cover", "railgun_jacket", "plasma_filament", "neutron_pearls", "quantum_lacing", "causality_seams", "pocket_singularity", "void_leather", "event_horizon_core", "eightfold_causality"]
	var actual_ids: Array[String] = []
	for definition_value in Content.BALL_UPGRADES:
		actual_ids.append(str((definition_value as Dictionary).id))
	_expect(actual_ids == expected_ids, "Ball IDs and catalog order remain save-compatible")
	_expect(game.get_current_ball_profile() == {"payload": 1.0, "speed": 1.0, "quality": 0.0, "drag": 1.0}, "No shell has the neutral complete profile")
	_expect(Content.BALL_PROFILES.world_series_ball.payload == 140.0 and Content.BALL_PROFILES.quantum_lacing.payload == 10000.0 and Content.BALL_PROFILES.eightfold_causality.payload == 1000000000.0, "Tier payload anchors remain exactly 140 / 10,000 / 1e9")
	var tier_ranges := {"human": [0, 16], "alien": [16, 21], "eldritch": [21, 26]}
	for tier in tier_ranges:
		var found := {"speed": false, "quality": false, "drag": false}
		var bounds: Array = tier_ranges[tier]
		for index in range(int(bounds[0]), int(bounds[1])):
			var prior: Dictionary = {"payload": 1.0, "speed": 1.0, "quality": 0.0, "drag": 1.0} if index == 0 else Content.BALL_PROFILES[actual_ids[index - 1]]
			var changes := _profile_axis_changes(prior, Content.BALL_PROFILES[actual_ids[index]])
			if changes.size() == 1 and str(changes[0]) in found:
				found[str(changes[0])] = true
		for axis in found:
			_expect(bool(found[axis]), "%s tier includes a %s-only shell step" % [tier, axis.capitalize()])
	game.purchased_ball_upgrades.append("fresh_wiffle")
	game.purchased_ball_upgrades.append("world_series_ball")
	game.purchased_ball_upgrades.append("taped_seams")
	_expect(game.get_current_ball_name() == "World-Series Game Ball" and game.get_current_ball_profile() == Content.BALL_PROFILES.world_series_ball, "The highest catalog shell replaces historical ownership without stacking")
	_expect(game.get_ball_upgrade_delta_text("real_leather") == "Quality + 0 → +80", "A readable shell delta reports whole-number Quality only")
	_expect(game.get_ball_profile_text("real_leather") == "Payload ×1.45 • Release Speed ×1.04 • Quality +80 • Air Drag ×1.00", "The full profile reports every current axis without stale payload-only copy")
	game.free()

func _test_immutable_release_snapshot() -> void:
	var game = _fresh_game()
	game.purchased_ball_upgrades.append("fresh_wiffle")
	var first_summary: Dictionary = game._empty_resolution_summary()
	game._begin_pitch_volley(first_summary, 0.0)
	var first: Dictionary = game.active_volleys[0].duplicate(true)
	var immutable_fields := ["speed_fps", "plate_speed_fps", "drag_per_foot", "outcomes", "saved_flags", "duration", "remaining"]
	game.purchased_ball_upgrades.append("youth_cork")
	var after_purchase: Dictionary = game.active_volleys[0]
	for field in immutable_fields:
		_expect(after_purchase[field] == first[field], "Owned shell changes cannot mutate released volley %s" % field)
	_expect(game.get_current_ball_profile() == Content.BALL_PROFILES.youth_cork, "Later ownership selects the later complete shell")
	var second_summary: Dictionary = game._empty_resolution_summary()
	game._begin_pitch_volley(second_summary, 0.1)
	var second: Dictionary = game.active_volleys[1]
	_expect(not is_equal_approx(float(second.drag_per_foot), float(first.drag_per_foot)), "The next release computes air drag from the later shell")
	_expect(is_equal_approx(float(second.drag_per_foot), game.get_ball_drag_per_foot(game.current_opponent)), "The next release stores the current shell drag")
	game.free()

func _test_body_adjective_copy() -> void:
	var game = _fresh_game()
	var expected := {"athletic": "Speed ×1.025; Quality +8.", "buff": "Speed ×1.045; Payload ×1.025.", "toned": "Recovery ×1.025; Hit delay ×0.975.", "creatine-loaded": "Speed ×1.045; Payload ×1.04.", "suspiciously vitaminized": "Speed ×1.07; Recovery ×1.025.", "roided-out": "Speed ×1.10; Recovery ×1.025."}
	var modifier_ids := {"athletic": "playground_conditioning", "buff": "pushup_phase", "toned": "running_laps", "creatine-loaded": "creatine", "suspiciously vitaminized": "suspicious_vitamins", "roided-out": "steroids"}
	for adjective in expected:
		var copy := game.get_run_body_adjective_effect_text(adjective)
		_expect(copy == expected[adjective], "%s body card has its exact numerical gameplay copy" % adjective)
		_expect(copy == Content.body_modifier_by_id(modifier_ids[adjective]).description and copy.contains("×"), "%s body card derives its concrete effect from the authoritative modifier" % adjective)
		_expect(not copy.contains("unavailable"), "%s body card is always available" % adjective)
	game.free()

func _test_mastery_semantics() -> void:
	var non_strike = _fresh_game()
	var requirement := non_strike.get_mastery_requirement(0)
	non_strike.opponent_mastery[0] = requirement - 0.01
	_resolve_outcome(non_strike, Content.BALL_INDEX, 1, false)
	_expect(non_strike.opponent_mastery[0] >= requirement and non_strike.highest_unlocked == 0, "Non-strikeout mastery can make an opponent ready without unlocking it")
	non_strike.plate_strikes = non_strike.get_strikes_required(0) - 1
	_resolve_outcome(non_strike, Content.STRIKE_INDEX, 1, false)
	_expect(non_strike.highest_unlocked == 1 and not non_strike.pending_run_choices.is_empty(), "The next completed strikeout unlocks a ready opponent and queues its mandatory reward")
	non_strike.pending_run_choices.clear()
	non_strike.free()
	var crossing_strike = _fresh_game()
	requirement = crossing_strike.get_mastery_requirement(0)
	crossing_strike.opponent_mastery[0] = requirement - 0.01
	crossing_strike.plate_strikes = crossing_strike.get_strikes_required(0) - 1
	_resolve_outcome(crossing_strike, Content.STRIKE_INDEX, 1, false)
	_expect(crossing_strike.highest_unlocked == 1 and not crossing_strike.pending_run_choices.is_empty(), "A completed strikeout that crosses mastery unlocks immediately and queues its reward")
	crossing_strike.pending_run_choices.clear()
	crossing_strike.free()
	var stale = _fresh_game()
	stale.highest_unlocked = 1
	stale.current_opponent = 1
	stale.opponent_mastery[1] = stale.get_mastery_requirement(1)
	stale.plate_strikes = stale.get_strikes_required(0) - 1
	_resolve_outcome(stale, Content.STRIKE_INDEX, 1, false, 0)
	_expect(stale.highest_unlocked == 1 and stale.pending_run_choices.is_empty(), "A resolution credited to opponent A cannot evaluate or unlock current opponent B")
	stale.free()

func _test_live_action_achievements_and_save() -> void:
	var offline = _fresh_game()
	var offline_events: Dictionary = offline.achievement_event_totals.duplicate(true)
	_resolve_outcome(offline, Content.STRIKE_INDEX, 3, false)
	_expect(offline.lifetime_pitches == 3.0 and offline.lifetime_strikeouts == 1.0 and offline.result_totals[Content.STRIKE_INDEX] == 3.0 and offline.opponent_mastery[0] > 0.0, "Offline resolution still advances XP/mastery/career lifetime and result totals")
	_expect(offline.live_action_achievement_totals.is_empty() and offline.achievement_event_totals == offline_events and "first_pitch" not in offline.unlocked_achievements, "Offline resolution never changes live action counters/events or unlocks action achievements")
	var offline_save := offline.to_save_data()
	offline.free()
	var live = _fresh_game()
	_resolve_outcome(live, Content.STRIKE_INDEX, 3, true)
	_expect(live.live_action_achievement_totals.pitches == 3.0 and live.live_action_achievement_totals.strikeouts == 1.0 and live.live_action_achievement_totals.get("outcome_%d" % Content.STRIKE_INDEX, 0.0) == 3.0, "Live resolution records pitches, outcomes, and strikeouts")
	_expect(live.live_action_achievement_totals.volley_size == 3.0, "Live volley size is the balls in one release")
	_expect(float(live.achievement_event_totals.get("double_strike_volley", 0.0)) == 1.0 and float(live.achievement_event_totals.get("triple_strike_volley", 0.0)) == 1.0, "Live resolution records relevant volley events")
	_expect("first_pitch" in live.unlocked_achievements and "first_strikeout" in live.unlocked_achievements and "volley_2" in live.unlocked_achievements, "Live action resolution unlocks its action achievements")
	_resolve_outcome(live, Content.STRIKE_INDEX, 1, true)
	_expect(live.live_action_achievement_totals.volley_size == 3.0, "Volley size remains a maximum, not cumulative pitches")
	var live_save := live.to_save_data()
	var expected_live: Dictionary = live.live_action_achievement_totals.duplicate(true)
	var restored = GameState.new()
	restored.apply_save_data(live_save)
	_expect(restored.live_action_achievement_totals == expected_live, "Nonempty live action counters round-trip exactly")
	var migrated_save := offline_save.duplicate(true)
	migrated_save.version = 28
	migrated_save.erase("live_action_achievement_totals")
	migrated_save.unlocked_achievements = ["first_pitch"]
	var migrated = GameState.new()
	migrated.apply_save_data(migrated_save)
	_expect(migrated.live_action_achievement_totals.is_empty() and "first_pitch" in migrated.unlocked_achievements, "v28 missing live counters migrate neutral while valid earned action IDs remain")
	_expect(migrated.lifetime_pitches == 3.0 and migrated.result_totals[Content.STRIKE_INDEX] == 3.0, "Migration does not infer old offline history into new live counters")
	live.free()
	restored.free()
	migrated.free()

func _test_achievement_semantics() -> void:
	var ids := {}
	var signatures := {}
	for definition_value in Content.ACHIEVEMENTS:
		var definition: Dictionary = definition_value
		var id := str(definition.id)
		_expect(not ids.has(id), "Achievement IDs are unique: %s" % id)
		ids[id] = true
		# Presentation fields (tier/reveal/secret/name/description) deliberately do not participate.
		var signature := "%s|%s|%s" % [definition.metric, str(definition.get("key", "")), str(definition.threshold)]
		_expect(not signatures.has(signature), "No duplicate achievement predicate signature: %s" % signature)
		signatures[signature] = id

func _initialize() -> void:
	_test_ball_profiles()
	_test_immutable_release_snapshot()
	_test_body_adjective_copy()
	_test_mastery_semantics()
	_test_live_action_achievements_and_save()
	_test_achievement_semantics()
	if failures == 0:
		print("PASS: M1 content/progression/navigation contract")
		quit(0)
	else:
		quit(1)
