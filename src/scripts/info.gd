extends CanvasLayer


@onready var label_scene: Label = $MarginContainer/VBoxContainer/LabelScene
@onready var label_hide: Label = $MarginContainer/VBoxContainer/LabelHide


var features_detected: Array = []
var features_not_detected: Array = []


func _ready() -> void:
	var parent = get_parent()
	if parent != null:
		if parent.name == "2D":
			label_scene.text = parent.external_get_scene_type()
			if parent.has_signal("HideStateInfo"):
				if not parent.HideStateInfo.is_connected(
						_on_hide_state_info_change,
				):
					parent.HideStateInfo.connect(_on_hide_state_info_change)


func _on_hide_state_info_change(info: String = "") -> void:
	if info != "":
		if info in features_detected:
			label_hide.text = "property: " + info
			label_hide.label_settings.font_color = Color.GREEN
		elif info in features_not_detected:
			label_hide.text = "property: " + info
			label_hide.label_settings.font_color = Color.RED
		else:
			label_hide.text = info
			label_hide.label_settings.font_color = Color.WHITE


func _on_feature_report(feature: String = "", detected: bool = false) -> void:
	if feature != "":
		if detected:
			if not feature in features_detected:
				features_detected.append(feature)
		else:
			if not feature in features_not_detected:
				features_not_detected.append(feature)

