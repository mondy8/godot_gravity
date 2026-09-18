extends Player

class_name Player_practice

# 練習モードでは脱落させずにその場へ復帰させる
signal player_respawn


func handle_fall() -> bool:
	if position.y > 400:
		position.y = 399
		set_freeze_enabled(true)
		player_respawn.emit()
		return true
	return false


# 練習モードでは敵との接触ダメージを発生させない
func check_enemy_bump():
	pass
