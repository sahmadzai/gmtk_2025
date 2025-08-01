extends Node2D

func _ready():
	var ui = $inGameUI
	var player = $Player
	ui.connect("move_inputs_updated", Callable(player, "_on_move_inputs_updated"))
	ui.connect("final_move_input_updated", Callable(player, "_on_final_move_input_updated"))
	player.connect("backspace_pressed", Callable(ui, "_on_backspace"))
