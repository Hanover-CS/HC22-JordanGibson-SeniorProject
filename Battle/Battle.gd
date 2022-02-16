# File : Battle.gd
# Created By : Jordan Gibson
# Last Updated : 2/15/2022
# Functionality : Allows for enemy and player to battle one another, handling wins and losses
#	On Player Win: Return to world if any enemies left, otherwise return to select screen
#	On Player Loss: Return to select screen and reset player HP

extends Node2D

onready var player_spawn : Vector2
onready var enemy_spawn : Vector2

onready var active_char : Object
onready var char_parent : Node2D = get_node("Characters")
# Used to deduct temporary attack from player at end of battle
var attack_potions_used = 0

export(ButtonGroup) var group

func _ready():
	player_spawn = $PlayerSpawnPoint.position
	enemy_spawn = $EnemySpawnPoint.position
	# Turns off label updating until characters are spawned
	set_process(false)

# Used to update labels as battle continues
func _process(delta):
	var attack_potion_label = get_node("Potions/Attack Potion/Label")
	var health_potion_label = get_node("Potions/Health Potion/Label")
	# Used for inventory reference
	var player = get_node("Characters").get_node("Player")
	attack_potion_label.text = ": " + str(player.get_potion_count("Attack Potion"))
	health_potion_label.text = ": " + str(player.get_potion_count("Health Potion"))

###############################################################
					## SETUP METHODS ##
##############################################################

# Displays appropriate BattleScreen and spawns player and enemy
func initialize(Player : KinematicBody2D, Enemy : Area2D, Map : String):
	show_battle_screen(Map)
	create_turn_order(Player, Enemy)
	# Turns on label updating after enemy and player spawned
	set_process(true)
	yield(get_tree().create_timer(.5), "timeout")
	play_turn()

# Displays correct battle screen
# Parameters : Map - String denoting battle screen to be shown
func show_battle_screen(Map : String):
	match Map:
		"Forest":
			$BattleScreen/Forest.visible = true
		"Ruins":
			$BattleScreen/Ruins.visible = true
		"Dungeon":
			$BattleScreen/Dungeon.visible = true

# Spawns enemy and player, then creates turn order based on speed
# Parameters : Player - Reference to player node, Enemy - Reference to enemy node
func create_turn_order(Player : KinematicBody2D, Enemy : Area2D):
	spawn_chars(Player, Enemy)
	var chars = char_parent.get_children()
	sort_children(chars)
	# Fastest character is first child after sort
	active_char = char_parent.get_child(0)

func spawn_chars(player : KinematicBody2D, enemy : Area2D):
	spawn_player(player)
	spawn_enemy(enemy)
	# Connects player attack signal to enemy _on_player_attack method and vice versa
	connect_signals(player, enemy)

func spawn_player(Player : KinematicBody2D):
	char_parent.add_child(Player)
	setup_player(Player)

func setup_player(Player : KinematicBody2D):
	# Disables movement process
	Player.set_physics_process(false)
	# Player positioning setup
	Player.set_global_position(player_spawn)
	face_right(Player)
	Player.scale = Vector2(.75,.75)
	Player.get_node("Sprite").get_node("AnimationPlayer").play("Idle")

func spawn_enemy(Enemy: Area2D):
	char_parent.add_child(Enemy)
	setup_enemy(Enemy)

func setup_enemy(enemy : Area2D):
	enemy.get_node("Heart").visible = true
	# Displays enemy HP label
	enemy.update_heart()
	# Enemy positioning setup
	face_left(enemy)
	enemy.set_global_position(enemy_spawn)
	enemy.scale = Vector2(3,3)

# Returns reference to enemy in 'Characters' node
func get_enemy():
	for child in get_node("Characters").get_children():
		if child.is_in_group("enemy"):
			return child

# Sorts character array in descending order according to speed
# Parameters : chars - Array to be sorted
func sort_children(chars : Array):
	chars.sort_custom(self, 'sort_chars')
	for character in chars:
		character.raise()

func sort_chars(char1, char2) -> bool:
	return char1.speed > char2.speed

