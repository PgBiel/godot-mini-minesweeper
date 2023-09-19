class_name Board extends Node

@export var width: int = 1
@export var height: int = 1

# Represents a Board's cell.
class Cell extends RefCounted:
	var x: int
	var y: int

	# Whether the user already clicked on this cell.
	var revealed := true

	# The amount of neighboring mines.
	var count := 0

	# If this cell is a mine.
	var is_mine := false

	func _init(x: int, y: int):
		self.x = x
		self.y = y

	func reveal() -> void:
		revealed = true

	func unreveal() -> void:
		revealed = false

	func is_revealed() -> bool:
		return revealed

	func is_a_mine() -> bool:
		return is_mine

	func get_count() -> int:
		return count

	func set_count(num: int) -> void:
		count = clampi(num, 0, 8)

	func set_is_mine(is_mine: bool) -> void:
		self.is_mine = is_mine

	# Resets this cell to the default state
	# (unrevealed, count of 0, not mine).
	func reset() -> void:
		unreveal()
		count = 0
		is_mine = false

	# Copy this cell.
	func copy() -> Cell:
		var cell := Cell.new(x, y)
		cell.revealed = revealed
		cell.count = count
		cell.is_mine = is_mine
		return cell

# Array of arrays of Cells representing this board.
# Notation: board_cells[Y * width + X]
var board_cells: Array[Cell] = []

func _init(width: int, height: int):
	self.width = width
	self.height = height
	fill_board()

# Fills this board with default cells.
func fill_board() -> void:
	board_cells.clear()
	for i in range(width * height):
		var coords: Vector2i = _arr_pos_to_coords(i)
		var x := coords.x
		var y := coords.y
		board_cells.append(Cell.new(x, y))

# Randomly places mines in this board.
func generate_mines(mine_count: int) -> void:
	var mines_left := mine_count
	var not_mine_filter = func(c: Cell): return not c.is_a_mine()
	var non_mines: Array[Cell] = board_cells.filter(not_mine_filter)
	non_mines.shuffle()

	while mines_left > 0 and not non_mines.is_empty():
		var cell: Cell = non_mines.pop_back()
		cell.is_mine = true
		mines_left -= 1
		for neighbor in neighbors_of(cell.x, cell.y):
			print("neighbor: " + ("%d" % neighbor.x) + ", " + ("%d" % neighbor.y))
			var i := _coords_to_arr_pos(neighbor.x, neighbor.y)
			var neighbor_cell := board_cells[i]
			# increase count of adjacent cells
			neighbor_cell.count += 1

# Inits this board with the given width, height and mine count.
func init_board(width: int, height: int, mine_count: int) -> void:
	self.width = width
	self.height = height
	fill_board()
	generate_mines(mine_count)

func _coords_to_arr_pos(x: int, y: int) -> int:
	return y * width + x

func _arr_pos_to_coords(arr_pos: int) -> Vector2i:
	return Vector2i(arr_pos % width, arr_pos / width)

# Returns true if the coordinates are valid in this board
func coords_within_bounds(x: int, y: int) -> bool:
	return (
		x >= 0
		and y >= 0
		and x < width
		and y < height
	)

# Sets cell values at a position
func set_cell_at(cell: Cell, x: int, y: int) -> void:
	if coords_within_bounds(x, y):
		var i: int = _coords_to_arr_pos(x, y)
		var new_cell = cell.copy()
		new_cell.x = x
		new_cell.y = y
		board_cells[i] = new_cell

# Returns the cell at a given position, if valid,
# or null.
func get_cell_at(x: int, y: int) -> Cell:
	if coords_within_bounds(x, y):
		var i: int = _coords_to_arr_pos(x, y)
		return board_cells[i]
	else:
		return null

# Returns all valid neighboring cell positions of a given cell position
# (Must be a valid coordinate in the board)
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