extends Node

var force_command: bool = false
var ending: int = 0
var ending_sprite: AtlasTexture = null
var ending_title: AtlasTexture = null
var ending_audio: AudioStreamMP3 = null
var return_from_ending: bool = false
var audio_seek: float = 0.0
var player: AudioStreamPlayer = null
var paused_players: Array = []
var paused_timers: Array = []

func _ready() -> void:
	Console.add_command("go_to_scene", get_to_scene, ["scene_path"], true, "Change scene to specific one")
	Console.add_command_autocomplete_list("go_to_scene", find_files(".tscn"))
	Console.add_command("play_audio", play_audio, ["audio_path"], true, "Play specific audio file")
	Console.add_command_autocomplete_list("play_audio", find_files(".mp3"))

func find_files(extension: String, path: String = "res://") -> Array:
	var files: Array = []
	var dir = DirAccess.open(path)
	
	if not dir:
		Global.print_error("无法打开目录: " + path, self)
		return files
	
	dir.list_dir_begin()
	var item = dir.get_next()
	
	while item != "":
		if item != "." and item != "..":
			var full_path = path + "/" + item
			
			if dir.current_is_dir():
				var sub_files = find_files(extension, full_path)
				files.append_array(sub_files)
			else:
				if item.to_lower().ends_with(extension):
					files.append(full_path)
		
		item = dir.get_next()
	
	dir.list_dir_end()
	if len(files) > 0:
		Global.print_info("Find " + str(len(files)) + " files in " + path + " with extension " + extension, self)
	return files

func get_to_scene(scene: String) -> void:
	if FileAccess.file_exists(scene):
		print_info("Changing scene to " + scene, self)
		get_tree().change_scene_to_file(scene)

func force_play(end: String) -> void:
	force_command = true
	print_info("Try to play ending "+str(end), self)
	ending = int(end)
	match ending:
		11:
			ending_sprite = load("res://textures/endings/11/logo.tres")
			ending_title = load("res://textures/endings/11/title.tres")
			ending_audio = load("res://media/普通结局BGM.mp3")
			get_tree().change_scene_to_file("res://scenes/ending.tscn")
		_:
			print_warning("Ending "+str(ending)+" not found!", self)

func play_ending(end: int) -> void:
	ending = end
	match ending:
		11:
			ending_sprite = load("res://textures/endings/11/logo.tres")
			ending_title = load("res://textures/endings/11/title.tres")
			ending_audio = load("res://media/普通结局BGM.mp3")
			get_tree().change_scene_to_file("res://scenes/ending.tscn")
		_:
			print_warning("Ending "+str(ending)+" not found!", self)

func pause_all_audio_players(node: Node = get_tree().root):
	for child in node.get_children():
		if child is AudioStreamPlayer or child is AudioStreamPlayer2D or child is AudioStreamPlayer3D:
			if not child.stream_paused:
				paused_players.append(child)
				child.stream_paused = true
		if child.get_child_count() > 0:
			pause_all_audio_players(child)

func pause_all_timers(node: Node = get_tree().root):
	for child in node.get_children():
		if child is Timer:
			if not child.paused:
				paused_timers.append(child)
				child.paused = true
		if child.get_child_count() > 0:
			pause_all_timers(child)

func play_audio(path: String) -> void:
	if not FileAccess.file_exists(path): return
	if player is AudioStreamPlayer:
		print_warning("Already has player, deleting it", self)
		player.queue_free()
	pause_all_audio_players()
	pause_all_timers()
	print_info("Created paused_players array: " + str(paused_players), self)
	print_info("Created paused_timers array: " + str(paused_timers), self)
	player = AudioStreamPlayer.new()
	add_child(player)
	print_info("AudioStreamPlayer created: " + str(player.get_path()), self)
	var audio: AudioStreamMP3 = load(path)
	player.stream = audio
	print_info("Audio " + path + " loaded, length " + str(audio.get_length()) + "s", self)
	player.finished.connect(_on_player_finished)
	player.play()
	print_info("Start playing audio", self)

func _on_player_finished() -> void:
	print_info("Audio finished playing, resume all paused players", self)
	for audio_player in paused_players:
		audio_player.stream_paused = false
	for timer in paused_timers:
		timer.paused = false
	print_info("Deleting player", self)
	player.queue_free()
	print_info("Done", self)

func print_info(msg: Variant, where: Node) -> void:
	print(format_string("info", where, str(msg)))
	Console.print_info(format_string_console(where, str(msg)))

func print_warning(msg: Variant, where: Node) -> void:
	print(format_string("warn", where, str(msg)))
	push_warning(str(msg))
	Console.print_warning(format_string_console(where, str(msg)))

func print_error(msg: Variant, where: Node) -> void:
	print(format_string("error", where, str(msg)))
	push_error(str(msg))
	Console.print_error(format_string_console(where, str(msg)))

func format_string(type: String, where: Node, content: String) -> String:
	return "[" + type.to_upper() + "] [" + where.get_script().resource_path + "] " + content 

func format_string_console(where: Node, content: String) -> String:
	return where.get_script().resource_path.get_file().get_basename().to_upper() + ": " + content
