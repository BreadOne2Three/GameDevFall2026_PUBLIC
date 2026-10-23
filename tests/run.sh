#!/bin/sh
# Runs the headless test suite. Set GODOT if your Godot binary lives elsewhere.
GODOT="${GODOT:-$HOME/Downloads/Godot.app/Contents/MacOS/Godot}"
cd "$(dirname "$0")/.." || exit 1
# --import refreshes the class_name cache so newly added classes are visible.
"$GODOT" --headless --path . --import >/dev/null 2>&1
out=$("$GODOT" --headless --path . --fixed-fps 60 -s tests/run_tests.gd 2>&1)
code=$?
echo "$out"
if echo "$out" | grep -q "SCRIPT ERROR"; then
	echo "Script errors detected"
	exit 1
fi
exit $code
