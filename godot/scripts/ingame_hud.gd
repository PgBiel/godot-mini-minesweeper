extends CanvasLayer

signal return_button_clicked

func set_mine_count(count: int) -> void:
	$Titlebar/MineCount.text = "Mines: %d" % count


func _on_return_button_pressed() -> void:
	return_button_clicked.emit()
