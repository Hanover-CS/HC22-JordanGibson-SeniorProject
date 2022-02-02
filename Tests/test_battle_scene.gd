extends "res://addons/gut/test.gd"

class TestBattle:
	extends "res://addons/gut/test.gd"

	onready var imp_scene = preload("res://Enemies/Small/Ruins/Imp/Imp.tscn")

	onready var player_scene = preload("res://Player/Player.tscn")
	onready var world_scene = preload("res://World.tscn")

	onready var world
	
	func _ready():
		world = world_scene.instance()
		add_child(world)

	func test_battle_start():
		var imp = imp_scene.instance()
		var player = player_scene.instance()
		world.add_child(player)
		world.add_child(imp)
		world.start_battle(player, imp)
		var battle_chars = world.get_node("Battle").get_node("Characters")
		assert_eq(world.get_child_count(), 1)

	func test_battle_enemy_speed_3():
		var imp = imp_scene.instance()
		var player = player_scene.instance()
		world.add_child(player)
		world.add_child(imp)
		world.start_battle(player, imp)
		var battle_chars = world.get_node("Battle").get_node("Characters")
		assert_eq(battle_chars.get_children(), [imp, player])

	func test_battle_enemy_speed_2():
		var imp = imp_scene.instance()
		var player = player_scene.instance()
		imp.speed = 2
		world.add_child(player)
		world.add_child(imp)
		world.start_battle(player, imp)
		var battle_chars = world.get_node("Battle").get_node("Characters")
		assert_eq(battle_chars.get_children(), [imp, player])

	func test_battle_enemy_speed_1():
		var imp = imp_scene.instance()
		var player = player_scene.instance()
		imp.speed = 1
		world.add_child(player)
		world.add_child(imp)
		world.start_battle(player, imp)
		var battle_chars = world.get_node("Battle").get_node("Characters")
		assert_eq(battle_chars.get_children(), [player, imp])

	func after_each():
		if world.get_child_count() > 0:
			for i in range(world.get_child_count() - 1 , -1, -1):
				var curr_child = world.get_child(i)
				world.remove_child(curr_child)
