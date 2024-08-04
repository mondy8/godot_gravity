extends Node2D

@onready var enemy01 = preload("res://scenes/main/Enemy_01_ball.tscn")
@onready var enemy02 = preload("res://scenes/main/Enemy_02_wall.tscn")
@onready var enemy03 = preload("res://scenes/main/Enemy_03_stinger.tscn")
@onready var enemy04 = preload("res://scenes/main/Enemy_04_biker.tscn")
@onready var enemy05 = preload("res://scenes/main/Enemy_05_electric.tscn")
@onready var enemy06 = preload("res://scenes/main/Enemy_06_electric.tscn")
@onready var enemy07 = preload("res://scenes/main/Enemy_07_bird.tscn")
@onready var enemy08 = preload("res://scenes/main/Enemy_08_rock.tscn")
@onready var enemy09 = preload("res://scenes/main/Enemy_09_biker_bro.tscn")
@onready var enemy10 = preload("res://scenes/main/Enemy_10_master.tscn")
@onready var enemy01_image = preload("res://images/01_雑魚ボール_立ち絵.png")
@onready var enemy02_image = preload("res://images/02_ぬりかべ_立ち絵.png")
@onready var enemy03_image = preload("res://images/03_ローリングハリネズミ_立ち絵.png")
@onready var enemy04_image = preload("res://images/04_バイク小僧_立ち絵.png")
@onready var enemy05_image = preload("res://images/05_電気ビリビリ_立ち絵.png")
@onready var enemy06_image = preload("res://images/06_ウ二マン_立ち絵.png")
@onready var enemy07_image = preload("res://images/07_デブ鳥_立ち絵.png")
@onready var enemy08_image = preload("res://images/08_デカ岩_立ち絵.png")
@onready var enemy09_image = preload("res://images/09_バイク親玉_立ち絵.png")
@onready var enemy10_image = preload("res://images/10_マスタージョージ_立ち絵.png")


@onready var enemySpawner = $EnemySpawner
@onready var playerSpawner = $PlayerSpawner
@onready var player = $Player
@onready var seesawGround = $Seesaw/SeesawGround
@onready var result = $ResultUI
@onready var hpUI = $HPUI/HPUIContainer
@onready var playerHP1 = $HPUI/HPUIContainer/PlayerHBoxContainer/PlayerHP1
@onready var playerHP2 = $HPUI/HPUIContainer/PlayerHBoxContainer/PlayerHP2
@onready var enemyHP1 = $HPUI/HPUIContainer/EnemyHBoxContainer2/EnemyHP1
@onready var enemyHP2 = $HPUI/HPUIContainer/EnemyHBoxContainer2/EnemyHP2
@onready var resultButton = $ResultUI/ResultButton
@onready var resultText = $ResultUI/ResultText
@onready var timetText = $ResultUI/TimeText
@onready var levelText = $LevelUI/LevelText
@onready var characterSprite = $CharacterUI/CharacterSprite
@onready var subText = $LevelUI/SubText
@onready var mainText = $LevelUI/MainText
@onready var audio_clear = $AudioClear1
@onready var audio_lose = $AudioLose
@onready var audio_winner = $AudioWinner
@onready var audio_label_ui = $AudioLabelUI
@onready var camera = $MainCamera

var is_game_set = false
var audio_bgm
var enemy_instance

var subTextsArray = [
	["ころがさないで、のらないで。", "わたしをザコと呼ばないで", "玉乗り検定１級"],
	["超えられない壁はない。", "この男に二言はなし。", "この俺を超えていけ。"],
	["パーティはおわらない！", "くるくる回転スパークル！", "今日も元気だ！"],
	["全速全身", "唯我独尊", "暴走自転車"],
	["ビリビリ！バチバチ！", "感電注意", "ショックな体験をあなたに"],
	["海鮮大好き", "おいしさ満点", "ほのかに香る潮の匂い"],
	["たわやかな3トンの巨体", "この世の全てを喰い尽くす", "バウンシングナイスボディ"],
	["ホップステップジャンピング", "トリップトゥザヘヴン", "ジャンピンジャックフラッシュ"],
	["弟がお世話になったね", "爆走ブラザーズ", "兄としての誇りを胸に" ],
	["最後の刺客", "ミステリアスな男", "世間は彼をこう呼ぶ"]
]

