extends CanvasLayer

@onready var position_arrow = $PositionArrow

var SCREEN_WIDTH: float = 576.0  # 画面の幅
var SCREEN_HEIGHT: float = 400.0  # 画面の高さ
var parent

func _ready() -> void:
	position_arrow.visible = false
	parent = get_parent()
	
func _process(delta: float) -> void:
	# プレイヤーが画面外に見切れた時の矢印
	if parent.global_position.y < -20:
		position_arrow.visible = true
		position_arrow.position.x = clamp(parent.global_position.x, 0, SCREEN_WIDTH)
		position_arrow.position.y = 10
	elif parent.global_position.x < -20 and parent.global_position.y < SCREEN_HEIGHT:
		position_arrow.visible = true
		position_arrow.position.x = 10
		position_arrow.position.y = parent.global_position.y
		position_arrow.rotation = -PI / 2
	elif parent.global_position.x > SCREEN_WIDTH + 20 and parent.global_position.y < SCREEN_HEIGHT:
		position_arrow.visible = true
		position_arrow.position.x = SCREEN_WIDTH - 10.0
		position_arrow.position.y = parent.global_position.y
		position_arrow.rotation = PI / 2
	else:
		position_arrow.visible = false
