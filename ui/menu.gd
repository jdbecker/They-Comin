class_name Menu extends Control

@onready var panel_container: PanelContainer = %PanelContainer
@onready var player_name: LineEdit = %PlayerName as LineEdit
@onready var address_entry: LineEdit = %AddressEntry as LineEdit


func _ready() -> void:
	player_name.text = Global.data.player_name


func _on_host_button_pressed() -> void:
	panel_container.hide()
	Lobby.host_game()


func _on_join_button_pressed() -> void:
	panel_container.hide()
	Lobby.join_game(address_entry.text)


func _on_player_name_text_changed(new_text: String) -> void:
	Global.data.player_name = new_text


func _on_player_name_focus_exited() -> void:
	Global.data.save_data()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func open() -> void:
	panel_container.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
