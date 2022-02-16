# File : Player.gd
# Created By : Jordan Gibson
# Last Updated : 2/15/2022
# Functionality : Player object that allows for world interaction <- Battling and 
#  purchasing from store

extends KinematicBody2D

# Stat Attributes
export (int) var health = 10
export (int) var damage = 1
export (int) var speed = 1
export (int) var movement_speed = 100

# Starter Inventory
var Inventory : Dictionary = {"Attack Potion" : 1, "Health Potion" : 4, "Gold": 0}

var level : int = 1
var max_health : int = 10
var xp_threshold : int = 3
var currXP : int = 0

var wait_time : float = .7

# Used for movement inputs
var direction : Vector2

# Battle signals
signal player_attack(damage)
signal player_death()
signal turn_completed()

onready var player_animation = $Sprite/AnimationPlayer

# Ensures that all character labels match current health, inventory, and level
func _ready():
	update_heart()
	update_gold()
	update_level()

# Movement function, enabled or disabled to allow player to move or not move
func _physics_process(delta):
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	# Moves player until they collide with an object <- Tile in tileMap or Enemy
	move_and_collide(Vector2(direction.x * movement_speed * delta, direction.y * movement_speed * delta))
	# Flips player sprite depending on if they are going left or right
	if direction.x != 0 or direction.y != 0:
		if direction.x < 0:
			$Sprite.flip_h = true
		else:
			$Sprite.flip_h = false
		player_animation.play("Walk")
	else:
		player_animation.play("Idle")

#############################################################
				## Getters and Manipulators ##
#############################################################
func get_speed():
	return(speed)

func give_speed(Speed):
	speed += Speed

func get_health():
	return(health)

func check_if_health_max():
	return(health == max_health)

func give_health(Health):
	max_health += Health
	health = max_health
	# Ensures that player heart counter is displaying correct amount
	update_heart()

func give_attack(Attack):
	damage += Attack

func get_attack():
	return(damage)

# Used to subtract temporary health gained from use of Attack Potions
func deduct_attack(attack):
	damage -= attack

func get_level():
	return(level)

func get_potion_count(PotionType):
	match PotionType:
		"Attack Potion":
			return(Inventory["Attack Potion"])
		"Health Potion":
			return(Inventory["Health Potion"])

func get_gold():
	return(Inventory["Gold"])

func give_gold(Gold):
	Inventory["Gold"] += Gold
	update_gold()

# Used for shop purchases
func deduct_gold(Gold):
	Inventory["Gold"] -= Gold
	update_gold()

func get_wait_time():
	return(wait_time)

# Label Updaters
func update_heart():
	var heart_label = get_node("Heart/Label")
	heart_label.text = ": " + str(health)

func update_gold():
	var gold_label = get_node("Gold/Label")
	gold_label.text = ": " + str(Inventory["Gold"])

func update_level():
	$Level.text = "Lvl: " + str(level)


# Allows for easier sprite manipulation
func get_sprite():
	return(get_node("Sprite"))

func give_XP(XP):
	currXP += XP
	check_for_level_up()

func check_for_level_up():
	if (currXP >= xp_threshold):
		level_up()
	else:
		pass

# Increases player level and spawns attribute screen for player to select attribute to upgrade
func level_up():
	# Refills player's health to full upon level up
	level += 1
	# Increased XP threshold
	xp_threshold = xp_threshold + floor(xp_threshold * .5)
	currXP = 0
	update_level()
	display_stat_select_screen()

# Brings up screen from which the player can choose a stat to upgrade upon level up
func display_stat_select_screen():
	var level_up_scene = load("res://Player/Level Up Screen/LevelUp.tscn")
	var level_up = level_up_scene.instance()
	level_up.rect_scale = Vector2(1.5, 1.5)
	add_child(level_up)

# Allows player to buy item from shop when appropriate button pressed in shop scene
# Parameters : Item - String sent from button press denoting item type to be purchased
func buy_item(Item : String):
	# Checks to see if player has enough gold
	if (Inventory.get("Gold") < 2):
		print("Not enough Gold!")
	else:
		if (Item == "Attack Potion" or Item == "Health Potion"):
			deduct_gold(2)
			Inventory[Item] += 1
		else:
			print("Not valid item type")

############################################################
				## Battle Methods ##
############################################################
# Starts battle if player collides with enemy
func _on_Knight_area_entered(area):
	if (area.is_in_group("enemy")):
		player_animation.stop()
		get_parent().start_battle(self, area)

func attack():
	player_animation.play("Slash")
	yield(get_tree().create_timer(wait_time), "timeout")
	emit_signal("player_attack", damage)
	yield(get_tree().create_timer(1.0), "timeout")
	emit_signal('turn_completed')

# Calls appropriate use function for potion and returns if respective potion was used
#   or not <- Health potion not used when at max health
func use_potion(PotionType : String):
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
	# Does not allow a player to use when at max health
	if (health == max_health):
		return false
	else:
		# Chooses a random heal amount based on level
		health += randi()%(level + 1) + 1
		# Brings players health back down to max if max surpassed
		if health > max_health:
			health = max_health
		Inventory["Health Potion"] -= 1
		# Ensures that heart label matches new healed HP
		update_heart()
		play_potion_animation()
		yield(get_tree().create_timer(.7), "timeout")
		# Only emits turn_completed signal after potion is used (When HP != Max)
		emit_signal("turn_completed")
		return true

func play_potion_animation():
	player_animation.play("UsePotion")
	player_animation.queue("Idle")

# Method used upon enemy emitting attack signal in battle, handles hurt and dying animation
# Parameters : enemy_damage - Integer denoting enemy attack
func _on_enemy_attack(enemy_damage : int):
	print("Player damage took: ", enemy_damage)
	health -= enemy_damage
	if health <= 0:
		# Ensures that health label does not display as negative
		health = 0
		player_animation.play("Dying")
		# Ensures that player health is changed to reflect 0 health
		update_heart()
		yield(get_tree().create_timer(wait_time), "timeout")
		emit_signal("player_death")
	else:
		player_animation.play("Hurt")
		player_animation.queue("Idle")
		yield(get_tree().create_timer(wait_time), "timeout")
		# Ensures that player health is changed to reflect lowered health
		update_heart()

# Resets players health to full and enable movement process
func revive_player():
	health = max_health
	update_heart()
	set_physics_process(true)
