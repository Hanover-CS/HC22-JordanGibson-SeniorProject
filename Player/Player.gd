extends Node2D

export (int) var hp = 10
export (int) var damage = 1
export (int) var defense = .05
export (int) var speed = 1
export (int) var movement_speed = 100

var direction : Vector2
var screen_size = 1024

signal player_attack(damage)
signal player_death()

onready var player_animation = $Sprite/AnimationPlayer

func _ready():
	player_animation.play("Idle")

func _physics_process(delta):
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	global_position.x += direction.x * movement_speed * delta
	global_position.y += direction.y * movement_speed * delta
	
	if direction.x != 0 or direction.y != 0:
		if direction.x < 0:
			$Sprite.flip_h = true
		else:
			$Sprite.flip_h = false
		player_animation.play("Walk")
	else:
		player_animation.play("Idle")

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
