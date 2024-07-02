extends RigidBody2D

@export var move_speed: float = 1000.0
@export var move_speed_max = 100
@export var jump_speed: float = 400.0
@export var drop_speed: float = 1500.0
@export var drop_seesaw_speed: float = 150.0
@export var enemy_bump_speed: float = 150.0

@export var base_jump_impulse_strength: float = 1000.0

@onready var move_right_force = Vector2(move_speed, 0)
@onready var move_left_force = Vector2(-move_speed, 0)
@onready var jump_force = Vector2(0, -jump_speed)
@onready var drop_force = Vector2(0, drop_speed)
@onready var collision_normal = Vector2(0, -1)

@onready var ray = $Raycast
@onready var ray_right_foot = $Raycast/RightFootRayCast2D
@onready var ray_left_foot = $Raycast/LeftFootRayCast2D
@onready var ray_right_side = $Raycast/RightBottomRayCast2D
@onready var ray_left_side = $Raycast/LeftBottomRayCast2D
@onready var audio_jump = $AudioJump
@onready var audio_drop = $AudioDrop
@onready var audio_attacked = $AudioAttacked

@onready var can_jump_buffer := false
@onready var is_dropping := false
@onready var get_damaged := false

# 着地後にシーソーに与えるシグナル
signal seesaw_collided(collided_position:Vector2, impulse:Vector2)
# 脱落シグナル
signal game_set(winner:String)
# カメラシェイクシグナル
signal camera_shake(duration: float, magnitude: float)

func _ready():
	if Global.current_level < 3 or Global.current_level == 7:
		enemy_bump_speed = 10
	elif Global.current_level > 7 or Global.current_level == 6:
		enemy_bump_speed = 150
		get_damaged = true
	elif Global.current_level < 7:
		enemy_bump_speed = 60
		get_damaged = true

func _physics_process(delta):
	# 脱落
	if position.y > 400 or position.x < -150 or position.x > 576 + 150:
		set_freeze_enabled(true)
		game_set.emit('player')
		return
	
	# ジャンプ処理
	var can_jump = check_jump()
	print(can_jump)
	if can_jump == true and can_jump_buffer == false:
		var collision_point = get_global_position()
		collision_point.y -= 80
		var velocity = linear_velocity
		var speed = velocity.length()
		var adjusted_impulse_strength = base_jump_impulse_strength * (speed / 1000)
		var impulse = collision_normal * adjusted_impulse_strength
		print(is_dropping)
		if is_dropping:
			impulse = impulse * 20
			is_dropping = false
			camera_shake.emit(0.5, 6.0)
		seesaw_collided.emit(collision_point, impulse)
	var force = await input_process(can_jump)
	self.apply_impulse(force, Vector2(0, 0))
	can_jump_buffer = can_jump
	
	check_enemy_bump()

# ジャンプ中か判定
func check_jump():
	if ray_right_foot.is_colliding() or ray_left_foot.is_colliding() or ray_right_side.is_colliding() or ray_left_side.is_colliding():
		return true
	else: 
		return false

# 敵と衝突中の処理
func check_enemy_bump():
	for child in ray.get_children():
		if child.is_colliding():
			var collider = child.get_collider()
			if collider is Enemy:
				var collider_position = collider.get_global_position()
				var self_position = global_position
				var direction = (self_position - collider_position).normalized()
				var force = direction * enemy_bump_speed
				self.apply_impulse(force, Vector2(0, 0))
				if get_damaged:
					if !audio_attacked.playing:
						audio_attacked.play()
					var tween = get_tree().create_tween()
					tween.tween_property(self, "modulate", Color(1, 0, 0, 1), 0.1)
					tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.1)
					tween.set_ease(Tween.EASE_IN_OUT)
					tween.set_trans(Tween.TRANS_QUINT)
					tween.play()
					camera_shake.emit(0.2, 6.0)


# キー入力判定
func input_process(can_jump:bool) -> Vector2:
	if can_jump:
		if Input.is_action_pressed("move_right") and self.linear_velocity.x < move_speed_max:
			return move_right_force
		if Input.is_action_pressed("move_left") and self.linear_velocity.x > -move_speed_max:
			return move_left_force
		if Input.is_action_just_pressed("move_up"):
			audio_jump.play()
			return jump_force
		
	else:
		if Input.is_action_pressed("move_right") and self.linear_velocity.x < move_speed_max:
			return Vector2(move_right_force.x/6, 0)
		if Input.is_action_pressed("move_left") and self.linear_velocity.x > -move_speed_max:
			return Vector2(move_left_force.x/6, 0)
		if Input.is_action_just_pressed("move_down") and !is_dropping:
			is_dropping = true
			set_freeze_enabled(true)
			var tween = get_tree().create_tween()
			tween.tween_property(self, "rotation", -3 *  2 * PI, 0.5)
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.set_trans(Tween.TRANS_QUINT)
			tween.play()
			var timer = self.get_tree().create_timer(0.5)
			await timer.timeout
			audio_drop.play()
			set_freeze_enabled(false)
			return drop_force
	return Vector2(0, 0)

