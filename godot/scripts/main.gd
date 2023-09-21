extends Node

@onready var tile_map := $TileMapContainer/TileMapParent/TileMap

func start() -> void:
	$StartMenuHUD.hide()
	var width: int = $StartMenuHUD.user_width
	var height: int = $StartMenuHUD.user_height
	var mines: int = $StartMenuHUD.user_mines
	$IngameHUD.set_mine_count(mines)
	$IngameHUD.show()
	show_tile_map()
	tile_map.init_board(width, height, mines)
	print("starting game")

## Returns to the start menu.
func go_back() -> void:
	hide_tile_map()
	$StartMenuHUD.show_continue()
	switch_to_start_menu()

## Resumes an ongoing game.
func resume_game() -> void:
	switch_to_game_hud()
	show_tile_map()

## Hides the start menu and shows the in-game HUD.
func switch_to_game_hud() -> void:
	$StartMenuHUD.hide()
	$IngameHUD.show()

## Hides the in-game HUD and shows the start menu.
func switch_to_start_menu() -> void:
	$IngameHUD.hide()
	$StartMenuHUD.show()

func show_tile_map() -> void:
	$TileMapContainer.show()
	$TileMapContainer/TileMapParent/TileMap.game_active = true

func hide_tile_map() -> void:
	$TileMapContainer.hide()
	$TileMapContainer/TileMapParent/TileMap.game_active = false

func _on_tile_map_bomb_revealed() -> void:
	tile_map.reveal_all_bombs()
	print("whoops")
