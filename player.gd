extends CharacterBody3D


@export var camera : Camera3D
@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
var path_follow : PathFollow3D

var current_rail : Node3D
@export var rails_parent : Node3D
var rails : Array

var rails_count
var rail_idx

var last_position : Vector3

@export var direction : float = -1.0

enum State {NONE, GRINDING, FLYING}	
var state : State

var closest_rail : Node3D 
@export var EPSILON = 0.1  # snap distance to attach to rail

func _ready():
	path_follow = get_parent()
	current_rail = path_follow.get_parent()
	path_follow.progress_ratio = 0.9
	state = State.GRINDING
	
	last_position = global_position
	
	for rail in rails_parent.get_children():
		rails.append(rail)
	
	rails_count = rails.size()
	rail_idx = rails.find(current_rail)
	
func _process(delta):
	camera.global_position.x = global_position.x
	camera.global_position.y = global_position.y

func _physics_process(delta):
	print(State.keys()[state])
	if state == State.GRINDING:
		
		var new_direction = Input.get_action_strength("run_right") - Input.get_action_strength("run_left")
		if new_direction != 0.0:
			direction = new_direction
			
		
		#path_follow = current_rail.path_follow
		path_follow.progress += direction * SPEED * delta;
		
		#if current_rail == null:
			#current_rail = closest_rail
		#var reached_end = (path_follow.progress_ratio >= 1.0 or path_follow.progress_ratio <= 0.0) and not closest_rail.is_looping
		var reached_end = (path_follow.progress_ratio >= 1.0 or path_follow.progress_ratio <= 0.0)
			
		if reached_end:
			print("reached_end")
		
		if reached_end or Input.is_action_just_pressed("jump"):
		#if Input.is_action_just_pressed("jump"):
			current_rail = null
			var old_transform = global_transform
			get_parent().remove_child(self)
			rails_parent.add_child(self)
			global_transform = old_transform
			state = State.FLYING
			var new_velocity = (global_position - last_position) / delta
			velocity = new_velocity
			move_and_slide()
			
		last_position = global_position
	
	elif state == State.FLYING:
		move_and_slide()
	
	elif state == State.NONE:
		pass

func _on_area_3d_body_entered(body):
	pass


class GetDistResult:
	var pos : float
	var length : float

func get_dist(_path_follow, ratio, pos_0, pos_1) -> GetDistResult:
	var result = GetDistResult.new()
	_path_follow.progress_ratio(ratio)
	result.pos = _path_follow.global_position
	result.length = (pos_1-pos_0).length()
	return result

func _on_area_3d_area_entered(area):
	if state != State.FLYING || not area.is_in_group("Rails"):
		return
	
	closest_rail = area.get_parent()
	var pos = global_position
	path_follow = closest_rail.path_follow
	#var ratio = get_path_ratio(path_follow, pos)
	var offset = find_closest_offset(path_follow.get_parent(), pos)
	
	get_parent().call_deferred("remove_child",self)
	path_follow.call_deferred("add_child",self)
	transform = Transform3D.IDENTITY
	#path_follow.progress_ratio = ratio
	path_follow.progress = offset
	print(path_follow.get_parent().curve.get_baked_length())
	#current_rail = closest_rail #BUG
	state = State.GRINDING
	#direction = -1.0  #TODO: properly determine the grind direction
	

#https://medium.com/@oddlyshapeddog/finding-the-nearest-global-position-on-a-curve-in-godot-4-726d0c23defb
func find_closest_abs_pos(
	path: Path3D,
	global_pos: Vector3
):
	var curve: Curve3D = path.curve
	# transform the target position to local space
	var path_transform: Transform3D = path.global_transform
	var local_pos: Vector3 = global_pos * path_transform
	# get the nearest offset on the curve
	var offset: float = curve.get_closest_offset(local_pos)
	# get the local position at this offset
	var curve_pos: Vector3 = curve.sample_baked(offset, true)
	# transform it back to world space
	curve_pos = path_transform * curve_pos
	return curve_pos

func find_closest_offset(
	path: Path3D,
	global_pos: Vector3
):
	var curve: Curve3D = path.curve
	# transform the target position to local space
	var path_transform: Transform3D = path.global_transform
	var local_pos: Vector3 = global_pos * path_transform
	# get the nearest offset on the curve
	var offset: float = curve.get_closest_offset(local_pos)
	
	return offset

func get_path_ratio(_path_follow, pos) -> float:
	var result = 0.0
	var ratio_left = 0.0
	var ratio_right = 1.0

	_path_follow.progress_ratio = ratio_left
	print(_path_follow.progress_ratio)
	var pos_left = _path_follow.global_position
	var length_l_p = (pos-pos_left).length()
	
	#var get_dist_result : GetDistResult
	#get_dist_result = get_dist(_path_follow, ratio_left, pos_left, pos)
	#var pos_left = get_dist_result.pos
	#var length_l_p = get_dist_reslt.length
	
	_path_follow.progress_ratio = ratio_right
	print(_path_follow.progress_ratio)
	var pos_right = _path_follow.global_position
	var length_l_r = (pos_right-pos_left).length()
	
	var ratio_mid = ratio_left + .5 * ratio_right
	_path_follow.progress_ratio = ratio_mid
	print(_path_follow.progress_ratio)
	var pos_mid = _path_follow.global_position
	var length_l_m = (pos_mid - pos_left).length()
	
	#BUG: assert fires, _path_follow.global_position does not work as i thought
	assert(ratio_mid == ratio_left or pos_mid != pos_left)
	
	var dist_try_snap = absf(length_l_m - length_l_p)
	var count_iters = 0
	var limit_iters = 2
	while dist_try_snap > EPSILON && count_iters < limit_iters:
		count_iters += 1
		if (length_l_p < length_l_m):
			ratio_right = ratio_mid
		else :
			ratio_left = ratio_mid
		
		_path_follow.progress_ratio = ratio_left
		pos_left = _path_follow.global_position
		length_l_p = (pos-pos_left).length()
		#get_dist_result : GetDistResult
		#get_dist_result = get_dist(_path_follow, ratio_left, pos_left, pos)
		# pos_left = get_dist_result.pos
		# length_l_p = get_dist_reslt.length
		
		_path_follow.progress_ratio = ratio_right
		pos_right = _path_follow.global_position
		length_l_r = (pos_right-pos_left).length()
		
		ratio_mid = ratio_left + .5 * ratio_right
		_path_follow.progress_ratio = ratio_mid
		pos_mid = _path_follow.global_position
		length_l_m = (pos_mid - pos_left).length()
		
		dist_try_snap = absf(length_l_m - length_l_p)
		
	result = ratio_mid
		
	return result
	
func _on_area_3d_area_exited(area):
	assert(area.get_parent() == closest_rail or state != State.FLYING)
	closest_rail = null
