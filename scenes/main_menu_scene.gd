extends Node2D

@onready var GAME_SCENE = preload("res://scenes/ingame_scene.tscn")
@onready var SETTINGS_SCENE = preload("res://scenes/game_settings_scene.tscn")

@export var game_scene:PackedScene
@export var settings_scene:PackedScene

@onready var overlay := %FadeOverlay
@onready var continue_button := %ContinueButton
@onready var new_game_button := %NewGameButton
@onready var settings_button := %SettingsButton
@onready var exit_button := %ExitButton

var next_scene
var is_init = false

func _ready() -> void:
	init()

func _process(delta):
	if !is_init:
		init()

func _on_settings_button_pressed() -> void:
	#new_game = false
	next_scene = SETTINGS_SCENE
	overlay.fade_out()
	
func _on_play_button_pressed() -> void:
	next_scene = GAME_SCENE
	overlay.fade_out()
	
func _on_continue_button_pressed() -> void:
	#new_game = false
	next_scene = GAME_SCENE
	overlay.fade_out()

#func _on_exit_button_pressed() -> void:
	#get_tree().quit()

func _on_fade_overlay_on_complete_fade_out() -> void:
	#if new_game and SaveGame.has_save():
		#SaveGame.delete_save()
	get_tree().change_scene_to_packed(next_scene)
	
func init():	
	print("hit")
	overlay.visible = true
	next_scene = GAME_SCENE
	#new_game_button.disabled = game_scene == null
	#settings_button.disabled = settings_scene == null
	#continue_button.visible = SaveGame.has_save() and SaveGame.ENABLED
	
	# connect signals
	new_game_button.pressed.connect(_on_play_button_pressed)
	#continue_button.pressed.connect(_on_continue_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	#exit_button.pressed.connect(_on_exit_button_pressed)
	overlay.on_complete_fade_out.connect(_on_fade_overlay_on_complete_fade_out)
	
	new_game_button.grab_focus()
	#if continue_button.visible:
	#else:
		#new_game_button.grab_focus()
	
	is_init = true
	
