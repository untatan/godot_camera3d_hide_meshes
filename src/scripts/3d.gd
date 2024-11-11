extends Node3D


signal FeatureDetection


const light_cull_0: int = 4293918720


@onready var meshinstance: MeshInstance3D = $MeshInstance3D
@onready var camera: Camera3D = $Camera3D
@onready var light: SpotLight3D = $SpotLight3D
@onready var label: Label3D = $MeshInstance3D/Label3D
@onready var area: Area3D = $Area3D


var cull_mask: int = 1
var speed: int = 1
var delta_time: float = 0.0
var something_done_once: bool = false
var other_nodes: Array = []


func _process(delta: float) -> void:
	delta_time += delta
	if area.has_overlapping_areas():
		meshinstance.global_rotate(
				Vector3(0.0, 1.0, 0.0),
				deg_to_rad(delta * float(speed)),
		)
	if delta_time > 1.0 and not something_done_once:
		something_done_once = true
		#do_something_once()


func do_something_once():
	var camera_properties = camera.get_property_list()
	for item in camera_properties:
		if item.name == "meshes_not_hidden":
			camera.meshes_not_hidden.clear()
			camera.meshes_not_hidden.append(123)


func set_cull_mask_layer(number: int = 0) -> int:
	label.text = str(number)
	speed = number
	var cm = number % 20
	if cm == 0:
		cm = 20
	light.light_cull_mask = light_cull_0
	for i in range(1, 21):
		if i == cm:
			var bit = (2 ** (i - 1)) + light_cull_0
			light.light_cull_mask = bit
			meshinstance.set_layer_mask_value(i, true)
			label.set_layer_mask_value(i, true)
			camera.set_cull_mask_value(i, true)
			light.set_layer_mask_value(i, true)
		else:
			meshinstance.set_layer_mask_value(i, false)
			label.set_layer_mask_value(i, false)
			camera.set_cull_mask_value(i, false)
			light.set_layer_mask_value(i, false)
	return cm


func only_show_this_mesh(clear: bool = true):
	var camera_properties = camera.get_property_list()
	var detected: bool = false
	for item in camera_properties:
		if item.name == "meshes_not_hidden":
			detected = true
			if clear:
				camera.meshes_not_hidden = []
			else:
				camera.meshes_not_hidden = [get_mesh_rid()]
			break
	emit_signal("FeatureDetection", "meshes_not_hidden", detected)


func hide_other_meshes(clear: bool = true):
	var camera_properties = camera.get_property_list()
	var detected: bool = false
	for item in camera_properties:
		if item.name == "meshes_hidden":
			detected = true
			camera.meshes_hidden = []
			if not clear:
				var mesh_rids: Array = []
				for node in other_nodes:
					if node != null:
						if node != self:
							mesh_rids.append(node.external_get_mesh_rid())
				camera.meshes_hidden = mesh_rids
			break
	emit_signal("FeatureDetection", "meshes_hidden", detected)


func get_mesh_rid() -> RID:
	return meshinstance.mesh.get_rid()


func external_get_mesh_rid() -> RID:
	return get_mesh_rid()


func external_set_cull_mask3D(cm: int = 0, first_scene: bool = false) -> int:
	if not first_scene:
		# until light cull mask for moving objects is fixed (4.4 ?)
		var renderer = ProjectSettings.get_setting(
				"rendering/renderer/rendering_method"
		)
		if renderer in  ["gl_compatibility", "mobile"]:
			light.visible = false
	if cm > 0:
		cull_mask = set_cull_mask_layer(cm)
	return cull_mask


func external_set_same_cull_nodes(
		cm: int = 0,
		scenes: Array = [],
):
	if cull_mask > 0:
		if cull_mask == cm:
			if not scenes.is_empty() and other_nodes.is_empty():
				for item in scenes:
					if item != null:
						if item != self:
							other_nodes.append(item)


func external_connect_feature_detect(node: Node = null):
	if node != null:
		if not FeatureDetection.is_connected(
			node._on_feature_report,
		):
			FeatureDetection.connect(node._on_feature_report)


func _on_hide_state_change(new_state: String = ""):
	if new_state == "hide_all":
		hide_other_meshes(true)
		only_show_this_mesh(false)
	elif new_state == "hide_other":
		only_show_this_mesh(true)
		hide_other_meshes(false)
	else:
		only_show_this_mesh(true)
		hide_other_meshes(true)

