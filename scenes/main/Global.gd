extends Node

var current_level := 10

var time := 0.0

var best_time = null

var enemy_bump_speed := 10
var player_get_damaged := false

var player_hp := 2
var enemy_hp := 2

var death_number := 0

var player_fall := false
var enemy_fall := false

const SCREEN_WIDTH: float = 576.0  # 画面の幅
const SCREEN_HEIGHT: float = 400.0  # 画面の高さ
