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
	_audit_little_timmy_equipment_beat()
	_audit_names()
	_audit_text_integrity()
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
	var tee_ball := _story_body("arrive_tee_ball").to_lower()
	_expect(tee_ball.contains("stride forward") and tee_ball.contains("knock the pathetic tee") and tee_ball.contains("take the mound") and tee_ball.contains("real baseball"), "Tee Ball must put the player on the mound after knocking down the tee")
	_expect(not tee_ball.contains("you hit") and not tee_ball.contains("you bat"), "Tee Ball must never imply the player bats from the tee")
	var hat := _story_body("little_timmy_hat").to_lower()
	_expect(hat.contains("wait... leave the hat.") and hat.contains("equipment") and hat.contains("loadout"), "Little Timmy's equipment beat must explain the actual unlock")

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

func _audit_little_timmy_equipment_beat() -> void:
	var fresh = GameStateScript.new()
	fresh.reset_fresh()
	fresh.pending_story_dialogs.clear()
	var summary := {"loot_found": 0, "loot_kept": 0, "loot_drops": [], "loot_discarded": 0, "loot_scrap_gained": 0.0}
	fresh._resolve_strikeout_loot(1.0, 0.0, summary, 0)
	_expect(fresh.loot_items.size() == 1 and str(fresh.loot_items[0].get("slot", "")) == "hat", "The first authoritative Little Timmy equipment acquisition must be a hat")
	_expect("little_timmy_hat" in fresh.story_seen, "The kept Little Timmy hat must record its story beat")
	_expect(not fresh.get_next_story_dialog().is_empty() and str(fresh.get_next_story_dialog().get("id", "")) == "little_timmy_hat", "The fresh Little Timmy hat beat must queue once")
	fresh._resolve_strikeout_loot(1.0, 0.0, summary, 0)
	_expect(fresh.story_journal.filter(func(entry: Dictionary) -> bool: return str(entry.get("id", "")) == "little_timmy_hat").size() == 1, "The Little Timmy hat beat must not replay after revisits")
	var restored = GameStateScript.new()
	restored.apply_save_data(fresh.to_save_data())
	_expect(str(restored.get_next_story_dialog().get("id", "")) == "little_timmy_hat", "A saved pending Little Timmy hat beat must survive load exactly once")
	restored.consume_next_story_dialog()
	_expect(restored.get_next_story_dialog().is_empty(), "A consumed Little Timmy hat beat must not replay after load")
	fresh.free()
	restored.free()

	var migrated = GameStateScript.new()
	migrated.apply_save_data({"version": 31, "lifetime_loot_found": 1.0, "loot_items": [{"id": "L000000001", "slot": "hat", "item_level": 1, "rarity": 0, "name": "Crooked Cap", "stats": {"quality_bonus": 0.02}, "roll_quality": 0.8, "color": "ffffff"}], "story_journal": [], "story_seen": []})
	_expect("little_timmy_hat" in migrated.story_seen, "Existing equipment saves must quietly migrate the Little Timmy story ID")
	_expect(migrated.pending_story_dialogs.is_empty(), "Existing equipment saves must not receive a retroactive popup")
	migrated.free()

func _audit_names() -> void:
	for index_value in Campaign.SIGNATURE_NAMES:
		var index := int(index_value)
		_expect(Content.batter_display_name(index, 0) == str(Campaign.SIGNATURE_NAMES[index_value]), "Authored signature names must remain unchanged")
	for index in [0, 33, 66]:
		_expect(Content.opponent_class_name(index) != Content.batter_display_name(index, 0), "Opponent classes must remain distinct from batter names")
	for representative in [1, 34, 70]:
		var space := Content.ordinary_name_combination_space(Content.name_pool_for(representative))
		var legacy_space := Content.v018_ordinary_name_combination_space(Content.name_pool_for(representative))
		_expect(space >= legacy_space * 2, "M2 ordinary name grammar must at least double v0.18.0 theoretical space")
		var generated := {}
		var prior := ""
		for generation in range(1, 513):
			var name := Content.batter_display_name(representative, generation)
			_expect(name == Content.batter_display_name(representative, generation), "Same inputs must reproduce the same batter name")
			_expect(name != prior, "Adjacent ordinary replacement batters must not repeat")
			generated[name] = true
			prior = name
		_expect(generated.size() >= 200, "Each human, alien, and eldritch corpus must produce substantial visible variety")

func _audit_text_integrity() -> void:
	for source in [
		RunContent.RUN_PERKS, RunContent.BOSS_PERKS, RunContent.STORY_BEATS,
		Content.LOOT_SLOTS, Content.LOOT_RARITIES, Content.LOOT_STATS, Content.LOOT_PREFIXES,
		Content.LOOT_SUFFIXES, Content.PITCHES, Content.ACHIEVEMENTS, Content.BODY_GROWTH_STAGES,
		Content.BODY_MODIFIERS, Content.GENETIC_UPGRADES, Content.ELDRITCH_UPGRADES,
		Content.DIVINE_BLESSINGS, Content.BATTER_NAME_POOLS, Content.BATTER_NAME_COMPONENTS,
		Content.BATTER_NAME_EXPANSIONS, Content.BATTER_NAME_M2_EXPANSIONS, Campaign.DISTANCE_TIERS,
		Campaign.levels(), Campaign.SIGNATURE_NAMES
	]:
		_audit_value_text(source, "content")

func _audit_value_text(value: Variant, context: String) -> void:
	if typeof(value) == TYPE_STRING:
		var text := str(value)
		for offset in text.length():
			var codepoint := text.unicode_at(offset)
			_expect(codepoint >= 32 and codepoint != 0x7f, "%s contains a control character" % context)
			_expect(codepoint != 0xfffd, "%s contains U+FFFD" % context)
			_expect(not (codepoint >= 0xe000 and codepoint <= 0xf8ff), "%s contains a private-use code point" % context)
			_expect(codepoint != 0x2022, "%s contains the unsupported bullet separator" % context)
	elif typeof(value) == TYPE_ARRAY:
		for nested in value:
			_audit_value_text(nested, context)
	elif typeof(value) == TYPE_DICTIONARY:
		for key in (value as Dictionary):
			_audit_value_text(key, context)
			_audit_value_text((value as Dictionary)[key], context)
