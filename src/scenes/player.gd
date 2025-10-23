extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const ACCELERATION = 8.0  # Añadido para aceleración gradual
const FRICTION = 10.0     # Añadido para frenado gradual

var sens := 0.5
@onready var CAM = $pivote

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	movimiento(delta)
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		CAM.rotate_x(deg_to_rad(-event.relative.y * sens))
		# Modificado: Se aumentó el límite para poder mirar más arriba
		CAM.rotation.x = clamp(CAM.rotation.x, deg_to_rad(-90), deg_to_rad(80))

func movimiento(delta: float) -> void:
	# Aplica la gravedad si no está en el suelo
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Maneja el salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Modificado: Se usan acciones del Input Map en lugar de teclas directas
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Modificado: Lógica de movimiento con aceleración y fricción
	if direction:
		# Acelera hacia la dirección del input
		velocity.x = move_toward(velocity.x, direction.x * SPEED, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, ACCELERATION * delta)
	else:
		# Frena aplicando fricción si no hay input
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		velocity.z = move_toward(velocity.z, 0, FRICTION * delta)
