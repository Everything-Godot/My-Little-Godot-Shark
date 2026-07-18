extends Node2D

@onready var icon_manager: IconManager = $IconManager
@onready var shark: AnimatedSprite2D = $Shark

var shark_eating: bool = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().name.contains("APPLE") or area.get_parent().name.contains("@RigidBody2D@"):
		Global.print_info("Shark ate " + area.get_parent().name, self)
		icon_manager.dragable_list.erase(area)
		area.get_parent().queue_free()
		shark_eating = true
		var original_animation = shark.animation
		var target_animation = get_animation_based_on_shark_emotion()
		icon_manager.allow_drag = false
		if icon_manager.tutorial_phase:
			icon_manager.tutorial_phase = false
			icon_manager.first_apple = null
			$Hand.visible = false
		shark.play(target_animation)
		Global.print_info("Play shark eating animation named " + target_animation + " twice based on current emotion.", self)
		await shark.animation_looped
		shark.play(target_animation)
		await shark.animation_looped
		shark.play(original_animation)
		Global.print_info("Done!", self)
		icon_manager.allow_drag = true
		shark_eating = false

func get_animation_based_on_shark_emotion() -> StringName:
	match shark.当前状态:
		shark.状态.无:
			return "说话"
		shark.状态.开心:
			return "开心的说话"
		shark.状态.期待:
			return "期待的说话"
		_:
			return "说话"
