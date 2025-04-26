extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_defending: bool = false
var is_dead: bool = false

func _physics_process(delta: float) -> void:
	if is_dead:
		return  # No controls after death

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta 

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor() and !is_defending:
		velocity.y = JUMP_VELOCITY

	# Shield
	if Input.is_action_pressed("shield"):
		defend()
	else:
		is_defending = false

	# Movement (only if not shielding)
	var direction := Input.get_axis("left", "right")
	if direction and !is_defending:
		velocity.x = direction * SPEED
		sprite.flip_h = direction < 0
		if sprite.animation != "run" and !Input.is_action_pressed("attack"):
			sprite.play("run")
	elif !is_defending:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor() and !Input.is_action_pressed("attack"):
			sprite.play("idle")

	# Attack
	if Input.is_action_just_pressed("attack") and !is_defending:
		attack()

	# Death
	if Input.is_action_just_pressed("death"):
		die()

	move_and_slide()

func attack() -> void:
	sprite.play("attack")

func defend() -> void:
	is_defending = true
	velocity.x = 0
	sprite.play("shield")

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	sprite.play("death")
