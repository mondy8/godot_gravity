extends RigidBody2D

@export var move_speed: float = 1000.0
@export var move_speed_max = 100
@export var jump_speed: float = 400.0
@export var drop_speed: float = 1500.0
@export var base_jump_impulse_strength: float = 1000.0

@onready var move_right_force = Vector2(move_speed, 0)
@onready var move_left_force = Vector2(-move_speed, 0)
@onready var jump_force = Vector2(0, -jump_speed)
@onready var drop_force = Vector2(0, drop_speed)
@onready var collision_normal = Vector2(0, -1)

@onready var ray_right_foot = $RightRayCast2D
@onready var ray_left_foot = $LeftRayCast2D

@onready var can_jump_buffer := false
@onready var is_dropping := false

# 着地後にシーソーに与えるシグナル
signal seesaw_collided(collided_position:Vector2, impulse:Vector2)
signal game_set(winner:String)

func _ready():
	pass

func _physics_process(delta):
	print(position)
	# 脱落
	if position.y > 400:
		set_freeze_enabled(true)
		game_set.emit('player')
		return
	
	# メイン処理
	var can_jump = check_jump()
	if can_jump == true and can_jump_buffer == false:
		var collision_point = get_global_position()
		var velocity = linear_velocity
		var speed = velocity.length()
		var adjusted_impulse_strength = base_jump_impulse_strength * (speed / 1000)
		var impulse = collision_normal * adjusted_impulse_strength
		print(is_dropping)
		if is_dropping:
			impulse = impulse * 20
			is_dropping = false
		seesaw_collided.emit(collision_point, impulse)
	var force = await input_process(can_jump)
	self.apply_impulse(force, Vector2(0, 0))
	can_jump_buffer = can_jump

# ジャンプ中か判定
func check_jump():
	if ray_right_foot.is_colliding() or ray_left_foot.is_colliding():
		return true
	else: 
		return false

# キー入力判定
func input_process(can_jump:bool) -> Vector2:
	if can_jump:
		if Input.is_action_pressed("move_right") and self.linear_velocity.x < move_speed_max:
			return move_right_force
		if Input.is_action_pressed("move_left") and self.linear_velocity.x > -move_speed_max:
			return move_left_force
		if Input.is_action_just_pressed("move_up"):
			return jump_force
		
	else:
		if Input.is_action_pressed("move_right") and self.linear_velocity.x < move_speed_max:
			return Vector2(move_right_force.x/6, 0)
		if Input.is_action_pressed("move_left") and self.linear_velocity.x > -move_speed_max:
			return Vector2(move_left_force.x/6, 0)
		if Input.is_action_just_pressed("move_down"):
			is_dropping = true
			set_freeze_enabled(true)
			var tween = get_tree().create_tween()
			tween.tween_property(self, "rotation", -3 *  2 * PI, 0.5)
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.set_trans(Tween.TRANS_QUINT)
			tween.play()
			var timer = self.get_tree().create_timer(0.5)
			await timer.timeout
			set_freeze_enabled(false)
			return drop_force
	return Vector2(0, 0)

