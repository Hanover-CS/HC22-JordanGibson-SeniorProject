extends Node2D

export (int) var hp = 10
export (int) var damage = 1
export (int) var defense = .05
export (int) var speed = 1

signal player_attack(damage)
signal player_death()

onready var player_animation = $Sprite/AnimationPlayer

func _ready():
	player_animation.play("Idle")

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("player_attack", damage)
		player_animation.play("Slash")
		player_animation.queue("Idle")

func _on_enemy_attack(damage):
	hp -= damage
	if hp <= 0:
		player_animation.play("Dying")
		emit_signal("player_death")
	else:
		player_animation.play("Hurt")
		player_animation.queue("Idle")

func play_turn():
	emit_signal("player_attack", damage)
	player_animation.play("Slash")

func _on_player_attack(damage):
	pass # Replace with function body.
