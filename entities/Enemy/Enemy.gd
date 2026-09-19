class_name Enemy
extends CharacterBody3D

enum STATES { IDLE, MOVE_TO_PLAYER }

@onready var health_component: HealthComponent = get_node_or_null("HealthComponent")
var player: layer

var is_dead: bool = false

func _ready() -> void:
	if health_component:
		health_component.died.connect(die)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Плавное затухание отталкивания по горизонтали
	velocity.x = move_toward(velocity.x, 0, 10.0 * delta)
	velocity.z = move_toward(velocity.z, 0, 10.0 * delta)
	
	if player:
		var target_vec = player.global_position
		target_vec.y = global_position.y
		look_at(target_vec, Vector3(0, 1, 0))
		

	move_and_slide()


func hit(knockback_force: Vector3 = Vector3.ZERO) -> void:
	velocity += knockback_force

func die() -> void:
	if is_dead:
		return
	is_dead = true
	print(self, " died")
	
	queue_free()
