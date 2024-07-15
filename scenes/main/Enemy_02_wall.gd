extends Enemy

# 脱落シグナル
signal game_set(loser:String)
# 着地後にシーソーに与えるシグナル
signal seesaw_collided(collided_position:Vector2, impulse:Vector2)

func _ready():
	sprite.scale *= 0.5
	collision_shape.scale *= 0.5
	mass = 3
	move_speed = 50.0
	move_speed_max = 10.0
	Global.enemy_bump_speed = 0
	Global.player_get_damaged = false

func _physics_process(delta):
	# 脱落
	if position.y > 400 or position.x < -150 or position.x > 576 + 150:
		set_freeze_enabled(true)
		game_set.emit('enemy')
		return
		
	# 画面の右側にいる場合、左に移動
	if position.x > screen_width * 0.7:
		direction = -1
	# 画面の左側にいる場合、右に移動
	elif position.x < screen_width * 0.3:
		direction = 1
	
	# 水平方向の移動
	var can_jump = check_jump()
	var force = Vector2(direction * move_speed, 0)
	if can_jump and (self.linear_velocity.x < move_speed_max or self.linear_velocity.x > -move_speed_max):
		self.apply_impulse(force, Vector2(0, 0))
