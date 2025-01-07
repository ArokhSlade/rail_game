extends CharacterBody3D


@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
var path_follow : PathFollow3D

@export var current_rail : Node3D
@export var rails_parent : Node3D
var rails : Array

var rails_count
var rail_idx

enum State {NONE, GRINDING, FLYING}

var state : State
@export var arrow : Node3D
	
func _ready():
	path_follow = current_rail.path_follow
	transform = path_follow.transform
	
	for rail in rails_parent.get_children():
		rails.append(rail)
	
	rails_count = rails.size()
	rail_idx = rails.find(current_rail)
	state = State.GRINDING
	

func _physics_process(delta):
	arrow.transform = transform
	
	var target_velocity = Vector3.ZERO
	if not is_on_floor():
		target_velocity += get_gravity() * delta

	# Handle jump.
	if state == State.GRINDING:
		
		if Input.is_action_just_pressed("jump"):
		
			current_rail = null
			state = State.FLYING
		
		else : 
			
			var speed = Input.get_action_strength("run_right") - Input.get_action_strength("run_left")
			
			if speed:
				target_velocity.x = speed * SPEED
			else:
				target_velocity.x = move_toward(velocity.x, 0, SPEED)
	
			var direction = path_follow.transform * Vector3.FORWARD
			velocity = direction * speed
			global_position = velocity * delta
			#move_and_slide()
	
	
	path_follow = current_rail.path_follow
	path_follow.progress += target_velocity.x * delta;
	#transform = path_follow.transform

	
