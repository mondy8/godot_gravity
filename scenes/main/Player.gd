extends RigidBody2D

@export var move_speed: float = 1000.0
@export var move_speed_max = 100
@export var jump_speed: float = 700.0

@onready var move_right_force = Vector2(move_speed, 0)
@onready var move_left_force = Vector2(-move_speed, 0)
@onready var jump_force = Vector2(0, -jump_speed)

@onready var ray_right_foot = $RightRayCast2D
@onready var ray_left_foot = $LeftRayCast2D


func _ready():
	pass

func _physics_process(delta):
	var can_jump = check_state()
	var force = input_process(can_jump)
	self.apply_impulse(force, Vector2(0, 0))

func check_state():
	if ray_right_foot.is_colliding() or ray_left_foot.is_colliding():
		return true
	else: 
		return false

func input_process(can_jump:bool):
	if can_jump:
		if Input.is_action_pressed("ui_right") and self.linear_velocity.x < move_speed_max:
			return move_right_force
		if Input.is_action_pressed("ui_left") and self.linear_velocity.x > -move_speed_max:
			return move_left_force
		if Input.is_action_just_pressed("ui_up"):
			return jump_force
		
	else:
		if Input.is_action_pressed("ui_right") and self.linear_velocity.x < move_speed_max:
			return Vector2(move_right_force.x/6, 0)
		if Input.is_action_pressed("ui_left") and self.linear_velocity.x > -move_speed_max:
			return Vector2(move_left_force.x/6, 0)
	return Vector2(0, 0)
