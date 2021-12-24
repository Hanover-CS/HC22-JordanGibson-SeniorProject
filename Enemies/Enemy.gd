extends Node2D

export (int) var health = 1
export (int) var damage = 1
export (int) var defense = 1
export (int) var speed = 1
export (int) var level = 1

signal attack_player(damage)

func play_turn():
	$Sprite/AnimationPlayer.play("Attack")
	emit_signal("attack_player", damage)
