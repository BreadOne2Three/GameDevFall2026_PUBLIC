extends SceneTree
## Headless test runner: runs every test_* method in every tests/test_*.gd file.
## Usage: tests/run.sh

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var passed := 0
	var failed := 0
	for file in DirAccess.get_files_at("res://tests"):
		if not (file.begins_with("test_") and file.ends_with(".gd")):
			continue
		var script : GDScript = load("res://tests/" + file)
		for method in script.get_script_method_list():
			var test_name : String = method.name
			if not test_name.begins_with("test_"):
				continue
			var test : TestCase = script.new()
			test.tree = self
			await test.call(test_name)
			test.cleanup()
			if test.failures.is_empty():
				passed += 1
			else:
				failed += 1
				print("FAIL %s::%s" % [file, test_name])
				for failure in test.failures:
					print("    ", failure)
	print("%d passed, %d failed" % [passed, failed])
	quit(1 if failed > 0 else 0)
