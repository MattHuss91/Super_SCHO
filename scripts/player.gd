extends CharacterBody2D

# --- constants ---------------------------------------------------------
const SPEED         := 180.0
const JUMP_VELOCITY := -520.0
const GRAVITY       := 980.0
const FIRE_RATE     := 0.18   # seconds between shots

# --- state -------------------------------------------------------------
var health      := 3
var facing_dir  := 1          # 1 = right, -1 = left
var _fire_cd    := 0.0
var _invincible := 0.0        # brief invincibility after hit

var _bullet_scene: PackedScene

func _ready() -> void:
	add_to_group("player")
	_bullet_scene = load("res://scenes/Bullet.tscn")

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Horizontal movement
	var h := Input.get_axis("move_left", "move_right")
	if h != 0.0:
		velocity.x = h * SPEED
		facing_dir = 1 if h > 0 else -1
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED * 3)

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Shooting
	_fire_cd -= delta
	if Input.is_action_pressed("shoot") and _fire_cd <= 0.0:
		_fire()
		_fire_cd = FIRE_RATE

	# Invincibility timer
	if _invincible > 0.0:
		_invincible -= delta
		modulate.a = 0.5 if fmod(_invincible, 0.1) > 0.05 else 1.0
	else:
		modulate.a = 1.0

	move_and_slide()

# --- shooting ----------------------------------------------------------

func _fire() -> void:
	var dir := _get_aim_dir()
	var bullet: Node2D = _bullet_scene.instantiate()
	bullet.direction = dir
	# Spawn bullet just ahead of the player's centre
	bullet.global_position = global_position + Vector2(float(facing_dir) * 16.0, -10.0)
	get_parent().add_child(bullet)

func _get_aim_dir() -> Vector2:
	var up   := Input.is_action_pressed("aim_up")
	var down := Input.is_action_pressed("aim_down") and not is_on_floor()
	var h    := Input.get_axis("move_left", "move_right")

	if up:
		# Diagonal-up if also moving, else straight up
		return Vector2(float(facing_dir), -1.0).normalized() if h != 0.0 else Vector2.UP
	if down:
		return Vector2(float(facing_dir), 1.0).normalized() if h != 0.0 else Vector2.DOWN
	return Vector2(float(facing_dir), 0.0)

# --- damage ------------------------------------------------------------

func take_damage() -> void:
	if _invincible > 0.0:
		return
	health -= 1
	_invincible = 1.2
	if health <= 0:
		get_tree().reload_current_scene()
