extends Control

signal move_inputs_updated(move_sequence)
signal final_move_input_updated(move_sequence)

# --- constants ---
# Map input to icon names and directions
var INPUT_TEXTURES: Dictionary # {string: Texture2D}
# Maps to vector directions if needed
const INPUT_DIRECTIONS = {
	"ui_up":    Vector2.UP,
	"ui_down":  Vector2.DOWN,
	"ui_left":  Vector2.LEFT,
	"ui_right": Vector2.RIGHT
}
var DEFAULT_BUTTON_ICON: Texture2D

# --- variables ---
var selected_button : Button = null
var move_sequence := []
var tween_map: Dictionary = {}
var should_auto_focus = true
var shot_count: int = 0
@onready var shot_count_label: Label = $"MarginContainer/BottomRow/ShotCount/ShotCount"

func _get_buttons():
	return get_node("MarginContainer/BottomRow/InputsContainer/HBoxContainer").get_children()

func _ready():
	print("INGAMEUI SCRIPT READY")
	
	# --- runtime constants --- (so we don't have to load() a million times elsewhere)
	INPUT_TEXTURES = {
		"ui_up":          load("res://assets/kenney_input-prompts_1.4/Keyboard & Mouse/Default/keyboard_arrow_up.png"),
		"ui_down":        load("res://assets/kenney_input-prompts_1.4/Keyboard & Mouse/Default/keyboard_arrow_down.png"),
		"ui_left":        load("res://assets/kenney_input-prompts_1.4/Keyboard & Mouse/Default/keyboard_arrow_left.png"),
		"ui_right":       load("res://assets/kenney_input-prompts_1.4/Keyboard & Mouse/Default/keyboard_arrow_right.png"),
	}
	DEFAULT_BUTTON_ICON = load("res://assets/kenney_input-prompts_1.4/Keyboard & Mouse/Default/keyboard_question_outline.png")
	
	# --- setup ---
		
	# show the persisted count
	shot_count_label.text = "%d" % GameState.shot_count
	
	# bump the counter each time the user inputs a move sequence
	connect("final_move_input_updated", Callable(self, "_on_shot_fired"))
	
	var buttons = _get_buttons()         # grabs the number of buttons that are in the scene tree
	move_sequence.resize(buttons.size()) # resizes the internal move sequence counter based on the number of buttons grabbed from the scene tree

	for button in buttons:
		if button is Button:
			button.icon = DEFAULT_BUTTON_ICON
			button.focus_mode = Control.FOCUS_ALL
			button.mouse_filter = Control.MOUSE_FILTER_STOP
			
			if len(move_sequence) - move_sequence.count(null):
				# already populated move_sequence means we're coming back in here from an already-shot state
				# don't re-bind buttons since they're binded already
				pass
				
			else:
				# bind the buttons when not binded yet
				var result = button.pressed.connect(_set_selected_button.bind(button), CONNECT_DEFERRED)
				if result != OK:
					print("Failed to connect pressed() signal for: ", button.name)
					
				
	if should_auto_focus and not buttons.is_empty():
		# if we're in here because we're on the 2nd+ shot
		# reset it, similar to how we're resetting the rendered images to [?]
		move_sequence.fill(null)
		
		# begin auto sequence from the start
		_set_selected_button(buttons[0] as Button)

# on_MovedButton_pressed --> will be used as a more generic function to set current pressed button
func _set_selected_button(button: Button):
	# edge case: if selected button still exists (user did not enter a directional input), then 
	# stop flashing it.
	if selected_button and selected_button != button:
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
		# check if event matches any of the 4 directions
		for action in INPUT_TEXTURES.keys():
			if event.is_action_pressed(action):
				selected_button.icon = INPUT_TEXTURES[action]

				# Update move_sequence
				var buttons = _get_buttons()
				var index = buttons.find(selected_button)
				if index != -1:
					move_sequence[index] = action

				stop_selection_animation(selected_button)
				selected_button.release_focus()
				selected_button = null
				
				if should_auto_focus:
					if index < len(move_sequence) - 1:
						_set_selected_button(buttons[index + 1] as Button)
					else:
						emit_signal("final_move_input_updated", move_sequence)
						return
				
				emit_signal("move_inputs_updated", move_sequence)
				return

		# handle backspace
		if event.is_action_pressed("ui_text_backspace"):
			_on_backspace()

func _on_backspace():
	print("we're inside of on backspace gang")
	var buttons = _get_buttons()
	var index = buttons.find(selected_button)
	if index > 0:
		index -= 1
	_set_selected_button(buttons[index] as Button)
	selected_button.icon = DEFAULT_BUTTON_ICON

# called when the user has filled out the entire move_sequence
func _on_shot_fired(_move_sequence):
	GameState.shot_count += 1
	shot_count_label.text = "%d" % GameState.shot_count

# Handles resetting all sequence inputs and changes the button icons back to default.
func reset_inputs():
	print("bombaclot test") # apparently this function is never run so idk why we have this
	move_sequence = [null, null, null, null] # lowkey remove this entire function idk
	var buttons = _get_buttons()
	for button in buttons:
		if button is Button:
			button.icon = DEFAULT_BUTTON_ICON
