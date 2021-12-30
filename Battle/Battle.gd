extends Node2D

onready var player_spawn : Vector2

onready var enemy_spawn : Vector2

var active_char

func _ready():
	player_spawn = $PlayerSpawnPoint.position
	enemy_spawn = $EnemySpawnPoint.position

func spawn_chars(player, enemy):
	$Characters.add_child(player)
	$Characters.get_node(player.name).set_global_position(player_spawn)
	$Characters.get_node(player.name).movement_speed = 0
	$Characters.add_child(enemy)
	$Characters.get_node(enemy.name).global_position = enemy_spawn

func create_turn_order(player, enemy):
	spawn_chars(player, enemy)
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
