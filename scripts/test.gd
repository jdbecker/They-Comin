#!/usr/bin/env -S godot -s
extends SceneTree

func _init() -> void:
	print("Hello world!")
	var result := test()
	quit(0 if result else 1)

func test() -> bool:
	return true
