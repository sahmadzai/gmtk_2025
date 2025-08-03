extends Control

@onready var play_button = $VBoxContainer/PlayButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var title_label = $VBoxContainer/VBoxContainer/TitleLabel
@onready var playbtn_hover = $VBoxContainer/PlayButton/HoverSFX
@onready var quitbtn_hover = $VBoxContainer/QuitButton/HoverSFX


func _ready():
	# Set the buttons pivot offset to the center for cleaner animations
	play_button.pivot_offset = play_button.size / 2
	quit_button.pivot_offset = quit_button.size / 2
	
	# Connect button hover signals for additional effects
	play_button.mouse_entered.connect(_on_play_button_hover)
	quit_button.mouse_entered.connect(_on_quit_button_hover)
	
	# Add a subtle entrance animation
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)
	
	# Trigger title idle animation
	_play_title_idle_animation()
	
func _play_title_idle_animation():
	# Add floating animation to title label
	var float_tween = create_tween()
	float_tween.set_loops()
	var original_y = title_label.position.y
	float_tween.tween_property(title_label, "position:y", original_y - 6, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	float_tween.tween_property(title_label, "position:y", original_y, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_play_button_hover():
	# Create a subtle scale effect on hover
	var tween = create_tween()
	tween.tween_property(play_button, "scale", Vector2(1.05, 1.05), 0.1)
	tween.tween_property(play_button, "scale", Vector2(1.0, 1.0), 0.1)
	
	# Trigger hover sound effect
	playbtn_hover.play()

func _on_quit_button_hover():
	# Create a subtle scale effect on hover
	var tween = create_tween()
	tween.tween_property(quit_button, "scale", Vector2(1.03, 1.03), 0.1)
	tween.tween_property(quit_button, "scale", Vector2(1.0, 1.0), 0.1)
	
	# Trigger hover sound effect
	quitbtn_hover.play()

func _on_play_button_pressed():
	# Optional: disable input to avoid double-press
	set_process_input(false)

	# Fade to black
	TransitionScreen.transition(2)
	await TransitionScreen.on_transition_finished

	# Load the main game scene
	get_tree().change_scene_to_file("res://scenes/tutorial01.tscn")

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
