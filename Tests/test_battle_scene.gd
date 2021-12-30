extends "res://addons/gut/test.gd"

class TestTurnQueue:
	extends "res://addons/gut/test.gd"
	
	onready var imp_scene = preload("res://Enemies/Small/Imp/Imp.tscn")
	onready var skullflame_scene = preload("res://Enemies/Small/Skullflame/Skullflame.tscn")
	onready var wisp_scene = preload("res://Enemies/Small/Wisp/Whisp.tscn")
	onready var glutmon_scene = preload("res://Enemies/Bosses/Glutmon/Glutmon.tscn")
	
	onready var player_scene = preload("res://Player/Player.tscn")
	onready var world_scene = preload("res://World.tscn")
	
	onready var player = player_scene.instance()
	onready var world = world_scene.instance()
	

	func test_small_enemy_order():
		world.add_child(player)
		world.add_child(imp_scene.instance())
		world.start_battle(player, world.get_node("Imp"))
		assert_eq(world.get_child_count(), 1)

	func after_each():
		if world.get_child_count() > 0:
			for i in range(world.get_child_count() - 1 , -1, -1):
				print(world.get_child(i).name)
				world.get_child(i).queue_free()

#	func test_small_enemy_order_multiple():
#		var imp = imp_scene.instance()
#		var skullflame = skullflame_scene.instance()
#		skullflame.speed = 2
#		char_parent.add_child(imp)
#		char_parent.add_child(player)
#		char_parent.add_child(skullflame)
#		battle.create_turn_order()
#		assert_eq(char_parent.get_children(), [imp, skullflame, player])

class TestBattleSpawn:
	extends "res://addons/gut/test.gd"
	
	onready var imp_scene = preload("res://Enemies/Small/Imp/Imp.tscn")
	onready var skullflame_scene = preload("res://Enemies/Small/Skullflame/Skullflame.tscn")
	onready var wisp_scene = preload("res://Enemies/Small/Wisp/Whisp.tscn")
	onready var glutmon_scene = preload("res://Enemies/Bosses/Glutmon/Glutmon.tscn")
	
	onready var player_scene = preload("res://Player/Player.tscn")
	onready var world_scene = preload("res://World.tscn")
	