# Connects necessary signals between player and enemy to allow for battle interaction
# Parameters : Player - Reference to player node, Enemy - Reference to enemy node
func connect_signals(Player : KinematicBody2D, Enemy : Area2D):
	connect_enemy_signals(Player, Enemy)
	connect_player_signals(Player, Enemy)
	setup_buttons()

# Connects player signals to enemy methods
# Parameters : Player - Reference to player node, Enemy - Reference to enemy node
func connect_enemy_signals(Player : KinematicBody2D, Enemy : Area2D):
	Enemy.connect('enemy_attack', Player, '_on_enemy_attack')
	Enemy.connect('enemy_death', self , '_on_player_win')
	# Connects to battle to alternate turns
	Enemy.connect('turn_completed', self, '_on_turn_completed')

# Connects enemy signals to player methods
# Parameters : Player - Reference to player node, Enemy - Reference to enemy node
func connect_player_signals(Player : KinematicBody2D, Enemy : Area2D):
	Player.connect('player_attack', Enemy, '_on_player_attack')
	Player.connect('player_death', self, '_on_player_loss')
	# Connects to battle to alternate turns
	Player.connect('turn_completed', self, '_on_turn_completed')

# Sets up player battle button connections
func setup_buttons():
	for button in group.get_buttons():
		button.connect("pressed", self, "button_pressed")

# Sprite flipping functionality, used to change direction of enemy or player
func face_right(character):
	if character.get_sprite().flip_h == true:
		character.get_sprite().flip_h = false
	else:
		pass

func face_left(character):
	if character.get_sprite().flip_h == false:
		character.get_sprite().flip_h = true
	else:
		pass


##################################################################
						# BATTLE METHODS #
##################################################################

#### BATTLE WIN METHODS ####

# Method triggered upon emission of 'enemy_death' signal from enemy
func _on_player_win():
	# Turns off label updating for battle
	set_process(false)
	# Makes map visible again
	get_parent().change_map_visibility(true)
	# Establishes reference to player and then deletes it from battle
	var player = char_parent.get_node("Player")
	char_parent.remove_child(player)
	# Gives XP and Gold to player
	reward_player(player)
	# Passes player back to world and configures it as needed
	respawn_player(player)
	# Checks to see if all enemies are defeated, returns to WorldSelect screen if so
	get_parent().check_enemy_count()
	self.queue_free()

# Gives player gold and XP after defeating enemy
func reward_player(Player : KinematicBody2D):
	var Gold = get_gold_amount()
	Player.give_gold(Gold)
	var XP = get_xp_amount()
	Player.give_XP(XP)

# Returns a random gold amount between 1-3
func get_gold_amount():
	return randi()%3+1

# Returns XP amount to be awarded
func get_xp_amount():
	var enemy_ref = get_enemy()
	# XP amount dependent on enemy level
	var xp_amount = floor(enemy_ref.get_level()/2)
	# Ensures level one enemies award XP
	if (xp_amount < 1):
		xp_amount = 1
	return(xp_amount)

# Respawns player in world, sets them back to position they were in before battle
#  and configures as necessary
# Parameters : Player - Reference to player node
func respawn_player(Player : KinematicBody2D):
	face_left(Player)
	# Takes away temporary attack from ATT potions
	Player.deduct_attack(attack_potions_used)
	var world_map = get_parent()
	world_map.add_child(Player)
	# Turns on label updating in world
	world_map.set_process(true)
	ready_for_world(Player, world_map)
	
# Configures player for world
func ready_for_world(Player : KinematicBody2D, Map : Node2D):
	# Spawns at previous position
	Player.position = Map.curr_pos
	# Enables movement
	Player.set_physics_process(true)
	Player.scale = Vector2(.4,.4)

#### BATTLE LOSS METHODS ####

# Triggered upon emission of 'player_death' signal from Player
func _on_player_loss():
	# Turns off label updating for battle
	set_process(false)
	player_faint()

func player_faint():
	var player = get_node("Characters").get_node("Player")
	# Writes faint message to battle textbox
	write_move("Player fainted! Return to World Select.", true)
	# Makes player buttons invisible
	get_node("Control").visible = false
	# Takes away temporary attack bonus from ATT potions
	player.deduct_attack(attack_potions_used)
	# Allows death animation to finish and message to appear
	yield(get_tree().create_timer(3.0), "timeout")
	# Returns player to WorldSelect
	pass_to_select_screen(player)

