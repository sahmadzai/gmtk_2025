extends Control

@onready var try_again_button = $VBoxContainer/TryAgainButton
@onready var main_menu_button = $VBoxContainer/MainMenuButton
@onready var you_win_label = $VBoxContainer/YouWinLabel
@onready var tryagainbtn_hover = $VBoxContainer/TryAgainButton/HoverSFX
@onready var mainmenubtn_hover = $VBoxContainer/MainMenuButton/HoverSFX

func _ready():
	# Set the buttons pivot offset to the center for cleaner animations
	try_again_button.pivot_offset = try_again_button.size / 2
	main_menu_button.pivot_offset = main_menu_button.size / 2
	
	# Connect button hover signals for additional effects
	try_again_button.mouse_entered.connect(_on_try_again_button_hover)
	main_menu_button.mouse_entered.connect(_on_main_menu_button_hover)
	
	# Trigger title idle animation
	_play_title_idle_animation()
	
func _play_title_idle_animation():
	# Add floating animation to title label
	var float_tween = create_tween()
	float_tween.set_loops()
	var original_y = you_win_label.position.y
	float_tween.tween_property(you_win_label, "position:y", original_y - 6, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	float_tween.tween_property(you_win_label, "position:y", original_y, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_try_again_button_hover():
	# Create a subtle scale effect on hover
	var tween = create_tween()
	tween.tween_property(try_again_button, "scale", Vector2(1.05, 1.05), 0.1)
	tween.tween_property(try_again_button, "scale", Vector2(1.0, 1.0), 0.1)
	
	# Trigger hover sound effect
	tryagainbtn_hover.play()

func _on_main_menu_button_hover():
	# Create a subtle scale effect on hover
	var tween = create_tween()
	tween.tween_property(main_menu_button, "scale", Vector2(1.03, 1.03), 0.1)
	tween.tween_property(main_menu_button, "scale", Vector2(1.0, 1.0), 0.1)
	
	# Trigger hover sound effect
	mainmenubtn_hover.play()

func _on_try_again_button_pressed():
	# Add a fade to black transition effect before going to main menu
	TransitionScreen.transition(2)
	await TransitionScreen.on_transition_finished
	
	# Restart the game by loading the main game scene
	get_tree().change_scene_to_file("res://scenes/tutorial01.tscn")

func _on_main_menu_button_pressed():
	# Add a fade to black transition effect before going to main menu
	TransitionScreen.transition(2)
	await TransitionScreen.on_transition_finished
	
	# Go back to the main menu
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

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
