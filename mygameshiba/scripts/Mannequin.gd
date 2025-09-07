extends CharacterBody3D

@export var speed := 5.0
@export var jump_velocity := 8.0

func _physics_process(delta):
	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	input_dir = input_dir.normalized()
	velocity.x = input_dir.x * speed
	velocity.z = input_dir.z * speed

	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity

	move_and_slide()
