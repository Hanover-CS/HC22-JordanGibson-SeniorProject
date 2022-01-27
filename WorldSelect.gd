extends Control
export(ButtonGroup) var group
onready var world_scene = load("res://World.tscn")
var world


func _ready():
	for button in group.get_buttons():
		button.connect("pressed", self, "button_pressed")
	world = world_scene.instance()

func button_pressed():
	var active_button = group.get_pressed_button()
	match active_button.name:
		"Forest":
			print(active_button.name)
			self.visible = false
			get_tree().get_root().add_child(world)
			world.initialize("Forest")
		"Ruins":
			print(active_button.name)
			self.visible = false
			get_tree().get_root().add_child(world)
			world.initialize("Ruins")
		"Dungeon":
			print(active_button.name)
		"Store":
			print(active_button.name)
