extends RigidBody2D

@export var screen_width: float = 576.0  # 画面の幅

@export var move_speed: float = 1000.0
@export var move_speed_max = 100
@export var jump_speed: float = 400.0
@export var base_jump_impulse_strength: float = 1000.0

@onready var jump_force = Vector2(0, -jump_speed)
@onready var collision_normal = Vector2(0, -1)

@onready var ray_right_foot = $RightRayCast2D
@onready var ray_left_foot = $LeftRayCast2D

@onready var can_jump_buffer := false
#@onready var is_dropping := false

# 着地後にシーソーに与えるシグナル
signal seesaw_collided(collided_position:Vector2, impulse:Vector2)
signal game_set(loser:String)

var direction = 1  # 初期の移動方向（右に移動）
var jump_timer = 0  # ジャンプタイマー

func _ready():
	randomize_jump()

func _physics_process(delta):
	# 脱落
	if position.y > 400:
		set_freeze_enabled(true)
		game_set.emit('enemy')
		return
	
	# 画面の右側にいる場合、左に移動
	if position.x > screen_width * 0.6:
		direction = -1
	# 画面の左側にいる場合、右に移動
	elif position.x < screen_width * 0.3:
		direction = 1

	# ランダムなタイミングでジャンプ
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
		var adjusted_impulse_strength = base_jump_impulse_strength * (speed / 100)
		var impulse = collision_normal * adjusted_impulse_strength
		seesaw_collided.emit(collision_point, impulse)
	
	# 水平方向の移動
	var force = Vector2(direction * move_speed, 0)
	if can_jump and (self.linear_velocity.x < move_speed_max or self.linear_velocity.x > -move_speed_max):
		self.apply_impulse(force, Vector2(0, 0))
		
	can_jump_buffer = can_jump

# ジャンプ中か判定
func check_jump():
	if ray_right_foot.is_colliding() or ray_left_foot.is_colliding():
		return true
	else: 
		return false

func jump():
	if check_jump():
		apply_central_impulse(jump_force)

func randomize_jump():
	jump_timer = randf_range(0.5, 2.0)
