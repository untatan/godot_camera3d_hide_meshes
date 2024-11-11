extends Sprite2D


@onready var sub_viewport: SubViewport = $SubViewport
@onready var sub_scene: Node3D = $"SubViewport/3d"


var cull_mask: int = 0


func connect_parent() -> void:
	var parent = get_parent()
	if parent != null:
		if parent.name == "2D":
			if parent.has_signal("HideState"):
				if not parent.HideState.is_connected(
						sub_scene._on_hide_state_change,
				):
					parent.HideState.connect(sub_scene._on_hide_state_change)


func external_set_cull_mask3D(cm: int = 0, first_scene: bool = false) -> int:
	var c: int = 0
	if cm > 0:
		c = sub_scene.external_set_cull_mask3D(cm, first_scene)
		cull_mask = c
	connect_parent()
	return c


func external_connect_feature_detect(node: Node = null):
	if node != null:
		sub_scene.external_connect_feature_detect(node)


func external_set_position_stacked(cm: int = 0):
	if cm > 0:
		var x = cm % 5
		var y = cm % 7
		global_position = Vector2(
			256 + (10 * x),
			256 + (5 * y),
		)


func external_set_position_grid(cm: int = 0):
	if cm > 0:
		var c = cm - 1
		var row = int(c / 5)
		var colon = c % 5
		sub_viewport.size = Vector2i(64, 64)
		global_position = Vector2(
				64 + (64 * colon),
				64 + (64 * row),
		)


func external_get_3Dscene() -> Node3D:
	return sub_scene

