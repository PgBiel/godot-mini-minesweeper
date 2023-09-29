## Global configuration for the game.
extends Node

signal appearance_bg_changed(new_value: Color)
signal effects_tilestyle_changed(new_value: TileStyle)

## Possible tile styles.
enum TileStyle {
	SQUARE,
	CIRCLE
}

## A generic setting.
class Setting:
	## Setting value.
	## Empty array means there is nothing.
	var _value: Array

	## Signal emitted for this setting.
	var sgn: Signal

	## Default value for this setting.
	var _default

	func _init(sgn: Signal, default) -> void:
		self._value = []
		self.sgn = sgn
		self._default = default

	## Reads this setting's value.
	func read():
		if _value.is_empty():
			return _default
		else:
			return _value[0]

	## Writes a new value for this setting.
	func write(new_value) -> void:
		if _value.is_empty():
			_value.append(new_value)
		else:
			_value[0] = new_value
		sgn.emit(new_value)

	## Resets this setting to its default.
	func reset() -> void:
		if not _value.is_empty():
			_value.pop_front()
			sgn.emit(_default)

## A setting which is also a color.
class ColorSetting extends Setting:
	func _init(sgn: Signal, default: Color) -> void:
		super(sgn, default)

	func read() -> Color:
		return super()

	func write(new_value: Color) -> void:
		super(new_value)

## A setting which is also a TileStyle.
class TileStyleSetting extends Setting:
	func _init(sgn: Signal, default: TileStyle) -> void:
		super(sgn, default)

	func read() -> TileStyle:
		return super()

	func write(new_value: TileStyle) -> void:
		super(new_value)

## The game's background setting.
var appearance_bg := ColorSetting.new(appearance_bg_changed, Color("b5732d"))

## Tile style effect to apply.
var effects_tilestyle := \
	TileStyleSetting.new(effects_tilestyle_changed, TileStyle.SQUARE)
