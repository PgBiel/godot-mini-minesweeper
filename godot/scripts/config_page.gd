extends Control

## Signals the user clicked "BACK" to return to the start menu.
signal go_back_requested

func _ready() -> void:
	# disable 'swatches' and 'recent colors'
	var picker: ColorPicker = %ThemePicker.get_picker()
	picker.presets_visible = false

func _on_return_button_pressed() -> void:
	go_back_requested.emit()
