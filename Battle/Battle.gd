extends Node2D

onready var player_scene = preload("res://Player/Player.tscn")
onready var player_spawn = $PlayerSpawnPoint.position
#
onready var enemy_scene = preload("res://Enemies/Small/Imp/Imp.tscn")
onready var enemy_spawn = $EnemySpawnPoint.position

var active_char

func _ready():
	add_child(player_scene.instance())
	add_child(enemy_scene.instance())

func create_turn_order():
	var char_parent = get_node("Characters")
	var chars = char_parent.get_children()
	chars.sort_custom(self, 'sort_chars')
	for character in chars:
		character.raise()
	active_char = char_parent.get_child(0)

func sort_chars(char1, char2) -> bool:
	return char1.speed > char2.speed

func play_turn(target):
	var char_parent = get_node("Characters")
	yield(active_char.play_turn(), 'completed')
	var next_index = (active_char.get_index() + 1) % char_parent.get_child_count()
	active_char = char_parent.get_child(next_index)
