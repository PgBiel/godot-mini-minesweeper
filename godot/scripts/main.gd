extends Node

@onready var tile_map := $TileMapContainer/TileMapParent/TileMap

func start():
	$StartMenuHUD.hide()
	var width: int = $StartMenuHUD.user_width
	var height: int = $StartMenuHUD.user_height
	var mines: int = $StartMenuHUD.user_mines
	$IngameHUD.set_mine_count(mines)
	$IngameHUD.show()

	tile_map.init_board(width, height, mines)
	$TileMapContainer.show()
	print("starting game")

func _on_start_menu_hud_start_button_clicked() -> void:
	start()

func _on_tile_map_bomb_revealed() -> void:
	tile_map.reveal_all_bombs()
	print("whoops")
