extends CharacterBody3D


@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
var path_follow : PathFollow3D

@export var current_rail : Node3D
@export var rails_parent : Node3D
var rails : Array

var rails_count
var rail_idx
var direction : float = 1.0
	

enum State {NONE, GRINDING, FLYING}	
var state : State = State.GRINDING
	
func _ready():
	path_follow = current_rail.path_follow
	transform = path_follow.transform
	
	for rail in rails_parent.get_children():
		rails.append(rail)
	
	rails_count = rails.size()
	rail_idx = rails.find(current_rail)
	

func _physics_process(delta):
	var target_velocity = Vector3.ZERO
	
	if state == State.GRINDING:
		if Input.is_action_just_pressed("jump"):
			current_rail = null
			state = State.FLYING
			velocity = 
		
		else :
			var new_direction = Input.get_action_strength("run_right") - Input.get_action_strength("run_left")
			if new_direction != 0.0:
				direction = new_direction
	
			target_velocity.x = direction * SPEED
	
	
		path_follow = current_rail.path_follow
		path_follow.progress += target_velocity.x * delta;
		transform = path_follow.transform

	if s


func _on_area_3d_body_entered(body: Node3D) -> void:
	if state == State.FLYING:
		if body.is_in_group(&"Rails"):
			current_rail = body		
