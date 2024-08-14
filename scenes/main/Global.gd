extends Node

var current_level := 1
var time := 0.0
var death_number := 0
var death_number_array = [0,0,0,0,0,0,0,0,0,0]
var best_time = null
var best_revenge = null

var enemy_bump_speed := 10
var player_get_damaged := false
var player_hp := 2
var enemy_hp := 2
var player_fall := false
var enemy_fall := false

const SCREEN_WIDTH: float = 576.0  # 画面の幅
const SCREEN_HEIGHT: float = 400.0  # 画面の高さ

func init_level():
	player_hp = 2
	enemy_hp = 2
	player_fall = false
	enemy_fall = false

func init_game():
	player_hp = 2
	enemy_hp = 2
	player_fall = false
	enemy_fall = false
	current_level = 1
	time = 0
	death_number = 0
	death_number_array = [0,0,0,0,0,0,0,0,0,0]
