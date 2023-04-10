extends Node

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	
	# set up FMOD
	Fmod.set_software_format(0, Fmod.FMOD_SPEAKERMODE_STEREO, 0)
	Fmod.init(1024, Fmod.FMOD_STUDIO_INIT_LIVEUPDATE, Fmod.FMOD_INIT_NORMAL)
	Fmod.set_sound_3D_settings(1.0, 32.0, 1.0)
	Fmod.set_listener_number(2)
	
	# load banks
# warning-ignore:return_value_discarded
	Fmod.load_bank("res://assets/Banks/Master.strings.bank", Fmod.FMOD_STUDIO_LOAD_BANK_NORMAL)
# warning-ignore:return_value_discarded
	Fmod.load_bank("res://assets/Banks/Master.bank", Fmod.FMOD_STUDIO_LOAD_BANK_NORMAL)
# warning-ignore:return_value_discarded
	Fmod.load_bank("res://assets/Banks/Music.bank", Fmod.FMOD_STUDIO_LOAD_BANK_NORMAL)
# warning-ignore:return_value_discarded
	Fmod.load_bank("res://assets/Banks/Vehicles.bank", Fmod.FMOD_STUDIO_LOAD_BANK_NORMAL)
	print("Fmod initialised.")


func _on_reload_scene_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/FmodScriptTest.tscn")


func _on_change_to_other_scene_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/OtherScene.tscn")
