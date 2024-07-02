extends Enemy

@export var screen_width: float = 576.0  # 画面の幅

@export var move_speed: float = 30.0
@export var move_speed_max:float = 30.0
@export var base_jump_impulse_strength: float = 1000.0
@onready var jump_force = Vector2(0, -600)
@onready var collision_normal = Vector2(0, -1)
@onready var move_on_jump = false

@onready var collision_shape = $CollisionShape2D
@onready var sprite = $Sprite2D
@onready var audio_jump = $AudioJump

# 脱落シグナル
signal game_set(loser:String)
# 着地後にシーソーに与えるシグナル
signal seesaw_collided(collided_position:Vector2, impulse:Vector2)

var direction = 1  # 初期の移動方向（右に移動）
var jump_timer = 0  # ジャンプタイマー
var jump_enable = false
var can_jump_buffer := false

func _ready():
	randomize_jump()
	
	# 色
	if Global.current_level < 3 or Global.current_level == 7:
		self.modulate  = Color(0.2, 1, 0.2, 1)
	elif Global.current_level == 10:
		self.modulate  = Color(0.5, 0.1, 0.1, 1)
	elif Global.current_level > 7 or Global.current_level == 6:
		self.modulate  = Color(1, 0, 0, 1)
	elif Global.current_level < 7:
		self.modulate  = Color(1, 0.5, 0.5, 1)
	
	# サイズ
	if Global.current_level in [1, 3, 4, 10]:
		sprite.scale = Vector2(0.3, 0.3)
		collision_shape.scale = Vector2(0.3, 0.3)
	elif Global.current_level in [2, 5, 6]:
		sprite.scale = Vector2(0.5, 0.5)
		collision_shape.scale = Vector2(0.5, 0.5)
	else:
		sprite.scale = Vector2(0.7, 0.7)
		collision_shape.scale = Vector2(0.7, 0.7)
		
	# ジャンプの有無
	jump_enable = Global.current_level > 3
	
	# ジャンプ力
	if Global.current_level in [4]:
		jump_force = Vector2(0, -300)
	elif Global.current_level in [10]:
		jump_force = Vector2(0, -1200)
	else:
		jump_force = Vector2(0, -600)
	
	# ジャンプ中に動くか
	if Global.current_level in [10]:
		move_on_jump = true
	else:
		move_on_jump = false
	
	# 重量 
	if Global.current_level in [1, 3, 4]:
		mass = 1
	else:
		mass = 2
	
	# 移動スピード 
	if Global.current_level in [1, 3, 4]:
		move_speed = 20.0
		move_speed_max = 25.0
	elif Global.current_level in [2]:
		move_speed = 40.0
		move_speed_max = 40.0
	elif Global.current_level in [5, 6]:
		move_speed = 30.0
		move_speed_max = 30.0
	elif Global.current_level in [7, 8]:
		move_speed = 10.0
		move_speed_max = 10.0
	elif Global.current_level in [9]:
		move_speed = 35.0
		move_speed_max = 40.0
	elif Global.current_level in [10]:
		move_speed = 20.0
		move_speed_max = 1000.0
	else:
		move_speed = 0.0
		move_speed_max = 0.0
	

func _physics_process(delta):
	# 脱落
	if position.y > 400 or position.x < -150 or position.x > 576 + 150:
		set_freeze_enabled(true)
		game_set.emit('enemy')
		return
		
	# 画面の右側にいる場合、左に移動
	if Global.current_level == 10:
		if position.x > screen_width * 0.6:
			direction = -1
		# 画面の左側にいる場合、右に移動
		elif position.x < screen_width * 0.4:
			direction = 1
	else:
		if position.x > screen_width * 0.7:
			direction = -1
		# 画面の左側にいる場合、右に移動
		elif position.x < screen_width * 0.3:
			direction = 1

	# ランダムなタイミングでジャンプ
	if jump_enable:
		jump_timer -= delta
		if jump_timer <= 0:
			jump()
			randomize_jump()
	
	# メイン処理
	var can_jump = check_jump()
	if can_jump == true and can_jump_buffer == false:
		var collision_point = get_global_position()
		var velocity = linear_velocity
		var speed = velocity.length()
		var adjusted_impulse_strength = base_jump_impulse_strength * (speed / 80)
		var impulse = collision_normal * adjusted_impulse_strength
		seesaw_collided.emit(collision_point, impulse)
	
	# 水平方向の移動
	var force = Vector2(direction * move_speed, 0)
	if move_on_jump:
		if (self.linear_velocity.x < move_speed_max or self.linear_velocity.x > -move_speed_max):
			self.apply_impulse(force, Vector2(0, 0))
	else: 
		if can_jump and (self.linear_velocity.x < move_speed_max or self.linear_velocity.x > -move_speed_max):
			self.apply_impulse(force, Vector2(0, 0))
		
	can_jump_buffer = can_jump

func jump():
	if check_jump():
		audio_jump.play()
		apply_central_impulse(jump_force)

func randomize_jump():
	jump_timer = randf_range(0.5, 2.0)
