# res://scenes/CreditsRoot.gd
# Description: Recycles three segment instances horizontally to create an infinite scrolling credits map
# Adds debug prints to trace recycling logic

extends Node2D

@export var segment_width: float = 1152.0  # match your TileMap width in pixels

@onready var player = $BallPlayer
var segments: Array[Node2D] = []

func _ready():
	# collect them in left→center→right order
	segments = [ $SegmentA, $SegmentB, $SegmentC ]
	# initialize positions
	segments[0].position.x = -segment_width
	segments[1].position.x =  0
	segments[2].position.x =  segment_width
	print("[CreditsRoot] Initialized segments:")
	for i in range(segments.size()):
		print("  Segment %d at x= %f".format(i, str(segments[i].position.x)))

func _process(delta):
	var px = player.global_position.x
	var center_x = segments[1].global_position.x
	print("[CreditsRoot] Player.x= %.2f, center segment x= %.2f" % [px, center_x])

	# scrolled too far right?
	if px > center_x + segment_width/2:
		print("[CreditsRoot] Scrolled past right boundary")
		_recycle_left_to_right()
	# or too far left?
	elif px < center_x - segment_width/2:
		print("[CreditsRoot] Scrolled past left boundary")
		_recycle_right_to_left()

func _recycle_left_to_right():
	var left = segments.pop_front()
	var new_x = segments[-1].position.x + segment_width
	print("[CreditsRoot] Recycling leftmost segment from x= %f to x= %f" % [left.position.x, new_x])
	left.position.x = new_x
	segments.append(left)
	_print_segment_positions()

func _recycle_right_to_left():
	var right = segments.pop_back()
	var new_x = segments[0].position.x - segment_width
	print("[CreditsRoot] Recycling rightmost segment from x= %f to x= %f" % [right.position.x, new_x])
	right.position.x = new_x
	segments.insert(0, right)
	_print_segment_positions()

# Helper: dump all segment positions
func _print_segment_positions():
	print("[CreditsRoot] Segment order/positions:")
	for i in range(segments.size()):
		print("  segments[%d] -> x= %f" % [i, segments[i].position.x])
