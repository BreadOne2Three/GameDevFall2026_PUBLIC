extends RefCounted
class_name TestCase
## Base class for headless tests. Each test_* method runs on a fresh instance.

var tree : SceneTree
var failures : Array[String] = []
var _owned : Array[Node] = []

func assert_true(condition: bool, message: String = "") -> void:
	if not condition:
		failures.append("expected true. " + message)

func assert_false(condition: bool, message: String = "") -> void:
	if condition:
		failures.append("expected false. " + message)

func assert_eq(actual: Variant, expected: Variant, message: String = "") -> void:
	if typeof(actual) != typeof(expected) or actual != expected:
		failures.append("expected %s, got %s. %s" % [str(expected), str(actual), message])

func assert_near(actual: float, expected: float, tolerance: float = 0.001, message: String = "") -> void:
	if absf(actual - expected) > tolerance:
		failures.append("expected %s ± %s, got %s. %s" % [expected, tolerance, actual, message])

## Adds a node to the scene tree (so _ready runs) and frees it after the test.
func add(node: Node) -> Node:
	tree.root.add_child(node)
	_owned.append(node)
	return node

## Frees a node after the test without adding it to the tree.
func track(node: Node) -> Node:
	_owned.append(node)
	return node

func cleanup() -> void:
	for node in _owned:
		if is_instance_valid(node):
			node.free()
