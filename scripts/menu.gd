extends Control

@onready var play_button = $VBoxContainer/PlayButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var title_label = $VBoxContainer/TitleLabel

func _ready():
	# Connect button hover signals for additional effects
	play_button.mouse_entered.connect(_on_play_button_hover)
	quit_button.mouse_entered.connect(_on_quit_button_hover)
	
	# Add a subtle entrance animation
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)

func _on_play_button_hover():
	# Create a subtle scale effect on hover
	var tween = create_tween()
	tween.tween_property(play_button, "scale", Vector2(1.05, 1.05), 0.1)
	tween.tween_property(play_button, "scale", Vector2(1.0, 1.0), 0.1)

func _on_quit_button_hover():
	# Create a subtle scale effect on hover
	var tween = create_tween()
	tween.tween_property(quit_button, "scale", Vector2(1.03, 1.03), 0.1)
	tween.tween_property(quit_button, "scale", Vector2(1.0, 1.0), 0.1)

func _on_play_button_pressed():
	# Add a nice transition effect before changing scenes
	var tween = create_tween()
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(self, "scale", Vector2(1.1, 1.1), 0.5)
	await tween.finished
	
	# Load the main game scene
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit_button_pressed():
	# Add a fade out effect before quitting
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	
	# Quit the game
	get_tree().quit()

func _input(event):
	# Allow Enter key to start the game
	if event.is_action_pressed("ui_accept"):
		_on_play_button_pressed()
	# Allow Escape key to quit
	elif event.is_action_pressed("ui_cancel"):
		_on_quit_button_pressed()

