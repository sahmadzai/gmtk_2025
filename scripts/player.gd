extends CharacterBody2D

const SPEED = 150.0

@onready var anim = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var input_vector := Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1

	input_vector = input_vector.normalized()
	velocity = input_vector * SPEED

	update_animation(input_vector)

	move_and_slide()

func update_animation(input_vector: Vector2) -> void:
	if input_vector == Vector2.ZERO:
		# Idle animation based on last played direction
		if anim.animation.begins_with("F_"):
			anim.play("F_Idle")
		elif anim.animation.begins_with("B_"):
			anim.play("B_Idle")
		elif anim.animation.begins_with("L_"):
			anim.play("L_Idle")
		elif anim.animation.begins_with("R_"):
			anim.play("R_Idle")
	else:
		# Determine movement direction and play run animation
		if abs(input_vector.x) > abs(input_vector.y):
			if input_vector.x > 0:
				anim.play("R_Run")
			else:
				anim.play("L_Run")
		else:
			if input_vector.y > 0:
				anim.play("F_Run")
			else:
				anim.play("B_Run")
