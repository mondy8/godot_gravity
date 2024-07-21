extends Enemy

@onready var audio_ring = $AudioRing

# 脱落シグナル
signal game_set(loser:String)
# 着地後にシーソーに与えるシグナル
signal seesaw_collided(collided_position:Vector2, impulse:Vector2)

var ring_timer = 1.0
var min_ring_time = 0.0
var max_ring_time = 2.0

func _ready():
	super.set_canvas()
	sprite.scale *= 0.5
	collision_shape.scale *= 0.5
	mass = 1.5
	move_speed = 40.0
	move_speed_max = 30.0
	Global.enemy_bump_speed = 60
	Global.player_get_damaged = true

func _physics_process(delta):
	# 脱落
	if position.y > SCREEN_HEIGHT:
		set_freeze_enabled(true)
		game_set.emit('enemy')
		return
	
	# ランダムなタイミングでチリン
	ring_timer -= delta
	if ring_timer <= 0:
		audio_ring.play()
		ring_timer = randomize_ring(min_ring_time, max_ring_time)
		
	# 画面の右側にいる場合、左に移動
	if position.x > screen_width * 0.6:
		direction = -1
		sprite.set_flip_h(false)
	# 画面の左側にいる場合、右に移動
	elif position.x < screen_width * 0.4:
		direction = 1
		sprite.set_flip_h(true)
	
	# 水平方向の移動
	var can_jump = check_jump()
	var force = Vector2(direction * move_speed, 0)
	# 端にいる場合は戻ろうとする
	if position.x < screen_width * 0.25 or position.x > screen_width * 0.75:
		force = Vector2(direction * move_speed * 9.65, 0)
	if can_jump and (self.linear_velocity.x < move_speed_max or self.linear_velocity.x > -move_speed_max):
		self.apply_impulse(force, Vector2(0, 0))

func randomize_ring(time_min:float, time_max:float) -> float:
	return randf_range(time_min, time_max)
