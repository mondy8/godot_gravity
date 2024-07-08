extends Enemy

# 脱落シグナル
signal game_set(loser:String)
# 着地後にシーソーに与えるシグナル
signal seesaw_collided(collided_position:Vector2, impulse:Vector2)

func _ready():
	sprite.scale *= 0.4
	collision_shape.scale *= 0.4
	mass = 1
	move_speed = 20.0
	move_speed_max = 30.0
	Global.enemy_bump_speed = 30
	Global.player_get_damaged = true

func _physics_process(delta):
	# 脱落
	if position.y > 400 or position.x < -150 or position.x > 576 + 150:
		set_freeze_enabled(true)
		game_set.emit('enemy')
		return
		
	# 画面の右側にいる場合、左に移動
	if position.x > screen_width * 0.55:
		direction = -1
	# 画面の左側にいる場合、右に移動
	elif position.x < screen_width * 0.45:
		direction = 1
	
	# 水平方向の移動
	var force = Vector2(direction * move_speed, 0)
	if move_on_jump:
		if (self.linear_velocity.x < move_speed_max or self.linear_velocity.x > -move_speed_max):
			self.apply_impulse(force, Vector2(0, 0))
	else: 
		if self.linear_velocity.x < move_speed_max or self.linear_velocity.x > -move_speed_max:
			self.apply_impulse(force, Vector2(0, 0))
