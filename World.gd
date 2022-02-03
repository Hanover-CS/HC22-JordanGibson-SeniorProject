extends Node2D
var battle_scene = preload("res://Battle/Battle.tscn")
var enemy_scene = preload("res://Enemies/Small/Ruins/Imp/Imp.tscn")
var player_scene = preload("res://Player/Player.tscn")
var spawn_points : Array = []
var enemy_types : Array = []
var active_floor
export (ButtonGroup) var group

func initialize(Map):
	match Map:
		"Forest":
			$Map/Forest.visible = true
			$Map/Dungeon.visible = false
			$Map/Ruins.visible = false
			$Store.visible = false
			get_spawnpoints("Forest")
			enemy_types = ["res://Enemies/Small/Forest/Small Mushroom/Small Mushroom.tscn", 
			"res://Enemies/Small/Forest/Twig Blight/Twig Blight.tscn", "res://Enemies/Small/Ruins/Wisp/Whisp.tscn",
			"res://Enemies/Medium/Forest/Wolf/Wolf.tscn"]
			spawn_enemies(enemy_scene, enemy_types.size(), 9)
			spawn_player("Forest")
			active_floor = "Forest"
		"Ruins":
			$Map/Forest.visible = false
			$Map/Dungeon.visible = false
			$Map/Ruins.visible = true
			$Store.visible = false
			get_spawnpoints("Ruins")
			enemy_types = ["res://Enemies/Small/Ruins/Imp/Imp.tscn", "res://Enemies/Small/Ruins/Skullflame/Skullflame.tscn", 
			"res://Enemies/Small/Ruins/Wisp/Whisp.tscn","res://Enemies/Small/Ruins/Child Spirit/Child Spirit.tscn",
			"res://Enemies/Small/Ruins/Hell Critter/Hell Critter.tscn"]
			spawn_enemies(enemy_scene, enemy_types.size(), 9)
			spawn_player("Ruins")
			active_floor = "Ruins"
		"Dungeon":
			$Map/Forest.visible = false
			$Map/Dungeon.visible = true
			$Map/Ruins.visible = false
			$Store.visible = false
			get_spawnpoints("Dungeon")
			enemy_types = ["res://Enemies/Small/Ruins/Imp/Imp.tscn", "res://Enemies/Small/Ruins/Skullflame/Skullflame.tscn", 
			"res://Enemies/Small/Ruins/Wisp/Whisp.tscn","res://Enemies/Small/Ruins/Child Spirit/Child Spirit.tscn",
			"res://Enemies/Small/Dungeon/Mimic/Mimic.tscn"]
			spawn_enemies(enemy_scene, enemy_types.size(), 9)
			spawn_player("Dungeon")
			active_floor = "Dungeon"
		"Store":
			for button in group.get_buttons():
				button.connect("pressed", self, "button_pressed")
			$Map.visible = false
			$Store.visible = true
			$Store/StoreKeeper/AnimationPlayer.play("Idle")
			spawn_player("Store")

func _on_Player_battle_start(player, enemy):
	start_battle(player, enemy)

func start_battle(player, enemy):
	var temp_player = player
	var temp_enemy = enemy
	add_child(battle_scene.instance())
	remove_child(player)
	get_node("Enemies").remove_child(enemy)
	$Map.visible = false
	$Enemies.visible = false
	$Battle.instance(temp_player, temp_enemy, active_floor)

func get_spawnpoints(Map):
#	spawn_points.clear()
	for i in range(10):
		spawn_points.append(get_node("SpawnPoints").get_node(Map).get_node("Normal").get_child(i))

func spawn_enemies(EnemyScene, NumTypes, NumEnemies):
	var Spawns = choose_spawns(NumEnemies)
	var enemies_spawned : Dictionary = make_enemy_type_dict()
	for spawn in Spawns:
		randomize()
		var type = enemy_types[randi()%NumTypes]
		while enemies_spawned[type] >= 3:
			type = enemy_types[randi()%NumTypes]
		var curr_type_val = enemies_spawned[type]
		enemies_spawned[type] = curr_type_val + 1
		var enemy = load(type).instance()
		get_node("Enemies").add_child(enemy)
		enemy.scale = Vector2(1.5,1.5)
		enemy.set_global_position(spawn_points[spawn].position)

func make_enemy_type_dict():
	var enemies = {}
	for type in enemy_types:
		enemies[type] = 0
	return enemies

func choose_spawns(NumEnemies):
	var SpawnsPicked = []
	for i in range(NumEnemies):
		randomize()
		var spawn_point = randi()%9+1
		while SpawnsPicked.count(spawn_point) == 1:
			spawn_point = randi()%9+1
		SpawnsPicked.append(spawn_point)
	return SpawnsPicked

func spawn_player(Map):
	var player = player_scene.instance()
	var player_spawn
	if (Map != "Store"):
		player_spawn = get_node("SpawnPoints/" + Map + "/Player/PlayerSpawn")
	else:
		player_spawn = get_node("Store/PlayerSpawn")
	add_child(player)
	player.set_global_position(player_spawn.position)
	player.scale = Vector2(.4,.4)

func button_pressed():
	var active_button = group.get_pressed_button()
	match active_button.name:
		"Attack Potion":
			get_node("Player").give_item("Attack Potion")
		"Health Potion":
			get_node("Player").give_item("Health Potion")
