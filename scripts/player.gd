# File: player.gd
# Description: Player controller that supports both manual (debug) movement 
# 			   and looped movement based on a predefined input sequence.
# Authors: Shamsullah Ahmadzai, David Huang, Bruke Amare

extends CharacterBody2D

const SPEED = 150.0  # Movement speed of the player

var manual_control := false  # Toggle for manual arrow key movement (debugging)
var target_position: Vector2
var moving: bool = false
var move_sequence := []  # Stores sequence of directions to move in
var loop_active := false
var current_step := 0
var loop_timer := 0.4
var loop_time_accumulator := 0.0
var loop_history := []
var last_direction := Vector2.DOWN  # Used to determine idle animation
var stuck_check := 0

@onready var anim = $AnimatedSprite2D  # Reference to AnimatedSprite2D node

func _ready():
	print("PLAYER SCRIPT READY")

func _input(event):
	if event.is_action_pressed("toggle_manual"):  # Press M to toggle manual control
		manual_control = !manual_control
		loop_active = false  # Disable loop when switching to manual
		print("Manual Control:", manual_control)

	elif event.is_action_pressed("start_loop"):  # Press G to start the loop
		print("Here is the move sequence ", move_sequence)
		if move_sequence.size() == 0 or move_sequence.has(null):
			print("Move sequence is incomplete or empty.")
			return
		loop_active = true
		current_step = 0
		loop_history.clear()
		stuck_check = 0

	elif event.is_action_pressed("reset_loop"):
		get_tree().reload_current_scene()  # Press R to reset the level

func _physics_process(delta):
	# --- MANUAL MOVEMENT ---
	if manual_control:
		var input_vector := Vector2.ZERO
		if Input.is_action_pressed("ui_up"): input_vector.y -= 1
		if Input.is_action_pressed("ui_down"): input_vector.y += 1
		if Input.is_action_pressed("ui_left"): input_vector.x -= 1
		if Input.is_action_pressed("ui_right"): input_vector.x += 1

		input_vector = input_vector.normalized()
		velocity = input_vector * SPEED
		move_and_slide()

		# Update animation
		update_animation(input_vector)
		return  # Prevent loop code from running in manual mode

	# --- AUTOMATED LOOP MOVEMENT ---
	if loop_active and move_sequence.size() > 0:
		if not moving:
			var action = move_sequence[current_step]
			var dir = Vector2.ZERO

			match action:
				"ui_up": dir = Vector2.UP
				"ui_down": dir = Vector2.DOWN
				"ui_left": dir = Vector2.LEFT
				"ui_right": dir = Vector2.RIGHT

			var new_target = global_position + dir * 32  # Move by 1 tile (32px)
			var collision_check = test_move(global_transform, dir * 2)

			if collision_check:
				print("Blocked by wall. Skipping move.")
				velocity = Vector2.ZERO
				moving = false
				update_animation(Vector2.ZERO)
				current_step = (current_step + 1) % move_sequence.size()
			else:
				print("Moving to next tile.")
				target_position = new_target
				velocity = dir * SPEED
				update_animation(dir)
				moving = true

	# Complete movement and snap to grid
	if moving:
		move_and_slide()
		if global_position.distance_to(target_position) < 2.0:
			global_position = target_position
			velocity = Vector2.ZERO
			moving = false
			current_step = (current_step + 1) % move_sequence.size()

func _on_move_inputs_updated(new_sequence):
	move_sequence = new_sequence.duplicate()
	print("Move sequence updated:", move_sequence)

func update_animation(input_vector: Vector2) -> void:
	# Determine idle animation based on last direction
	if input_vector == Vector2.ZERO:
		match last_direction:
			Vector2.UP: anim.play("B_Idle")
			Vector2.DOWN: anim.play("F_Idle")
			Vector2.LEFT: anim.play("L_Idle")
			Vector2.RIGHT: anim.play("R_Idle")
	else:
		last_direction = input_vector
		# Determine run animation based on movement axis
		if abs(input_vector.x) > abs(input_vector.y):
			anim.play("R_Run" if input_vector.x > 0 else "L_Run")
		else:
			anim.play("F_Run" if input_vector.y > 0 else "B_Run")
