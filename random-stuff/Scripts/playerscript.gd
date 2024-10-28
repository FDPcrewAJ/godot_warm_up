extends CharacterBody3D


const JUMP_VELOCITY = 4.5
const mouse_sens = 0.5

var allow_control = true
var direction = Vector3.ZERO
var lerp_speed = 7.0
var current_speed = 3.0

@onready var camera = $Neck/Head/Camera
@onready var head = $Neck/Head
@onready var resume_button = $menu/resume_button


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if allow_control:
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
			head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))



func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
	
	if Input.is_action_pressed("sprint"):
		current_speed = 7.0
	else:
		current_speed = 3.0
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		
	if Input.is_action_just_pressed("escape"):
		allow_control = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		resume_button.visible = true

	move_and_slide()


func _on_resume_button_pressed():
	allow_control = true
	resume_button.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
