# File : World.gd
# Created by : Jordan Gibson
# Last Update : 2/15/2022
# Functionality : Handles spawning of world maps and spawns - Player and 
#  Enemies when necessary

# World base node
extends Node2D
# Resources for instancing
var battle_scene = preload("res://Battle/Battle.tscn")
var world_scene = load("res://World.tscn")
# Arrays to serve as containers for respective information denoted by name
var spawn_points : Array = []
var enemy_types : Array = []
var boss_type : Array = []
# Active floor used to keep track of which map is being used currently
var active_floor : String
# Used to save player's position upon battle start
var curr_pos : Vector2
# Button groups allowing for easier button handling
export (ButtonGroup) var group
export (ButtonGroup) var group2

# Sets up initial map based on which button was pressed in WorldSelect screen
# Parameters : Map - String denoting which map should be active, received from
#					WorldSelect screen
#			   Player - Reference to player node, used for spawning
func initialize(Map : String, Player : KinematicBody2D):
	# Ensures that respective map is visible
	check_visibility(Map, Player)
	# Connects button signals for back button and shop buttons
	setup_buttons()
	match Map:
		"Forest":
			active_floor = "Forest"
		"Ruins":
			active_floor = "Ruins"
		"Dungeon":
			active_floor = "Dungeon"
		"Store":
			active_floor = "Store"
	# Prepares map
	setup_map(Player)
	
# Ensures that respective map and player are visible
# Parameters : Map - String denoting Map that should be visible
# Parameters : Map - String denoting which map should be active, received from
#					WorldSelect screen
#			   Player - Reference to player node
func check_visibility(Map : String, Player : KinematicBody2D):
	if (Map == "Store"):
		pass
	if (Player.visible == false):
		Player.visible = true
	if (get_node("Map/" + Map).visible == false):
		get_node("Map/" + Map).visible = true

# Establishes connections between 'pressed' button signal and respective button
#   pressed method for every button in group
func setup_buttons():
	# Group -> Shop Buttons
	for button in group.get_buttons():
		button.connect("pressed", self, "shop_button_pressed")
	# Group 2 -> Back Buttons, used for easier screen transitioning in development
	for button in group2.get_buttons():
		button.connect("pressed", self, "back_button_pressed")

# Sets up respective map based on active_floor variable
# Parameters : Player - Reference to player node to allow for spawning
func setup_map(Player : KinematicBody2D):
	# Enables visibility of active floor map
	get_node("Map/" + active_floor).visible = true
	# Sets up necessary components of store map
	if (active_floor == "Store"):
		$Map/Store/StoreKeeper/AnimationPlayer.play("Idle")
		spawn_player(Player)
		# Updates potion counts in store to match current player inventory
		update_potion_labels()
	else:
		# Readies and spawns player and enemies
		get_spawnpoints()
		setup_chars(Player)

# Spawns player and enemies, ensuring they have necessary attributes
# Parameters : Player - Reference to player node
func setup_chars(Player : KinematicBody2D):
	spawn_player(Player)
	# Updates labels on left side of map to match player inventory
	setup_labels(Player)
	# Sets enemy_types array to active_floor enemy types
	set_enemy_types()
	# Spawns enemies, amount based on player level
	spawn_enemies(enemy_types.size(), Player.get_level() + 2)
	#  Allows for tileMap collision
	make_world_interactable()

# Appends respective spawn points to spawn_points array according to active
#  floor
func get_spawnpoints():
	for i in range(10):
		spawn_points.append(get_node("SpawnPoints/" + active_floor + "/Normal").get_child(i))


# Spawns player on respective player_spawn according to enemy floor
# Parameters : Player - Reference to player node
func spawn_player(Player : KinematicBody2D):
	# Adds Player node to scene
	add_child(Player)
	var player_spawn
	if (active_floor != "Store"):
		player_spawn = get_node("SpawnPoints/" + active_floor + "/Player/PlayerSpawn")
		# Makes sure that heart label is visible under player when in world
		Player.get_node("Gold").visible = false
		Player.get_node("Heart").visible = true
	else:
		# Makes sure that gold label is visible under player when in store
		player_spawn = get_node("Map/Store/PlayerSpawn")
		Player.get_node("Gold").visible = true
		Player.get_node("Heart").visible = false
	# Spawns player on spawn point and scales player size down for scene
	Player.set_global_position(player_spawn.position)
	Player.scale = Vector2(.4,.4)

