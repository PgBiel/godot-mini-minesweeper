extends CanvasLayer

signal start_button_clicked
signal continue_button_clicked

## User-provided grid width (in cells)
var user_width: int = 0
## User-provided grid height (in cells)
var user_height: int = 0
## User-provided mine count
var user_mines: int = 0

## Default values for each board preset.
## Each preset is a dictionary with the following properties:
## - name: String => The displayed name for the preset.
## - width: int => The board's width for that preset.
## - height: int => The board's height for that preset.
## - mines: int => The board's mine count for that preset.
@export var presets: Array[Dictionary] = [
	{ name = "Basic", width = 9, height = 9, mines = 10 },
	{ name = "Medium", width = 16, height = 16, mines = 40 },
	{ name = "Expert", width = 16, height = 30, mines = 99 },
	{ name = "Custom", width = 0, height = 0, mines = 0 },
]

## Index, in the presets array, of the "Custom" preset.
## It is selected when the user starts typing something in the inputs.
## Set to -1 to disable.
@export var custom_preset_index = 3

## Index of the default preset to show when the user
## performs no PresetInput selection.
@export var default_preset_index = 0

## Whether the 'Continue' button is currently shown.
@export var continue_shown: bool = false

func _ready() -> void:
	%ContinueButton.visible = continue_shown
	update_start_button_disable()
	_display_presets()

## Updates the presets shown in the PresetInput
## based on the 'presets' array.
func _display_presets():
	%PresetInput.clear()
	var id: int = 0
	for preset in presets:
		var name: String = preset["name"]
		var width: int = preset["width"]
		var height: int = preset["height"]
		var mines: int = preset["mines"]
		%PresetInput.add_item(name, id)
		id += 1
	%PresetInput.select(default_preset_index)
	apply_preset(default_preset_index)

## Sets max mines to width * height
func update_max_mines():
	var new_max_mines := user_width * user_height
	%MinesInput.max_value = new_max_mines
	%MinesInput.value = mini(%MinesInput.value, new_max_mines)
	update_start_button_disable()

func update_start_button_disable():
	%StartButton.disabled = user_mines == 0
	if %StartButton.disabled:
		%StartButton.tooltip_text = "Requires more than 0 mines"
	else:
		%StartButton.tooltip_text = ""

## Resets the configuration values
func reset():
	%WidthInput.value = 0.0
	%HeightInput.value = 0.0
	%MinesInput.value = 0.0
	user_width = 0
	user_height = 0
	user_mines = 0
	update_start_button_disable()

func show_continue():
	continue_shown = true
	%ContinueButton.show()

func hide_continue():
	continue_shown = false
	%ContinueButton.hide()

## Changes the currently selected preset
## to the preset marked as "Custom", as per the
## 'custom_preset_index' variable.
## No-op if 'custom_preset_index' contains a negative value.
func select_custom_preset() -> void:
	if custom_preset_index >= 0:
		%PresetInput.select(custom_preset_index)

func _set_width(value: int, update_input: bool = false):
	user_width = maxi(value, 0)
	if update_input:
		%WidthInput.set_value_no_signal(user_width as float)
		update_max_mines()

func _set_height(value: int, update_input: bool = false):
	user_height = maxi(value, 0)
	if update_input:
		%HeightInput.set_value_no_signal(user_height as float)
		update_max_mines()

func _set_mines(value: int, update_input: bool = false):
	user_mines = clampi(value, 0, user_width * user_height)
	if update_input:
		%MinesInput.set_value_no_signal(user_mines as float)
		update_start_button_disable()

func _on_width_input_value_changed(value: float) -> void:
	_set_width(value as int, false)
	update_max_mines()
	select_custom_preset()

func _on_height_input_value_changed(value: float) -> void:
	_set_height(value as int, false)
	update_max_mines()
	select_custom_preset()

func _on_mines_input_value_changed(value: float) -> void:
	_set_mines(value as int, false)
	update_start_button_disable()
	select_custom_preset()

func _on_start_button_pressed() -> void:
	start_button_clicked.emit()

func _on_continue_button_pressed() -> void:
	continue_button_clicked.emit()

func apply_preset(index: int) -> void:
	if index >= 0 and index < presets.size():
		var preset: Dictionary = presets[index]
		var width: int = preset["width"]
		var height: int = preset["height"]
		var mines: int = preset["mines"]
		# update variables AND inputs' visible values
		_set_width(width, true)
		_set_height(height, true)
		_set_mines(mines, true)
	else:
		print_debug("[!!!] Somehow got an invalid index from PresetInput: %d" % index)
