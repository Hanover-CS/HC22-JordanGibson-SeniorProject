extends Node2D

var battle_scene = preload("res://Battle/Battle.tscn")
var enemy_scene = preload("res://Enemies/Bosses/Glutmon/Glutmon.tscn")
var player_scene = preload("res://Player/Player.tscn")

func _ready():
	add_child(player_scene.instance())
	add_child(enemy_scene.instance())

func _on_Player_battle_start(player, enemy):
	start_battle(player, enemy)

func start_battle(player, enemy):
	var temp_player = player
	var temp_enemy = enemy
	add_child(battle_scene.instance())
	remove_child(player)
	remove_child(enemy)
	$Battle.create_turn_order(temp_player, temp_enemy)
