extends TileMap

# Represents a Minesweeper cell.
class Cell:
	var revealed := false
	var count := 0
	var is_mine := false

	func unreveal():
		revealed = false

	func set_count(num: int):
		count = clampi(num, 0, 6)

	func set_is_mine(is_mine: bool):
		self.is_mine = is_mine

@export var cell_layer: int = 0
@export var tile_atlas_id: int = 0
@export var tile_atlas_coords_empty_tile: int = 0
@export var tile_atlas_coords_base_turned_tile: int = 1
@export var tile_atlas_coords_turned_tile_1: int = 2

# array of rows of Cell instances
var board_cells: Array[Array] = []

# On click, try to reveal cell
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("tile_reveal"):
		var clicked_tile_pos: Vector2i = local_to_map(event.position)
		print("got click at: " + ("%d" % clicked_tile_pos[0]) + " " + ("%d" % clicked_tile_pos[1]))
		reveal_at(clicked_tile_pos[0], clicked_tile_pos[1])

# Clears and inits the board
func init_board(width: int, height: int) -> void:
	clear()
	add_layer(cell_layer)
	generate_board(width, height)

# Generates the board cell instances and textures
func generate_board(width: int, height: int) -> void:
	board_cells = []
	for y in range(height):
		var row_cells = []
		for x in range(width):
			var cell = Cell.new()
			cell.set_count(randi_range(0, 3))
			row_cells.append(cell)
			display_cell_at(cell, x, y)

		board_cells.append(row_cells)

# converts the empty tile position X to Vector2i
# (assumes the atlas is a straight line, so Y = 0)
func _atlas_coords_empty_tile() -> Vector2i:
	return Vector2i(tile_atlas_coords_empty_tile, 0)

func _atlas_coords_base_turned_tile() -> Vector2i:
	return Vector2i(tile_atlas_coords_base_turned_tile, 0)

func _atlas_coords_turned_tile_num(num: int) -> Vector2i:
	return Vector2i(tile_atlas_coords_turned_tile_1 + clampi(num, 1, 3) - 1, 0)

# Displays [ ] at an unrevealed cell's location
func show_unrevealed_cell_at(x: int, y: int) -> void:
	set_cell(cell_layer, Vector2i(x, y), tile_atlas_id, _atlas_coords_empty_tile())

# Displays [ ] at a turned cell's location
func show_base_turned_cell_at(x: int, y: int) -> void:
	set_cell(cell_layer, Vector2i(x, y), tile_atlas_id, _atlas_coords_base_turned_tile())

# Displays [1], [2], ... at a cell's location
func show_turned_cell_num_at(num: int, x: int, y: int) -> void:
	set_cell(cell_layer, Vector2i(x, y), tile_atlas_id, _atlas_coords_turned_tile_num(num))

# set the cell texture at a given coord, based on its data
func display_cell_at(cell: Cell, x: int, y: int) -> void:
	if not cell.revealed:
		show_unrevealed_cell_at(x, y)
	elif cell.is_mine:
		# TODO
		print("lol")
		show_base_turned_cell_at(x, y)
	elif cell.count == 0:
		show_base_turned_cell_at(x, y)
	else:
		show_turned_cell_num_at(cell.count, x, y)

# try to reveal a cell at given coords
func reveal_at(x: int, y: int) -> void:
	var cell: Cell = board_cells[x][y]
	if not cell.revealed:
		cell.revealed = true
		display_cell_at(cell, x, y)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_board(12, 12)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
