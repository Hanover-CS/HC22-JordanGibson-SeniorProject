extends "res://addons/gut/test.gd"

class TestTurnQueue:
	extends "res://addons/gut/test.gd"
	
	onready var imp_scene = preload("res://Enemies/Small/Imp/Imp.tscn")
	onready var skullflame_scene = preload("res://Enemies/Small/Skullflame/Skullflame.tscn")
	onready var wisp_scene = preload("res://Enemies/Small/Wisp/Whisp.tscn")
	onready var glutmon_scene = preload("res://Enemies/Bosses/Glutmon/Glutmon.tscn")
	
	onready var player_scene = preload("res://Player/Player.tscn")
	onready var battle_scene = preload("res://Battle/Battle.tscn")
	
	onready var player = player_scene.instance()
	onready var battle = battle_scene.instance()
	
	
	onready var char_parent = battle.get_node("Characters")
	
	func before_each():
		var curr_child
		for i in range(0, char_parent.get_child_count(), -1):
			curr_child = char_parent.get_child(i)
			char_parent.remove_child(curr_child)
	
	func test_small_enemy_order():
		var imp = imp_scene.instance()
		char_parent.add_child(imp)
		char_parent.add_child(player)
		battle.create_turn_order()
		assert_eq(char_parent.get_child(0), imp)

	func test_small_enemy_order_multiple():
		var imp = imp_scene.instance()
		var skullflame = skullflame_scene.instance()
		skullflame.speed = 2
		char_parent.add_child(imp)
		char_parent.add_child(player)
		char_parent.add_child(skullflame)
		battle.create_turn_order()
		assert_eq(char_parent.get_children(), [imp, skullflame, player])
