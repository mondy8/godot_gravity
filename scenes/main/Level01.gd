extends Node2D

class_name ingame
static var game_set = false

@onready var player = $Player
@onready var enemy = $Enemy
@onready var seesawGround = $Seesaw/SeesawGround
@onready var result = $ResultUI
@onready var resultButton = $ResultUI/ResultButton
@onready var resultText = $ResultUI/ResultText

# レベル変更シグナル
signal change_level(newLevel:String)

func _ready() -> void:
	result.visible = false
	resultButton.visible = false
	resultButton.connect("pressed", _on_result_button_pressed)

	# playerからシーソーへ与えるシグナル
	player.seesaw_collided.connect(_on_seesaw_collided)
	enemy.seesaw_collided.connect(_on_seesaw_collided)
	player.game_set.connect(_on_game_set)
	enemy.game_set.connect(_on_game_set)
	
# シーソーへの衝突処理
func _on_seesaw_collided(collided_position:Vector2, impulse:Vector2):
	print("object got notify from Subject !!")
	var seesawPosition = seesawGround.to_local(collided_position)
	seesawGround.apply_impulse(seesawPosition, impulse)

func _on_game_set(loser:String):
	if !game_set:
		result.visible = true
		if loser == 'player':
			resultText.text = 'You Lose'
			resultButton.visible = true
			var timer = self.get_tree().create_timer(1)
			await timer.timeout
			print('lose')
		else:
			resultText.text = 'You Win'
			var timer = self.get_tree().create_timer(1)
			await timer.timeout
			print('win')
			change_level.emit("level01")

func _on_result_button_pressed():
	# ボタンが押されたときにレベルを変更
	change_level.emit("level01")
