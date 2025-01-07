extends Path3D

@onready var path_follow = $PathFollow3D
@export var shape : Node3D
@export var area : Area3D
@export var is_looping = false

func _ready():
	path_follow.loop = is_looping

func get_dist_sq(_path_follow, ratio, near_pos):
	_path_follow.progress_ratio = ratio
	var diff = _path_follow.global_position - near_pos
	var dist_sq = diff.length_squared()
	return dist_sq

#func get_closest_progress(near_position : Vector3) -> float:
	#var left = 0.
	#var right = 1.
	#
	#var left_dist = get_dist(path_follow, left, near_pos)
	#var right_dist = get_dist(path_follow, right, near_pos)
	#
	#for step in range(16):
		#var mid = left + .5 * (right - left)
		#
	#
	#var old_ratio = .5
	#var old_distance : float
	#path_follow.progress_ratio = old_ratio
	#
	#var difference : Vector3 = (path_follow.global_position - near_position)
	#old_distance = difference.length_squared()
	#
	#var interval = .25
	#for step in range(16):
		#
		#var higher_ratio = old_ratio + interval
		#path_follow.progress_ratio = higher_ratio
		#var higher_distance = (path_follow.global_position - near_position).length_squared()
				#
		#var lower_ratio = old_ratio - interval
		#path_follow.progress_ratio = lower_ratio
		#var lower_distance = (path_follow.global_position - near_position).length_squared()
		#
		#if lower_distance < higher_distance:
			#if lower_distance < old_distance:
				#pass
		#
		#
		#
		#
		#interval *= .5
	#
