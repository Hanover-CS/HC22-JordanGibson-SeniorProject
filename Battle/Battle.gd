extends Node2D

onready var player_spawn : Vector2 = $PlayerSpawnPoint.position
onready var enemy_spawn : Vector2 = $EnemySpawnPoint.position

onready var active_char : Object
onready var char_parent : Node2D

func _process(delta):
	if (Input.is_action_just_pressed("ui_accept")):
		play_turn()

func instance(player, enemy):
	create_turn_order(player, enemy)
	yield(get_tree().create_timer(1.0), "timeout")
	play_turn()

func create_turn_order(player, enemy):
	char_parent = $Characters
	spawn_chars(player, enemy)
	var chars = char_parent.get_children()
	sort_children(chars)
	active_char = char_parent.get_child(0)

func spawn_chars(player : Area2D, enemy : Area2D):
	spawn_player(player)
	spawn_enemy(enemy)
	connect_signals(player, enemy)

func spawn_player(player : Area2D):
	player.set_process(false)
	char_parent.add_child(player)
	player.set_global_position(player_spawn)
	player.get_node("Sprite").get_node("AnimationPlayer").play("Idle")
	player.movement_speed = 0

func spawn_enemy(enemy : Area2D):
	char_parent.add_child(enemy)
	enemy.set_global_position(enemy_spawn)

func connect_signals(player, enemy):
	enemy.connect('enemy_attack', player, '_on_enemy_attack')
	player.connect('player_attack', enemy, '_on_player_attack')

func sort_children(chars : Array):
	chars.sort_custom(self, 'sort_chars')
	for character in chars:
		character.raise()

func sort_chars(char1, char2) -> bool:
	return char1.speed > char2.speed

func play_turn():
	active_char.play_turn()
	var next_index : int = (active_char.get_index() + 1) % (char_parent.get_child_count())
	active_char = char_parent.get_child(next_index)