var characterNameArray = [
	"ミスターザコボール",
	"フミオ・十三郎",
	"とげりん★とげりん",
	"チャリツー",
	"ズタボロ・ロボ",
	"ウニマン",
	"デブドリー",
	"ハッピーガイ",
	"チャリツー兄",
	"マスター・ジョージ",
]

var characterImageArray = [
	enemy01_image,
	enemy02_image,
	enemy03_image,
	enemy04_image,
]

# レベル変更シグナル
signal change_level(newLevel:String)
# タイマー操作シグナル
signal start_timer(control: bool)

func _ready() -> void:
	# 初期化
	Global.player_hp = 2
	Global.enemy_hp = 2
	result.visible = false
	resultButton.visible = false
	resultButton.connect("pressed", _on_result_button_pressed)
	audio_bgm = get_node("../../audio/audioBGM")
	playerHP1.visible = true
	playerHP2.visible = true
	enemyHP1.visible = true
	enemyHP2.visible = true
	
	# 敵の生成
	if Global.current_level == 1:
		enemy_instance= enemy01.instantiate()
		characterSprite.texture = enemy01_image
	elif Global.current_level == 2:
		enemy_instance= enemy02.instantiate()
		characterSprite.texture = enemy02_image
	elif Global.current_level == 3:
		enemy_instance= enemy03.instantiate()
		characterSprite.texture = enemy03_image
	elif Global.current_level == 4:
		enemy_instance= enemy04.instantiate()
		characterSprite.texture = enemy04_image
	elif Global.current_level == 5:
		enemy_instance= enemy05.instantiate()
		characterSprite.texture = enemy05_image
	elif Global.current_level == 6:
		enemy_instance= enemy06.instantiate()
		characterSprite.texture = enemy06_image
	elif Global.current_level == 7:
		enemy_instance= enemy07.instantiate()
		characterSprite.texture = enemy07_image
		enemy_instance.camera_shake.connect(_on_camera_shake) # カメラシェイク
	elif Global.current_level == 8:
		enemy_instance= enemy08.instantiate()
		characterSprite.texture = enemy08_image
		enemy_instance.camera_shake.connect(_on_camera_shake) # カメラシェイク
	elif Global.current_level == 9:
		enemy_instance= enemy09.instantiate()
		characterSprite.texture = enemy09_image
	elif Global.current_level == 10:
		enemy_instance= enemy10.instantiate()
		characterSprite.texture = enemy10_image
	else:
		enemy_instance= enemy01.instantiate()
		characterSprite.texture = enemy01_image

	# playerからシーソーへ与えるシグナル
	player.seesaw_collided.connect(_on_seesaw_collided)
	enemy_instance.seesaw_collided.connect(_on_seesaw_collided)
	# 脱落シグナル
	player.game_set.connect(_on_game_set)
	enemy_instance.game_set.connect(_on_game_set)
	# カメラシェイクシグナル
	player.camera_shake.connect(_on_camera_shake)
	
	# レベルスタート演出
	showLevelUI()
	levelText.text = "Level " + str(Global.current_level)
	subText.text = subTextsArray[Global.current_level - 1][Global.death_number % 3]
	mainText.text = characterNameArray[Global.current_level - 1]
	var timer = self.get_tree().create_timer(3.5)
	await timer.timeout
	start_timer.emit(true)
	
	# 敵配置
	enemy_instance.position = enemySpawner.position
	add_child(enemy_instance)
	
# シーソーへの衝突処理
func _on_seesaw_collided(collided_position:Vector2, impulse:Vector2):
	var seesawPosition = seesawGround.to_local(collided_position)
	
	seesawGround.apply_impulse(seesawPosition, impulse)

