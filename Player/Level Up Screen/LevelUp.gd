# File : LevelUp.gd
# Created By : Jordam Gibson
# Last Updated : 2/15/2022
# Functionality : Screen allowing player to select which stat to increase upon
#   level up

extends Control

export(ButtonGroup) var group

# Establishes button connections
func _ready():
	for button in group.get_buttons():
		button.connect("pressed", self, "button_pressed")

# Calls appropriate player method to increase repective stat
func button_pressed():
	var active_button = group.get_pressed_button()
	var player = get_parent()
	match active_button.name:
		"Attack":
			player.give_attack(1)
			self.queue_free()
		"Health":
			player.give_health(1)
			self.queue_free()
		"Speed":
			player.give_speed(1)
			self.queue_free()
