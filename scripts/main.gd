# File: MainScene.gd
# Description: Root scene script for connecting UI signals to the Player.
# Authors: Shamsullah Ahmadzai, David Huang, Bruke Amare

extends Node2D

func _ready():
	var ui = $inGameUI
	var player = $Player
	ui.connect("move_inputs_updated", Callable(player, "_on_move_inputs_updated"))
