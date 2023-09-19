extends CanvasLayer

signal start_button_clicked

## User-provided grid width (in cells)
var user_width: int = 0
## User-provided grid height (in cells)
var user_height: int = 0
## User-provided mine count
var user_mines: int = 0

## Sets max mines to width * height
func update_max_mines():
	$ConfigContainer/MinesInput.max_value = user_width * user_height

## Resets the configuration values
func reset():
	$ConfigContainer/WidthInput.value = 0.0
	$ConfigContainer/HeightInput.value = 0.0
	$ConfigContainer/MinesInput.value = 0.0
	user_width = 0
	user_height = 0
	user_mines = 0

func _on_width_input_value_changed(value: float) -> void:
	user_width = maxi(value as int, 0)
	update_max_mines()

func _on_height_input_value_changed(value: float) -> void:
	user_height = maxi(value as int, 0)
	update_max_mines()

func _on_mines_input_value_changed(value: float) -> void:
	user_mines = clampi(value as int, 0, user_width * user_height)


func _on_start_button_pressed() -> void:
	start_button_clicked.emit()
