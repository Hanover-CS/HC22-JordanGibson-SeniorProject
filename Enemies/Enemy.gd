# File : Enemy.gd
# Created By : Jordan Gibson
# Last Update : 2/15/2022
# Functionality : Parent class from which all enemy instances will inherit,
#  allowing for easier creation of enemy sub-types

# Enemy base node
extends Area2D
# Stat Values
export (int) var health = 4
export (int) var damage = 1
export (int) var speed = 1
export (int) var level = 1
# Animation player and association aniimation wait_time variable
onready var animation = $Sprite/AnimationPlayer
onready var wait_time = 1.0
# Battling signals
signal enemy_attack(damage)
signal enemy_death()
signal turn_completed()
# Plays enemy idle animation on instancing, sets 'Level' label
func _ready():
	animation.play("Idle")
	$Level.text = "Lvl: " + str(level)
# Getters and Manipulators
func get_speed():
	return(speed)

func speed_up(SpeedAmount):
	speed += SpeedAmount

func get_health():
	return(health)

func health_up(HealthAmount):
	health += HealthAmount

func damage_up(DamageAmount):
	damage += DamageAmount
# Used to halt for enough time to allow for complete animation playing
func get_wait_time():
	return(wait_time)

func get_level():
	return(level)
# Used for easier sprite manipulation 
func get_sprite():
	return(get_node("Sprite"))

func play_turn():
	attack()

func attack():
	animation.play("Attack")
	animation.queue("Idle")
	# Wait for animation to finish before sending attacking signal
	yield(get_tree().create_timer(wait_time), "timeout")
	emit_signal("enemy_attack", damage)
	# Wait for player damage animation to finish before sending complete signal
	yield(get_tree().create_timer(1.0), "timeout")
	# Signal used to signal when to switch turns in Battle.gd
	emit_signal("turn_completed")
	
# Used to scale enemies to allow for increasing difficulty
# Parameters: NumLevels - how many levels said enemy needs to level up by
#			  printEnemyStats - Indicates whether enemy's new stats after
#				levelling should be printed to output panel <- DEBUGGING
func level_up(NumLevels : int, printEnemyStats : bool):
	if (NumLevels == 1):
		pass
	else:
		# One level deducted to account for initial starting level
		# Ensures player and enemy are the same level
		level += NumLevels - 1
		# Updates level label
		$Level.text = "Lvl: " + str(level)
		raise_stats(NumLevels - 1)
		if printEnemyStats:
			print("New stat values for level: " + str(level) + " '" + self.name + "' HP: " + str(health) + " Attack: " + str(damage) + " Speed: " + str(speed))

# Raises enemy stats according to player level
# Parameters: NumLevels - indicates player's current level
func raise_stats(NumLevels : int):
	# Enemy gains 1 damage every four player levels
	damage_up(NumLevels / 4)
	# Enemy gains 1 speed every three player levels
	speed_up(NumLevels / 3)
	# Enemy gains 1 health for every player level
	health_up(NumLevels)

# Handles damage calculation and animation playing upon player attack 
#   during battle
# Parameters : player_damage - Indicates attack of player
func _on_player_attack(player_attack):
	health -= player_attack
	# Checks to see if enemy was defeated
	if health <= 0:
		# Ensures that health is displayed as 0 if attack deals more damage than
		#  remaining health
		if health < 0:
			health = 0
		animation.play("Dying")
		# Update heart label show current health, 0 in this case
		update_heart()
		# Wait for 'Dying' animation to finish
		yield(get_tree().create_timer(wait_time), "timeout")
		# Alert battle that enemy has been defeated
		emit_signal("enemy_death")
	else:
		animation.play("Hurt")
		# Allow 'Hurt' animation to complete
		yield(get_tree().create_timer(wait_time), "timeout")
		# Update heart level to show current health
		update_heart()
		# Readies enemy to play Idle animation following completing of 
		#  hurt animation
		animation.queue("Idle")

# Updates heart label with current health value
func update_heart():
	var heart_label = get_node("Heart/Label")
	heart_label.text = ": " + str(health)
