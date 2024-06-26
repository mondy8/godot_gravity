extends Node2D

@onready var fade_overlay = %FadeOverlay
@onready var pause_overlay = %PauseOverlay
@onready var player = $Player
@onready var seesawGround = $Seesaw/SeesawGround

func _ready() -> void:
	fade_overlay.visible = true
	
	if SaveGame.has_save():
		SaveGame.load_game(get_tree())
	
	pause_overlay.game_exited.connect(_save_game)
	
	# playerからシーソーへ与えるシグナル
	player.player_seesaw_collided.connect(_on_player_seesaw_collided)


func _input(event) -> void:
	if event.is_action_pressed("pause") and not pause_overlay.visible:
		get_viewport().set_input_as_handled()
		get_tree().paused = true
		pause_overlay.grab_button_focus()
		pause_overlay.visible = true
		
func _save_game() -> void:
	SaveGame.save_game(get_tree())

# シーソーへの衝突処理
func _on_player_seesaw_collided(collided_position:Vector2, impulse:Vector2):
	print("Observed1 got notify from Subject !!")
	var seesawPosition = seesawGround.to_local(collided_position)
	seesawGround.apply_impulse(seesawPosition, impulse)
	print(collided_position)
	print(seesawPosition)
