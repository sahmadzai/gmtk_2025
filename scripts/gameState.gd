extends Node

var was_win_transition := false
var next_scene_path := ""
var shot_count: int = 0

# Dictionary of starting positions for each level0
var level_start_positions := {
	"tutorial01": Vector2(88, 104),
	"tutorial02": Vector2(136, 40),
	"tutorial03": Vector2(104, 32),
	"level01": Vector2(104, 88),
	"level02": Vector2(88, 152),
	"level03": Vector2(152, 104),
	"level04": Vector2(216, 56)
}

# Dictionary mapping current scene name to next scene path
var level_progression := {
	"tutorial01": "res://scenes/tutorial02.tscn",
	"tutorial02": "res://scenes/tutorial03.tscn",
	"tutorial03": "res://scenes/level01.tscn",
	#"tutorial03": "res://scenes/credits.tscn", # Comment in PROD, just testing end screen
	"level01": "res://scenes/level02.tscn",
	"level02": "res://scenes/level03.tscn",
	"level03": "res://scenes/level04.tscn",
	"level04": "res://scenes/credits.tscn"
}

# Dictionary mapping of how many input‐buttons each level0 has
var max_inputs := {
	"tutorial01": 1,
	"tutorial02": 4,
	"tutorial03": 5,
	"level01":     5,
	"level02":     5,
	"level03":     3,
	"level04":     1,
}

func get_next_scene_path(current_scene_name: String) -> String:
	return level_progression.get(current_scene_name, "res://scenes/tutorial01.tscn")
