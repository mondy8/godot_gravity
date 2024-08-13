extends RigidBody2D

var move_speed = 15.0
var move_speed_max = 20.0
var direction := 1

func _physics_process(delta):		
	# 画面の右側にいる場合、左に移動
	if position.x > Global.SCREEN_WIDTH * 0.54:
		direction = -1
	# 画面の左側にいる場合、右に移動
	elif position.x < Global.SCREEN_WIDTH * 0.46:
		direction = 1
	
	# 水平方向の移動
	var force = Vector2(direction * move_speed, 0)
		
	if self.linear_velocity.x < move_speed_max or self.linear_velocity.x > -move_speed_max:
		self.apply_impulse(force, Vector2(0, 0))
