extends Node

@onready var tile_map := %TileMap

var game_over := false

func _ready() -> void:
	hide_tile_map()

func start() -> void:
	%StartMenuHUD.hide()
	var width: int = %StartMenuHUD.user_width
	var height: int = %StartMenuHUD.user_height
	var mines: int = %StartMenuHUD.user_mines
	%IngameHUD.set_mine_count(mines)
	%IngameHUD.set_result_in_progress()
	%IngameHUD.show()
	tile_map.init_board(width, height, mines)
	game_over = false
	show_tile_map()

## Returns to the start menu.
func go_back() -> void:
	hide_tile_map()
	%StartMenuHUD.show_continue()
	switch_to_start_menu()

## Resumes an ongoing game.
func resume_game() -> void:
	switch_to_game_hud()
	show_tile_map()

## Hides the start menu and shows the in-game HUD.
func switch_to_game_hud() -> void:
	%StartMenuHUD.hide()
	%IngameHUD.show()

## Hides the in-game HUD and shows the start menu.
func switch_to_start_menu() -> void:
	%IngameHUD.hide()
	%StartMenuHUD.show()

func show_tile_map() -> void:
	%TileMapContainer.show()
	%TileMap.game_active = not game_over

func hide_tile_map() -> void:
	%TileMapContainer.hide()
	%TileMap.game_active = false

func end_game() -> void:
	game_over = true
	tile_map.game_active = false

func _on_tile_map_bomb_revealed() -> void:
	tile_map.reveal_all_bombs()
	end_game()
	%IngameHUD.set_result_game_over()

func update_mines_left_count(new_mines_left_count: int) -> void:
	%IngameHUD.set_mine_count(new_mines_left_count)

func _on_tile_map_victory() -> void:
	end_game()
	%IngameHUD.set_result_victory()