func pass_to_select_screen(Player):
	var world_map = get_parent()
	# Turns off label updating in world map
	world_map.set_process(false)
	char_parent.remove_child(Player)
	# Resets payer health and turns on movement, in 'Player.gd'
	Player.revive_player()
	# Makes player invisible
	Player.visible = false
	get_tree().root.get_node("WorldSelect").add_child(Player)
	# Makes select screen visible again
	get_tree().root.get_node("WorldSelect").visible = true
	# Deletes battle scene
	get_parent().queue_free()

#### TURN FUNCTIONALITY ####

func play_turn():
	var battleControls = get_node("Control")
	if active_char.name == "Player":
		# If player's turn and player is still alive, reveal player buttons
		if active_char.get_health() > 0:
			battleControls.visible = true
		else:
			pass
	else:
		# If enemy turn, display attack message and call enemy turn method
		write_move(format_name(active_char.name) + " attacked!", false)
		active_char.play_turn()

# Gets rid of '@' and integer characters used by Godot to distiniguish
#  multiple instances of same scene type
# Parameters : Name - Name to be formatted
func format_name(Name : String):
	var nums = ['0','1','2','3','4','5','6','7','8','9','10', '@']
	var nameAcc : String = ""
	for ch in Name:
		if nums.count(ch) == 1:
			pass
		else:
			nameAcc += ch
	return(nameAcc)

# Writes move to battle scene textbox
func write_move(MoveString : String, KeepDisplayed : bool):
	var textbox = get_node("TextBox")
	var battleControls = get_node("Control")
	# Hides player buttons and displays textbox
	battleControls.visible = false
	textbox.visible = true
	textbox.text = MoveString
	yield(get_tree().create_timer(active_char.get_wait_time()), "timeout")
	# Keeps textbox displayed if true, used for player faint message
	textbox.visible = KeepDisplayed

# Used for player battle functionality
func button_pressed():
	var active_button = group.get_pressed_button()
	var player = get_node("Characters").get_node("Player")
	var buttons = get_node("Control")
	match active_button.name:
		"Attack":
			player.attack()
			write_move("You attacked!", false)
		"Health Potion":
			# potion_used is true or false depending on results of use_potion in 
			#  Player.gd
			var potion_used = player.use_potion("Health Potion")
			if potion_used:
				write_move("HP UP! HP: " + str(player.get_health()), false)
			# If player health is max, don't use health potion
			elif (player.check_if_health_max()):
				write_move("At Max Health!", false)
				yield(get_tree().create_timer(1.0), "timeout")
				buttons.visible = true
			# If potion was not used, player is out of potions
			else:
				write_move("No HP Potions!", false)
				yield(get_tree().create_timer(1.0), "timeout")
				buttons.visible = true
		"Attack Potion":
			# potion_used is true or false depending on results of use_potion in 
			#  Player.gd
			var potion_used = player.use_potion("Attack Potion")
			if potion_used:
				write_move("ATT UP! ATT: " + str(player.get_attack()), false)
				# Stores amount of attack_potions to deduct temporary attack bonus
				# of player
				attack_potions_used += 1
			else:
				write_move("No ATT Potions!", false)
				yield(get_tree().create_timer(1.0), "timeout")
				buttons.visible = true

# Triggered on emission of 'turn_completed' signal from Player or Enemy, 
#    passes turn to next character in battle turn order
func _on_turn_completed():
	if active_char.name == "Player":
		# Makes player buttons visible if player's turn
		get_node("Control").visible = false
	# Checks to see if battle is over, must have 2 chars to continue battling
	if get_node("Characters").get_child_count() == 1:
		pass
	else:
		# Allows last turn to complete - >animations to play through
		yield(get_tree().create_timer(.5), "timeout")
		# Passes turn back and forth
		var next_index : int = (active_char.get_index() + 1) % (char_parent.get_child_count())
		active_char = char_parent.get_child(next_index)
		play_turn()


