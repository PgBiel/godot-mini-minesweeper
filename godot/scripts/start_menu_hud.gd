extends CanvasLayer

## User-provided grid width
var user_width: int = 0
## User-provided grid height
var user_height: int = 0
## User-provided mine count
var user_mines: int = 0

func update_max_mines():
	$ConfigContainer/MinesInput.max_value = user_width * user_height

func _on_width_input_value_changed(value: float) -> void:
	user_width = maxi(value as int, 0)
	update_max_mines()

func _on_height_input_value_changed(value: float) -> void:
	user_height = maxi(value as int, 0)
	update_max_mines()

func _on_mines_input_value_changed(value: float) -> void:
	user_mines = clampi(value as int, 0, user_width * user_height)
