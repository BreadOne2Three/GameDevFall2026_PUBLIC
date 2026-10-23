extends TestCase
## Tuning lives in the scenes, so the inspector shows the values that actually run.
## An action script must not change its exported values in _init().

func test_action_scripts_keep_their_declared_defaults() -> void:
	for file in DirAccess.get_files_at("res://actions"):
		if not file.ends_with(".gd"):
			continue
		var script : GDScript = load("res://actions/" + file)
		var action : Node = script.new()
		for prop in script.get_script_property_list():
			if not (prop.usage & PROPERTY_USAGE_EDITOR):
				continue
			var declared = script.get_property_default_value(prop.name)
			assert_eq(action.get(prop.name), declared, "%s.%s" % [file, prop.name])
		action.free()
