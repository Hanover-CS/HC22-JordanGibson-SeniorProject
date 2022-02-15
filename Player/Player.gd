extends KinematicBody2D

export (int) var health = 10
export (int) var damage = 1
export (int) var speed = 1
export (int) var movement_speed = 100

var Inventory : Dictionary = {"Attack Potion" : 1, "Health Potion" : 4, "Gold": 0}

var level : int = 2
var max_health : int = 10
var xp_threshold : int = 3
var currXP : int = 0

var wait_time : float = .7
var direction : Vector2

signal player_attack(damage)
signal player_death()
signal turn_completed()

onready var player_animation = $Sprite/AnimationPlayer

func _ready():
	update_heart()
	update_gold()
	update_level()

func _physics_process(delta):
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	move_and_collide(Vector2(direction.x * movement_speed * delta, direction.y * movement_speed * delta))

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

func give_speed(Speed):
	speed += Speed
	print("Speed = " + str(speed))

func get_health():
	return(health)

func check_if_health_max():
	return(health == max_health)

func give_health(Health):
	max_health += Health
	health = max_health
	update_heart()

func give_attack(Attack):
	damage += Attack

func get_attack():
	return(damage)

func deduct_attack(attack):
	damage -= attack

func get_level():
	return(level)

func update_level():
	$Level.text = "Lvl: " + str(level)

func get_potion_count(PotionType):
	match PotionType:
		"Attack Potion":
			return(Inventory["Attack Potion"])
		"Health Potion":
			return(Inventory["Health Potion"])

func get_wait_time():
	return(wait_time)

func update_heart():
	var heart_label = get_node("Heart/Label")
	heart_label.text = ": " + str(health)

func update_gold():
	var gold_label = get_node("Gold/Label")
	gold_label.text = ": " + str(Inventory["Gold"])

func get_gold():
	return(Inventory["Gold"])

func give_gold(Gold):
	Inventory["Gold"] += Gold
	update_gold()

func deduct_gold(Gold):
	Inventory["Gold"] -= Gold
	update_gold()

func give_XP(XP):
	currXP += XP
	check_for_level_up()
	print(currXP)

func check_for_level_up():
	if (currXP >= xp_threshold):
		level_up()
	else:
		pass

func level_up():
	level += 1
	xp_threshold = xp_threshold + floor(xp_threshold * .5)
	currXP = 0
	update_level()
	display_stat_select_screen()

func display_stat_select_screen():
	var level_up_scene = load("res://Player/Level Up Screen/LevelUp.tscn")
	var level_up = level_up_scene.instance()
	level_up.rect_scale = Vector2(1.5, 1.5)
	add_child(level_up)

func _on_Knight_area_entered(area):
	if (get_parent().name == "World" and area.is_in_group("enemy")):
		player_animation.stop()
		get_parent().start_battle(self, area)

func attack():
	player_animation.play("Slash")
	yield(get_tree().create_timer(wait_time), "timeout")
	emit_signal("player_attack", damage)
	yield(get_tree().create_timer(1.0), "timeout")
	emit_signal('turn_completed')

func use_potion(PotionType):
	if (PotionType == "Attack Potion" or PotionType == "Health Potion"):
		if (Inventory.get(PotionType) > 0):
			if (PotionType == "Attack Potion"):
				use_attack_potion()
				return(true)
			elif (PotionType == "Health Potion"):
				var potion_used = use_health_potion()
				return(potion_used)
		

func use_attack_potion():
	give_attack(1)
	Inventory["Attack Potion"] -= 1
	play_potion_animation()
	yield(get_tree().create_timer(.7), "timeout")
	emit_signal("turn_completed")

func use_health_potion():
	if (health == max_health):
		return false
	else:
		health += randi()%(level + 1) + 1
		if health > max_health:
			health = max_health
		Inventory["Health Potion"] -= 1
		update_heart()
		play_potion_animation()
		yield(get_tree().create_timer(.7), "timeout")
		emit_signal("turn_completed")
		return true

func play_potion_animation():
	player_animation.play("UsePotion")
	player_animation.queue("Idle")

func buy_item(Item):
	if (Inventory.get("Gold") < 2):
		print("Not enough Gold!")
	else:
		if (Item == "Attack Potion" or Item == "Health Potion"):
			deduct_gold(2)
			Inventory[Item] += 1
		else:
			print("Not valid item type")

func _on_enemy_attack(enemy_damage):
	print("Player damage took: ", enemy_damage)
	health -= enemy_damage
	if health <= 0:
		player_animation.play("Dying")
		update_heart()
		yield(get_tree().create_timer(wait_time), "timeout")
		emit_signal("player_death")
	else:
		player_animation.play("Hurt")
		player_animation.queue("Idle")
		yield(get_tree().create_timer(wait_time), "timeout")
		update_heart()

func revive_player():
	health = max_health
	update_heart()
	set_physics_process(true)
