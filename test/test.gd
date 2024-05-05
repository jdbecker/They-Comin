extends MainLoop

func _init() -> void:
	print("Hello world!")
	assert(true, "Passed a test")
	assert(false, "Failed a test")
	print("Done running tests")
