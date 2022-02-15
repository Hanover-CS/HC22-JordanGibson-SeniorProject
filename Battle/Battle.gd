extends Node2D

onready var enemy_class = preload("res://Enemies/Enemy.gd")

onready var player_spawn : Vector2
onready var enemy_spawn : Vector2

onready var active_char : Object
onready var char_parent : Node2D = get_node("Characters")

var attack_potions_used = 0

export(ButtonGroup) var group

func _ready():
	player_spawn = $PlayerSpawnPoint.position
	enemy_spawn = $EnemySpawnPoint.position
	set_process(false)

func _process(delta):
	var attack_potion_label = get_node("Potions/Attack Potion/Label")
	var health_potion_label = get_node("Potions/Health Potion/Label")
	var player = get_node("Characters").get_node("Player")
	attack_potion_label.text = ": " + str(player.get_potion_count("Attack Potion"))
	health_potion_label.text = ": " + str(player.get_potion_count("Health Potion"))

func initialize(player : KinematicBody2D, enemy : Area2D, Map : String):
	show_map(Map)
	create_turn_order(player, enemy)
	set_process(true)
	yield(get_tree().create_timer(.5), "timeout")
	play_turn()

func show_map(Map : String):
	match Map:
		"Forest":
			$BattleScreen/Forest.visible = true
		"Ruins":
			$BattleScreen/Ruins.visible = true
		"Dungeon":
			$BattleScreen/Dungeon.visible = true

func create_turn_order(player, enemy):
	spawn_chars(player, enemy)
	var chars = char_parent.get_children()
	sort_children(chars)
	active_char = char_parent.get_child(0)

func spawn_chars(player : KinematicBody2D, enemy : Area2D):
	spawn_player(player)
	spawn_enemy(enemy)
	connect_signals(player, enemy)

func spawn_player(player : KinematicBody2D):
	char_parent.add_child(player)
	setup_player(player)

func setup_player(player):
	player.set_physics_process(false)
	player.set_global_position(player_spawn)
	face_right(player)
	player.scale = Vector2(.75,.75)
	player.get_node("Sprite").get_node("AnimationPlayer").play("Idle")

func spawn_enemy(enemy: Area2D):
	char_parent.add_child(enemy)
	setup_enemy(enemy)

func setup_enemy(enemy : Area2D):
	enemy.get_node("Heart").visible = true
	enemy.update_heart()
	face_left(enemy)
	enemy.set_global_position(enemy_spawn)
	enemy.scale = Vector2(3,3)

func sort_children(chars : Array):
	chars.sort_custom(self, 'sort_chars')
	for character in chars:
		character.raise()

func sort_chars(char1, char2) -> bool:
	return char1.speed > char2.speed

func connect_signals(player : KinematicBody2D, enemy : Area2D):
	connect_enemy_signals(player, enemy)
	connect_player_signals(player, enemy)
	setup_buttons()

func connect_enemy_signals(player : KinematicBody2D, enemy : Area2D):
	enemy.connect('enemy_attack', player, '_on_enemy_attack')
	enemy.connect('enemy_death', self , '_on_player_win')
	enemy.connect('turn_completed', self, '_on_turn_completed')

func connect_player_signals(player : KinematicBody2D, enemy : Area2D):
	player.connect('player_attack', enemy, '_on_player_attack')
	player.connect('player_death', self, '_on_player_loss')
	player.connect('turn_completed', self, '_on_turn_completed')

func setup_buttons():
	for button in group.get_buttons():
		button.connect("pressed", self, "button_pressed")

func face_right(character):
	if character.get_node("Sprite").flip_h == true:
		character.get_node("Sprite").flip_h = false
	else:
		pass

func face_left(character):
	if character.get_node("Sprite").flip_h == false:
		character.get_node("Sprite").flip_h = true
	else:
		pass

func _on_player_win():
	set_process(false)
	get_parent().change_map_visibility(true)
	var player = char_parent.get_node("Player")
	char_parent.remove_child(player)
	reward_player(player)
	respawn_player(player)
	get_parent().check_enemy_count()
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
	face_left(Player)
	Player.deduct_attack(attack_potions_used)
	var world_map = get_parent()
	world_map.add_child(Player)
	ready_for_world(Player, world_map)
	

func ready_for_world(Player : KinematicBody2D, Map : Node2D):
	Player.position = Map.curr_pos
	Player.set_physics_process(true)
	Player.scale = Vector2(.4,.4)

func _on_player_loss():
	set_process(false)
	player_faint()

func player_faint():
	var player = get_node("Characters").get_node("Player")
	write_move("Player fainted! Return to World Select.", true)
	get_node("Control").visible = false
	player.deduct_attack(attack_potions_used)
	yield(get_tree().create_timer(3.0), "timeout")
	pass_to_select_screen(player)

func pass_to_select_screen(Player):
	char_parent.remove_child(Player)
	Player.revive_player()
	Player.visible = false
	get_tree().root.get_node("WorldSelect").add_child(Player)
	get_tree().root.get_node("WorldSelect").visible = true
	get_parent().queue_free()

func _on_turn_completed():
	if active_char.name == "Player":
		get_node("Control").visible = false
	if get_node("Characters").get_child_count() == 1:
		pass
	else:
		var next_index : int = (active_char.get_index() + 1) % (char_parent.get_child_count())
		active_char = char_parent.get_child(next_index)
		play_turn()

func play_turn():
	var battleControls = get_node("Control")
	if active_char.name == "Player":
		if active_char.get_health() > 0:
			battleControls.visible = true
		else:
			pass
	else:
		active_char.play_turn()
		write_move(format_name(active_char.name) + " attacked!", false)

func format_name(Name : String):
	var nums = ['1','2','3','4','5','6','7','8','9','10', '@']
	var nameAcc : String = ""
	for ch in Name:
		if nums.count(ch) == 1:
			pass
		else:
			nameAcc += ch
	return(nameAcc)

func write_move(MoveString, KeepDisplayed):
	var textbox = get_node("TextBox")
	var battleControls = get_node("Control")
	battleControls.visible = false
	textbox.visible = true
	textbox.text = MoveString
	yield(get_tree().create_timer(active_char.get_wait_time()), "timeout")
	textbox.visible = KeepDisplayed

func button_pressed():
	var active_button = group.get_pressed_button()
	var player = get_node("Characters").get_node("Player")
	var buttons = get_node("Control")
	match active_button.name:
		"Attack":
			player.attack()
			write_move("You attacked!", false)
		"Health Potion":
			var potion_used = player.use_potion("Health Potion")
			if potion_used:
				write_move("HP UP! HP: " + str(player.get_health()), false)
			elif (player.check_if_health_max()):
				write_move("At Max Health!", false)
				yield(get_tree().create_timer(1.0), "timeout")
				buttons.visible = true
			else:
				write_move("No HP Potions!", false)
				yield(get_tree().create_timer(1.0), "timeout")
				buttons.visible = true
		"Attack Potion":
			var potion_used = player.use_potion("Attack Potion")
			if potion_used:
				write_move("ATT UP! ATT: " + str(player.get_attack()), false)
				attack_potions_used += 1
			else:
				write_move("No ATT Potions!", false)
				yield(get_tree().create_timer(1.0), "timeout")
				buttons.visible = true


