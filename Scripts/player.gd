extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 10
const COOL_BONE = 3

var mouse_prev_pos 
@onready var camera = $anotherNeck/neck/Camera3D
@onready var neck = $anotherNeck/neck
@onready var anotherNeck = $anotherNeck
@onready var raycast = $anotherNeck/neck/RayCast3D
@onready var wheel = $Wheel
@onready var charecter = $Guy
@onready var anim_tree = $AnimationTree
@onready var light = $OmniLight3D


var intendedDir = 0

func _ready() -> void:
	mouse_prev_pos = get_viewport().get_mouse_position()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

var sensativity = 5

func _process(delta: float) -> void:
	if position.y < -100:
		position = Vector3.ZERO
	light.global_position = charecter.to_global(charecter.get_bone_global_pose(COOL_BONE).origin)
	light.omni_range = velocity.length() + 5
	charecter.rotation.y += (fmod(intendedDir - charecter.rotation.y - PI, PI*2) - PI) * delta * 2
	# charecter.rotation.y += intendedDir - charecter.rotation.y
	if Input.is_action_just_pressed("escape"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			$CanvasLayer.visible = true
			var textResult = ""
			textResult += "5EEnoWAY\n"
			for musicText in Music.checklist_5EEnoWAY.keys():
				textResult += "| [-] - ???\n" if !Music.checklist_5EEnoWAY[musicText] else "| [X] - " + musicText + "\n"
			$CanvasLayer/Label.text = textResult
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			$CanvasLayer.visible = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		neck.rotate_x(deg_to_rad(-event.relative.y * 0.1 * sensativity))
		anotherNeck.rotate_y(deg_to_rad(event.relative.x * 0.1 * -1 * sensativity))
		var camera_rot = neck.rotation_degrees
		neck.rotation_degrees = camera_rot
		neck.rotation.x = clamp(neck.rotation.x, -1,1)
		if raycast.is_colliding():
			var lenght = raycast.global_transform.origin.distance_to(raycast.get_collision_point())
			camera.position.z = lenght
		else:
			camera.position.z = 3

func _physics_process(delta: float) -> void:

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if is_on_wall():
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
			velocity.x += 1 if velocity.x > 0 else -1
			velocity.z += 1 if velocity.z > 0 else -1
			velocity += get_wall_normal() * 1
	else:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "foward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x * sin(anotherNeck.rotation.y + PI/2) + input_dir.y * sin(anotherNeck.rotation.y), 0, input_dir.x * cos(anotherNeck.rotation.y + PI/2) + input_dir.y * cos(anotherNeck.rotation.y))).normalized()

	alignWheel(velocity)
	anim_tree["parameters/Blend2/blend_amount"] = clamp(velocity.length()/10, 0, 1)
	anim_tree["parameters/AnimationNodeBlendSpace2D/blend_position"] = Vector2(input_dir.x, -input_dir.y)
	camera.fov = clamp(50 + velocity.length() * 2, 60, 120)
	if direction:
		alignCharecter(direction)
		velocity.x += SPEED * direction.x * delta * 2
		velocity.z += SPEED * direction.z * delta * 2
		velocity.x *= 0.99
		velocity.z *= 0.99
	else:
		velocity.x *= 0.95
		velocity.z *= 0.95
	move_and_slide()

func alignWheel(vel : Vector3):
	wheel.rotation.z -= vel.length() / 50
	wheel.rotation.y = -Vector2(vel.x,vel.z).angle()
	if is_on_floor():
		wheel.rotation.x = 0
	else:
		wheel.rotation.x += abs(vel.y) / 10

func alignCharecter(dir):
	intendedDir = -Vector2(dir.x,dir.z).angle() + PI/2
	
