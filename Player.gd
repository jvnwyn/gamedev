extends KinematicBody

#physics
export var moveSpeed: float = 5.0
export var jumpForce: float = 5.0
export var gravity: float = 12.0

#camera look
var minlookAngle: float = -90.0
var maxlookAngle: float = 90.0
var lookSensitivity: float = 0.5

#vectors 
var velocity: Vector3 = Vector3()
var mouseDelta: Vector2 = Vector2()

#player components
onready var camera = get_node("Camera")

func _input(event):
	#mouse movement 
	if event is InputEventMouseMotion:
		mouseDelta = event.relative
		
func _process(delta):
	#rotate camera along x-axis
	camera.rotation_degrees -= Vector3(rad2deg(mouseDelta.y),0,0)*lookSensitivity*delta
	#clamp the vertical camera rotation
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minlookAngle, maxlookAngle)
	#rotate player along y-axis
	rotation_degrees -= Vector3(0, rad2deg(mouseDelta.x), 0) * lookSensitivity*delta
	
	#resets the mouse delta vector
	mouseDelta = Vector2()
	
func _physics_process(delta):
	#resets the x and z velocity
	velocity.x = 0
	velocity.z = 0
	var input = Vector2()
	#movement inputs
	if Input.is_action_pressed("move_forward"):
		input.y -= 1
	if Input.is_action_pressed("move_backward"):
		input.y += 1
	if Input.is_action_pressed("move_left"):
		input.x -= 1
	if Input.is_action_pressed("move_right"):
		input.x += 1
	#normalize the input so no faster movement diagonally
	input = input.normalized()
				
	#get our forward and right directions
	var forward = global_transform.basis.z
	var right = global_transform.basis.x
	
	#set the velocity
	velocity.z = (forward*input.y + right * input.x).z * moveSpeed
	velocity.x = (forward*input.y + right * input.x).x * moveSpeed
	
	#apply gravity 
	velocity.y -= gravity * delta
	
	#move the player
	velocity = move_and_slide(velocity, Vector3.UP)
	
	#jump if button is pressed and if our player is also standing on the floor
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jumpForce
		
func window_activity():
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	OS.window_fullscreen = true					
	
	
	
	
	
		
