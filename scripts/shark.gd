extends AnimatedSprite2D

@onready var shark_talks: AudioStreamPlayer = $"../SharkTalks"
@onready var game: Node2D = $".."

enum 状态 {
	无 = 0,
	开心 = 1,
	期待 = 2
}

@export var 当前状态: 状态:
	set(value):
		当前状态 = value
		Global.print_info("状态 changed to: " + enum_to_string(value), self)

func enum_to_string(enum_value: 状态) -> String:
	match enum_value:
		状态.无:
			return "无"
		状态.开心:
			return "开心"
		状态.期待:
			return "期待"
		_:
			return "无"

func _ready() -> void:
	当前状态 = 状态.无
	var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "scale", Vector2(6.7, 6.7), 1)
	tween.tween_property(self, "scale", Vector2(6.5, 6.5), 1)
	tween.set_loops()

func _process(_delta: float) -> void:
	if not game.shark_eating:
		if shark_talks.playing:
			match 当前状态:
				状态.无:
					play_anim("说话")
				状态.开心:
					play_anim("开心的说话")
				状态.期待:
					play_anim("期待的说话")
				_:
					play_anim("说话")
		else:
			match 当前状态:
				状态.无:
					play_anim("default")
				状态.开心:
					play_anim("default")
				状态.期待:
					play_anim("期待")
				_:
					play_anim("default")

func play_anim(Anim_name: StringName) -> void:
	if animation != Anim_name:
		play(Anim_name)
