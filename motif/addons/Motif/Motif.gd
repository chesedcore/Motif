@tool
extends EditorPlugin

var type_queue: Array[String]

func _enable_plugin() -> void:
	# Add autoloads here.
	pass

func _disable_plugin() -> void:
	# Remove autoloads here.
	pass

func _enter_tree() -> void:
	add_custom_type("Arc", "Node2D", preload("res://addons/Motif/scripts/structs/arc.gd"), preload("res://addons/Motif/icons/arc.png"))

func _exit_tree() -> void:
	destroy_types()

func destroy_types() -> void:
	for type in type_queue:
		remove_custom_type(type)
