extends CanvasLayer

@onready var position_arrow = $PositionArrow

var parent


func _ready() -> void:
	position_arrow.visible = false
	parent = get_parent()


func _process(delta: float) -> void:
	# プレイヤーが画面外に見切れた時の矢印
	if parent.global_position.y < -20:
		position_arrow.visible = true
		position_arrow.position.x = clamp(parent.global_position.x, 0, Global.SCREEN_WIDTH)
		position_arrow.position.y = 10
	elif parent.global_position.x < -20 and parent.global_position.y < Global.SCREEN_HEIGHT:
		position_arrow.visible = true
		position_arrow.position.x = 10
		position_arrow.position.y = parent.global_position.y
		position_arrow.rotation = -PI / 2
	elif (
		parent.global_position.x > Global.SCREEN_WIDTH + 20
		and parent.global_position.y < Global.SCREEN_HEIGHT
	):
		position_arrow.visible = true
		position_arrow.position.x = Global.SCREEN_WIDTH - 10.0
		position_arrow.position.y = parent.global_position.y
		position_arrow.rotation = PI / 2
	else:
		position_arrow.visible = false
