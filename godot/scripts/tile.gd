extends Area2D

# An attempt to reveal the tile was made.
signal reveal

# []  (not yet revealed)
static var unrevealed_texture = preload("res://assets/art/empty-tile.png")

# [1], [2], [3]
static var number_textures = [
	preload("res://assets/art/base-turned-tile.png"),
	preload("res://assets/art/turned-tile-1.png"),
	preload("res://assets/art/turned-tile-2.png"),
	preload("res://assets/art/turned-tile-3.png")
]

# Whether or not this tile was revealed so far
var revealed := false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("tile_reveal"):
		print("Got reveal event: " + ("REVEALED" if revealed else "NOT REVEALED"))
		if not revealed:
			reveal.emit()

# unreveals this tile (displays default texture)
func unreveal() -> void:
	revealed = false
	$Sprite2D.texture = unrevealed_texture

# reveal this tile with the given number
func reveal_num(num: int) -> void:
	revealed = true
	var texture_index: int = clampi(num, 0, 3)
	$Sprite2D.texture = number_textures[texture_index]
