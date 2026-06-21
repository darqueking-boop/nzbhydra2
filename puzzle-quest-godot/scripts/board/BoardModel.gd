extends RefCounted
class_name BoardModel

## Pure data model for the match-3 board. No Godot nodes — fully unit-testable.

const COLS := 8
const ROWS := 8
const MIN_MATCH := 3

var grid: Array = []  # grid[col][row] = GemTypes.Type (int) or -1 for empty

func _init() -> void:
	_init_grid()
	fill_random()
	while has_matches():
		fill_random()

func _init_grid() -> void:
	grid.clear()
	for c in COLS:
		grid.append([])
		for _r in ROWS:
			grid[c].append(-1)

## Fills all -1 cells with random gems (avoids instant matches during fill).
func fill_random() -> void:
	for c in COLS:
		for r in ROWS:
			if grid[c][r] == -1:
				var exclude: Array[int] = _match_exclusions(c, r)
				grid[c][r] = GemTypes.weighted_random(exclude)

## Returns gem type at position, or -1 if out of bounds.
func get_gem(c: int, r: int) -> int:
	if c < 0 or c >= COLS or r < 0 or r >= ROWS:
		return -1
	return grid[c][r]

func set_gem(c: int, r: int, type: int) -> void:
	grid[c][r] = type

func swap(a: Vector2i, b: Vector2i) -> void:
	var tmp := grid[a.x][a.y]
	grid[a.x][a.y] = grid[b.x][b.y]
	grid[b.x][b.y] = tmp

func is_adjacent(a: Vector2i, b: Vector2i) -> bool:
	return abs(a.x - b.x) + abs(a.y - b.y) == 1

## Returns all matches currently on the board as Array of Array[Vector2i].
func find_matches() -> Array:
	var matches: Array = []
	var visited := {}

	# Horizontal
	for r in ROWS:
		var c := 0
		while c < COLS:
			var t := grid[c][r]
			var end := c + 1
			while end < COLS and _matches_type(grid[end][r], t):
				end += 1
			if end - c >= MIN_MATCH:
				var group: Array[Vector2i] = []
				for x in range(c, end):
					group.append(Vector2i(x, r))
					visited[Vector2i(x, r)] = true
				matches.append(group)
			c = end

	# Vertical
	for c in COLS:
		var r := 0
		while r < ROWS:
			var t := grid[c][r]
			var end := r + 1
			while end < ROWS and _matches_type(grid[c][end], t):
				end += 1
			if end - r >= MIN_MATCH:
				var group: Array[Vector2i] = []
				for y in range(r, end):
					if Vector2i(c, y) not in visited:
						group.append(Vector2i(c, y))
				if group.size() > 0:
					matches.append(group)
			r = end

	return matches

func has_matches() -> bool:
	return find_matches().size() > 0

## Clears matched gems, returns dict of {GemTypes.Type: count}.
func clear_matches(match_groups: Array) -> Dictionary:
	var counts: Dictionary = {}
	for group in match_groups:
		var type := grid[group[0].x][group[0].y]
		for pos in group:
			grid[pos.x][pos.y] = -1
		counts[type] = counts.get(type, 0) + group.size()
	return counts

## Applies gravity: gems fall down into empty cells. Returns true if anything moved.
func apply_gravity() -> bool:
	var moved := false
	for c in COLS:
		var write_row := ROWS - 1
		for r in range(ROWS - 1, -1, -1):
			if grid[c][r] != -1:
				if r != write_row:
					grid[c][write_row] = grid[c][r]
					grid[c][r] = -1
					moved = true
				write_row -= 1
	return moved

## Checks whether swapping a and b would create at least one match.
func would_match(a: Vector2i, b: Vector2i) -> bool:
	swap(a, b)
	var result := has_matches()
	swap(a, b)
	return result

## Returns true if any valid move exists on the board.
func has_valid_moves() -> bool:
	for c in COLS:
		for r in ROWS:
			var pos := Vector2i(c, r)
			for neighbor in [Vector2i(c+1, r), Vector2i(c, r+1)]:
				if is_adjacent(pos, neighbor) and get_gem(neighbor.x, neighbor.y) != -1:
					if would_match(pos, neighbor):
						return true
	return false

func _matches_type(a: int, b: int) -> bool:
	if a == -1 or b == -1:
		return false
	if a == GemTypes.Type.WILDCARD or b == GemTypes.Type.WILDCARD:
		return true
	return a == b

func _match_exclusions(c: int, r: int) -> Array[int]:
	var exclude: Array[int] = []
	# Avoid creating horizontal match
	if c >= 2 and grid[c-1][r] == grid[c-2][r] and grid[c-1][r] != -1:
		exclude.append(grid[c-1][r])
	# Avoid creating vertical match
	if r >= 2 and grid[c][r-1] == grid[c][r-2] and grid[c][r-1] != -1:
		exclude.append(grid[c][r-1])
	return exclude
