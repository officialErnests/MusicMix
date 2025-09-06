extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var mouse_prev_pos 
@onready var camera = $anotherNeck/neck/Camera3D
@onready var neck = $anotherNeck/neck
@onready var anotherNeck = $anotherNeck
@onready var raycast = $anotherNeck/neck/RayCast3D

func _ready() -> void:
	mouse_prev_pos = get_viewport().get_mouse_position()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

var sensativity = 10

func _process(delta: float) -> void:
	neck.rotation.x = neck.rotation.x * 0.99
	if Input.is_action_just_pressed("escape"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		neck.rotate_x(deg_to_rad(-event.relative.y * 0.1 * sensativity))
		anotherNeck.rotate_y(deg_to_rad(event.relative.x * 0.1 * -1 * sensativity))
		var camera_rot = neck.rotation_degrees
		neck.rotation_degrees = camera_rot
		if raycast.is_colliding():
			var lenght = raycast.global_transform.origin.distance_to(raycast.get_collision_point())
			camera.position.z = lenght
		else:
			camera.position.z = 3

func _physics_process(delta: float) -> void:

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "foward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED 
		velocity.z = direction.z * SPEED 
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
