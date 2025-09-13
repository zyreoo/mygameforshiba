extends CharacterBody3D

@export var speed := 5.0
@export var jump_velocity := 8.0
@export var mouse_sensitivity := 0.002
@export var rotation_speed := 2.0

@onready var camera: Camera3D = $Camera3D
@onready var mannequin_model: Node3D = $"mannequiny-0_3_0"
@onready var animation_player: AnimationPlayer = $"mannequiny-0_3_0/AnimationPlayer"

enum CameraMode { FIRST_PERSON, THIRD_PERSON }
var current_camera_mode: CameraMode = CameraMode.FIRST_PERSON

const FIRST_PERSON_CAMERA_POS := Vector3(0, 1.8, 0)
const THIRD_PERSON_CAMERA_POS := Vector3(0, 2, -3)
const THIRD_PERSON_CAMERA_ROT := Vector3(-0.3, 0, 0)

func _ready():
	set_camera_mode(current_camera_mode)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func set_camera_mode(mode: CameraMode) -> void:
	current_camera_mode = mode
	
	if mode == CameraMode.FIRST_PERSON:
		camera.position = FIRST_PERSON_CAMERA_POS
		camera.rotation = Vector3.ZERO
		mannequin_model.hide()
	else:
		camera.position = THIRD_PERSON_CAMERA_POS
		camera.rotation = THIRD_PERSON_CAMERA_ROT
		mannequin_model.show()
		play_animation("idle")

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if current_camera_mode == CameraMode.FIRST_PERSON:
			rotate_y(-event.relative.x * mouse_sensitivity)
			camera.rotate_x(-event.relative.y * mouse_sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event.is_action_pressed("toggle_camera"):
		set_camera_mode(CameraMode.THIRD_PERSON if current_camera_mode == CameraMode.FIRST_PERSON else CameraMode.FIRST_PERSON)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= 9.8 * delta
		if current_camera_mode == CameraMode.THIRD_PERSON:
			if velocity.y > 0:
				play_animation("air_jump")
			else:
				play_animation("air_land")

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		if current_camera_mode == CameraMode.THIRD_PERSON:
			play_animation("air_jump_anticipation")

	if current_camera_mode == CameraMode.FIRST_PERSON:
		handle_first_person_movement()
	else:
		handle_third_person_movement(delta)

	move_and_slide()

func handle_first_person_movement() -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

func handle_third_person_movement(delta: float) -> void:
	if Input.is_action_pressed("move_left"):
		rotation.y += rotation_speed * delta
	if Input.is_action_pressed("move_right"):
		rotation.y -= rotation_speed * delta

	var forward_input = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	var input_dir = Vector3(0, 0, forward_input).rotated(Vector3.UP, rotation.y).normalized()
	
	velocity.x = input_dir.x * speed
	velocity.z = input_dir.z * speed
	
	if input_dir != Vector3.ZERO and is_on_floor():
		play_animation("run")
	elif is_on_floor():
		play_animation("idle")

func play_animation(anim_name: String) -> void:
	if animation_player.has_animation(anim_name) and animation_player.current_animation != anim_name:
		animation_player.play(anim_name)