# Establishes enemy and boss type arrays for active floor
func set_enemy_types():
	match active_floor:
		"Forest":
			enemy_types = ["res://Enemies/Small/Forest/Small Mushroom/Small Mushroom.tscn", 
			"res://Enemies/Small/Forest/Twig Blight/Twig Blight.tscn", "res://Enemies/Small/Forest/Whisp/Whisp.tscn",
			 "res://Enemies/Medium/Forest/Fungal Monster/Fungal Monster.tscn", "res://Enemies/Medium/Forest/Wendigo/Wendigo.tscn",
			"res://Enemies/Medium/Forest/Wolf/Wolf.tscn"]
			boss_type = ["res://Enemies/Bosses/Forest/Froghemoth/Froghemoth.tscn"]
		"Ruins":
			enemy_types = ["res://Enemies/Small/Ruins/Child Spirit/Child Spirit.tscn", "res://Enemies/Small/Ruins/Hell Critter/Hell Critter.tscn",
			"res://Enemies/Small/Ruins/Imp/Imp.tscn", "res://Enemies/Small/Ruins/Skullflame/Skullflame.tscn",
			"res://Enemies/Medium/Ruins/Demon/Demon.tscn"]
			boss_type = ["res://Enemies/Bosses/Ruins/Death.tscn"]
		"Dungeon":
			enemy_types = ["res://Enemies/Small/Dungeon/Mimic/Mimic.tscn", "res://Enemies/Small/Dungeon/Sludge/Sludge.tscn",
			"res://Enemies/Medium/Dungeon/Skeletal Warrior/Skeletal Warrior.tscn", "res://Enemies/Small/Dungeon/Rogue/Rogue.tscn"]
			boss_type = ["res://Enemies/Bosses/Dungeon/Dragon.tscn"]

# Initializes label values on left side of screen to match player inventory
# Paramters : Player - Reference to player node
func setup_labels(Player : KinematicBody2D):
	# Makes sure labels are visible
	$Map/Labels.visible = true
	var gold_label = get_node("Map/Labels/Gold/Label")
	var attack_potion_label = get_node("Map/Labels/Attack Potion/Label")
	var health_potion_label = get_node("Map/Labels/Health Potion/Label")
	# Updates label text according to Player inventory
	gold_label.text = ": " + str(Player.get_gold())
	attack_potion_label.text = ": " + str(Player.get_potion_count("Attack Potion"))
	health_potion_label.text = ": " + str(Player.get_potion_count("Health Potion"))

# Initializes label values on left side of store screen to match player inventory
# Paramters : Player - Reference to player node
func update_potion_labels():
	var health_potion_label = get_node("Map/Store/Potions/Health Potion/Label")
	var attack_potion_label = get_node("Map/Store/Potions/Attack Potion/Label")
	var player = get_node("Player")
	# Updates label text according to Player inventory
	health_potion_label.text = ": " + str(player.get_potion_count("Health Potion"))
	attack_potion_label.text = ": " + str(player.get_potion_count("Attack Potion"))

# Spawns enemies into map based on active floor
# Parameters : NumTypes - Integer indicating amounnt of enemy types (enemy_types.size())
# 			   NumEnemies - Integer indicating amount of enemies to be spawned
func spawn_enemies(NumTypes : int, NumEnemies : int):
	# Makes sure that number of enemies does not exceed amount of spawn points
	if NumEnemies > 9:
		NumEnemies = 9
	# Player level reference
	var playerLevel : int = get_node("Player").get_level()
	# Spawns boss every 5 floors
	if (playerLevel % 5 == 0):
		spawn_boss(playerLevel)
	# Gets random spawns for enemies
	var Spawns = choose_spawns(NumEnemies)
	# Initializes dictionary to allow for balancing of enemy spawns
	var enemies_spawned : Dictionary = make_enemy_type_dict()
	# Spawns an enemy on each randomly chosen spawn point
	for spawn in Spawns:
		# Reseeds random number generator
		randomize()
		# Spawns enemy
		var enemy_type = get_valid_type(NumTypes, enemies_spawned)
		var enemy = load(enemy_type).instance()
		enemies_spawned[enemy_type] += 1
		spawn_single_enemy(enemy, spawn_points[spawn].position)

# Used to spawn boss into map
# Parameters : playerLevel - Integer used to scale boss to player
func spawn_boss(playerLevel : int):
	# Chooses random boss type (For multiple boss types on same floor)
	var index : int = randi()%boss_type.size()
	# Gets necessary boss_scene reference from boss_type array
	var boss : Area2D = load(boss_type[index]).instance()
	# Scales boss to player according to player's level
	boss.level_up(playerLevel / 2, false)
	# Gets respective spawning location for active floor
	var boss_spawn : Vector2 = get_node("SpawnPoints/" + active_floor + "/Boss/BossSpawn").position
	get_node("Enemies").add_child(boss)
	boss.set_global_position(boss_spawn)

# Randomly generates an array of integers indicating spawn points
# Parameters : NumEnemies - Integer denoting how many spawns should be picked
func choose_spawns(NumEnemies : int):
	var SpawnsPicked = []
	for i in range(NumEnemies):
		randomize()
		var spawn_point = randi()%9+1
		# Checks to see if a spawn has already been chosen, repeats until unique spawn
		# is found
		while SpawnsPicked.count(spawn_point) == 1:
			spawn_point = randi()%9+1
		# Adds unique spawn value to SpawnsPicked array
		SpawnsPicked.append(spawn_point)
	return SpawnsPicked

# Initializes empty dictionary for enemy balancing array
func make_enemy_type_dict():
	var enemies = {}
	for type in enemy_types:
		enemies[type] = 0
	return enemies

