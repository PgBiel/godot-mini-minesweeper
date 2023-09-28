## Global configuration for the game.
extends Node

signal appearance_bg_changed(new_value: Color)

## A setting which is also a color.
class ColorSetting:
	## Setting value.
	## Empty array means there is nothing.
	var value: Array[Color]

	## Signal emitted for this setting.
	var sgn: Signal

	## Default value for this setting.
	var default: Color

	func _init(sgn: Signal, default: Color) -> void:
		self.value = []
		self.sgn = sgn
		self.default = default

	func read() -> Color:
		if value.is_empty():
			return default
		else:
			return value[0]

	func write(new_value: Color) -> void:
		if value.is_empty():
			value.append(new_value)
		else:
			value[0] = new_value
		sgn.emit(new_value)

	func reset() -> void:
		if not value.is_empty():
			value.pop_front()
			sgn.emit(default)

## The game's background setting.
var appearance_bg := ColorSetting.new(appearance_bg_changed, Color("b5732d"))
