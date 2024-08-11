extends RigidBody2D

class_name Player_practice

@onready var charcter_canvas = preload("res://scenes/main/CharacterCanvas.tscn")

@export var move_speed: float = 50.0
@export var move_speed_max = 250
@export var jump_speed: float = 500.0
@export var drop_speed: float = 1500.0
@export var drop_seesaw_speed: float = 150.0
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
@onready var audio_attacked_electric = $AudioAttackedElectric
@onready var audio_dashed = $AudioDashed
@onready var sprite = $Sprite2D
@onready var animation = $AnimationPlayer

@onready var can_jump_buffer := false
@onready var is_dropping := false
@onready var get_damaged := false
@onready var move_right_interval := 0
@onready var move_left_interval := 0
@onready var dash_interval := 0
@onready var gameset_interval := 0
@onready var MOVE_FAST_LIMIT := 20
@onready var dash_interval_limit := 30
@onready var sprite_scale := Vector2(1, 1)
@onready var sprite_amplitude := 0.01  # Y軸の振幅
@onready var sprite_frequency := 3.0   # 周波数（1秒あたりのサイクル数）
@onready var time_elapsed := 0.0
@onready var dash_speed := 20.0
var canvas


# 着地後にシーソーに与えるシグナル
signal seesaw_collided(collided_position:Vector2, impulse:Vector2)
# カメラシェイクシグナル
signal camera_shake(duration: float, magnitude: float)
# プレイヤーが落ちたシグナル
signal player_respawn()

func _ready():
	sprite_scale = sprite.scale
	canvas = charcter_canvas.instantiate()
	var position_arrow = canvas.get_node("PositionArrow")
	position_arrow.modulate = Color(0.85, 0.85, 0.85, 1)
	add_child(canvas)

func _physics_process(delta):
	# 脱落
	if position.y > 400 and !Global.player_fall:
		Global.player_fall = true
		position.y = 399
		set_freeze_enabled(true)
		player_respawn.emit()
		return
	
	# ダッシュ判定用
	move_right_interval += 1
	move_left_interval += 1
	dash_interval += 1
	
	var can_jump = check_jump()
	# ジャンプ着地判定
	if can_jump and can_jump_buffer == false:
		var collision_point = get_global_position()
		var velocity = linear_velocity
		var speed = velocity.length()
		var adjusted_impulse_strength = base_jump_impulse_strength * (speed / 1000)
		var impulse = collision_normal * adjusted_impulse_strength
		if is_dropping:
			if collision_point.x < Global.SCREEN_WIDTH / 6 or collision_point.x > Global.SCREEN_WIDTH * 5 / 6:
				impulse = Vector2(0, -20000)
			elif collision_point.x < Global.SCREEN_WIDTH * 2 / 6 or collision_point.x > Global.SCREEN_WIDTH * 4 / 6:
				impulse = Vector2(0, -30000)
			else: 
				impulse = Vector2(0, -50000)
				
			is_dropping = false
			camera_shake.emit(0.5, 6.0)
		else:
			animation.play("stop")
			
		seesaw_collided.emit(collision_point, impulse)
	elif can_jump:
		# リズムを取る
		time_elapsed += delta
		var scale_offset = sprite_scale.y + sin(time_elapsed * sprite_frequency * 2.0 * PI) * sprite_amplitude
		sprite.scale.y = scale_offset
	
	# プレイヤーの移動
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
				var force = direction * Global.enemy_bump_speed
				self.apply_impulse(force, Vector2(0, 0))
				if Global.player_get_damaged:
					if !audio_attacked.playing:
						if Global.current_level == 5:
							audio_attacked_electric.play()
						else:
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
	var velocity = linear_velocity
	var speed = velocity.length()
	
	# ダッシュ中
	if speed > 1000:
		create_ghost()
		if move_right_interval == MOVE_FAST_LIMIT / 2:
			return move_left_force * dash_speed
		if move_left_interval == MOVE_FAST_LIMIT / 2:
			return move_right_force * dash_speed
	
	# ダッシュ判定
	if Input.is_action_just_pressed("move_right"):
		if dash_interval > dash_interval_limit and move_right_interval < MOVE_FAST_LIMIT:
			move_right_interval = 0
			audio_dashed.play()
			animation.play("dash")
			dash_interval = 0
			return move_right_force * dash_speed
		move_right_interval = 0
		sprite.set_flip_h(false)
	if Input.is_action_just_pressed("move_left"):
		if dash_interval > dash_interval_limit and move_left_interval < MOVE_FAST_LIMIT:
			move_left_interval = 0
			audio_dashed.play()
			animation.play("dash")
			dash_interval = 0
			return move_left_force * dash_speed
		move_left_interval = 0
		sprite.set_flip_h(true)
		
	# ジャンプしていない時
	if can_jump:
		if Input.is_action_pressed("move_right") and self.linear_velocity.x < move_speed_max:
			animation.play("walk")
			return move_right_force
		if Input.is_action_pressed("move_left") and self.linear_velocity.x > -move_speed_max:
			animation.play("walk")
			return move_left_force
		if Input.is_action_just_pressed("move_up"):
			audio_jump.play()
			animation.play("jump")
			return jump_force
		
	# ジャンプ中
	else:
		if Input.is_action_pressed("move_right") and self.linear_velocity.x < move_speed_max:
			return Vector2(move_right_force.x/6, 0)
		elif Input.is_action_pressed("move_left") and self.linear_velocity.x > -move_speed_max:
			return Vector2(move_left_force.x/6, 0)
		elif Input.is_action_just_pressed("move_down") and !is_dropping:
			is_dropping = true
			animation.play("drop")
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

# ゴーストスプライト
func create_ghost():
	var ghost_sprite = Sprite2D.new()
	ghost_sprite.texture = sprite.texture
	ghost_sprite.scale = sprite.scale
	ghost_sprite.rotation = sprite.rotation
	ghost_sprite.modulate = Color(1, 1, 1, 0.5)  # 初期の透明度を設定
	ghost_sprite.hframes = sprite.hframes
	ghost_sprite.vframes = sprite.vframes
	ghost_sprite.frame = sprite.frame
	ghost_sprite.frame_coords = sprite.frame_coords
	var global_position = get_global_position()
	ghost_sprite.global_position = global_position

	# ゴーストスプライトをシーンに追加
	get_tree().root.add_child(ghost_sprite)

	# ゴーストスプライトをフェードアウト
	var tween = get_tree().create_tween()
	tween.tween_property(ghost_sprite, "modulate:a", 0, 0.2)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.connect("finished", Callable(self, "_on_tween_completed").bind(ghost_sprite, tween))
	tween.play()

# フェードアウトが完了したらゴーストスプライトを削除
func _on_tween_completed(ghost_sprite, tween):
	ghost_sprite.queue_free()
