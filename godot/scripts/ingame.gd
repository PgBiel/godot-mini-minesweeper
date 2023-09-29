extends Control

## Indicates the user requested to return to the start menu.
signal go_back_requested

var game_over := true

var circle_shader: Shader = preload("res://shaders/circle-tile.gdshader")

func _ready() -> void:
	disable_game()
	GameConfig.effects_tilestyle_changed.connect(update_tilestyle)

## Starts the game. Make sure to call 'enable_game()' afterwards.
## Takes the width and height of the board, alongside its expected
## amount of mines.
func start(width: int, height: int, mines: int) -> void:
	%IngameHUD.set_mine_count(mines)
	%IngameHUD.set_result_in_progress()
	%GameGrid.init_board(width, height, mines)
	game_over = false

## Shows Ingame together with the ingame HUD.
func show_with_hud():
	show()
	%IngameHUD.show()

## Hides both Ingame and the ingame HUD.
func hide_with_hud():
	hide()
	%IngameHUD.hide()

## Enables the user to interact with the game grid,
## if the game isn't over.
func enable_game() -> void:
	%GameGrid.game_active = not game_over

## Disables interaction with the game grid.
func disable_game() -> void:
	%GameGrid.game_active = false

## Triggers game over, and disables interaction
## with the game grid.
func end_game() -> void:
	game_over = true
	%GameGrid.game_active = false

func go_back() -> void:
	go_back_requested.emit()

## When a bomb was revealed, reveal all other bombs,
## trigger game over, and show the game over status.
func _on_game_grid_bomb_revealed() -> void:
	%GameGrid.reveal_all_bombs()
	end_game()
	%IngameHUD.set_result_game_over()

## Updates the mine count in the HUD.
func update_mines_left_count(new_mines_left_count: int) -> void:
	%IngameHUD.set_mine_count(new_mines_left_count)

## Upon victory, end the game and show the victory status.
func _on_game_grid_victory() -> void:
	end_game()
	%IngameHUD.set_result_victory()

## Updates the game grid's tile style.
func update_tilestyle(new_value: GameConfig.TileStyle):
	match new_value:
		GameConfig.TileStyle.SQUARE:
			%GameGrid.material = null
		GameConfig.TileStyle.CIRCLE:
			var material := ShaderMaterial.new()
			material.shader = circle_shader
			%GameGrid.material = material
