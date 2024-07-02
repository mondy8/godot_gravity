extends Enemy

@export var screen_width: float = 576.0  # 画面の幅

@export var move_speed: float = 10.0
@export var move_speed_max:float = 10.0
@onready var collision_normal = Vector2(0, -1)

# 脱落シグナル
var direction = 1  # 初期の移動方向（右に移動）

func _physics_process(delta):
		
	# 画面の右側にいる場合、左に移動
	if position.x > screen_width * 0.6:
		direction = -1
	# 画面の左側にいる場合、右に移動
	elif position.x < screen_width * 0.3:
		direction = 1

	# 水平方向の移動
	var force = Vector2(direction * move_speed, 0)
	if self.linear_velocity.x < move_speed_max or self.linear_velocity.x > -move_speed_max:
		self.apply_impulse(force, Vector2(0, 0))
