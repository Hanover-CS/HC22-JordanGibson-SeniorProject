extends "res://addons/gut/test.gd"

onready var battle = $Battle

func before_all():
	battle.remove_children()

func test_SmallEnemy_TurnOrder():
	
	battle.add_child($Enemies/)
