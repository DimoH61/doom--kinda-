class_name Enemy
extends CharacterBody3D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Плавное затухание отталкивания по горизонтали
	velocity.x = move_toward(velocity.x, 0, 10.0 * delta)
	velocity.z = move_toward(velocity.z, 0, 10.0 * delta)

	move_and_slide()


func take_damage(amount: float, knockback_force: Vector3 = Vector3.ZERO) -> void:
	velocity += knockback_force
