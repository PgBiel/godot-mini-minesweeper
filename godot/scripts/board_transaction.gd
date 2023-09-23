## Represents an operation on a board of cells.
class_name BoardTransaction extends Node

## Which cells were revealed in this transaction.
var revealed_cells: Array[Vector2i] = []

## Which cells were unrevealed in this transaction.
var unrevealed_cells: Array[Vector2i] = []

## Which cells were flagged in this transaction.
var flagged_cells: Array[Vector2i] = []

## Which cells were unflagged in this transaction.
var unflagged_cells: Array[Vector2i] = []

## Generates the inverse transaction of this one,
## which just undoes this transaction's operations when applied.
func generate_undo() -> BoardTransaction:
	var undo_transaction := BoardTransaction.new()
	undo_transaction.unrevealed_cells.assign(revealed_cells)
	undo_transaction.revealed_cells.assign(unrevealed_cells)
	undo_transaction.flagged_cells.assign(unflagged_cells)
	undo_transaction.unflagged_cells.assign(flagged_cells)
	return undo_transaction

## Applies this transaction to a board, if possible.
##
## Returns 'true' on success, 'false' on failure.
## Does not apply any changes on failure.
## Specify 'true' as the second argument to ignore inconsistency checks,
## thus inhibiting failure.
func apply(board: Board, ignore_failures: bool = false) -> bool:
	var cells_to_change: Array[Board.Cell] = []
	for cell_pos in revealed_cells:
		var cell := board.get_cell_at_pos(cell_pos)
		if cell == null or cell.is_revealed():
			# invalid starting state (cell is null or already revealed)
			if ignore_failures:
				continue
			else:
				return false
		var new_cell := cell.copy()
		new_cell.reveal()
		cells_to_change.append(new_cell)

	for cell_pos in unrevealed_cells:
		var cell := board.get_cell_at_pos(cell_pos)
		if cell == null or not cell.is_revealed():
			# invalid starting state (cell is null or already unrevealed)
			if ignore_failures:
				continue
			else:
				return false
		var new_cell := cell.copy()
		new_cell.reveal()
		cells_to_change.append(new_cell)

	for cell_pos in flagged_cells:
		var cell := board.get_cell_at_pos(cell_pos)
		if cell == null or cell.flagged:
			# invalid starting state (cell is null or already flagged)
			if ignore_failures:
				continue
			else:
				return false
		var new_cell := cell.copy()
		new_cell.flagged = true
		cells_to_change.append(new_cell)

	for cell_pos in unflagged_cells:
		var cell := board.get_cell_at_pos(cell_pos)
		if cell == null or not cell.flagged:
			# invalid starting state (cell is null or already not flagged)
			if ignore_failures:
				continue
			else:
				return false
		var new_cell := cell.copy()
		new_cell.flagged = false
		cells_to_change.append(new_cell)

	# apply all changes
	for cell in cells_to_change:
		board.set_cell_at(cell, cell.x, cell.y)

	return true
