extends CharacterBody3D


@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
var path_follow : PathFollow3D

var current_rail : Node3D
@export var rails_parent : Node3D
var rails : Array

var rails_count
var rail_idx

	
func _ready():
	path_follow = get_parent()
	current_rail = path_follow.get_parent()
	#global_transform = path_follow.global_transform
	
	for rail in rails_parent.get_children():
		rails.append(rail)
	
	rails_count = rails.size()
	rail_idx = rails.find(current_rail)
	

func _physics_process(delta):
	var target_velocity = Vector3.ZERO
	

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		#switch rail
		var new_rail_idx = (rail_idx + 1)%rails_count
		current_rail = rails[new_rail_idx]
		rail_idx = new_rail_idx
		get_parent().remove_child(self)
		current_rail.path_follow.add_child(self)
		
		
		

	var direction = Input.get_action_strength("run_right") - Input.get_action_strength("run_left")
	
	if direction:		
		target_velocity.x = direction * SPEED
	else:
		target_velocity.x = move_toward(velocity.x, 0, SPEED)
	
	#velocity = target_velocity
	#
	#move_and_slide()
	
	
	
	path_follow = current_rail.path_follow
	path_follow.progress += target_velocity.x * delta;
	#globaltransform = path_follow.transform

	
