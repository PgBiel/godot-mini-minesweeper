extends Node

func _ready() -> void:
	switch_to_start_menu()

## Starts the game (upon start button click).
func start() -> void:
	var width: int = %StartMenuHUD.user_width
	var height: int = %StartMenuHUD.user_height
	var mines: int = %StartMenuHUD.user_mines
	%Ingame.start(width, height, mines)
	switch_to_ingame()
	%Ingame.enable_game()

## Returns to the start menu when the user clicks "BACK"
## from ingame.
func go_back() -> void:
	%StartMenuHUD.show_continue()
	switch_to_start_menu()

## Resumes an ongoing game.
func resume_game() -> void:
	switch_to_ingame()

func hide_huds_and_menus() -> void:
	%StartMenuHUD.hide()
	%Ingame.disable_game()
	%Ingame.hide_with_hud()
	%ConfigPage.hide()

## Hides the start menu and shows the in-game HUD and UI.
func switch_to_ingame() -> void:
	hide_huds_and_menus()
	%Ingame.show_with_hud()
	%Ingame.enable_game()

## Hides the in-game HUD and UI and shows the start menu.
func switch_to_start_menu() -> void:
	hide_huds_and_menus()
	%StartMenuHUD.show()

func switch_to_settings() -> void:
	hide_huds_and_menus()
	%ConfigPage.show()
