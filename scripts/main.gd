extends Node2D

func _ready():
	var ui = $inGameUI
	var ball_player = $BallPlayer
	ui.connect("move_inputs_updated", Callable(ball_player, "_on_move_inputs_updated"))
	ui.connect("final_move_input_updated", Callable(ball_player, "_on_final_move_input_updated"))
	ball_player.connect("backspace_pressed", Callable(ui, "_on_backspace"))
	ball_player.connect("actions_list_cleared", Callable(ui, "_ready"))
	ball_player.connect("move_started", Callable(ui, "_on_move_started"))
	ball_player.connect("move_finished", Callable(self, "_on_move_finished"))
