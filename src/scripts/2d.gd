extends Node2D


signal HideState
signal HideStateInfo


const scene_types: Array = ["stacked", "grid"]
const hide_states: Array = ["default", "hide_all", "hide_other"]


@onready var viewport_scene: PackedScene = preload("res://scenes/viewport.tscn")
@onready var info_node: Node = $Info


var number_viewports: int = 1
var scene_type: String = ""
var scenes_viewport: Dictionary = {}
var hide_state: String = ""


func _ready() -> void:
	emit_signal("HideStateInfo", hide_states[0])
	create_viewports()


func create_viewports():
	if scene_type in scene_types:
		var first_scene: bool = true
		for i in range(1, number_viewports + 1):
			var vps = viewport_scene.instantiate()
			add_child(vps)
			var cm: int = vps.external_set_cull_mask3D(i, first_scene)
			if first_scene:
				vps.external_connect_feature_detect(info_node)
				first_scene = false
			if scene_type == "stacked":
				vps.external_set_position_stacked(i)
			elif scene_type == "grid":
				vps.external_set_position_grid(i)
			if cm > 0:
				if not scenes_viewport.has(cm):
					scenes_viewport[cm] = []
				scenes_viewport[cm].append(vps.external_get_3Dscene())
		for item in scenes_viewport.keys():
			for node in scenes_viewport[item]:
				if node != null:
					node.external_set_same_cull_nodes(
							item,
							scenes_viewport[item],
					)


func external_get_scene_type() -> String:
	return scene_type


func external_set_hide_state(state: String = ""):
	if state in hide_states:
		if state != hide_state:
			hide_state = state
			emit_signal("HideState", hide_state)
			var label_text: String = hide_states[0]
			if hide_state == hide_states[1]:
				label_text = "meshes_not_hidden"
			if hide_state == hide_states[2]:
				label_text = "meshes_hidden"
			emit_signal("HideStateInfo", label_text)

