@tool
extends Node

# 配置选项
@export_group("扫描设置")
@export var include_subdirectories: bool = true
@export var skip_import_folders: bool = true
@export var output_folder: String = "res://"
@export var max_files: int = 1000  # 安全限制，防止无限循环

@export_group("文件类型")
@export var include_scenes: bool = true
@export var include_mp3s: bool = true
@export var include_wavs: bool = false
@export var include_oggs: bool = false
@export var custom_extensions: Array[String] = []

# 按钮
@export_tool_button("生成资源列表", "FileSave")
var generate_action = _generate_all_lists

@export_tool_button("仅生成场景列表", "Scene")
var generate_scenes_only_action = _generate_scenes_only

@export_tool_button("仅生成音频列表", "AudioStreamMP3")
var generate_audio_only_action = _generate_audio_only

@export_tool_button("清除生成的文件", "Remove")
var clear_action = _clear_generated_files

func _generate_all_lists():
	print("=== 开始生成所有资源列表 ===")
	
	var scene_list: Array = []
	var mp3_list: Array = []
	var wav_list: Array = []
	var ogg_list: Array = []
	var custom_list: Array = []
	
	# 使用更安全的扫描方式
	if include_scenes:
		scene_list = _generate_file_list_safe(".tscn")
		print("找到 " + str(scene_list.size()) + " 个场景")
	
	if include_mp3s:
		mp3_list = _generate_file_list_safe(".mp3")
		print("找到 " + str(mp3_list.size()) + " 个 MP3")
	
	if include_wavs:
		wav_list = _generate_file_list_safe(".wav")
		print("找到 " + str(wav_list.size()) + " 个 WAV")
	
	if include_oggs:
		ogg_list = _generate_file_list_safe(".ogg")
		print("找到 " + str(ogg_list.size()) + " 个 OGG")
	
	for ext in custom_extensions:
		if not ext.is_empty():
			var custom_files = _generate_file_list_safe(ext)
			custom_list.append_array(custom_files)
			print("找到 " + str(custom_files.size()) + " 个 " + ext + " 文件")
	
	# 保存列表
	if include_scenes and scene_list.size() > 0:
		_save_resource_list(scene_list, "scene_list.gd", "Scene")
	
	if include_mp3s and mp3_list.size() > 0:
		_save_resource_list(mp3_list, "mp3_list.gd", "MP3")
	
	if include_wavs and wav_list.size() > 0:
		_save_resource_list(wav_list, "wav_list.gd", "WAV")
	
	if include_oggs and ogg_list.size() > 0:
		_save_resource_list(ogg_list, "ogg_list.gd", "OGG")
	
	if custom_list.size() > 0:
		_save_resource_list(custom_list, "custom_resources_list.gd", "Custom")
	
	print("=== 资源列表生成完成 ===")

func _generate_scenes_only():
	print("=== 生成场景列表 ===")
	var scene_list = _generate_file_list_safe(".tscn")
	print("找到 " + str(scene_list.size()) + " 个场景")
	_save_resource_list(scene_list, "scene_list.gd", "Scene")
	print("✅ 场景列表已生成")

func _generate_audio_only():
	print("=== 生成音频列表 ===")
	var all_audio: Array = []
	
	if include_mp3s:
		var mp3_list = _generate_file_list_safe(".mp3")
		all_audio.append_array(mp3_list)
		print("找到 " + str(mp3_list.size()) + " 个 MP3")
	
	if include_wavs:
		var wav_list = _generate_file_list_safe(".wav")
		all_audio.append_array(wav_list)
		print("找到 " + str(wav_list.size()) + " 个 WAV")
	
	if include_oggs:
		var ogg_list = _generate_file_list_safe(".ogg")
		all_audio.append_array(ogg_list)
		print("找到 " + str(ogg_list.size()) + " 个 OGG")
	
	_save_resource_list(all_audio, "audio_list.gd", "Audio")
	print("✅ 音频列表已生成")

func _clear_generated_files():
	print("=== 清除生成的文件 ===")
	
	var files_to_delete = [
		"scene_list.gd",
		"mp3_list.gd",
		"wav_list.gd",
		"ogg_list.gd",
		"audio_list.gd",
		"custom_resources_list.gd"
	]
	
	var deleted_count = 0
	for filename in files_to_delete:
		var path = output_folder + "/" + filename
		if FileAccess.file_exists(path):
			var dir = DirAccess.open(output_folder)
			if dir:
				var err = dir.remove(filename)
				if err == OK:
					deleted_count += 1
					print("已删除: " + filename)
	
	print("✅ 已删除 " + str(deleted_count) + " 个文件")

