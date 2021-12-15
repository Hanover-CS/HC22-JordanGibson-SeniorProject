extends Sprite

export (int) var hp = 10
export (int) var damage = 1
export (int) var defense = .05

signal player_attack(damage)

onready var player_animation = $AnimationPlayer

func _ready():
	player_animation.play("Idle")

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("player_attack", damage)
		player_animation.play("Slash")
		player_animation.queue("Idle")

func _on_Glutmon_enemy_attack(damage):
	hp -= damage
	if hp <= 0:
		player_animation.play("Dying")
	else:
		player_animation.play("Hurt")
		player_animation.queue("Idle")
