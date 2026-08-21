extends SceneTree

const Content = preload("res://scripts/content.gd")
const Campaign = preload("res://scripts/campaign.gd")
const GameStateScript = preload("res://scripts/game_state.gd")
const RunContent = preload("res://scripts/run_content.gd")

var failures := 0

func _initialize() -> void:
	print("No Hitter — story and name audit")
	_audit_story_copy()
	_audit_rebirth_middle_school_trigger()
	_audit_names()
	if failures > 0:
		push_error("FAIL: %d story/name audit assertion(s) failed" % failures)
		quit(1)
	else:
		print("PASS: story and name audit")
		quit(0)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func _story_body(id: String) -> String:
	return str(RunContent.story_by_id(id).get("body", ""))

func _audit_story_copy() -> void:
	var ids := {}
	for beat_value in RunContent.STORY_BEATS:
		var beat: Dictionary = beat_value
		var id := str(beat.id)
		_expect(not id.is_empty() and not ids.has(id), "Story IDs must remain unique")
		ids[id] = true
	for subera_index in range(1, 11):
		var story_id := str(Campaign.level(subera_index * Campaign.LEVELS_PER_SUBERA).story_key)
		_expect(not RunContent.story_by_id(story_id).is_empty(), "Every human arrival story key must exist")
	_expect(_story_body("prologue_little_timmy").contains("Little Timmy") and _story_body("prologue_little_timmy").contains("Wiffle"), "The opening must retain Little Timmy and the Wiffle ball")
	_expect(_story_body("prologue_little_timmy").to_lower().contains("rolls across the plate"), "The opening must retain the rolling two-foot practice punchline")
	_expect(_story_body("story_tab_explained").contains("LOG → STORY"), "Story onboarding must point to LOG → STORY")
	var coach := _story_body("arrive_coach_pitch").to_lower()
	_expect(not coach.contains("coach throws") and not coach.contains("coach pitches"), "Coach Pitch copy must never say a coach throws the player's pitches")
	_expect(coach.contains("you seize the mound"), "Coach Pitch must frame the player as defending the mound")
	var rebirth := _story_body("first_rebirth").to_lower()
	_expect(rebirth.contains("was it all a dream") and rebirth.contains("modifications") and rebirth.contains("conquest of the stars"), "First rebirth must retain the dream, modifications, and conquest anchors")
	_expect(_story_body("rebirth_middle_school").to_lower().contains("axe body spray and acne"), "Replay Middle School must retain the Axe/acne anchor")
	var octathulhu := _story_body("octathulhu_contact").to_lower()
	_expect(octathulhu.contains("eat the universe") and octathulhu.contains("beat him at baseball") and octathulhu.contains("eight bats"), "Octathulhu must retain existential baseball stakes and eight bats")

func _audit_rebirth_middle_school_trigger() -> void:
	var first_lifetime = GameStateScript.new()
	first_lifetime.reset_fresh()
	first_lifetime.pending_story_dialogs.clear()
	first_lifetime.highest_unlocked = 12
	first_lifetime.current_opponent = 11
	_expect(first_lifetime.set_current_opponent(12), "First-lifetime Middle School entry should be reachable")
	_expect("rebirth_middle_school" not in first_lifetime.story_seen, "The replay Middle School beat must not occur in the first lifetime")
	first_lifetime.free()

	var replay = GameStateScript.new()
	replay.reset_fresh()
	replay.pending_story_dialogs.clear()
	replay.lifetime_genetic_rebirths = 1
	replay.highest_unlocked = 12
	replay.current_opponent = 11
	_expect(replay.set_current_opponent(12), "Post-rebirth Middle School entry should be reachable")
	_expect("rebirth_middle_school" in replay.story_seen, "Post-rebirth Middle School entry must record its replay beat")
	var entries: int = replay.story_journal.size()
	replay.current_opponent = 11
	replay.set_current_opponent(12)
	_expect(replay.story_journal.size() == entries, "The replay Middle School beat must record exactly once")
	replay.free()

	var migrated = GameStateScript.new()
	migrated.apply_save_data({"version": 29, "highest_unlocked": 12, "current_opponent": 12, "lifetime_genetic_rebirths": 1, "genetic_rebirths": 1, "story_journal": [], "story_seen": []})
	_expect("rebirth_middle_school" in migrated.story_seen, "Pre-v30 post-rebirth Middle School saves must migrate the durable story ID")
	migrated.free()

func _audit_names() -> void:
	for index_value in Campaign.SIGNATURE_NAMES:
		var index := int(index_value)
		_expect(Content.batter_display_name(index, 0) == str(Campaign.SIGNATURE_NAMES[index_value]), "Authored signature names must remain unchanged")
	for index in [0, 33, 66]:
		_expect(Content.opponent_class_name(index) != Content.batter_display_name(index, 0), "Opponent classes must remain distinct from batter names")
	for representative in [1, 34, 70]:
		var generated := {}
		var prior := ""
		for generation in range(1, 513):
			var name := Content.batter_display_name(representative, generation)
			_expect(name == Content.batter_display_name(representative, generation), "Same inputs must reproduce the same batter name")
			_expect(name != prior, "Adjacent ordinary replacement batters must not repeat")
			generated[name] = true
			prior = name
		_expect(generated.size() >= 200, "Each human, alien, and eldritch corpus must produce substantial visible variety")
