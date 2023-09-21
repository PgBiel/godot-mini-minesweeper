extends CanvasLayer

signal start_button_clicked
signal continue_button_clicked

## User-provided grid width (in cells)
var user_width: int = 0
## User-provided grid height (in cells)
var user_height: int = 0
## User-provided mine count
var user_mines: int = 0

@export var continue_shown: bool = false

func _ready() -> void:
	$ContinueButton.visible = continue_shown

## Sets max mines to width * height
func update_max_mines():
	var new_max_mines := user_width * user_height
	$ConfigContainer/MinesInput.max_value = new_max_mines
	$ConfigContainer/MinesInput.value = mini($ConfigContainer/MinesInput.value, new_max_mines)

## Resets the configuration values
func reset():
	$ConfigContainer/WidthInput.value = 0.0
	$ConfigContainer/HeightInput.value = 0.0
	$ConfigContainer/MinesInput.value = 0.0
	user_width = 0
	user_height = 0
	user_mines = 0

func show_continue():
	continue_shown = true
	$ContinueButton.show()

func hide_continue():
	continue_shown = false
	$ContinueButton.hide()

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


func _on_continue_button_pressed() -> void:
	continue_button_clicked.emit()
