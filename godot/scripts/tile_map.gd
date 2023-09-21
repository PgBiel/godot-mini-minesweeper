extends TileMap

signal bomb_revealed

@export var cell_layer: int = 0
@export var tile_atlas_id: int = 0
@export var tile_atlas_coords_empty_tile: int = 0
@export var tile_atlas_coords_flag_tile: int = 1
@export var tile_atlas_coords_bomb_tile: int = 2
@export var tile_atlas_coords_base_turned_tile: int = 3
@export var tile_atlas_coords_turned_tile_1: int = 4

## Currently active minesweeper board
var board: Board

## Whether the game is active and we should respond to clicks on the grid
var game_active := false

## Whether we have already generated mines on the grid
var mines_placed := false

## Total amount of mines we are expected to have on the grid
var mine_count := 0

# On click, try to reveal cell
# (also generate mines if they were not already generated)
func _unhandled_input(event: InputEvent) -> void:
	if board != null and game_active:
		var get_clicked_pos := func() -> Vector2i:
			# convert global pos to local
			# fixes scaling problem
			var local_pos: Vector2i = to_local(event.position)
			var clicked_tile_pos: Vector2i = local_to_map(local_pos)
			return clicked_tile_pos

		if event.is_action_released("tile_reveal"):
			var clicked_tile_pos: Vector2i = get_clicked_pos.call()
			if not mines_placed:
				mines_placed = true
				# exclude the clicked pos from mine placement, if possible
				board.generate_mines(mine_count, [clicked_tile_pos])

			# reveal the clicked cell, plus, if it had a count of zero,
			# reveal its neighbors recursively
			var adjacent_vein_cells := board.get_empty_tile_vein(clicked_tile_pos.x, clicked_tile_pos.y)
			for pos in adjacent_vein_cells:
				reveal_cell_at(pos.x, pos.y)

		elif event.is_action_released("tile_flag"):
			var clicked_tile_pos: Vector2i = get_clicked_pos.call()
			toggle_flag_at(clicked_tile_pos.x, clicked_tile_pos.y)

## Clears and inits the board
func init_board(width: int, height: int, mine_count: int) -> void:
	clear_layer(cell_layer)
	generate_board(width, height)
	mines_placed = false
	self.mine_count = mine_count
	center_tilemap_horizontally()

## Generates the board cell instances and textures
func generate_board(width: int, height: int) -> void:
	board = Board.new(width, height)
	# we place mines on first click
	for y in range(height):
		for x in range(width):
			var cell := board.get_cell_at(x, y)
			display_cell_at(cell, x, y)

## Make a vector at y = 0 with the given x
##
## We use this for tile atlas coords, as we assume the tile atlas
## is a straight line.
func x_at_first_row(x: int) -> Vector2i:
	return Vector2i(x, 0)

## Returns tile atlas position for cell with the given number
##
## Basically adds the number to the position of the tile for "1"
func _atlas_coords_turned_tile_num(num: int) -> Vector2i:
	return x_at_first_row(tile_atlas_coords_turned_tile_1 + clampi(num, 1, 8) - 1)

## Displays [ ] at an unrevealed cell's location
func show_unrevealed_cell_at(x: int, y: int) -> void:
	set_cell(cell_layer, Vector2i(x, y), tile_atlas_id, x_at_first_row(tile_atlas_coords_empty_tile))

## Displays [ ] at a turned cell's location
func show_base_turned_cell_at(x: int, y: int) -> void:
	set_cell(cell_layer, Vector2i(x, y), tile_atlas_id, x_at_first_row(tile_atlas_coords_base_turned_tile))

## Displays a flag at an unrevealed cell's location
func show_flag_cell_at(x: int, y: int) -> void:
	set_cell(cell_layer, Vector2i(x, y), tile_atlas_id, x_at_first_row(tile_atlas_coords_flag_tile))

## Displays a bomb at a revealed cell's location
func show_bomb_cell_at(x: int, y: int) -> void:
	set_cell(cell_layer, Vector2i(x, y), tile_atlas_id, x_at_first_row(tile_atlas_coords_bomb_tile))

## Displays [1], [2], ... at a cell's location
func show_turned_cell_num_at(num: int, x: int, y: int) -> void:
	set_cell(cell_layer, Vector2i(x, y), tile_atlas_id, _atlas_coords_turned_tile_num(num))

## Set the cell texture at a given coord, based on its data
func display_cell_at(cell: Board.Cell, x: int, y: int) -> void:
	if not cell.is_revealed():
		if cell.flagged:
			show_flag_cell_at(x, y)
		else:
			show_unrevealed_cell_at(x, y)
	elif cell.is_a_mine():
		show_bomb_cell_at(x, y)
	elif cell.get_count() == 0:
		show_base_turned_cell_at(x, y)
	else: # revealed cell, not a mine, count > 0
		show_turned_cell_num_at(cell.count, x, y)

## Try to reveal a cell at given coords (after player clicked there)
func reveal_cell_at(x: int, y: int) -> void:
	var cell := board.get_cell_at(x, y)
	if cell != null and not cell.is_revealed():
		cell.reveal()
		display_cell_at(cell, x, y)
		if cell.is_a_mine():
			bomb_revealed.emit()

## Toggles whether a cell at a position is flagged.
## Updates the Board instance and also the cell's graphical appearance.
func toggle_flag_at(x: int, y: int) -> void:
	var cell: Board.Cell = board.get_cell_at(x, y)
	if cell != null:
		board.toggle_cell_flag(x, y)
		display_cell_at(cell, x, y)

## Called by main scene, reveals all bombs in the grid
func reveal_all_bombs() -> void:
	for mine in board.get_all_mines():
		show_bomb_cell_at(mine.x, mine.y)

## Calculate a TileMap's bounds
##
## From https://ask.godotengine.org/3276/tilemap-size
func calculate_bounds(tilemap: TileMap) -> Rect2:
	var cell_bounds: Rect2 = tilemap.get_used_rect()
	var tile_size = tilemap.tile_set.tile_size
	# create transform
	var cell_to_pixel = Transform2D(
		Vector2(tile_size.x * tilemap.scale.x, 0),
		Vector2(0, tile_size.y * tilemap.scale.y),
		Vector2()
	)
	# apply transform
	return Rect2(cell_to_pixel * cell_bounds.position, cell_to_pixel * cell_bounds.size)

## Nudge the TileMap to the left a bit so that placing it by its top left
## centers it
func center_tilemap_horizontally() -> void:
	var total_width: float = get_viewport().size.x
	var self_width: float = calculate_bounds(self).size.x
	var new_x: float = maxf(-total_width / 2, -self_width / 2)

	position.x = new_x
