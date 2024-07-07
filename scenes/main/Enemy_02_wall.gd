extends Enemy

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
	sprite.scale *= 0.5
	collision_shape.scale *= 0.5
	mass = 3
	move_speed = 50.0
	move_speed_max = 10.0

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
	var force = Vector2(direction * move_speed, 0)
	if move_on_jump:
		if (self.linear_velocity.x < move_speed_max or self.linear_velocity.x > -move_speed_max):
			self.apply_impulse(force, Vector2(0, 0))
	else: 
		if self.linear_velocity.x < move_speed_max or self.linear_velocity.x > -move_speed_max:
			self.apply_impulse(force, Vector2(0, 0))
