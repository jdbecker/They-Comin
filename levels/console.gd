class_name Console
extends Node3D

@export var label_text: String = "Console" : set = _set_label_text
@export var ui_scene: PackedScene = preload("res://ui/Inventory.tscn")

@onready var label_3d: Label3D = $Label3D as Label3D


func _set_label_text(value: String) -> void:
	label_text = value
	
	if not is_node_ready():
		await ready
	
	label_3d.text = label_text
