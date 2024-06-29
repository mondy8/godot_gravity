extends Node2D

@onready var player = $Player
@onready var enemy = $Enemy_heavy
@onready var seesawGround = $Seesaw/SeesawGround
@onready var result = $ResultUI
@onready var resultButton = $ResultUI/ResultButton
@onready var resultText = $ResultUI/ResultText
@onready var timetText = $ResultUI/TimeText
@onready var levelText = $LevelUI/LevelText
@onready var audio_clear = $AudioClear1
@onready var audio_lose = $AudioLose
@onready var audio_winner = $AudioWinner
@onready var camera = $MainCamera

var is_game_set = false

# レベル変更シグナル
signal change_level(newLevel:String)
# タイマー操作シグナル
signal start_timer(control: bool)

func _ready() -> void:
	result.visible = false
	resultButton.visible = false
	resultButton.connect("pressed", _on_result_button_pressed)

	# playerからシーソーへ与えるシグナル
	player.seesaw_collided.connect(_on_seesaw_collided)
	enemy.seesaw_collided.connect(_on_seesaw_collided)
	# 脱落シグナル
	player.game_set.connect(_on_game_set)
	enemy.game_set.connect(_on_game_set)
	# カメラシェイクシグナル
	player.camera_shake.connect(_on_camera_shake)
	
	levelText.text = "Level " + str(Global.current_level)
	levelText.visible = true
	var timer = self.get_tree().create_timer(1)
	await timer.timeout
	levelText.visible = false
	start_timer.emit(true)
	
# シーソーへの衝突処理
func _on_seesaw_collided(collided_position:Vector2, impulse:Vector2):
	print("object got notify from Subject !!")
	var seesawPosition = seesawGround.to_local(collided_position)
	seesawGround.apply_impulse(seesawPosition, impulse)

# ゲーム終了
func _on_game_set(loser:String):
	if !is_game_set:
		result.visible = true	
		start_timer.emit(false)
		if loser == 'player':
			audio_lose.play()
			is_game_set = true
			resultText.text = 'You Lose'
			resultButton.visible = true
			print('lose')
			return
		else:
			if Global.current_level == 10:
				audio_winner.play()
				is_game_set = true
				resultText.text = 'You Are the Champion!\nThank you for playing'
				timetText.text = "Clear time: " + str(Global.time)
				
			else:
				audio_clear.play()
				is_game_set = true
				resultText.text = 'You Win'
				var timer = self.get_tree().create_timer(2)
				await timer.timeout
				print('win')
				change_level.emit(Global.current_level + 1)
			return

# ボタンが押されたときにレベルを変更
func _on_result_button_pressed():
	# レベルはリセットする
	Global.time = 0
	change_level.emit(1)

# カメラシェイク
func _on_camera_shake(duration: float, magnitude: float) -> void:
	var tween = get_tree().create_tween()

	# duration秒かけてカメラを揺らす
	for i in range(int(duration * 10)):  # 10は更新頻度（1秒間に10回更新）
		var offset = Vector2(randf_range(-magnitude, magnitude), randf_range(-magnitude, magnitude))
		tween.tween_property(camera, "offset", Vector2(288, 162) + offset, 0.1)

	# 元の位置に戻す
	tween.tween_property(camera, "offset", Vector2(288, 162), 0.1)
