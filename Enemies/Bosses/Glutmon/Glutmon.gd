extends "res://Enemies/Multiphase_Enemy.gd"

onready var FirstFormAnimation = $FirstForm/FirstFormAnimation
onready var SecondFormAnimation = $SecondForm/SecondFormAnimation
onready var ThirdFormAnimation = $ThirdForm/ThirdFormAnimation

var current_form = "FirstForm"
signal died()

func _ready():
	$FirstForm.visible = true
	$SecondForm.visible = false
	$ThirdForm.visible = false
	FirstFormAnimation.play("Idle")

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_up"):
		match current_form:
			"FirstForm":
				FirstFormAnimation.play("Attack")
				emit_signal("enemy_attack", damage)
				FirstFormAnimation.queue("Idle")
			"SecondForm":
				SecondFormAnimation.play("Attack")
				emit_signal("enemy_attack", damage)
				SecondFormAnimation.queue("Idle")
			"ThirdForm":
				ThirdFormAnimation.play("Attack")
				emit_signal("enemy_attack", damage)
				ThirdFormAnimation.queue("Idle")
	
	if health <= 0:
		die()
	
	if health <= 3 and current_form == "FirstForm":
		transform()
	
	elif health <= 2 and current_form == "SecondForm":
		transform_giant()

func transform():
	current_form = "SecondForm"
	$FirstForm.visible = false
	$SecondForm.visible = true
	SecondFormAnimation.play("Transform")
	SecondFormAnimation.queue("Idle")
	health = 5
	damage = 2
	speed = 2

func transform_giant():
	current_form = "ThirdForm"
	$SecondForm.visible = false
	$ThirdForm.visible = true
	ThirdFormAnimation.play("Transform")
	ThirdFormAnimation.queue("Idle")
	health = 6
	damage = 3
	speed = 1


#func _on_player_attack(damage):
#	take_damage(damage)
#	print(health)

func take_damage(damage):
	health -= damage
	match current_form:
		"FirstForm":
			FirstFormAnimation.play("Hurt")
			FirstFormAnimation.queue("Idle")
		"SecondForm":
			SecondFormAnimation.play("Hurt")
			SecondFormAnimation.queue("Idle")
		"ThirdForm":
			ThirdFormAnimation.play("Hurt")
			ThirdFormAnimation.queue("Idle")

func die():
	match current_form:
		"FirstForm":
			FirstFormAnimation.play("Dying")
		"SecondForm":
			SecondFormAnimation.play("Dying")
		"ThirdForm":
			ThirdFormAnimation.play("Dying")


func _on_Glutmon_died():
	queue_free()
