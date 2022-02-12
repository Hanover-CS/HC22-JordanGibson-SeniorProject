extends Control

export(ButtonGroup) var group

func _ready():
	for button in group.get_buttons():
		button.connect("pressed", self, "button_pressed")

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
