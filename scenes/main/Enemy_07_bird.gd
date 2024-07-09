extends Enemy

@onready var audio_attack = $AudioAttack

# 脱落シグナル
signal game_set(loser:String)
# 着地後にシーソーに与えるシグナル
signal seesaw_collided(collided_position:Vector2, impulse:Vector2)
# カメラシェイクシグナル
signal camera_shake(duration: float, magnitude: float)

var min_jump_time := 0.5
var max_jump_time := 2.0
var init_sprite_scale := Vector2(1, 1)

func _ready():
	sprite.scale *= 0.8
	collision_shape.scale *= 0.8
	mass = 3
	move_speed = 35.0
	move_speed_max = 10.0
	jump_force = Vector2(0, -1400)
	jump_timer = randomize_jump(min_jump_time, max_jump_time)
	Global.enemy_bump_speed = 100
	Global.player_get_damaged = true
	
	init_sprite_scale = sprite.scale

func _physics_process(delta):
	# 脱落
	if position.y > 400 or position.x < -150 or position.x > 576 + 150:
		set_freeze_enabled(true)
		game_set.emit('enemy')
		return
		
	# 画面の右側にいる場合、左に移動
	if position.x > screen_width * 0.7:
		direction = -1
		sprite.set_flip_h(false)
	# 画面の左側にいる場合、右に移動
	elif position.x < screen_width * 0.3:
		direction = 1
		sprite.set_flip_h(true)

	# ランダムなタイミングでジャンプ
	jump_timer -= delta
	if jump_timer <= 0:
		jump(self, jump_force)
		jump_timer = randomize_jump(min_jump_time, max_jump_time)
	
	# メイン処理
	var can_jump = check_jump()
	if can_jump == true and can_jump_buffer == false:
		var collision_point = get_global_position()
		var velocity = linear_velocity
		var speed = velocity.length()
		var adjusted_impulse_strength = base_jump_impulse_strength * (speed / 10)
		var impulse = collision_normal * adjusted_impulse_strength
		seesaw_collided.emit(collision_point, impulse)
		audio_attack.play()
		camera_shake.emit(0.5, 6.0)
		var tween = get_tree().create_tween()
		tween.tween_property(sprite, "scale", Vector2(init_sprite_scale.x, init_sprite_scale.y * 0.7), 0.1)
		tween.tween_property(sprite, "scale", init_sprite_scale, 0.3)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_QUINT)
	
	# 水平方向の移動
	var force = Vector2(direction * move_speed, 0)
	if can_jump and (self.linear_velocity.x < move_speed_max or self.linear_velocity.x > -move_speed_max):
		self.apply_impulse(force, Vector2(0, 0))
		
	can_jump_buffer = can_jump


