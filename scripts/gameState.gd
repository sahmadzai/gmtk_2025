extends Node

var was_win_transition := false
var next_scene_path := ""

# Dictionary of starting positions for each level
var level_start_positions := {
	"tutorial01": Vector2(88, 104),
	"tutorial02": Vector2(136, 40),
	"tutorial03": Vector2(104, 32),
	"level01": Vector2(88, 81),
	"level02": Vector2(104, 177),
	"level03": Vector2(152, 113),
	"level04": Vector2(152, 113)
}

# Dictionary mapping current scene name to next scene path
var level_progression := {
	"tutorial01": "res://scenes/tutorial02.tscn",
	"tutorial02": "res://scenes/tutorial03.tscn",
	#"tutorial03": "res://scenes/level01.tscn",
	"tutorial03": "res://scenes/credits.tscn", # Comment in PROD, just testing end screen
	"level01": "res://scenes/level02.tscn",
	"level02": "res://scenes/level03.tscn",
	"level03": "res://scenes/level04.tscn"
}

func get_next_scene_path(current_scene_name: String) -> String:
	return level_progression.get(current_scene_name, "res://scenes/tutorial01.tscn")
