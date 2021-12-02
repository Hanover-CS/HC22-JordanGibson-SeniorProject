extends "res://Enemies/Enemy.gd"

onready var FirstFormAnimation = $FirstForm/FirstFormAnimation
onready var SecondFormAnimation = $SecondForm/SecondFormAnimation
onready var ThirdFormAnimation = $ThirdForm/ThirdFormAnimation

var current_form = "FirstForm"

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
				FirstFormAnimation.queue("Idle")
			"SecondForm":
				SecondFormAnimation.play("Attack")
				SecondFormAnimation.queue("Idle")
			"ThirdForm":
				ThirdFormAnimation.play("Attack")
				ThirdFormAnimation.queue("Idle")
	
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
	health = 8
	damage = 2

func transform_giant():
	current_form = "ThirdForm"
	$SecondForm.visible = false
	$ThirdForm.visible = true
	ThirdFormAnimation.play("Transform")
	ThirdFormAnimation.queue("Idle")
	health = 10
	damage = 3


func _on_Knight_Sprite_Sheet_player_attack(damage):
	take_damage(damage) # Replace with function body.

func take_damage(damage):
	health -= damage
	match current_form:
		"FirstForm":
			FirstFormAnimation.play("")
