# 自动生成的 Scene 列表
# 生成时间: 2026-07-15T20:37:24
# 总计: 7 个文件

static func get_scene_paths() -> Array:
	return [
		"res:///scenes/apple.tscn",
		"res:///scenes/dragable_item.tscn",
		"res:///scenes/ending.tscn",
		"res:///scenes/game.tscn",
		"res:///scenes/lang_selection.tscn",
		"res:///scenes/logo.tscn",
		"res:///scenes/warning.tscn",
	]

static func get_scene_names() -> Array:
	var names = []
	for path in get_scene_paths():
		names.append(path.get_file().get_basename())
	return names

static func get_scene_dict() -> Dictionary:
	var dict = {}
	for path in get_scene_paths():
		dict[path.get_file().get_basename()] = path
	return dict

static func get_scene_path(name: String) -> String:
	return get_scene_dict().get(name, "")

static func exists(name: String) -> bool:
	return get_scene_dict().has(name)