# 安全的文件列表生成 - 使用迭代而不是递归
func _generate_file_list_safe(extension: String) -> Array:
	var files: Array = []
	var dir_stack: Array = []
	
	# 从根目录开始
	var root_dir = DirAccess.open("res://")
	if not root_dir:
		print("ERROR: 无法打开 res://")
		return files
	
	dir_stack.append({"dir": root_dir, "path": "res://"})
	
	var processed_files = 0
	
	while dir_stack.size() > 0 and processed_files < max_files:
		var current = dir_stack.pop_back()
		var dir = current["dir"]
		var base_path = current["path"]
		
		dir.list_dir_begin()
		var item = dir.get_next()
		
		while item != "" and processed_files < max_files:
			if item != "." and item != "..":
				var full_path = base_path + "/" + item
				
				if dir.current_is_dir():
					# 检查是否应该跳过此目录
					if not _should_skip_directory(item):
						var sub_dir = DirAccess.open(full_path)
						if sub_dir:
							dir_stack.append({"dir": sub_dir, "path": full_path})
				else:
					# 检查文件
					if not _should_skip_file(full_path):
						if item.to_lower().ends_with(extension):
							files.append(full_path)
							processed_files += 1
			
			item = dir.get_next()
		
		dir.list_dir_end()
		
		# 每处理100个文件打印一次进度
		if processed_files % 100 == 0 and processed_files > 0:
			print("已扫描 " + str(processed_files) + " 个文件...")
	
	if processed_files >= max_files:
		print("WARNING: 达到最大文件限制 (" + str(max_files) + ")，可能未扫描完所有文件")
	
	print("扫描完成: " + str(processed_files) + " 个文件")
	return files

func _should_skip_directory(dir_name: String) -> bool:
	if skip_import_folders:
		if dir_name == ".import" or dir_name == ".git" or dir_name == ".godot":
			return true
		if dir_name.begins_with("."):
			return true
	return false

func _should_skip_file(file_path: String) -> bool:
	if skip_import_folders:
		if file_path.contains(".import"):
			return true
		# 跳过 .gdignore 文件
		if file_path.get_file() == ".gdignore":
			return true
	return false

func _save_resource_list(list: Array, filename: String, resource_type: String):
	# 去重
	list = _deduplicate_array(list)
	
	var content = ""
	content += "# 自动生成的 " + resource_type + " 列表\n"
	content += "# 生成时间: " + Time.get_datetime_string_from_system() + "\n"
	content += "# 总计: " + str(list.size()) + " 个文件\n\n"
	
	# 路径列表
	content += "static func get_" + resource_type.to_lower() + "_paths() -> Array:\n"
	content += "\treturn [\n"
	
	list.sort()
	for path in list:
		content += "\t\t\"" + path + "\",\n"
	
	content += "\t]\n\n"
	
	# 名称列表
	content += "static func get_" + resource_type.to_lower() + "_names() -> Array:\n"
	content += "\tvar names = []\n"
	content += "\tfor path in get_" + resource_type.to_lower() + "_paths():\n"
	content += "\t\tnames.append(path.get_file().get_basename())\n"
	content += "\treturn names\n\n"
	
	# 字典
	content += "static func get_" + resource_type.to_lower() + "_dict() -> Dictionary:\n"
	content += "\tvar dict = {}\n"
	content += "\tfor path in get_" + resource_type.to_lower() + "_paths():\n"
	content += "\t\tdict[path.get_file().get_basename()] = path\n"
	content += "\treturn dict\n\n"
	
	# 根据名称获取路径
	content += "static func get_" + resource_type.to_lower() + "_path(name: String) -> String:\n"
	content += "\treturn get_" + resource_type.to_lower() + "_dict().get(name, \"\")\n\n"
	
	# 检查是否存在
	content += "static func exists(name: String) -> bool:\n"
	content += "\treturn get_" + resource_type.to_lower() + "_dict().has(name)\n"
	
	var file = FileAccess.open(output_folder + "/" + filename, FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()
		print("已保存: " + output_folder + "/" + filename)
	else:
		print("ERROR: 无法保存: " + output_folder + "/" + filename)

func _deduplicate_array(arr: Array) -> Array:
	var result: Array = []
	var seen: Dictionary = {}
	
	for item in arr:
		if not seen.has(item):
			seen[item] = true
			result.append(item)
	
	return result
