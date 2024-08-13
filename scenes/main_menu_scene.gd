extends Node2D

static var GAME_SCENE = load("res://scenes/ingame_scene.tscn")
static var SETTINGS_SCENE = load("res://scenes/game_settings_scene.tscn")
static var PRACTICE_SCENE = load("res://scenes/practice_scene.tscn")

@onready var ball = preload("res://scenes/intro_ball_rigid_body_2d.tscn")

@export var game_scene:PackedScene
@export var settings_scene:PackedScene

@onready var overlay := %FadeOverlay
@onready var new_game_button := %NewGameButton
@onready var settings_button := %SettingsButton
@onready var practice_button := %PracticeButton
@onready var ball_timer := %BallTimer
@onready var audio_select := $audio_select
@onready var audio_press := $audio_press

var next_scene

func _ready() -> void:
	init()

func _on_settings_button_pressed() -> void:
	next_scene = SETTINGS_SCENE
	overlay.fade_out()
	audio_press.play()
	
func _on_play_button_pressed() -> void:
	next_scene = GAME_SCENE
	Global.init_game()
	overlay.fade_out()
	audio_press.play()
	
func _on_practice_button_pressed() -> void:
	next_scene = PRACTICE_SCENE
	overlay.fade_out()
	audio_press.play()

func _on_fade_overlay_on_complete_fade_out() -> void:
	#if new_game and SaveGame.has_save():
		#SaveGame.delete_save()
	get_tree().change_scene_to_packed(next_scene)
	
func init():
	overlay.visible = true
	next_scene = GAME_SCENE
	#new_game_button.disabled = game_scene == null
	#settings_button.disabled = settings_scene == null
	#continue_button.visible = SaveGame.has_save() and SaveGame.ENABLED
	
	# connect signals
	new_game_button.pressed.connect(_on_play_button_pressed)
	new_game_button.connect("focus_entered", Callable(self, "_on_button_entered"))
	new_game_button.connect("mouse_entered", Callable(self, "_on_button_entered"))
	settings_button.pressed.connect(_on_settings_button_pressed)
	settings_button.connect("focus_entered", Callable(self, "_on_button_entered"))
	settings_button.connect("mouse_entered", Callable(self, "_on_button_entered"))
	practice_button.pressed.connect(_on_practice_button_pressed)
	practice_button.connect("focus_entered", Callable(self, "_on_button_entered"))
	practice_button.connect("mouse_entered", Callable(self, "_on_button_entered"))
	overlay.on_complete_fade_out.connect(_on_fade_overlay_on_complete_fade_out)
	
	practice_button.grab_focus()

func _on_timer_timeout() -> void:
	var ball_instance = ball.instantiate()
	ball_instance.position.x = randf_range(170, 400)
	var scale_value = randf_range(0.3, 2)
	var init_sprite_scale = ball_instance.get_node("Sprite2D").scale
	ball_instance.get_node("Sprite2D").scale = init_sprite_scale * scale_value
	var init_collision_scale = ball_instance.get_node("CollisionShape2D").scale
	ball_instance.get_node("CollisionShape2D").scale = init_collision_scale * scale_value
	var time_value = randf_range(3, 5)
	ball_timer.wait_time = time_value
	add_child(ball_instance)
	
func _on_button_entered():
	audio_select.play()
