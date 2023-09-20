class_name Board extends Node

@export var width: int = 1
@export var height: int = 1

## Represents a Board's cell.
class Cell extends RefCounted:
	var x: int
	var y: int

	## Whether the user already clicked on this cell.
	var revealed := false

	## The amount of neighboring mines.
	var count := 0

	## If this cell is a mine.
	var is_mine := false

	func _init(x: int, y: int):
		self.x = x
		self.y = y

	## Returns this cell's position as a Vector2i.
	func position() -> Vector2i:
		return Vector2i(x, y)

	## Marks this cell as revealed.
	func reveal() -> void:
		revealed = true

	## Marks this cell as not revealed.
	func unreveal() -> void:
		revealed = false

	func is_revealed() -> bool:
		return revealed

	func is_a_mine() -> bool:
		return is_mine

	## Gets the amount of neighboring mines to this cell.
	func get_count() -> int:
		return count

	## Sets the amount of neighboring mines to this cell.
	func set_count(num: int) -> void:
		count = clampi(num, 0, 8)

	func set_is_mine(is_mine: bool) -> void:
		self.is_mine = is_mine

	## Resets this cell to the default state
	## (unrevealed, count of 0, not mine).
	func reset() -> void:
		unreveal()
		count = 0
		is_mine = false

	## Copy this cell.
	func copy() -> Cell:
		var cell := Cell.new(x, y)
		cell.revealed = revealed
		cell.count = count
		cell.is_mine = is_mine
		return cell

## Flattened array of arrays of Cells representing this board.
##
## Notation: board_cells[Y * width + X]
var board_cells: Array[Cell] = []

## Inits the board, also filling it with default (unrevealed) cells.
func _init(width: int, height: int):
	self.width = width
	self.height = height
	fill_board()

## Fills this board with default cells.
func fill_board() -> void:
	board_cells.clear()
	for i in range(width * height):
		var coords: Vector2i = _arr_pos_to_coords(i)
		var x := coords.x
		var y := coords.y
		board_cells.append(Cell.new(x, y))

## Randomly places 'mine_count' mines in this board.
## Does not place mines in the excluded locations, unless the mine count
## would surpass (total - excluded).
## Setting excludes to an empty array does not exclude any cells.
func generate_mines(mine_count: int, mine_excludes: Array[Vector2i]) -> void:
	var mines_left := mine_count

	var not_mine_cells := board_cells.filter(func(c: Cell): return not c.is_a_mine())
	var not_mine_count := not_mine_cells.size()

	# non-deterministic exclusion
	mine_excludes.shuffle()
	while (
		not mine_excludes.is_empty()
		and (not_mine_count - mine_excludes.size()) < mine_count
	):
		# ignore exclusions until there are enough available cells
		# to fit the mines in
		mine_excludes.pop_back()

	var available_cell_filter = func(c: Cell):
		return c.position() not in mine_excludes
	var available_cells := not_mine_cells.filter(available_cell_filter)

	# random mine placement
	available_cells.shuffle()

	while mines_left > 0 and not available_cells.is_empty():
		var cell: Cell = available_cells.pop_back()
		cell.is_mine = true
		mines_left -= 1
		for neighbor in neighbors_of(cell.x, cell.y):
			var i := _coords_to_arr_pos(neighbor.x, neighbor.y)
			var neighbor_cell := board_cells[i]
			# increase count of adjacent cells
			neighbor_cell.count += 1

## Inits this board with the given width, height and mine count
## (mines are placed randomly through 'generate_mines').
func init_board(width: int, height: int, mine_count: int, mine_excludes: Array[Vector2i]) -> void:
	self.width = width
	self.height = height
	fill_board()
	generate_mines(mine_count, mine_excludes)

## Returns the positions of all mines in the grid
func get_all_mines() -> Array[Vector2i]:
	var mines: Array[Cell] = board_cells \
		.filter(func(c: Cell): return c.is_a_mine());

	var mine_positions: Array[Vector2i] = []

	# workaround for .map returning untyped Array
	mine_positions.assign(mines \
		.map(func(c: Cell): return Vector2i(c.x, c.y)))

	return mine_positions

func _coords_to_arr_pos(x: int, y: int) -> int:
	return y * width + x

func _arr_pos_to_coords(arr_pos: int) -> Vector2i:
	return Vector2i(arr_pos % width, arr_pos / width)

## Returns true if the coordinates are valid in this board
func coords_within_bounds(x: int, y: int) -> bool:
	return (
		x >= 0
		and y >= 0
		and x < width
		and y < height
	)

## Sets cell attributes at the given position.
func set_cell_at(cell: Cell, x: int, y: int) -> void:
	if coords_within_bounds(x, y):
		var i: int = _coords_to_arr_pos(x, y)
		var new_cell = cell.copy()
		new_cell.x = x
		new_cell.y = y
		board_cells[i] = new_cell

## Returns the cell at a given position, if valid,
## or null otherwise.
func get_cell_at(x: int, y: int) -> Cell:
	if coords_within_bounds(x, y):
		var i: int = _coords_to_arr_pos(x, y)
		return board_cells[i]
	else:
		return null

## Returns all valid neighboring cell positions of a given cell position,
## if they are valid positions within the board.
func neighbors_of(x: int, y: int) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = [
		Vector2i(x - 1, y),
		Vector2i(x - 1, y - 1),
		Vector2i(x - 1, y + 1),
		Vector2i(x, y + 1),
		Vector2i(x, y - 1),
		Vector2i(x + 1, y),
		Vector2i(x + 1, y - 1),
		Vector2i(x + 1, y + 1),
	]

	neighbors = neighbors.filter(func(coords: Vector2i): return coords_within_bounds(coords.x, coords.y))
	return neighbors
