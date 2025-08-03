extends Camera2D

var shake_strength = 0.0
var shake_tween: Tween
@onready var player_node: Node2D
var shake_start_position: Vector2 # will return to this original position

func _ready():
	print("Camera shake ready")

# This function is called every frame
func _process(delta):
	# If there is no shake, manually make the camera follow the player's position
	if is_instance_valid(player_node) and shake_strength <= 0:
		position = player_node.position
	
	# Only apply shake if the shake_strength is greater than zero
	if shake_strength > 0:
		# The random position is added to the position the player was at when the shake began
		position = shake_start_position + Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))


# This is the public function you will call from other scripts
# It starts the screen shake with a given duration and intensity
func start_shake(duration: float, strength: float):
	# If a tween already exists and is active, stop it
	if shake_tween and is_instance_valid(shake_tween) and shake_tween.is_running():
		#shake_tween.stop()
		return
	
	# Store the player's current position to use as the base for the shake
	if is_instance_valid(player_node):
		shake_start_position = player_node.position
		
	# Create a new tween using the SceneTree method (Godot 4)
	shake_tween = get_tree().create_tween()
	
	# Set the initial shake strength
	self.shake_strength = strength
	
	# Animate the shake_strength from its current value down to 0 over the specified duration
	shake_tween.tween_property(self, "shake_strength", 0.0, duration)
	
	print("Screen shake started with strength: ", strength)
