extends Node


@export_range(1, 64) var count_viewports_2D: int = 21


@onready var gui_scene: PackedScene = preload("res://scenes/gui.tscn")
@onready var scene2D: PackedScene = preload("res://scenes/2D.tscn")


var gui_node: CanvasItem = null
var stacked_node: CanvasItem = null
var grid_node: CanvasItem = null


var hide_state: String = "default"


func _ready() -> void:
	create_scene_gui()
	create_scene_stacked()
	create_scene_grid()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_released("escape", true):
		if gui_node != null:
			gui_node.queue_free()
		if stacked_node != null:
			stacked_node.queue_free()
		if grid_node != null:
			grid_node.queue_free()
		get_tree().quit()
	elif event.is_action_released("enter", true):
		toggle_view()
	elif event.is_action_released("space", true):
		toggle_hide()


func create_scene_gui():
	var gui = gui_scene.instantiate()
	add_child(gui)
	gui_node = gui
	gui_node.visible = true


func create_scene_stacked():
	var stacked = scene2D.instantiate()
	stacked.number_viewports = count_viewports_2D
	stacked.scene_type ="stacked"
	stacked_node = stacked


func create_scene_grid():
	var grid = scene2D.instantiate()
	grid.number_viewports = count_viewports_2D
	grid.scene_type ="grid"
	grid_node = grid


func toggle_view():
	if gui_node != null and stacked_node != null and grid_node != null:
		if gui_node.visible:
			gui_node.visible = false
			if not is_ancestor_of(stacked_node):
				add_child(stacked_node)
				stacked_node.external_set_hide_state(hide_state)
		elif is_ancestor_of(stacked_node):
			gui_node.visible = false
			remove_child(stacked_node)
			if not is_ancestor_of(grid_node):
				add_child(grid_node)
				grid_node.external_set_hide_state(hide_state)
		elif is_ancestor_of(grid_node):
			gui_node.visible = true
			remove_child(grid_node)


func toggle_hide():
	if stacked_node != null and grid_node != null:
		if is_ancestor_of(stacked_node) or is_ancestor_of(grid_node):
			var new_state: String = ""
			if hide_state == "default":
				new_state = "hide_all"
			elif hide_state == "hide_all":
				new_state = "hide_other"
			elif hide_state == "hide_other":
				new_state = "default"
			else:
				new_state = "default"
			hide_state = new_state
			if not is_ancestor_of(grid_node):
				stacked_node.external_set_hide_state(new_state)
			elif not is_ancestor_of(stacked_node):
				grid_node.external_set_hide_state(new_state)

