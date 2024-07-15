extends Enemy

@onready var audio_attack = $AudioAttack
@onready var animation = $AnimationPlayer

# 脱落シグナル
signal game_set(loser:String)
# 着地後にシーソーに与えるシグナル
signal seesaw_collided(collided_position:Vector2, impulse:Vector2)

var min_jump_time := 0.5
var max_jump_time := 2.0
var min_sting_time := 50.0
var max_sting_time := 130.0
var sting_timer := 0
var init_bump_speed = 0
var is_stinging := false

func _ready():
	sprite.scale *= 0.4
	collision_shape.scale *= 0.4
	mass = 1.5
	move_speed = 30.0
	move_speed_max = 20.0
	jump_force = Vector2(0, -200)
	jump_timer = randomize_jump(min_jump_time, max_jump_time)
	Global.enemy_bump_speed = init_bump_speed
	Global.player_get_damaged = false
	
	sting_timer = randomize_sting(min_sting_time, max_sting_time)
	

func _physics_process(delta):
	# 脱落
	if position.y > 400 or position.x < -150 or position.x > 576 + 150:
		set_freeze_enabled(true)
		game_set.emit('enemy')
		return
		
	# 画面の右側にいる場合、左に移動
	if position.x > screen_width * 0.57:
		direction = -1
		sprite.set_flip_h(true)
	# 画面の左側にいる場合、右に移動
	elif position.x < screen_width * 0.43:
		direction = 1
		sprite.set_flip_h(false)

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
		var adjusted_impulse_strength = base_jump_impulse_strength * (speed / 80)
		var impulse = collision_normal * adjusted_impulse_strength
		seesaw_collided.emit(collision_point, impulse)
	
	if is_stinging:
		animation.play("attack")
	elif !can_jump:
		animation.play("jump")
	elif animation.current_animation != "walk":
		animation.play("walk")
		
	# ランダムなタイミングで刺す
	sting_timer -= delta
	if can_jump and sting_timer <= 0:
		sting()
		sting_timer = randomize_sting(min_sting_time, max_sting_time)
	
	# 水平方向の移動
	var force = Vector2(direction * move_speed, 0)
	if !is_stinging and self.linear_velocity.x < move_speed_max or self.linear_velocity.x > -move_speed_max:
		self.apply_impulse(force, Vector2(0, 0))
		
	can_jump_buffer = can_jump

func sting():
	audio_attack.play()
	Global.player_get_damaged = true
	Global.enemy_bump_speed = 1000
	is_stinging = true
	var timer = self.get_tree().create_timer(0.5)
	await timer.timeout
	Global.player_get_damaged = false
	Global.enemy_bump_speed = init_bump_speed
	is_stinging = false

func randomize_sting(time_min:float, time_max:float) -> float:
	return randf_range(time_min, time_max)
