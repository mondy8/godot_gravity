extends Node2D

const BALL = preload("res://scenes/intro_ball_rigid_body_2d.tscn")

@export var game_scene: PackedScene
@export var settings_scene: PackedScene
@export var practice_scene: PackedScene

@onready var overlay := %FadeOverlay
@onready var new_game_button := %NewGameButton
@onready var settings_button := %SettingsButton
@onready var practice_button := %PracticeButton
@onready var ball_timer := %BallTimer
@onready var audio_select := $audio_select
@onready var audio_press := $audio_press
@onready var best_score_text := %best_score_text

var next_scene


func _ready() -> void:
	init()


func _on_settings_button_pressed() -> void:
	next_scene = settings_scene
	overlay.fade_out()
	audio_press.play()


func _on_play_button_pressed() -> void:
	next_scene = game_scene
	Global.init_game()
	overlay.fade_out()
	audio_press.play()


func _on_practice_button_pressed() -> void:
	next_scene = practice_scene
	overlay.fade_out()
	audio_press.play()


func _on_fade_overlay_on_complete_fade_out() -> void:
	get_tree().change_scene_to_packed(next_scene)


func init():
	if SaveGame.has_save():
		SaveGame.load_game(get_tree())
	overlay.visible = true
	next_scene = game_scene

	# connect signals
	new_game_button.pressed.connect(_on_play_button_pressed)
	new_game_button.focus_entered.connect(_on_button_entered)
	new_game_button.mouse_entered.connect(_on_button_entered)
	settings_button.pressed.connect(_on_settings_button_pressed)
	settings_button.focus_entered.connect(_on_button_entered)
	settings_button.mouse_entered.connect(_on_button_entered)
	practice_button.pressed.connect(_on_practice_button_pressed)
	practice_button.focus_entered.connect(_on_button_entered)
	practice_button.mouse_entered.connect(_on_button_entered)
	overlay.on_complete_fade_out.connect(_on_fade_overlay_on_complete_fade_out)

	practice_button.grab_focus()

	var config = ConfigFile.new()
	var err = config.load("user://scores.cfg")
	best_score_text.visible = false
	if err != OK:
		return

	for player in config.get_sections():
		# Fetch the data for each section.
		var best_time = config.get_value(player, "best_time")
		var best_revenge = config.get_value(player, "best_revenge")
		var result_text = "ベストタイム：" + str(best_time) + "秒 ベストやり直し回数：" + str(best_revenge) + "回"
		best_score_text.text = result_text
		best_score_text.visible = true
		Global.best_time = best_time
		Global.best_revenge = best_revenge


func _on_timer_timeout() -> void:
	var ball_instance = BALL.instantiate()
	ball_instance.position.x = randf_range(170, 400)
	var scale_value = randf_range(0.5, 2)
	var init_sprite_scale = ball_instance.get_node("Sprite2D").scale
	ball_instance.get_node("Sprite2D").scale = init_sprite_scale * scale_value
	var init_collision_scale = ball_instance.get_node("CollisionShape2D").scale
	ball_instance.get_node("CollisionShape2D").scale = init_collision_scale * scale_value
	var time_value = randf_range(3, 5)
	ball_timer.wait_time = time_value
	add_child(ball_instance)


func _on_button_entered():
	audio_select.play()
