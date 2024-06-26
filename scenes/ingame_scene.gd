extends Node2D

class_name ingame
static var game_set = false

@onready var fade_overlay = %FadeOverlay
@onready var pause_overlay = %PauseOverlay
@onready var player = $Player
@onready var enemy = $Enemy
@onready var seesawGround = $Seesaw/SeesawGround
@onready var resultText = $ResultText

func _ready() -> void:
	fade_overlay.visible = true
	
	if SaveGame.has_save():
		SaveGame.load_game(get_tree())
	
	pause_overlay.game_exited.connect(_save_game)
	
	# playerからシーソーへ与えるシグナル
	player.seesaw_collided.connect(_on_seesaw_collided)
	enemy.seesaw_collided.connect(_on_seesaw_collided)
	player.game_set.connect(_on_game_set)
	enemy.game_set.connect(_on_game_set)
	#call_deferred("_pause_game")

#func _pause_game():
	#get_tree().paused = true
	#var timer = self.get_tree().create_timer(3)
	#await timer.timeout
	#get_tree().paused = false

func _input(event) -> void:
	if event.is_action_pressed("pause") and not pause_overlay.visible:
		get_viewport().set_input_as_handled()
		get_tree().paused = true
		pause_overlay.grab_button_focus()
		pause_overlay.visible = true
		
func _save_game() -> void:
	SaveGame.save_game(get_tree())

# シーソーへの衝突処理
func _on_seesaw_collided(collided_position:Vector2, impulse:Vector2):
	print("object got notify from Subject !!")
	var seesawPosition = seesawGround.to_local(collided_position)
	seesawGround.apply_impulse(seesawPosition, impulse)

func _on_game_set(loser:String):
	if !game_set:
		if loser == 'player':
			resultText.text = 'You Lose'
		else:
			resultText.text = 'You Win'
			
