extends Enemy

@onready var left_side_ray = $LeftSideRayCast
@onready var right_side_ray = $RightSideRayCast
@onready var audio_beep = $AudioBeep

var init_bump_speed := 30

# 脱落シグナル
signal game_set(loser:String)
# 着地後にシーソーに与えるシグナル
signal seesaw_collided(collided_position:Vector2, impulse:Vector2)

func _ready():
	sprite.scale *= 0.8
	collision_shape.scale *= 0.8
	mass = 3
	move_speed = 0.0
	move_speed_max = 30.0
	Global.enemy_bump_speed = init_bump_speed
	Global.player_get_damaged = true
	
	
	var timer = self.get_tree().create_timer(0.5)
	await timer.timeout
	move_speed = 80.0

func _physics_process(delta):
	# 脱落
	if position.y > 400 or position.x < -150 or position.x > 576 + 150:
		set_freeze_enabled(true)
		game_set.emit('enemy')
		return
		
	# 画面の右側にいる場合、左に移動
	if position.x > screen_width * 0.62:
		direction = -1
		sprite.set_flip_h(false)
	# 画面の左側にいる場合、右に移動
	elif position.x < screen_width * 0.38:
		direction = 1
		sprite.set_flip_h(true)
	
	# 水平方向の移動
	var can_jump = check_jump()
	var force = Vector2(direction * move_speed, 0)
	if self.linear_velocity.x < move_speed_max or self.linear_velocity.x > -move_speed_max:
		self.apply_impulse(force, Vector2(0, 0))
	
	var is_colliding_player = check_colliding_player()
	if is_colliding_player:
		player_collision()

func check_colliding_player() -> bool:
	if left_side_ray.is_colliding():
		var collider = left_side_ray.get_collider()
		return collider is Player
	
	elif right_side_ray.is_colliding():
		var collider = right_side_ray.get_collider()
		return collider is Player
	
	else:
		return false
		
func player_collision():
	audio_beep.play()
	Global.enemy_bump_speed = 300
	var timer = self.get_tree().create_timer(1)
	await timer.timeout
	Global.enemy_bump_speed = init_bump_speed
