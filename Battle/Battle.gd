extends Node2D

onready var player_scene = preload("res://Player/Player.tscn")
onready var player_spawn = $PlayerSpawnPoint.position

onready var enemy_scene = preload("res://Enemies/Bosses/Glutmon/Glutmon.tscn")
onready var enemy_spawn = $EnemySpawnPoint.position

func _ready():
	var player = player_scene.instance()
	var enemy = enemy_scene.instance()
	add_child(player)
	add_child(enemy)
	enemy.position = enemy_spawn
	player.position = player_spawn
