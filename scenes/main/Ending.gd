extends Node2D

const MENU_SCENE = preload("res://scenes/main_menu_scene.tscn")

@onready var label = $Label
@onready var characters = $characters
@onready var buttons = $Buttons
@onready var shareButton = %ShareButton
@onready var menuButton = %MenuButton
@onready var fade_overlay = %FadeOverlay
@onready var pause_overlay = %PauseOverlay

@export var fade_time = 1.0
@export var display_time = 2.0
@export var move_time = 30.0

var current_text_index = 0
var is_last_message = false

var endingText = []
const TWITTER_SHARE_URL = "https://twitter.com/intent/tweet?text="

var revenge := 0
var time := 0
var rival := ""

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

func _ready():
	buttons.visible = false
	fade_overlay.visible = true
	label.modulate = Color(1, 1, 1, 0)
	shareButton.pressed.connect(_on_share_button_pressed)
	menuButton.pressed.connect(_on_menu_button_pressed)
	
	revenge = sum(Global.death_number_array)
	time = floor(Global.time)
	
	var max_value = Global.death_number_array.max()
	var max_index = Global.death_number_array.find(max_value)
	rival = characterNameArray[max_index]
	
	endingText = [
		"SO シーソー！\nリザルト",
		"クリアタイム：" + str(time) + "秒",
		"リベンジ回数：" + str(revenge) + "回",
		"あなたのライバル：" + rival,
		"クレジット",
		"ゲームデザイン：MONDY\nイラスト：エス",
		"BGM：イワシロ音楽素材",
		"Thank you for Playing!\n"
	]
	
	display_next_text()
	move_characters()
	fade_overlay.fade_in()

func display_next_text():
	# 全てのテキストが表示されたら終了
	if current_text_index == endingText.size() - 1:
		is_last_message = true
	
	label.text = endingText[current_text_index]
	current_text_index += 1
	
	var fade_in = get_tree().create_tween()
	fade_in.set_ease(Tween.EASE_IN_OUT)
	
	label.modulate = Color(1, 1, 1, 0)
	
	# フェードイン
	fade_in.tween_property(label, "modulate:a", 1.0, fade_time)
	await fade_in.finished
	
	if !is_last_message:
		_on_fade_in_finished()
	else:
		buttons.visible = true
		var scrollIn = get_tree().create_tween()
		scrollIn.set_trans(Tween.TRANS_SPRING)
		scrollIn.tween_property(buttons, "offset:y", 0.0, fade_time)
		shareButton.grab_focus()

# 表示中
func _on_fade_in_finished():
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = display_time
	add_child(timer)
	timer.start()
	await timer.timeout
	_on_display_timeout()

# フェードアウト
func _on_display_timeout():
	var fade_out = get_tree().create_tween()
	fade_out.set_ease(Tween.EASE_IN_OUT)
	fade_out.tween_property(label, "modulate:a", 0.0, fade_time)
	await fade_out.finished
	display_next_text()

# キャラクターたちの移動
func move_characters():
	var move01 = get_tree().create_tween()
	move01.tween_property(characters, "position:x", -2000.0, move_time)
	
# シェアボタン
func _on_share_button_pressed() -> void:
	var url = TWITTER_SHARE_URL + ("あなたはシーソーチャンピオンになった！").uri_encode() + "%0A" + ("クリアタイム：").uri_encode() + str(time) + ("秒").uri_encode() + "%0A" + ("リベンジ回数：").uri_encode() + str(revenge) + ("回").uri_encode() + "%0A" + ("あなたのライバル：").uri_encode() + (rival).uri_encode() + "%0A" + ("https://godotplayer.com/games/seesaw").uri_encode() + "&hashtags=" + ("SOシーソー").uri_encode()
	OS.shell_open(url)
	
# メニューボタン
func _on_menu_button_pressed() -> void:
		fade_overlay.fade_out()
		fade_overlay.on_complete_fade_out.connect(_on_fade_overlay_on_complete_fade_out)
		
func _on_fade_overlay_on_complete_fade_out() -> void:
	get_tree().change_scene_to_packed(MENU_SCENE)

# 配列の合計
func sum(arr:Array):
	var result = 0
	for i in arr:
		result+=i
	return result
