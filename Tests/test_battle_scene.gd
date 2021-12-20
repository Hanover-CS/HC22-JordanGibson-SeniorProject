extends "res://addons/gut/test.gd"

class TestTurnQueue:
	extends "res://addons/gut/test.gd"
	
	onready var imp_scene = preload("res://Enemies/Small/Imp/Imp.tscn")
	onready var skullflame_scene = preload("res://Enemies/Small/Skullflame/Skullflame.tscn")
	onready var wisp_scene = preload("res://Enemies/Small/Wisp/Whisp.tscn")
	onready var glutmon_scene = preload("res://Enemies/Bosses/Glutmon/Glutmon.tscn")
	onready var player_scene = preload("res://Player/Player.tscn")
	onready var battle_scene = preload("res://Battle/Battle.tscn")
	
	func test_small_enemy_order():
		var player = player_scene.instance()
		var imp = imp_scene.instance()
		var battle = battle_scene.instance()
		var char_parent = battle.get_node("Characters")
		char_parent.add_child(imp)
		char_parent.add_child(player)
		battle.create_turn_order()
		assert_eq(char_parent.get_child(0), imp)
