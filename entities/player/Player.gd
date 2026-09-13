extends CharacterBody3D

class_name Player


const SPEED = 6.0
const JUMP_VELOCITY = 4.5


@export var weapon_scene: PackedScene

@onready var head: CSGBox3D = $Head
@onready var camera: Camera3D = %Camera3D
@onready var hand: Node3D = %Hand
@onready var ray_cast: RayCast3D = $Head/Camera3D/RayCast3D
@onready var shot_gun_sprite: AnimatedSprite2D = $Head/Camera3D/CanvasLayer/Control/ShotGunSprite
@onready var audio_stream_player: AudioStreamPlayer = $Head/Camera3D/CanvasLayer/Control/AudioStreamPlayer



var current_weapon: Weapon = null


var sens: float = 0.003
var camera_rotation_x: float = 0.0


func _ready() -> void:
	if weapon_scene:
		_equip_weapon(weapon_scene)
	shot_gun_sprite.play("ShotGun_Idle")


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if GameManager.window_has_focus:
		movement_proccess(delta)
	



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and GameManager.window_has_focus:
		camera_proccess(event)
	
	if event.is_action_pressed("Mouse_left_button") and current_weapon and current_weapon.can_shoot and current_weapon.current_ammo > 0 and shot_gun_sprite.animation == "ShotGun_Idle":
		current_weapon.shoot(ray_cast)
		shot_gun_sprite.play("ShotGun_shoot")
		var hit_direction: Vector3 = ray_cast.global_transform.basis.z
		velocity += hit_direction * 8
	
	if event.is_action_pressed("reload") and current_weapon:
		current_weapon.reload()



func movement_proccess(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY


	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 40 * delta)
		velocity.z = move_toward(velocity.z, 0, 40 * delta)
	
	move_and_slide()


func camera_proccess(event: InputEvent) -> void:
	rotate_y(event.relative.x * -sens)
	
	camera_rotation_x -= event.relative.y * sens
	camera_rotation_x = clampf(camera_rotation_x, deg_to_rad(-80.0), deg_to_rad(90.0))
	camera.rotation.x = camera_rotation_x


func _equip_weapon(new_weapon_scene: PackedScene) -> void:
	if current_weapon:
		current_weapon.queue_free()

	var instance = new_weapon_scene.instantiate()
	if instance is Weapon:
		current_weapon = instance
		hand.add_child(current_weapon)


func _on_shot_gun_sprite_frame_changed() -> void:
	if shot_gun_sprite.animation == "ShotGun_shoot":
		if shot_gun_sprite.frame == 2:
			audio_stream_player.pitch_scale = randf_range(0.98, 1.02)
			audio_stream_player.play()


func _on_shot_gun_sprite_animation_finished() -> void:
	if shot_gun_sprite.animation == "ShotGun_shoot":
		shot_gun_sprite.play("ShotGun_Idle")
