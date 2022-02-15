extends Node2D

onready var enemy_class = preload("res://Enemies/Enemy.gd")

onready var player_spawn : Vector2
onready var enemy_spawn : Vector2

onready var active_char : Object
onready var char_parent : Node2D

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
	set_process(true)
	yield(get_tree().create_timer(.5), "timeout")
	play_turn()

func create_turn_order(player, enemy):
	char_parent = $Characters
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
	player.get_node("Sprite").get_node("AnimationPlayer").play("Idle")
	face_right(player)
	player.scale = Vector2(.75,.75)

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

func spawn_enemy(enemy: Area2D):
	char_parent.add_child(enemy)
	enemy.get_node("Heart").visible = true
	enemy.update_heart()
	face_left(enemy)
	enemy.set_global_position(enemy_spawn)
	enemy.scale = Vector2(3,3)

func connect_signals(player : KinematicBody2D, enemy : Area2D):
	enemy.connect('enemy_attack', player, '_on_enemy_attack')
	enemy.connect('enemy_death', self , '_on_player_win')
	enemy.connect('turn_completed', self, '_on_turn_completed')
	player.connect('player_attack', enemy, '_on_player_attack')
	player.connect('player_death', self, '_on_player_loss')
	player.connect('turn_completed', self, '_on_turn_completed')
	for button in group.get_buttons():
		button.connect("pressed", self, "button_pressed")

func _on_player_win():
	set_process( false)
	get_parent().change_map_visibility(true)
	var temp_player = $Characters/Player
	get_node("Characters").remove_child(temp_player)
	reward_player(temp_player)
	respawn_player(temp_player)
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
	var world_map = get_parent()
	world_map.add_child(Player)
	Player.position = world_map.curr_pos
	Player.set_physics_process(true)
	Player.scale = Vector2(.4,.4)

func _on_player_loss():
	set_process(false)
	get_node("Control").visible = false
	write_move("Player fainted! Return to World Select.", true)
	var player = get_node("Characters").get_node("Player")
	get_node("Characters").remove_child(player)
	yield(get_tree().create_timer(2.0), "timeout")
	pass_to_select(player)

func pass_to_select(Player):
	Player.revive_player()
	Player.visible = false
	get_tree().root.get_node("WorldSelect").add_child(Player)
	get_tree().root.get_node("WorldSelect").visible = true
	get_parent().queue_free()

func sort_children(chars : Array):
	chars.sort_custom(self, 'sort_chars')
	for character in chars:
		character.raise()

func sort_chars(char1, char2) -> bool:
	return char1.speed > char2.speed

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
	if get_enemy().get_health() <= 0:
		pass
	else:
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
			else:
				write_move("No ATT Potions!", false)
				yield(get_tree().create_timer(1.0), "timeout")
				buttons.visible = true


