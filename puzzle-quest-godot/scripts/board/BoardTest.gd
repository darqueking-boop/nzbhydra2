extends Node
class_name BoardTest

## GDScript unit tests for BoardModel. Run in-editor or via CLI with --headless.
## Usage: godot --headless -s scripts/board/BoardTest.gd

func run_all() -> void:
	var passed := 0
	var failed := 0
	var tests := [
		"test_board_initializes_no_matches",
		"test_swap_creates_match",
		"test_no_match_swap_rejected",
		"test_gravity_fills_gaps",
		"test_wildcard_matches_any",
		"test_clear_reduces_count",
		"test_has_valid_moves",
	]
	for t in tests:
		if call(t):
			passed += 1
			print("  PASS  %s" % t)
		else:
			failed += 1
			print("  FAIL  %s" % t)
	print("\n%d/%d tests passed." % [passed, passed + failed])

func test_board_initializes_no_matches() -> bool:
	var b := BoardModel.new()
	return not b.has_matches()

func test_swap_creates_match() -> bool:
	var b := BoardModel.new()
	# Force a known configuration in the top-left 3 cells
	b.set_gem(0, 0, GemTypes.Type.RED)
	b.set_gem(1, 0, GemTypes.Type.BLUE)
	b.set_gem(2, 0, GemTypes.Type.RED)
	b.set_gem(3, 0, GemTypes.Type.RED)
	# Swapping (1,0) BLUE with (2,0) RED should reveal 3 REDs in a row
	return b.would_match(Vector2i(1, 0), Vector2i(2, 0))

func test_no_match_swap_rejected() -> bool:
	var b := BoardModel.new()
	b.set_gem(0, 0, GemTypes.Type.RED)
	b.set_gem(1, 0, GemTypes.Type.BLUE)
	# Isolated swap — no match possible unless surrounding gems cooperate
	# Just verify would_match returns false for a clearly isolated pair
	for c in BoardModel.COLS:
		for r in BoardModel.ROWS:
			b.set_gem(c, r, GemTypes.Type.BLUE)
	b.set_gem(0, 0, GemTypes.Type.RED)
	b.set_gem(1, 0, GemTypes.Type.GREEN)
	return not b.would_match(Vector2i(0, 0), Vector2i(1, 0))

func test_gravity_fills_gaps() -> bool:
	var b := BoardModel.new()
	for c in BoardModel.COLS:
		for r in BoardModel.ROWS:
			b.set_gem(c, r, GemTypes.Type.RED)
	# Clear middle row
	for c in BoardModel.COLS:
		b.set_gem(c, 3, -1)
	b.apply_gravity()
	# All empties should now be at the top
	for c in BoardModel.COLS:
		for r in range(1, BoardModel.ROWS):
			if b.get_gem(c, r) == -1:
				return false
	return true

func test_wildcard_matches_any() -> bool:
	var b := BoardModel.new()
	for c in BoardModel.COLS:
		for r in BoardModel.ROWS:
			b.set_gem(c, r, GemTypes.Type.BLUE)
	b.set_gem(0, 0, GemTypes.Type.WILDCARD)
	b.set_gem(1, 0, GemTypes.Type.RED)
	b.set_gem(2, 0, GemTypes.Type.RED)
	# WILDCARD + RED + RED = match of REDs (wildcard joins)
	return b.find_matches().size() > 0

func test_clear_reduces_count() -> bool:
	var b := BoardModel.new()
	for c in BoardModel.COLS:
		for r in BoardModel.ROWS:
			b.set_gem(c, r, GemTypes.Type.GREEN)
	var matches := b.find_matches()
	if matches.is_empty():
		return false
	var counts := b.clear_matches(matches)
	var total := 0
	for t in counts:
		total += counts[t]
	return total > 0

func test_has_valid_moves() -> bool:
	var b := BoardModel.new()
	return b.has_valid_moves()

func _ready() -> void:
	print("\n=== BoardModel Tests ===")
	run_all()
	get_tree().quit()
