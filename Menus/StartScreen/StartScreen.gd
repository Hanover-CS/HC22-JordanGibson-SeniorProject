# File : StartScreen.gd
# Created By : Jordan Gibson
# Last Updated : 2/15/2022
# Functionality : Simple start screen that initializes WorldSelect scene
extends Node2D

func _process(delta):
	# "ui_accept" == ENTER
	if (Input.is_action_just_pressed("ui_accept")):
		get_tree().change_scene("res://Menus/WorldSelect/WorldSelect.tscn")
