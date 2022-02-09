extends Node2D

onready var enemy_class = preload("res://Enemies/Enemy.gd")

onready var player_spawn : Vector2
onready var enemy_spawn : Vector2

onready var active_char : Object
onready var char_parent : Node2D

func _ready():
	player_spawn = $PlayerSpawnPoint.position
	enemy_spawn = $EnemySpawnPoint.position

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
	print(player.Inventory)
	player.set_process(false)
	char_parent.add_child(player)
	setup_player(player)

func setup_player(player):
	player.set_global_position(player_spawn)
	player.get_node("Sprite").get_node("AnimationPlayer").play("Idle")
	face_right(player)
	player.scale = Vector2(.75,.75)

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
	enemy.connect('turn_completed', self, '_on_turn_completed')
	player.connect('player_attack', enemy, '_on_player_attack')
	player.connect('player_death', self, '_on_player_loss')
	player.connect('turn_completed', self, '_on_turn_completed')

func _on_player_win():
	get_parent().change_map_visibility(true)
	var temp_player = $Characters/Player
	get_node("Characters").remove_child(temp_player)
	face_left(temp_player)
	reward_player(temp_player)
	respawn_player(temp_player)
	self.queue_free()

func reward_player(Player):
	var Gold = get_gold_amount()
	Player.give_gold(Gold)
	var XP = get_xp_amount()
	Player.give_XP(XP)

func get_gold_amount():
	return randi()%3+1

func get_xp_amount():
	var enemy_ref = get_enemy()
	var xp_amount = floor(enemy_ref.get_level()/2)
	if (xp_amount < 1):
		xp_amount = 1
	return(xp_amount)

func get_enemy():
	for child in get_node("Characters").get_children():
		if child.is_in_group("enemy"):
			return child

func respawn_player(Player):
	var world_map = get_parent()
	world_map.add_child(Player)
	Player.conn_flag = false
	Player.position = world_map.curr_pos
	Player.set_process(true)
	Player.scale = Vector2(.4,.4)

func _on_player_loss():
	var player = get_node("Characters").get_node("Player")
	get_node("Characters").remove_child(player)
	player.revive_player()
	player.visible = false
	get_tree().root.get_node("WorldSelect").add_child(player)
	get_tree().root.get_node("WorldSelect").visible = true
	get_parent().queue_free()

func sort_children(chars : Array):
	chars.sort_custom(self, 'sort_chars')
	for character in chars:
		character.raise()

func sort_chars(char1, char2) -> bool:
	return char1.speed > char2.speed

func _on_turn_completed():
	var next_index : int = (active_char.get_index() + 1) % (char_parent.get_child_count())
	active_char = char_parent.get_child(next_index)
	yield(get_tree().create_timer(active_char.get_wait_time()), "timeout")
	active_char.play_turn()

func play_turn():
	active_char.play_turn()
