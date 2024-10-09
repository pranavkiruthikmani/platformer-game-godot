extends CharacterBody2D


@export var movement_data : PlayerMovementData


"""var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")"""
@export var gravity = 1250

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var starting_position = global_position

var alreadyDoubleJumped = false
var current_scence = null

func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_on_floor() or coyote_jump_timer.time_left > 0:
		alreadyDoubleJumped = false
		if Input.is_action_just_pressed("jump"):
			velocity.y = movement_data.JUMP_VELOCITY
	if not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < movement_data.JUMP_VELOCITY / 2:
			velocity.y = movement_data.JUMP_VELOCITY / 2
		if Input.is_action_just_pressed("jump") and alreadyDoubleJumped == false:
			velocity.y = movement_data.JUMP_VELOCITY
			alreadyDoubleJumped = true

	var direction = Input.get_axis("left", "right")
	
	if direction:
		velocity.x = move_toward(velocity.x, movement_data.SPEED * direction, movement_data.ACCELERATION * delta)
	elif direction == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, 200 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, movement_data.FRICTION * delta)
		
	update_animations(direction)
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor()
	if just_left_ledge:
		coyote_jump_timer.start()
	
func update_animations(input_axis):
	if input_axis != 0:
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	
	if not is_on_floor():
		animated_sprite_2d.play("jump")

func _on_hazard_detector_area_entered(area):
	global_position = starting_position


func _on_level_change_detector_area_entered(area):
	var current_scene = str(get_tree().current_scene.name)
	var current_level = int(current_scene[5])
	var next_level = str(current_level + 1)
	var path_level = "res://level1.tscn"
	path_level[11] = next_level
	get_tree().change_scene_to_file(path_level)
	
