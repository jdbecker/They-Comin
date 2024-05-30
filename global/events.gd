extends Node

signal menu_closed

signal scrap_changed
signal inventory_changed
signal equipped_gun_changed
signal window_state_changed(state: EntryWindow.STATE)

# debug panel
signal window_toggle_button_pressed(state: EntryWindow.STATE)
