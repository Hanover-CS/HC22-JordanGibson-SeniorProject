extends Node2D

onready var enemy_class = preload("res://Enemies/Enemy.gd")

onready var player_spawn : Vector2
onready var enemy_spawn : Vector2

onready var active_char : Object
onready var char_parent : Node2D

func _ready():
	player_spawn = $PlayerSpawnPoint.position
	enemy_spawn = $EnemySpawnPoint.position

func _process(delta):
	if (Input.is_action_just_pressed("ui_accept")):
		play_turn()

func instance(player : Area2D, enemy : Area2D, Map : String):
	match Map:
		"Forest":
			$BattleScreen/Forest.visible = true
			$BattleScreen/Ruins.visible = false
			$BattleScreen/Dungeon.visible = false
		"Ruins":
			$BattleScreen/Forest.visible = false
			$BattleScreen/Ruins.visible = true
			$BattleScreen/Dungeon.visible = false
		"Dungeon":
			$BattleScreen/Forest.visible = false
			$BattleScreen/Ruins.visible = false
			$BattleScreen/Dungeon.visible = true
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
	player.set_physics_process(false)
	char_parent.add_child(player)
	setup_player(player)

func setup_player(player):
	player.set_global_position(player_spawn)
	player.get_node("Sprite").get_node("AnimationPlayer").play("Idle")
	face_right(player)
	player.scale = Vector2(.75,.75)
	player.movement_speed = 0

func face_right(character : Area2D):
	if character.get_node("Sprite").flip_h == true:
		character.get_node("Sprite").flip_h = false
	else:
		pass

func face_left(character : Area2D):
	if character.get_node("Sprite").flip_h == false:
		character.get_node("Sprite").flip_h = true
	else:
		pass

func spawn_enemy(enemy: Area2D):
	char_parent.add_child(enemy)
	face_left(enemy)
	enemy.set_global_position(enemy_spawn)
	enemy.scale = Vector2(3,3)

func connect_signals(player : Area2D, enemy : Area2D):
	enemy.connect('enemy_attack', player, '_on_enemy_attack')
	enemy.connect('enemy_death', self , '_on_player_win')
	player.connect('player_attack', enemy, '_on_player_attack')
	player.connect('player_death', self, '_on_player_loss')

func _on_player_win():
	get_parent().change_map_visibility(true)
	var temp_player = $Characters/Player
	get_node("Characters").remove_child(temp_player)
	respawn_player(temp_player)
	self.queue_free()

func respawn_player(player):
	var world_map = get_parent()
	world_map.add_child(player)
	player.global_position = world_map.curr_pos
	player.set_physics_process(true)
	player.scale = Vector2(.4,.4)

func _on_player_loss():
	get_tree().root.get_node("WorldSelect").visible = true
	get_parent().queue_free()

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
