extends SceneTree

const MainScene = preload("res://main.tscn")

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _run() -> void:
	var main = MainScene.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	_expect(main.native_update_test_session, "The fixed --native-update-test flag must activate before startup loading")
	_expect(main.development_session and main.game.save_writes_locked, "Update-test startup must be in-memory and write-locked")
	_expect(not main.game.last_load_succeeded and not main.game.last_load_had_error, "Update-test startup must skip persistent save load/recovery")
	_expect(not main.game.save_game(), "Update-test startup must reject an attempted persistent save")
	_expect(main._native_update_current_version() == main.NATIVE_UPDATE_TEST_VERSION, "Update-test startup must compare with the fixed old test version")
	_expect(main.title_subtitle_label.text.contains("UPDATE TEST SESSION") and main.title_subtitle_label.text.contains("NOT SAVED"), "Update-test title copy must disclose volatile test-session play")
	_expect(not main.native_update_export_button.visible, "Update-test startup must hide backup export rather than offering a disabled development action")
	_expect(main.native_update_request != null and main.native_update_check_elapsed <= main.NATIVE_UPDATE_CHECK_INTERVAL, "Update-test startup must enable the normal native manifest request path immediately")
	main.free()
	if failures.is_empty():
		print("PASS: native update test mode is read-safe and forced-outdated")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("FAIL: %d native update-test issue(s)" % failures.size())
	quit(1)