# Gets a enemy type that has not been spawned any more than three times, used for balancing of spawns
# Parameters : NumTypes - Integer indicating amount of enemy types (enemy_types.size())
#              EnemyDict - Current enemy balancing dictionary, used to check how
#					many times a certain enemy type has been spawned
func get_valid_type(NumTypes : int, EnemyDict : Dictionary):
	# Chooses a random enemy type from enemy_type array
	var type = enemy_types[randi()%NumTypes]
	# Repeats until a type has been chosen that has not been spawned any more than 3 times
	while EnemyDict[type] >= 3:
		type = enemy_types[randi()%NumTypes]
	# Returns enemy type that has not been spawned any greater than 3 times
	return type

# Spawns and sets up single enemy instance
# Parameters : enemyScene - Reference to enemy scene to be spawned,
#			   spawnLocation - Position at which enemy should be spawned
func spawn_single_enemy(enemyScene : Area2D, spawnLocation : Vector2):
	get_node("Enemies").add_child(enemyScene)
	enemyScene.level_up(get_node("Player").get_level(), false)
	enemyScene.scale = Vector2(1.5,1.5)
	enemyScene.set_global_position(spawnLocation)

# Ensures that map is on the same collision layer and mask as player
#  Allows for different tileMap collision layouts on different floors
func make_world_interactable():
	# Collision not necessary on Store floor
	if active_floor == "Store":
		pass
	# Sets active floor map to be on same 'level' as player
	else:
		var background = get_node("Map/" + str(active_floor)).get_node("Background")
		var foreground = get_node("Map/" + str(active_floor)).get_node("Foreground")
		background.collision_layer = 1
		background.collision_mask = 1
		foreground.collision_layer = 1
		foreground.collision_mask = 1

# Signal triggered when player runs into enemy
# Parameters : Player - Reference to player node, 
#			   Enemy  - Reference to enemy collided with
func _on_Player_battle_start(Player : KinematicBody2D, Enemy : Area2D):
	start_battle(Player, Enemy)

# Initiates a battle between the player and the enemy
# Parameters : Player - Reference to player node, 
#			   Enemy  - Reference to enemy collided with
func start_battle(Player : KinematicBody2D, Enemy : Area2D):
	# Makes sure that map is not visible
	change_map_visibility(false)
	# Disables player movement
	Player.set_physics_process(false)
	# Removes player from world in order to pass it to battle scene
	var temp_player = Player
	# Saves player's current position in map
	curr_pos = Player.get_global_position()
	# Used to make make sure Player has enough time to disconnect signals
	yield(get_tree().create_timer(.01), 'timeout')
	remove_child(Player)
	# Removes enemy from world in order to pass it to battle scene, removed from
	#  'Enemies' node to remove from world map
	var temp_enemy = Enemy
	get_node("Enemies").remove_child(Enemy)
	# Used to make make sure Player has enough time to disconnect signals
	yield(get_tree().create_timer(.01), 'timeout')
	# Adds battle scene to world and passes player and enemy to it
	add_child(battle_scene.instance())
	$Battle.initialize(temp_player, temp_enemy, active_floor)

# Changes whether or not enemies and map are visible
# Parameters : isVisible - indicates whether or not they should be visible
func change_map_visibility(isVisible : bool):
	$Map.visible = isVisible
	$Enemies.visible = isVisible

# Handles player buying functionality in shop
func shop_button_pressed():
	var active_button = group.get_pressed_button()
	match active_button.name:
		"Attack Potion":
			print("Attack Potion")
			get_node("Player").buy_item("Attack Potion")
		"Health Potion":
			print("Health Potion")
			get_node("Player").buy_item("Health Potion")
	# Changes potion labels to reflect new player inventory
	update_potion_labels()

# Allows for traversal back to select screen
func back_button_pressed():
	pass_player_to_select(get_node("Player"))
	get_node("Map").get_parent().queue_free()
	get_parent().get_node("WorldSelect").visible = true

# Checks to see if any enemies left in world, returns to select screen if not
func check_enemy_count():
	if (get_node("Enemies").get_children() == []):
		pass_player_to_select(get_node("Player"))
	else:
		pass

# Passes player to WorldSelect screen to allow for another map to be selected
# Parameters : Player - Reference to player node
func pass_player_to_select(Player : KinematicBody2D):
	ready_player_to_pass(Player)
	change_map_visibility(false)
	# Ensures that no nodes are orphaned (Taking up memory with no pointer to them)
	clear_all()
	# Adds player to WorldSelect screen and makes it visible again
	var select_screen = get_tree().root.get_node("WorldSelect")
	select_screen.add_child(Player)
	select_screen.visible = true

# Sets Player up to be passed to select, removes from world and makes invisible
# Parameters : Player - Reference to player node
func ready_player_to_pass(Player : KinematicBody2D):
	Player.visible = false
	remove_child(Player)

# Clears all nodes from world
func clear_all():
	clear_enemies()
	clear_world()

# Makes sure that all enemy nodes are deleted in 'Enemies' node
func clear_enemies():
	var enemies = get_node("Enemies")
	for enemy in enemies.get_children():
		enemy.queue_free()

# Deletes all nodes from world
func clear_world():
	for node in self.get_children():
		node.queue_free()
	self.queue_free()
