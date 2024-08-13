extends Node2D

@onready var overlay := %FadeOverlay
@onready var return_button := %ReturnButton
@onready var audio_select := $audio_select
@onready var audio_press := $audio_press

func _ready():
	overlay.on_complete_fade_out.connect(_on_fade_overlay_on_complete_fade_out)
	return_button.pressed.connect(_on_return_button_pressed)
	
	overlay.visible = true
	return_button.grab_focus()
	return_button.connect("focus_entered", Callable(self, "_on_button_entered"))
	return_button.connect("mouse_entered", Callable(self, "_on_button_entered"))

func _on_fade_overlay_on_complete_fade_out():
	get_tree().change_scene_to_file("res://scenes/main_menu_scene.tscn")

func _on_return_button_pressed():
	audio_press.play()
	overlay.fade_out()
	
func _on_button_entered():
	audio_select.play()
