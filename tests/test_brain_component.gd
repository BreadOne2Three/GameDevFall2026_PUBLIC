extends TestCase

const FakeAction := preload("res://tests/lib/fake_action.gd")

var brain : BrainComponent
var learning : LearningComponent

func _make(scores: Dictionary) -> void:
	brain = track(BrainComponent.new())
	learning = track(LearningComponent.new())
	for action_name in scores:
		var action := FakeAction.new()
		action.name = action_name
		action.fixed_score = scores[action_name]
		brain.add_child(action)
	brain.setup(null, learning)

func _action(action_name: String):
	return brain.get_action(action_name)

func test_picks_highest_score() -> void:
	_make({"A": 0.3, "B": 0.6})
	brain.think()
	assert_eq(brain.current_action_name(), "B")

func test_stickiness_keeps_current_on_near_tie() -> void:
	_make({"A": 0.5, "B": 0.2})
	brain.think()
	_action("B").fixed_score = 0.55
	brain.think()
	assert_eq(brain.current_action_name(), "A")

func test_learned_bias_changes_choice() -> void:
	_make({"A": 0.4, "B": 0.5})
	learning.biases["A"] = 0.2
	brain.think()
	assert_eq(brain.current_action_name(), "A")

func test_survival_guard_ignores_negative_bias_when_need_is_high() -> void:
	_make({"Eat": 0.6, "Other": 0.3})
	_action("Eat").is_survival = true
	_action("Eat").fixed_need = 0.9
	learning.biases["Eat"] = -0.5
	brain.think()
	assert_eq(brain.current_action_name(), "Eat")

func test_negative_bias_applies_when_need_is_low() -> void:
	_make({"Eat": 0.6, "Other": 0.3})
	_action("Eat").is_survival = true
	_action("Eat").fixed_need = 0.5
	learning.biases["Eat"] = -0.5
	brain.think()
	assert_eq(brain.current_action_name(), "Other")

func test_zero_score_cannot_be_rescued_by_bias() -> void:
	_make({"A": 0.0, "B": 0.1})
	learning.biases["A"] = 0.5
	brain.think()
	assert_eq(brain.current_action_name(), "B")

func test_finished_action_ends_and_brain_rethinks() -> void:
	_make({"A": 0.6, "B": 0.3})
	brain.tick(0.01)
	assert_eq(brain.current_action_name(), "A")
	_action("A").finish = true
	_action("A").fixed_score = 0.0
	brain.tick(0.01)
	assert_eq(brain.current_action_name(), "B")

func test_committed_action_only_yields_to_urgent_survival() -> void:
	_make({"Rest": 0.5, "Play": 0.2, "Eat": 0.0})
	brain.think()
	_action("Rest").committed = true
	_action("Play").fixed_score = 0.9
	brain.think()
	assert_eq(brain.current_action_name(), "Rest", "non-survival can't interrupt")
	_action("Eat").is_survival = true
	_action("Eat").fixed_score = 0.8
	brain.think()
	assert_eq(brain.current_action_name(), "Eat")

func test_cooldown_blocks_action() -> void:
	_make({"A": 0.6, "B": 0.3})
	_action("A").cooldown_left = 1.0
	brain.think()
	assert_eq(brain.current_action_name(), "B")

func test_gives_up_after_max_duration() -> void:
	_make({"Stuck": 0.6, "B": 0.3})
	_action("Stuck").max_duration = 1.0
	brain.tick(0.1)
	assert_eq(brain.current_action_name(), "Stuck")
	for i in 12:
		brain.tick(0.1)
	assert_eq(brain.current_action_name(), "B")
	assert_true(_action("Stuck").cooldown_left > 0.0)

func test_switch_records_learning_history() -> void:
	_make({"A": 0.6})
	brain.think()
	assert_eq(learning.current_action, "A")
	brain.interrupt()
	assert_eq(learning.current_action, "")
	assert_eq(learning.history.size(), 1)

func test_request_joint_accepts_when_free_and_refuses_during_survival() -> void:
	_make({"Play": 0.1, "Eat": 0.9})
	_action("Play").fixed_need = 0.5
	assert_true(brain.request_joint("Play", null))
	assert_eq(brain.current_action_name(), "Play")
	brain.interrupt()
	_action("Eat").is_survival = true
	brain.think()
	assert_eq(brain.current_action_name(), "Eat")
	assert_false(brain.request_joint("Play", null))
