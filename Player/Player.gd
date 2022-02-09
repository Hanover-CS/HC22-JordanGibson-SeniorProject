extends Node2D

var level : int = 1
var max_health = 10
var xp_threshold = 5
var currXP = 0

export (int) var health = 10
export (int) var damage = 10
export (int) var defense = .05
export (int) var speed = 1
export (int) var movement_speed = 100

var Inventory : Dictionary = {"Attack Potion" : 0, "Health Potion" : 0, "Gold": 0}

var wait_time = .7
var direction : Vector2
var conn_flag = false

signal player_attack(damage)
signal player_death()
signal turn_completed()

onready var player_animation = $Sprite/AnimationPlayer

func _process(delta):
	check_connection()
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	position.x += direction.x * movement_speed * delta
	position.y += direction.y * movement_speed * delta

	if direction.x != 0 or direction.y != 0:
		if direction.x < 0:
			$Sprite.flip_h = true
		else:
			$Sprite.flip_h = false
		player_animation.play("Walk")
	else:
		player_animation.play("Idle")

func check_connection():
	if (get_parent().name == "World" and conn_flag == false):
		connect('area_entered', self, "_on_Knight_area_entered")
		player_animation.play("Idle")
		conn_flag = true
	else:
		pass

func give_XP(XP):
	currXP += XP
	check_for_level_up()
	print(currXP)

func check_for_level_up():
	if (currXP >= xp_threshold):
		level_up()
		print("LEVEL UP")
	else:
		pass

func level_up():
	level += 1
	xp_threshold = xp_threshold + floor(xp_threshold * .5)
	currXP = 0
	var level_up_scene = load("res://Player/Level Up Screen/LevelUp.tscn")
	var level_up = level_up_scene.instance()
	add_child(level_up)
	print(level)

func get_speed():
	return(speed)

func give_speed(Speed):
	speed += Speed
	print("Speed = " + str(speed))

func get_health():
	return(health)
	
func give_health(Health):
	health += Health
	print("Health = " + str(health))

func give_attack(Attack):
	damage += Attack
	print("Attack = " + str(damage))

func get_level():
	return(level)

func get_wait_time():
	return(wait_time)

func _on_Knight_area_entered(area):
	if (get_parent().name == "World" and area.is_in_group("enemy")):
		player_animation.stop()
		get_parent().start_battle(self, area)

func play_turn():
	attack()

func attack():
	player_animation.play("Slash")
	yield(get_tree().create_timer(wait_time), "timeout")
	emit_signal("player_attack", damage)
	emit_signal('turn_completed')

func use_potion(PotionType):
	if (PotionType == "Attack Potion" or PotionType == "Health Potion"):
		if (Inventory.get(PotionType) > 0):
			if (PotionType == "Attack Potion"):
				damage += 1
			elif (PotionType == "Health Potion"):
				health += randi()%3
				if health > max_health:
					health = max_health
			var curr_amount = Inventory.get(PotionType)
			Inventory[PotionType] = curr_amount - 1
			print(Inventory)
		else:
			print("You do not have enough " + str(PotionType) + " potions!")
	else:
		print("Not valid potion type")	

func buy_item(Item):
	if (Inventory.get("Gold") < 2):
		print("Not enough Gold!")
	else:
		if (Item == "Attack Potion" or Item == "Health Potion"):
			var curr_amount = Inventory.get(Item)
			deduct_gold(2)
			Inventory[Item] = curr_amount + 1
			print(Inventory)
		else:
			print("Not valid item type")

func give_gold(Gold):
	var curr_amount = Inventory.get("Gold")
	Inventory["Gold"] = curr_amount + Gold
	print(Inventory)

func deduct_gold(Gold):
	var curr_amount = Inventory.get("Gold")
	Inventory["Gold"] = curr_amount - Gold

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
