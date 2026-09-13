class_name Weapon
extends Node3D

signal ammo_changed(current: int, max_ammo: int)
signal shot_fired

@export var data: WeaponData:
	set(value):
		data = value
		_apply_data()



var current_ammo: int = 0:
	set(value):
		current_ammo = value
		ammo_changed.emit(current_ammo, data.max_ammo)

var can_shoot: bool = true
var fire_timer: SceneTreeTimer

func _ready() -> void:
	_apply_data()


func _apply_data() -> void:
	if not is_node_ready() or not data:
		return
	
	current_ammo = data.max_ammo


func shoot(ray_cast: RayCast3D) -> void:
	if not can_shoot or current_ammo <= 0 or not data:
		return
	can_shoot = false
	current_ammo -= 1
	shot_fired.emit()
	print(current_ammo, " / ", data.max_ammo)
	
	_proccess_hit(ray_cast)
	
	
	get_tree().create_timer(data.base_fire_rate).timeout.connect(func(): can_shoot = true)


func _proccess_hit(ray_cast: RayCast3D) -> void:
	if ray_cast and ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		var health = collider.get_node_or_null("HealthComponent") as HealthComponent
		print(collider)
		if health and health.has_method("take_damage"):
			var hit_direction: Vector3 = -ray_cast.global_transform.basis.z
			var knockback_vector: Vector3 = hit_direction * 5.0
			
			knockback_vector.y += 0.5
			health.take_damage(data.base_damage)
			if collider.has_method("hit"):
				collider.hit(knockback_vector)


func reload() -> void:
	if not data:
		return
	current_ammo = data.max_ammo
