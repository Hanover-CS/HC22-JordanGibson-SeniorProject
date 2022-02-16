extends "res://addons/gut/test.gd"

class TestPlayer:
	extends "res://addons/gut/test.gd"
	var player = load("res://Player/Player.gd")
	
	func test_PlayerGetters():
		var Player = player.new();
		var health : int= Player.get_health()
		var correct : int = 10
		assert_eq(health, correct)
