extends BaseEnemy

# --- Variables ---
# Ya no necesitamos la referencia @onready al jugador
var player: CharacterBody3D = null
var current_state = State.IDLE

# --- Enums ---
enum State { IDLE, CHASE } # Podemos añadir ATTACK, PATROL, etc.

# --- Lógica Principal ---
func _physics_process(delta: float) -> void:
	# La máquina de estados decide qué hacer en cada fotograma
	match current_state:
		State.IDLE:
			idle_state(delta)
		State.CHASE:
			chase_state(delta)

# --- Estados ---
func idle_state(delta: float) -> void:
	# En estado de reposo, el enemigo frena gradualmente
	velocity = velocity.lerp(Vector3.ZERO, delta * 5.0)
	move_and_slide()

func chase_state(delta: float) -> void:
	if player == null:
		current_state = State.IDLE
		return

	# 1. Aplica gravedad
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	# 2. Rota suavemente para mirar al jugador
	var direction_to_player = player.global_position - global_position
	look_at(player.global_position, Vector3.UP)
	# Suavizamos el giro para que no sea instantáneo (opcional pero recomendable)
	# rotation.y = lerp_angle(rotation.y, atan2(direction_to_player.x, direction_to_player.z), delta * 5.0)


	# 3. Calcula la velocidad objetivo (hacia adelante)
	var target_velocity = -transform.basis.z * velocidad

	# 4. Interpola la velocidad actual hacia la objetivo para una aceleración suave
	velocity.x = lerp(velocity.x, target_velocity.x, delta * 4.0)
	velocity.z = lerp(velocity.z, target_velocity.z, delta * 4.0)

	# 5. Ejecuta el movimiento
	move_and_slide()

# --- Señales de Detección ---
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player = body
		current_state = State.CHASE

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player = null
		current_state = State.IDLE
