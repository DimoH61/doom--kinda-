class_name layer

extends CharacterBody3D


var speed = 6.0
var jump_velocity = 7.5

@export var WEAPON_DATA : Weapons
var current_weapon_instance

@onready var UI: Control = $Head/Camera3D/UI_Canvas/UI


@onready var attack_cooldown: Timer = $AttackCooldown

@onready var head: CSGBox3D = $Head
@onready var camera: Camera3D = %Camera3D
@onready var ray_cast: RayCast3D = $Head/Camera3D/RayCast3D
#@onready var shot_gun_sprite: AnimatedSprite2D = $Head/Camera3D/CanvasLayer/Control/ShotGunSprite
#@onready var audio_stream_player: AudioStreamPlayer = $Head/Camera3D/CanvasLayer/Control/AudioStreamPlayer
#@onready var knife_sprite: AnimatedSprite2D = $Head/Camera3D/CanvasLayer/Control/KnifeSprite


var sens: float = 0.001


func _ready() -> void:
	if WEAPON_DATA != null or WEAPON_DATA.scene != null:
		var weapon_instance = WEAPON_DATA.scene.instantiate()
		UI.add_child(weapon_instance)
		current_weapon_instance = weapon_instance
		weapon_instance.scale = Vector2(0.6, 0.6)
		weapon_instance.play("idle")
	else:
		push_error("weapon data missing")



func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if GameManager.window_has_focus:
		movement_proccess(delta)
	



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and GameManager.window_has_focus:
		camera_proccess(event)
	
	if event.is_action_pressed("attack") and attack_cooldown.is_stopped():
		current_weapon_instance.play("attack")
		
		#var hit_direction: Vector3 = ray_cast.global_transform.basis.z
		#velocity += hit_direction * 8
	#
	#if event.is_action_pressed("reload") and current_weapon:
		#current_weapon.reload()



func movement_proccess(delta: float) -> void:
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir := Input.get_vector("a", "d", "w", "s")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction and is_on_floor():
		velocity.x = lerp(velocity.x, direction.x * speed, 10 * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, 10 * delta)
	elif is_on_floor():
		velocity.x = lerp(velocity.x, 0.0, 10.0 * delta)
		velocity.z = lerp(velocity.z, 0.0, 10.0 * delta)
	elif is_on_floor() == false and direction:
		velocity.x = lerp(velocity.x, direction.x * speed, 1.0 * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, 1.0 * delta)
	
	move_and_slide()



func camera_proccess(event: InputEvent) -> void:
	rotate_y(event.relative.x * -sens)
	camera.rotation.x += -(event.relative.y * sens)
	camera.rotation.x = clampf(camera.rotation.x, deg_to_rad(-90.0), deg_to_rad(90.0))
