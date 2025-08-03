extends Control

@onready var try_again_button = $VBoxContainer/TryAgainButton
@onready var main_menu_button = $VBoxContainer/MainMenuButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var game_over_label = $VBoxContainer/GameOverLabel
@onready var animation_player = $AnimationPlayer

func _ready():
	# Connect button hover signals for additional effects
	try_again_button.mouse_entered.connect(_on_try_again_button_hover)
	main_menu_button.mouse_entered.connect(_on_main_menu_button_hover)
	quit_button.mouse_entered.connect(_on_quit_button_hover)
	
	# Start the fade-in animation
	animation_player.play("fade_in")
	
	# After fade-in, start the pulse animation
	await animation_player.animation_finished
	animation_player.play("pulse")

func _on_try_again_button_hover():
	# Create a subtle scale effect on hover
	var tween = create_tween()
	tween.tween_property(try_again_button, "scale", Vector2(1.05, 1.05), 0.1)
	tween.tween_property(try_again_button, "scale", Vector2(1.0, 1.0), 0.1)

func _on_main_menu_button_hover():
	# Create a subtle scale effect on hover
	var tween = create_tween()
	tween.tween_property(main_menu_button, "scale", Vector2(1.03, 1.03), 0.1)
	tween.tween_property(main_menu_button, "scale", Vector2(1.0, 1.0), 0.1)

func _on_quit_button_hover():
	# Create a subtle scale effect on hover
	var tween = create_tween()
	tween.tween_property(quit_button, "scale", Vector2(1.03, 1.03), 0.1)
	tween.tween_property(quit_button, "scale", Vector2(1.0, 1.0), 0.1)

func _on_try_again_button_pressed():
	# Add a nice transition effect before restarting the game
	animation_player.stop()
	var tween = create_tween()
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(self, "scale", Vector2(1.1, 1.1), 0.5)
	await tween.finished
	
	# Restart the game by loading the main game scene
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_main_menu_button_pressed():
	# Add a transition effect before going to main menu
	animation_player.stop()
	var tween = create_tween()
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.4)
	tween.parallel().tween_property(self, "scale", Vector2(0.9, 0.9), 0.4)
	await tween.finished
	
	# Go back to the main menu
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_quit_button_pressed():
	# Add a fade out effect before quitting
	animation_player.stop()
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	
	# Quit the game
	get_tree().quit()

func _input(event):
	# Allow Enter key to try again
	if event.is_action_pressed("ui_accept"):
		_on_try_again_button_pressed()
	# Allow Escape key to go to main menu
	elif event.is_action_pressed("ui_cancel"):
		_on_main_menu_button_pressed()

# Function to be called when the player dies (for future implementation)
func show_game_over():
	# This function can be called from the game when the player dies
	# It will show this scene with the fade-in animation
	visible = true
	animation_player.play("fade_in")

