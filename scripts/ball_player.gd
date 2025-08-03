extends CharacterBody2D

signal backspace_pressed
signal actions_list_cleared


const SPEED = 125.0  # Movement speed of the player

var manual_control := false  # Toggle for manual arrow key movement (debugging)
var starting_position: Vector2
var target_position: Vector2
var moving: bool = false
var move_sequence := []  # Stores sequence of directions to move in
var loop_active := false
var current_step := 0
var loop_history := []
var last_direction := Vector2.DOWN  # Used to determine idle animation
var is_dead_animation = false

@onready var anim = $AnimatedSprite2D  # Reference to AnimatedSprite2D node
@onready var water_layer = $"../WaterLayer" 
@onready var path_layer = $"../PathLayer" 
@onready var tween = $Tween
@onready var death_sounds = [$DeathSound1, $DeathSound2, $DeathSound3]
@onready var win_sounds = [$WinSound1]
@onready var transition_sounds = [$TransitionSound1]
@onready var wall_sounds = [$WallSound1]

func _ready():
	print("BALL PLAYER SCRIPT READY")
	starting_position = global_position # write down the player's initial starting position
	update_animation(Vector2.ZERO) # idle animation on load-in
	
	if GameState.was_win_transition:
		GameState.was_win_transition = false
		is_dead_animation = true
		
		# Get current scene name (e.g. "tutorial01")
		var scene_path = get_tree().current_scene.scene_file_path
		var scene_name = scene_path.get_file().get_basename()
		
		# Use fallback if missing
		starting_position = GameState.level_start_positions.get(scene_name, global_position)
		
		# Start with huge scale
		scale = Vector2(70.0, 70.0)
		
		var tween_instance = get_tree().create_tween()
		tween_instance.set_parallel(true)
		tween_instance.tween_property(self, "scale", Vector2(1, 1), 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween_instance.tween_property(self, "global_position", starting_position, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween_instance.connect("finished", Callable(self, "_on_intro_transition_finished"))
	else:
		starting_position = global_position

func _on_intro_transition_finished():
	is_dead_animation = false

func _input(event):
	if event.is_action_pressed("toggle_manual"):  # Press M to toggle manual control
		manual_control = !manual_control
		print("Manual Control:", manual_control)
		if manual_control:
			loop_active = false  # Disable loop when switching to manual
			
		else: # switching back to automatic (don't disable loop)
			# simulate an event start (G press)
			#moving = false # should already be false
			_press_G_start()

	elif event.is_action_pressed("start_loop"):  # Press G to start the loop
		print("Here is the move sequence ", move_sequence)
		if move_sequence.size() == 0 or move_sequence.has(null):
			print("Move sequence is incomplete or empty.")
			return
		loop_active = true
		current_step = 0
		loop_history.clear()

	elif event.is_action_pressed("reset_loop"):
		_reset_full_level()  # Press R to reset the level

	elif loop_active and event.is_action_pressed("ui_text_backspace"):
		_reset_player_but_save_actions()

func _reset_full_level():
	get_tree().reload_current_scene()

func _reset_player_but_save_actions():
	# reset player position to initial
	global_position = starting_position

	# stop movement, stop loop, reset variables
	velocity = Vector2.ZERO
	loop_active = false
	moving = false
	current_step = 0
	loop_history.clear()
	update_animation(Vector2.ZERO)
	
	emit_signal("backspace_pressed")
	
func _clear_actions_but_keep_position():
	# stop loop, stop movement, reset variables
	loop_active = false
	moving = false # (should already be false if we're at collision, this line should be redundant) 
	move_sequence.clear()
	current_step = 0
	loop_history.clear()
	update_animation(Vector2.ZERO)

	print("Actions list cleared, player position unchanged.")

	emit_signal("actions_list_cleared")
	
func _hit_wall_sound_and_shake():
	wall_sounds[randi() % len(wall_sounds)].play()
	var camera = get_parent().get_node("Camera2D")

	# Check if the camera node exists before trying to call the function
	if is_instance_valid(camera):
		# Call the screen shake function with a duration and strength
		camera.start_shake(0.3, 8)

func _physics_process(delta):
	# if being animated, don't run any other logic
	if is_dead_animation:
		return

	# if in the winning hole, start winning animation
	if _is_in_winning_hole(global_position):
		print("Player is in winning hole! Starting win animation.")
		_start_win_animation()
		return

	# if in deadly water, start death animation
	elif _is_in_deadly_water(global_position):
		print("Player is in deadly water! Starting death animation.")
		TransitionScreen.transition(3) # REMOVE IF DISLIKE FADE ON DEATH
		_start_death_animation()
		await TransitionScreen.on_transition_finished # REMOVE IF DISLIKE
		

		return
	
	# Complete movement and snap to grid
	elif moving:
		print("I'm still moving ", velocity, " ", delta, " and deadly water: ", _is_in_deadly_water(global_position))
		var collision = move_and_collide(velocity * delta)
		
		if collision:
			velocity = Vector2.ZERO
			moving = false
			current_step = (current_step + 1) % move_sequence.size()
			# wall hit sound will play before next turn starts
			
		elif global_position.distance_to(target_position) < 2.0:
			global_position = target_position
			velocity = Vector2.ZERO
			moving = false
			current_step = (current_step + 1) % move_sequence.size()
	
	# not moving = true; decide next step
	else: 
		# --- MANUAL MOVEMENT ---
		if manual_control:
			var input_vector := Vector2.ZERO
			if Input.is_action_pressed("ui_up"):    input_vector.y -= 1
			if Input.is_action_pressed("ui_down"):  input_vector.y += 1
			if Input.is_action_pressed("ui_left"):  input_vector.x -= 1
			if Input.is_action_pressed("ui_right"): input_vector.x += 1

			input_vector = input_vector.normalized()
			velocity = input_vector * SPEED
			move_and_slide()

			# Update animation
			update_animation(input_vector)
			
			# INFO: manual movement currently doesn't guarantee snapping to grid tile...

		# --- AUTOMATED LOOP MOVEMENT ---
		elif loop_active and move_sequence.size() > 0:
			var action = move_sequence[current_step]
			var dir = Vector2.ZERO

			match action:
				"ui_up": dir =    Vector2.UP
				"ui_down": dir =  Vector2.DOWN
				"ui_left": dir =  Vector2.LEFT
				"ui_right": dir = Vector2.RIGHT

			var new_target = global_position + dir * 16  # Move by 4 tiles (16px)
			var collision_check = test_move(global_transform, dir * 2)

			if collision_check:
				print("Blocked by wall. Skipping move.")
				velocity = Vector2.ZERO
				moving = false
				update_animation(Vector2.ZERO)
				current_step = (current_step + 1) % move_sequence.size()
				
				# next golf shot
				_clear_actions_but_keep_position()
				_hit_wall_sound_and_shake()
			else:
				print("Moving to next tile.")
				target_position = new_target
				velocity = dir * SPEED
				update_animation(dir)
				moving = true

# check if we're on deadly water
func _is_in_deadly_water(death_position: Vector2) -> bool:
	if not is_instance_valid(water_layer):
		print("Water layer was not found, returning false. (Since this is a golf game, why doesn't your level have a water layer?)")
		return false

	var map_coords = water_layer.local_to_map(death_position)
	var tile_data = water_layer.get_cell_tile_data(map_coords) # Assumes WaterLayer is layer 0
	
	if tile_data and tile_data.get_custom_data("waterDeath"):
		return true
	
	return false
	
# check if we're on deadly water
func _is_in_winning_hole(win_position: Vector2) -> bool:
	if not is_instance_valid(path_layer):
		print("Path layer was not found, returning false. (Since this is a golf game, why doesn't your level have a path layer?)")
		return false

	var map_coords = path_layer.local_to_map(win_position)
	var tile_data = path_layer.get_cell_tile_data(map_coords) # Assumes WaterLayer is layer 0
	
	if tile_data and tile_data.get_custom_data("holeWin"):
		return true
	
	return false
	
func _start_death_animation():
	# don't start another animation if it's already playing
	if is_dead_animation:
		return

	# animation is starting now
	is_dead_animation = true
	
	# Stop all movement immediately
	velocity = Vector2.ZERO
	moving = false
	update_animation(Vector2.ZERO, "angry") # TODO (easy): can we update the animation to a DEATH one? like X_X eyes or something

	death_sounds[randi() % len(death_sounds)].play()

	var tween_instance = get_tree().create_tween()
	tween_instance.tween_property(self, "scale", Vector2(0.1, 0.1), 0.5)
	tween_instance.connect("finished", Callable(self, "_death_animation_finished"))

func _death_animation_finished():
	print("Death animation finished. Reloading scene.")
	# animation is done
	is_dead_animation = false
	_press_R_restart()
	
func _start_win_animation():
	# don't start another animation if it's already playing
	if is_dead_animation:
		return

	# animation is starting now
	is_dead_animation = true
	
	# Stop all movement immediately
	velocity = Vector2.ZERO
	moving = false
	update_animation(Vector2.ZERO) # TODO (easy): can we update the animation to a DEATH one? like X_X eyes or something

	win_sounds[randi() % len(win_sounds)].play()
	
	# Set next scene path using GameState method
	var current_scene = get_tree().current_scene.scene_file_path.get_file().get_basename()
	GameState.next_scene_path = GameState.get_next_scene_path(current_scene)

	var tween_instance = get_tree().create_tween()
	tween_instance.tween_property(self, "scale", Vector2(0.1, 0.1), 0.5)
	tween_instance.connect("finished", Callable(self, "_win_animation_next"))
	
func _win_animation_next(): # should ONLY be called by _start_win_animation
	print("Win animation started. Playing transition screen (win next).")
	#is_dead_animation = false # we're not done yet
	update_animation(Vector2.ZERO, "smug") # TODO (easy): use some smug animation
	
	transition_sounds[randi() % len(transition_sounds)].play()
	
	var tween_instance = get_tree().create_tween()
	tween_instance.tween_property(self, "scale", Vector2(70.0, 70.0), 2)
	tween_instance.connect("finished", Callable(self, "_win_animation_finished"))
	
func _win_animation_finished():
	print("Win animation finished. Changing scene.")
	GameState.was_win_transition = true
	
	# Check if we're going to the credits scene
	if GameState.next_scene_path.contains("credits"):
		# Run fade transition in parallel with scene change
		print("Transitioning to credits scene with fade.")
		TransitionScreen.transition(1)
		await TransitionScreen.on_transition_finished
		get_tree().change_scene_to_file(GameState.next_scene_path)
	else:
		# Normal transition for other levels
		get_tree().change_scene_to_file(GameState.next_scene_path)

func _on_move_inputs_updated(new_sequence):
	move_sequence = new_sequence.duplicate()
	print("Move sequence updated:", move_sequence)
	
# wrapper function for _on_move_inputs_updated
# used specifically when: 1. should_auto_focus and 2. we have fully populated the sequence list
func _on_final_move_input_updated(new_sequence):
	print("Final move inputted, auto-focus running.")
	_on_move_inputs_updated(new_sequence)
	# simulate an event start (G press)
	_press_G_start()
	
func _press_G_start():
	# simulate an event start (G press)
	var event = InputEventAction.new()
	event.action = "start_loop"
	event.pressed = true
	_input(event)
	
func _press_R_restart():
	# simulate an event start (G press)
	var event = InputEventAction.new()
	event.action = "reset_loop"
	event.pressed = true
	_input(event)

func update_animation(input_vector: Vector2, set_custom : String = "") -> void:
	if set_custom:
		if set_custom == "angry":
			anim.play("angry")
		elif set_custom == "sad":
			print("Sad animation not implemented yet.")
		elif set_custom == "smug":
			anim.play("smug")
	# Determine idle animation based on last direction
	elif input_vector == Vector2.ZERO:
		anim.play("idle")
	else:
		last_direction = input_vector
		# Determine run animation based on movement axis
		if abs(input_vector.x) > abs(input_vector.y):
			anim.play("r_roll" if input_vector.x > 0 else "l_roll")
		else:
			anim.play("d_roll" if input_vector.y > 0 else "u_roll")
