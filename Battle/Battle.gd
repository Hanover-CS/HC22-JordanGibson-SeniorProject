extends Node2D

onready var player_spawn : Vector2 = $PlayerSpawnPoint.position

onready var enemy_spawn : Vector2 = $EnemySpawnPoint.position

onready var active_char : Object
onready var char_parent : Node2D

func _process(delta):
	if (Input.is_action_just_pressed("ui_accept")):
		play_turn()

func create_turn_order(player, enemy):
	spawn_chars(player, enemy)
	char_parent = $Characters
	var chars = char_parent.get_children()
	chars.sort_custom(self, 'sort_chars')
	for character in chars:
		character.raise()
	active_char = char_parent.get_child(0)

func spawn_chars(player, enemy):
	player.set_process(false)
	$Characters.add_child(player)
	player.set_global_position(player_spawn)
	player.movement_speed = 0
	$Characters.add_child(enemy)
	enemy.set_global_position(enemy_spawn)
	connect_signals(player, enemy)

func connect_signals(player, enemy):
	enemy.connect('enemy_attack', player, '_on_enemy_attack')
	player.connect('player_attack', enemy, '_on_player_attack')

func sort_chars(char1, char2) -> bool:
	return char1.speed > char2.speed

func play_turn():
	active_char.play_turn()
	var next_index : int = (active_char.get_index() + 1) % (char_parent.get_child_count())
	active_char = char_parent.get_child(next_index)
