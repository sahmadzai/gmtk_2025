# File: inGameUI.gd
# Description: UI panel for customizing move sequences and sending them to 
#			   the player.
# Authors: Shamsullah Ahmadzai, David Huang, Bruke Amare

extends Control

signal move_inputs_updated(move_sequence)

var selected_button : Button = null
var move_sequence := []
var tween_map: Dictionary = {}

# Map input to icon names and directions
const INPUT_TEXTURES = {
	"ui_up": "keyboard_arrow_up.png",
	"ui_down": "keyboard_arrow_down.png",
	"ui_left": "keyboard_arrow_left.png",
	"ui_right": "keyboard_arrow_right.png"
}

# Maps to vector directions if needed
const INPUT_DIRECTIONS = {
	"ui_up": Vector2.UP,
	"ui_down": Vector2.DOWN,
	"ui_left": Vector2.LEFT,
	"ui_right": Vector2.RIGHT
}

func _ready():
	print("INGAMEUI SCRIPT READY")
	var buttons = get_node("MarginContainer/HBoxContainer/HBoxContainer").get_children() # grabs the number of buttons that are in the scene tree
	move_sequence.resize(buttons.size()) # resizes the internal move sequence counter based on the number of buttons grabbed from the scene tree

	for button in buttons:
		if button is Button:
			#print("Found button: ", button.name)
			button.icon = load("res://assets/kenney_input-prompts_1.4/Keyboard & Mouse/Default/keyboard_question_outline.png")
			button.focus_mode = Control.FOCUS_ALL
			button.mouse_filter = Control.MOUSE_FILTER_STOP
			var result = button.pressed.connect(_on_MoveButton_pressed.bind(button), CONNECT_DEFERRED)
			if result != OK:
				print("Failed to connect pressed() signal for: ", button.name)

func _on_MoveButton_pressed(button: Button):
	# edge case: if a user presses a button, does not make an input, and then presses another button, you need to stop the first button from flashing
	stop_selection_animation(selected_button)
	
	# do normal button things
	selected_button = button
	print("Button press detected: ", button.name)
	start_selection_animation(button)

# Start a fade in/out animation on selected button
func start_selection_animation(button: Button):
	# Kill any existing tween on this button first
	if tween_map.has(button):
		tween_map[button].kill()
		tween_map.erase(button)

	var tween = create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(button, "modulate:a", 0.5, 0.5)
	tween.tween_property(button, "modulate:a", 1.0, 0.5)

	tween_map[button] = tween

# Stops the fade in/out animation on the selected button
func stop_selection_animation(button: Button):
	if tween_map.has(button):
		tween_map[button].kill()
		tween_map.erase(button)

	button.modulate.a = 1.0  # Force full opacity

# Listens and handles the user input on a button and changes the icon to reflect
# the key a user pressed.
func _input(event):
	if selected_button and event is InputEventKey and event.pressed:
		for action in INPUT_TEXTURES.keys():
			if Input.is_action_pressed(action):
				var icon_path = "res://assets/kenney_input-prompts_1.4/Keyboard & Mouse/Default/" + INPUT_TEXTURES[action]
				print("Loading icon: ", icon_path)
				selected_button.icon = load(icon_path)

				# Update move_sequence
				var buttons = get_node("MarginContainer/HBoxContainer/HBoxContainer").get_children()
				var index = buttons.find(selected_button)
				if index != -1:
					move_sequence[index] = action

				stop_selection_animation(selected_button)
				selected_button.release_focus()
				selected_button = null
				emit_signal("move_inputs_updated", move_sequence)
				break

# Handles resetting all sequence inputs and changes the button icons back to default.
func reset_inputs():
	print("bombaclot test") # apparently this function is never run so idk why we have this
	move_sequence = [null, null, null, null] # lowkey remove this entire function idk
	var buttons = get_node("MarginContainer/HBoxContainer/HBoxContainer").get_children()
	for button in buttons:
		if button is Button:
			button.icon = load("res://assets/kenney_input-prompts_1.4/Keyboard & Mouse/Default/keyboard_question_outline.png")
