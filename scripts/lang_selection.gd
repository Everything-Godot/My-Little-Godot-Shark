extends Control

@onready var english_button: TextureButton = $EnglishButton
@onready var japanese_button: TextureButton = $JapaneseButton
@onready var chinese_button: TextureButton = $ChineseButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audios: AudioStreamPlayer = $Audios
@onready var talks: AudioStreamPlayer = $Talks
@onready var shark: AnimatedSprite2D = $SharkControl/Shark
@onready var shark_button: Button = $SharkControl/Shark/SharkButton
@onready var shark_idle_player: AnimationPlayer = $SharkIDLEPlayer
@onready var shark_anim_player: AnimationPlayer = $SharkAnimPlayer
@onready var advice_timer: Timer = $AdviceTimer
@onready var adapt_no_button: TextureButton = $StartGamePrompt/NoButton

var restore_chinese: bool = false
var restore_japanese: bool = false
var restore_english: bool = false

var click_counter: int = 0
var no_counter: int = 0

var min_button_pos: Vector2 = Vector2(0.0, 800.0)
var max_button_pos: Vector2 = Vector2(622.0, 1502.0)

var 滑走的音效: Array = [
	preload("uid://cvm7apr8mgu7v"),
	preload("uid://nqi0b0acynvn"),
	preload("uid://biihulnfelfa0"),
	preload("uid://dqnohf8td3mug"),
]

const 小鲨鱼被点击 = preload("uid://bawkxkdwd5v8c")
const 我觉得要不选中文吧_ = preload("uid://cbdtq71l4rp")
const 不要再点我啦 = preload("uid://b3gbwu1kis627")

func _ready() -> void:
	english_button.visible = true
	japanese_button.visible = true
	chinese_button.visible = true
	english_button.material.set_shader_parameter("dark_amount", 0)
	japanese_button.material.set_shader_parameter("dark_amount", 0)
	chinese_button.material.set_shader_parameter("dark_amount", 0)
	english_button.disabled = false
	japanese_button.disabled = false
	chinese_button.disabled = false
	shark.play("default")
	shark_idle_player.play("idle")

func _on_english_button_pressed() -> void:
	advice_timer.paused = true
	animation_player.play("English")
	if not japanese_button.disabled:
		japanese_button.disabled = true
		restore_japanese = true
	if not chinese_button.disabled:
		chinese_button.disabled = true
		restore_chinese = true
	await animation_player.animation_finished
	english_button.material.set_shader_parameter("dark_amount", 0.35)
	await talks.finished
	if restore_japanese:
		japanese_button.disabled = false
		restore_japanese = false
	if restore_chinese:
		chinese_button.disabled = false
		restore_chinese = false
	advice_timer.paused = false
	shark.play("default")

func _on_japanese_pressed() -> void:
	advice_timer.paused = true
	animation_player.play("Japanese")
	if not english_button.disabled:
		english_button.disabled = true
		restore_english = true
	if not chinese_button.disabled:
		chinese_button.disabled = true
		restore_chinese = true
	await animation_player.animation_finished
	japanese_button.material.set_shader_parameter("dark_amount", 0.35)
	await talks.finished
	if restore_english:
		english_button.disabled = false
		restore_english = false
	if restore_chinese:
		chinese_button.disabled = false
		restore_chinese = false
	advice_timer.paused = false
	shark.play("default")

func _on_chinese_button_pressed() -> void:
	shark_button.disabled = true
	advice_timer.paused = true
	animation_player.play("Chinese")
	await animation_player.animation_finished
	chinese_button.visible = false
	japanese_button.visible = false
	english_button.visible = false
	chinese_button.material.set_shader_parameter("dark_amount", 0.35)
	shark_anim_player.play("happy")
	await talks.finished
	shark.play("happy")

func _on_shark_button_pressed() -> void:
	if audios.playing: return
	if click_counter == 9:
		shark_button.disabled = true
		talks.stream = 不要再点我啦
		talks.play()
		shark.play("talk_with_tired")
		await talks.finished
		shark.play("tired")
		click_counter += 1
	elif click_counter < 9:
		audios.stream = 小鲨鱼被点击
		audios.play()
		shark_anim_player.play("be_clicked")
		await shark_anim_player.animation_finished
		click_counter += 1

func _on_advice_timer_timeout() -> void:
	var save = shark.animation
	talks.stream = 我觉得要不选中文吧_
	talks.play()
	shark.play("advise")
	if not english_button.disabled:
		english_button.disabled = true
		restore_english = true
	if not japanese_button.disabled:
		japanese_button.disabled = true
		restore_japanese = true
	if not chinese_button.disabled:
		chinese_button.disabled = true
		restore_chinese = true
	await talks.finished
	if restore_english:
		english_button.disabled = false
		restore_english = false
	if restore_japanese:
		japanese_button.disabled = false
		restore_japanese = false
	if restore_chinese:
		chinese_button.disabled = false
		restore_chinese = false
	shark.play(save)

func _on_adapt_yes_button_pressed() -> void:
	print("User agreed to adapt the shark")
	# TODO: Transition effect and bump to next game scene (WIP)

func _on_adapt_no_button_pressed() -> void:
	print("Disagree count: "+str(no_counter))
	if no_counter >= 7:
		adapt_no_button.disabled = true
		return
	adapt_no_button.disabled = true
	no_counter += 1
	var tween: Tween = get_tree().create_tween()
	var rand_x = randf_range(min_button_pos.x, max_button_pos.x)
	var rand_y = randf_range(min_button_pos.y, max_button_pos.y)
	var rand_pos: Vector2 = Vector2(rand_x, rand_y)
	print("Generated random position: "+str(rand_pos))
	tween.tween_property(adapt_no_button, "position", rand_pos, 0.75).set_trans(Tween.TRANS_LINEAR)
	audios.stream = 滑走的音效[randi_range(0, 3)]
	audios.play()
	await tween.finished
	adapt_no_button.disabled = false
