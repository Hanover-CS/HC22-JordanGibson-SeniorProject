extends Node2D
var battle_scene = preload("res://Battle/Battle.tscn")
var enemy_scene = preload("res://Enemies/Small/Imp/Imp.tscn")
var player_scene = preload("res://Player/Player.tscn")
onready var spawn_points : Array = []

func _ready():
	self.initialize("Forest")

func initialize(Map):
	match Map:
		"Forest":
			$Map/Forest.visible = true
			$Map/Dungeon.visible = false
			$Map/Ruins.visible = false
			get_spawnpoints("Forest")
			spawn_enemies("Imp", 7)
			spawn_player("Forest")
		"Ruins":
			$Map/Forest.visible = true
			$Map/Dungeon.visible = false
			$Map/Ruins.visible = false
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
	remove_child(enemy)
	$Map.visible = false
	$Battle.instance(temp_player, temp_enemy)

func get_spawnpoints(Map):
	spawn_points.clear()
	for i in range(1,11):
		spawn_points.append(get_node("SpawnPoints").get_node(Map).get_node("Normal").get_node("Spawn" + str(i)))

func spawn_enemies(Enemy, NumEnemies):
	var NumsPicked = []
	for i in range(NumEnemies):
		var spawn_point = randi()%9+1
		while NumsPicked.count(spawn_point) == 1:
			spawn_point = randi()%9+1
		NumsPicked.append(spawn_point)
		var enemy = enemy_scene.instance()
		add_child(enemy)
		enemy.scale = Vector2(1.5,1.5)
		enemy.set_global_position(spawn_points[spawn_point].position)

func spawn_player(Map):
	var player = player_scene.instance()
	add_child(player)
	player.set_global_position($SpawnPoints/Forest/Player/PlayerSpawn.position)
	player.scale = Vector2(.4,.4)
