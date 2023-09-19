extends TileMap

@export var cell_layer: int = 0
@export var tile_atlas_id: int = 0
@export var tile_atlas_coords_empty_tile: int = 0
@export var tile_atlas_coords_bomb_tile: int = 1
@export var tile_atlas_coords_base_turned_tile: int = 2
@export var tile_atlas_coords_turned_tile_1: int = 3

# minesweeper board
var board: Board

# On click, try to reveal cell
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("tile_reveal"):
		# convert global pos to local
		# fixes scaling problem
		var local_pos = to_local(event.position)
		var clicked_tile_pos: Vector2i = local_to_map(local_pos)
		reveal_cell_at(clicked_tile_pos[0], clicked_tile_pos[1])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_board(12, 12)
	print("hello")

# Clears and inits the board
func init_board(width: int, height: int) -> void:
	clear_layer(cell_layer)
	generate_board(width, height)

# Generates the board cell instances and textures
func generate_board(width: int, height: int) -> void:
	board = Board.new(width, height)
	board.generate_mines(10)
	for y in range(height):
		for x in range(width):
			var cell := board.get_cell_at(x, y)
			display_cell_at(cell, x, y)

# make a vector at position 0
# we use this for tile atlas coords, as we assume the tile atlas
# is a straight line.
func x_at_first_row(x: int) -> Vector2i:
	return Vector2i(x, 0)

# returns atlas position for cell with the given number
# basically adds the number to the position of the tile for "1"
func _atlas_coords_turned_tile_num(num: int) -> Vector2i:
	return x_at_first_row(tile_atlas_coords_turned_tile_1 + clampi(num, 1, 8) - 1)

# Displays [ ] at an unrevealed cell's location
func show_unrevealed_cell_at(x: int, y: int) -> void:
	set_cell(cell_layer, Vector2i(x, y), tile_atlas_id, x_at_first_row(tile_atlas_coords_empty_tile))

# Displays [ ] at a turned cell's location
func show_base_turned_cell_at(x: int, y: int) -> void:
	set_cell(cell_layer, Vector2i(x, y), tile_atlas_id, x_at_first_row(tile_atlas_coords_base_turned_tile))

# Displays [ ] at a turned cell's location
func show_bomb_cell_at(x: int, y: int) -> void:
	set_cell(cell_layer, Vector2i(x, y), tile_atlas_id, x_at_first_row(tile_atlas_coords_bomb_tile))

# Displays [1], [2], ... at a cell's location
func show_turned_cell_num_at(num: int, x: int, y: int) -> void:
	set_cell(cell_layer, Vector2i(x, y), tile_atlas_id, _atlas_coords_turned_tile_num(num))

# set the cell texture at a given coord, based on its data
func display_cell_at(cell: Board.Cell, x: int, y: int) -> void:
	if not cell.is_revealed():
		show_unrevealed_cell_at(x, y)
	elif cell.is_a_mine():
		show_bomb_cell_at(x, y)
	elif cell.get_count() == 0:
		show_base_turned_cell_at(x, y)
	else:
		show_turned_cell_num_at(cell.count, x, y)
	print("yay! " + ("%d" % x) + ", " + ("%d" % y) + "!")

# try to reveal a cell at given coords
func reveal_cell_at(x: int, y: int) -> void:
	var cell := board.get_cell_at(x, y)
	if cell != null and not cell.is_revealed():
		cell.reveal()
		display_cell_at(cell, x, y)
		if cell.is_a_mine():
			print("mine hit!")
