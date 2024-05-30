class_name ScrapUI
extends HBoxContainer

@onready var scrap: Label = %Scrap


func _ready() -> void:
	Events.scrap_changed.connect(_refresh_scrap)
	_refresh_scrap()


func _refresh_scrap() -> void:
	scrap.text = str(Global.data.scrap)
