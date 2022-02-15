extends Node2D

export (int) var health = 4
export (int) var damage = 1
export (int) var defense = 1
export (int) var speed = 1
export (int) var level = 1

onready var animation = $Sprite/AnimationPlayer
onready var wait_time = 1.0

signal enemy_attack(damage)
signal enemy_death()
signal turn_completed()

func _ready():
	animation.play("Idle")
	$Level.text = "Lvl: " + str(level)

func get_speed():
	return(speed)

func get_health():
	return(health)

func get_wait_time():
	return(wait_time)

func get_level():
	return(level)

func play_turn():
	attack()

func attack():
	animation.play("Attack")
	animation.queue("Idle")
	yield(get_tree().create_timer(wait_time), "timeout")
	emit_signal("enemy_attack", damage)
	yield(get_tree().create_timer(1.0), "timeout")
	emit_signal("turn_completed")

func update_heart():
	var heart_label = get_node("Heart/Label")
	heart_label.text = ": " + str(health)

func level_up(NumLevels : int):
	if (NumLevels == 1):
		pass
	else:
		level += NumLevels
		$Level.text = "Lvl: " + str(level)
		damage_up(NumLevels / 2)
		speed_up(NumLevels / 3)
		health_up(NumLevels)
		print("New stat values for level: " + str(level) + " '" + self.name + "' HP: " + str(health) + " Attack: " + str(damage) + " Speed: " + str(speed))

func damage_up(DamageAmount):
	damage += DamageAmount

func speed_up(SpeedAmount):
	speed += SpeedAmount

func health_up(HealthAmount):
	health += HealthAmount

func _on_player_attack(player_damage):
	health -= player_damage
	if health <= 0:
		animation.play("Dying")
		update_heart()
		yield(get_tree().create_timer(.5), "timeout")
		emit_signal("enemy_death")
	else:
		animation.play("Hurt")
		yield(get_tree().create_timer(wait_time), "timeout")
		update_heart()
		animation.queue("Idle")
