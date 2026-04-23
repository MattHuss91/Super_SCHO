extends CharacterBody2D

const SPEED          := 55.0
const GRAVITY        := 980.0
const SHOOT_INTERVAL := 2.8
const DETECT_RANGE   := 600.0   # px — only chase/shoot within this range

var health      := 2
var _shoot_cd   := 0.0
var _bullet_scene: PackedScene

func _ready() -> void:
	add_to_group("enemy")
	_bullet_scene = load("res://scenes/EnemyBullet.tscn")
	# Stagger first shot so enemies don't fire simultaneously
	_shoot_cd = randf_range(0.5, SHOOT_INTERVAL)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player and global_position.distance_to(player.global_position) < DETECT_RANGE:
		var dx := player.global_position.x - global_position.x
		velocity.x = sign(dx) * SPEED

		_shoot_cd -= delta
		if _shoot_cd <= 0.0:
			_shoot_at(player)
			_shoot_cd = SHOOT_INTERVAL
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED * 3)

	move_and_slide()

func _shoot_at(target: Node2D) -> void:
	var bullet: Node2D = _bullet_scene.instantiate()
	bullet.direction = (target.global_position - global_position).normalized()
	bullet.global_position = global_position
	get_parent().add_child(bullet)

func take_damage() -> void:
	health -= 1
	modulate = Color(1.5, 0.5, 0.5)          # flash red-ish
	if health <= 0:
		queue_free()
	else:
		# Reset colour after a brief delay
		await get_tree().create_timer(0.12).timeout
		if is_instance_valid(self):
			modulate = Color.WHITE
