# File : WorldSelect.gd
# Created by : Jordan Gibson
# Last Updated : 2/15/2022
# Functionality : Allows player to select which map they would like to play in
#  and to navigate to store
extends Control
export(ButtonGroup) var group

var world_scene = preload("res://World.tscn")
var player_scene = preload("res://Player/Player.tscn")

var player
var world
# Establishes connections between world buttons and instanes player
func _ready():
	for button in group.get_buttons():
		button.connect("pressed", self, "button_pressed")
	# Player instanced here to allow for passing of one player instance to world and back
	player = player_scene.instance()

func button_pressed():
	# Readies player to be passed to world, node cannot be added as child if already 
	#  a child of another node
	if (self.is_a_parent_of(player)):
		remove_child(player)
	world = world_scene.instance()
	var active_button = group.get_pressed_button()
	# Makes sure that players health is reset and movement enabled before entering world
	player.revive_player()
	match active_button.name:
		"Forest":
			self.visible = false
			get_tree().get_root().add_child(world)
			world.initialize("Forest", player)
		"Ruins":
			self.visible = false
			get_tree().get_root().add_child(world)
			world.initialize("Ruins", player)
		"Dungeon":
			self.visible = false
			get_tree().get_root().add_child(world)
			world.initialize("Dungeon", player)
		"Store":
			self.visible = false
			get_tree().get_root().add_child(world)
			world.initialize("Store", player)
