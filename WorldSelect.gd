extends Control
export(ButtonGroup) var group

onready var world_scene = load("res://World.tscn")
var player_scene = preload("res://Player/Player.tscn")

var player
var world


func _ready():
	for button in group.get_buttons():
		button.connect("pressed", self, "button_pressed")
	player = player_scene.instance()

func button_pressed():
	if (self.is_a_parent_of(player)):
		remove_child(player)
	world = world_scene.instance()
	var active_button = group.get_pressed_button()
	match active_button.name:
		"Forest":
			print(active_button.name)
			self.visible = false
			get_tree().get_root().add_child(world)
			world.initialize("Forest", player)
		"Ruins":
			print(active_button.name)
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
