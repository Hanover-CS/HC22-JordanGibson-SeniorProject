extends Node2D
var battle_scene = preload("res://Battle/Battle.tscn")
var enemy_scene = preload("res://Enemies/Small/Ruins/Imp/Imp.tscn")
var player_scene = preload("res://Player/Player.tscn")
var spawn_points : Array = []
var enemy_types : Array = ["res://Enemies/Small/Forest/Small Mushroom/Small Mushroom.tscn","res://Enemies/Small/Forest/Twig Blight/Twig Blight.tscn","res://Enemies/Small/Ruins/Imp/Imp.tscn", "res://Enemies/Small/Ruins/Skullflame/Skullflame.tscn"]
var active_floor

func initialize(Map):
	match Map:
		"Forest":
			$Map/Forest.visible = true
			$Map/Dungeon.visible = false
			$Map/Ruins.visible = false
			get_spawnpoints("Forest")
			spawn_enemies(enemy_scene, 4, 9)
			spawn_player("Forest")
			active_floor = "Forest"
		"Ruins":
			$Map/Forest.visible = false
			$Map/Dungeon.visible = false
			$Map/Ruins.visible = true
			get_spawnpoints("Ruins")
			spawn_enemies(enemy_scene, 4, 9)
			spawn_player("Ruins")
			active_floor = "Ruins"
		"Dungeon":
			$Map/Forest.visible = true
			$Map/Dungeon.visible = false
			$Map/Ruins.visible = false

func _on_Player_battle_start(player, enemy):
	start_battle(player, enemy)

func start_battle(player, enemy):
	var temp_player = player
	var temp_enemy = enemy
	add_child(battle_scene.instance())
	remove_child(player)
	get_node("Enemies").remove_child(enemy)
	$Map.visible = false
	$Battle.instance(temp_player, temp_enemy, active_floor)

func get_spawnpoints(Map):
#	spawn_points.clear()
	for i in range(10):
		spawn_points.append(get_node("SpawnPoints").get_node(Map).get_node("Normal").get_child(i))

func spawn_enemies(EnemyScene, NumTypes, NumEnemies):
	var Spawns = choose_spawns(NumEnemies)
	for spawn in Spawns:
		randomize()
		var type = enemy_types[randi()%NumTypes-1]
		var enemy = load(type).instance()
		get_node("Enemies").add_child(enemy)
		enemy.scale = Vector2(1.5,1.5)
		enemy.set_global_position(spawn_points[spawn].position)

func choose_spawns(NumEnemies):
	var NumsPicked = []
	for i in range(NumEnemies):
		randomize()
		var spawn_point = randi()%9+1
		while NumsPicked.count(spawn_point) == 1:
			spawn_point = randi()%9+1
		NumsPicked.append(spawn_point)
	return NumsPicked

func spawn_player(Map):
	var player = player_scene.instance()
	var player_spawn = get_node("SpawnPoints/" + Map + "/Player/PlayerSpawn")
	add_child(player)
	player.set_global_position(player_spawn.position)
	player.scale = Vector2(.4,.4)
