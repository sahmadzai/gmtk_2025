# File: CreditsBallPlayer.gd
# Description: Simple player controller for the infinite credits map.
#              Supports manual 4-way movement & facing animations.
# Author: (you)

extends CharacterBody2D

const SPEED := 500.0  # Movement speed in credits screen

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Gather input
	var input_vec := Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		input_vec.x += 1
	if Input.is_action_pressed("ui_left"):
		input_vec.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_vec.y += 1
	if Input.is_action_pressed("ui_up"):
		input_vec.y -= 1

	# Normalize and move
	input_vec = input_vec.normalized()
	velocity = input_vec * SPEED
	move_and_slide()

	# Update animation
	_update_animation(input_vec)

func _update_animation(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		anim.play("idle")
	else:
		# Walking animation in the stronger axis
		if abs(dir.x) > abs(dir.y):
			anim.play("r_roll" if dir.x > 0 else "l_roll")
		else:
			anim.play("d_roll" if dir.y > 0 else "u_roll")
