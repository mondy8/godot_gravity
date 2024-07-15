extends RigidBody2D

class_name Enemy

var move_speed: float = 30.0
var move_speed_max:float = 30.0
var base_jump_impulse_strength: float = 1000.0
var jump_force = Vector2(0, -600)
var direction = 1  # 初期の移動方向（右に移動）
var jump_timer = 0  # ジャンプタイマー
var jump_enable = false
var can_jump_buffer := false

@onready var ray_right_foot = $RightRayCast2D
@onready var ray_left_foot = $LeftRayCast2D
@onready var collision_shape = $CollisionShape2D
@onready var sprite = $Sprite2D
@onready var audio_jump = $AudioJump

@export var screen_width: float = 576.0  # 画面の幅
@onready var collision_normal = Vector2(0, -1)

# ジャンプ中か判定
func check_jump():
	if ray_right_foot.is_colliding() or ray_left_foot.is_colliding():
		return true
	if ray_right_foot.is_colliding():
		var collider = ray_right_foot.get_collider()
		if collider is Player:
			return false
		else:
			return true
	
	elif ray_left_foot.is_colliding():
		var collider = ray_left_foot.get_collider()
		if collider is Player:
			return false
		else:
			return true
	
	else:
		return false

func jump(target_node: Node2D, jump_force: Vector2) -> void:
	if check_jump():
		audio_jump.play()
		target_node.apply_central_impulse(jump_force)

func randomize_jump(time_min:float, time_max:float) -> float:
	return randf_range(time_min, time_max)
