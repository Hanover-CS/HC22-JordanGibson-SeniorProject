extends "res://Enemies/Enemy.gd"

onready var animation = $Sprite/AnimationPlayer

func _ready():
	animation.play("Idle")
