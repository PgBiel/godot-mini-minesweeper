extends CanvasLayer

signal return_button_clicked

enum GameResult {
	IN_PROGRESS,
	GAME_OVER,
	VICTORY
}

var result := GameResult.IN_PROGRESS

func _ready() -> void:
	update_result_view()

func set_mine_count(count: int) -> void:
	%MineCount.text = "Mines: %d" % count

func update_result_view():
	%GameOverLabel.visible = result == GameResult.GAME_OVER
	%VictoryLabel.visible = result == GameResult.VICTORY

func set_result_in_progress():
	result = GameResult.IN_PROGRESS
	update_result_view()

func set_result_game_over():
	result = GameResult.GAME_OVER
	update_result_view()

func set_result_victory():
	result = GameResult.VICTORY
	update_result_view()

func _on_return_button_pressed() -> void:
	return_button_clicked.emit()
