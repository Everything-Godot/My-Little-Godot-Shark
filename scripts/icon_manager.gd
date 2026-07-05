extends Control
class_name IconManager

enum IconList {
	苹果,
	哑铃,
	灯泡,
	睡觉,
	垃圾桶,
	出门
}

func _ready() -> void:
	Console.add_command("activate_icon", activate_icon, ["icon"], true, "Activate specific icon.")
	var icon_list_param := [
		IconList.苹果,
		IconList.哑铃,
		IconList.灯泡,
		IconList.睡觉,
		IconList.垃圾桶,
		IconList.出门
	]
	Console.add_command_autocomplete_list("activate_icon", icon_list_param)

func activate_icon(icon: IconList) -> void:
	Global.print_info("Activating icon " + str(icon), self)