# ゲーム終了
func _on_game_set(loser:String):
	if !is_game_set:
		# 残機あり
		if loser == 'player':
			var player_hp_buffer = Global.player_hp
			Global.player_hp -= 1
			if (player_hp_buffer - 1) != 0:
				playerHP2.visible = false
				# playerの位置をスタートへ移動
				# rigidbodyの移動 参考：https://stackoverflow.com/questions/77721286/set-a-rigid-body-position-in-godot-4?newreg=fb10af98801a484a947edbb845fe75c2
				PhysicsServer2D.body_set_state(
					player.get_rid(),
					PhysicsServer2D.BODY_STATE_TRANSFORM,
					Transform2D.IDENTITY.translated(playerSpawner.position)
				)
				player.set_freeze_enabled(false)
				Global.player_fall = false
				return
			else:
				playerHP1.visible = false
				playerHP2.visible = false
		elif loser == 'enemy':
			var enemy_hp_buffer = Global.enemy_hp
			Global.enemy_hp -= 1
			if (enemy_hp_buffer - 1) != 0:
				enemyHP2.visible = false
				# enemyの位置をスタートへ移動
				PhysicsServer2D.body_set_state(
					enemy_instance.get_rid(),
					PhysicsServer2D.BODY_STATE_TRANSFORM,
					Transform2D.IDENTITY.translated(enemySpawner.position)
				)
				enemy_instance.set_freeze_enabled(false)
				return
			else:
				enemyHP1.visible = false
				enemyHP2.visible = false
			
		# 残機なし
		result.visible = true
		start_timer.emit(false)
		if loser == 'player':
			audio_lose.play()
			is_game_set = true
			resultText.text = 'You Lose...'
			resultButton.text = 'Revenge!'
			resultButton.visible = true
			resultButton.grab_focus()
			return
		else:
			if Global.current_level == 10:
				audio_winner.play()
				is_game_set = true
				resultText.text = 'You Are the Champion!\nThank you for Playing!'
				timetText.text = "Clear time: " + str(Global.time)
				resultButton.text = 'Play Again!'
				resultButton.visible = true
				resultButton.grab_focus()
				Global.current_level += 1
				
			else:
				audio_clear.play()
				is_game_set = true
				Global.death_number = 0
				resultText.text = 'You Win!'
				var tween = get_tree().create_tween()
				tween.tween_property(audio_bgm, "volume_db", -40, 2.5)
				tween.set_ease(Tween.EASE_IN)
				var timer = self.get_tree().create_timer(3)
				await timer.timeout
				change_level.emit(Global.current_level + 1)
			return

# ボタンが押されたときにレベルを変更
func _on_result_button_pressed():
	if Global.current_level == 11:
		# 最終レベルの場合はリセットする
		Global.time = 0
		change_level.emit(1)
	else:
		# リトライ
		Global.death_number += 1
		change_level.emit(Global.current_level)

# カメラシェイク
func _on_camera_shake(duration: float, magnitude: float) -> void:
	var tween = get_tree().create_tween()

	# duration秒かけてカメラを揺らす
	for i in range(int(duration * 10)):  # 10は更新頻度（1秒間に10回更新）
		var offset = Vector2(randf_range(-magnitude, magnitude), randf_range(-magnitude, magnitude))
		tween.tween_property(camera, "offset", Vector2(288, 162) + offset, 0.1)

	# 元の位置に戻す
	tween.tween_property(camera, "offset", Vector2(288, 162), 0.1)

func showLevelUI():
	var tween1 = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	var tween3 = get_tree().create_tween()
	var tween4 = get_tree().create_tween()
	var tween5 = get_tree().create_tween()
	tween1.set_trans(Tween.TRANS_BACK)
	tween2.set_trans(Tween.TRANS_BACK)
	tween3.set_trans(Tween.TRANS_BACK)
	tween4.set_trans(Tween.TRANS_BACK)
	tween5.set_trans(Tween.TRANS_BACK)
	tween1.set_ease(Tween.EASE_IN_OUT)
	tween2.set_ease(Tween.EASE_IN_OUT)
	tween3.set_ease(Tween.EASE_IN_OUT)
	tween4.set_ease(Tween.EASE_IN_OUT)
	tween5.set_ease(Tween.EASE_IN_OUT)
	tween1.tween_property(levelText, "position:x", 0, 0.6)
	tween1.tween_property(levelText, "position:x", 0, 2)
	tween1.tween_property(levelText, "position:x", -500, 1)
	tween2.tween_property(subText, "position:x", 0, 0.8)
	tween2.tween_property(subText, "position:x", 0, 2)
	tween2.tween_property(subText, "position:x", -500, 1)
	tween3.tween_property(mainText, "position:x", 0, 0.9)
	tween3.tween_property(mainText, "position:x", 0, 2)
	tween3.tween_property(mainText, "position:x", -500, 1)
	tween4.tween_property(characterSprite, "position", Vector2(452, 241), 0.4)
	tween4.tween_property(characterSprite, "position", Vector2(452, 241), 3)
	tween4.tween_property(characterSprite, "position", Vector2(829,531), 0.4)
	tween5.tween_property(hpUI, "position:y", -44, 3)
	tween5.tween_property(hpUI, "position:y", 0, 0.4)
	
	audio_label_ui.play()
	var timer = self.get_tree().create_timer(2.8)
	await timer.timeout
	audio_label_ui.play()
	
