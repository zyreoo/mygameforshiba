extends CharacterBody3D

@export var speed := 5.0
@export var jump_velocity := 8.0
@export var rotation_speed := 2.0

@onready var animation_player: AnimationPlayer = $"mannequiny-0_3_0/AnimationPlayer"

func _ready():
	play_animation("idle")

func _physics_process(delta):
	if Input.is_action_pressed("move_left"):
		rotation.y += rotation_speed * delta
	if Input.is_action_pressed("move_right"):
		rotation.y -= rotation_speed * delta

	var input_dir = Vector3.ZERO
	var forward_input = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	
	input_dir = Vector3(0, 0, forward_input).rotated(Vector3.UP, rotation.y)
	input_dir = input_dir.normalized()

	velocity.x = input_dir.x * speed
	velocity.z = input_dir.z * speed

	if not is_on_floor():
		velocity.y -= 9.8 * delta
		if velocity.y > 0:
			play_animation("air_jump")
		else:
			play_animation("air_land")
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
			play_animation("air_jump_anticipation")
		elif input_dir != Vector3.ZERO:
			play_animation("run")
		else:
			play_animation("idle")

	move_and_slide()

func play_animation(anim_name: String):
	if animation_player.has_animation(anim_name):
		if animation_player.current_animation != anim_name:
			animation_player.play(anim_name)
