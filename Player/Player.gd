extends Node2D

var level : int = 7
export (int) var health = 10
export (int) var damage = 1
export (int) var defense = .05
export (int) var speed = 1
export (int) var movement_speed = 100

var Inventory : Dictionary = {"Attack Potion" : 0, "Health Potion" : 0}

var wait_time = 1.0
var direction : Vector2
var screen_size = 1024

signal player_attack(damage)
signal player_death()
signal turn_completed()

onready var player_animation = $Sprite/AnimationPlayer

func _ready():
	if (get_parent().name == "World"):
		connect("battle_start", get_parent(), "_on_Player_battle_start")
		player_animation.play("Idle")
	else:
		player_animation.play("Idle")

func _process(delta):
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	global_position.x += direction.x * movement_speed * delta
	global_position.y += direction.y * movement_speed * delta
	
	if direction.x != 0 or direction.y != 0:
		if direction.x < 0:
			$Sprite.flip_h = true
		else:
			$Sprite.flip_h = false
		player_animation.play("Walk")
	else:
		player_animation.play("Idle")

func get_speed():
	return(speed)

func get_health():
	return(health)

func get_level():
	return(level)

func _on_Knight_area_entered(area):
	if (get_parent().name == "World" and area.is_in_group("enemy")):
		player_animation.stop()
		get_parent().start_battle(self, area)

func play_turn():
	attack()
	return self

func attack():
	player_animation.play("Slash")
	yield(get_tree().create_timer(wait_time), "timeout")
	print(2)
	emit_signal("player_attack", damage)

func give_item(Item):
	if (Item == "Attack Potion"):
		var curr_amount = Inventory.get(Item)
		Inventory[Item] = curr_amount + 1
		print(Inventory)
	elif (Item == "Health Potion"):
		var curr_amount = Inventory.get(Item)
		Inventory[Item] = curr_amount + 1
		print(Inventory)

func _on_enemy_attack(enemy_damage):
	print("Player damage took: ", enemy_damage)
	health -= enemy_damage
	if health <= 0:
		player_animation.play("Dying")
		emit_signal("player_death")
	else:
		player_animation.play("Hurt")
		yield(get_tree().create_timer(wait_time), "timeout")
		player_animation.play("Idle")
