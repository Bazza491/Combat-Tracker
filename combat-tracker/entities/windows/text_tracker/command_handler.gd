extends Resource
class_name CommandHandler

@export_storage var encounter: CombatEncounter


func _init(encounter_in: CombatEncounter) -> void:
	encounter = encounter_in


func handle_command(cmd: TextTracker.Command, args: Array[String]):
	match cmd:
		TextTracker.Command.NONE:
			pass
		TextTracker.Command.DAMAGE:
			_deal_damage(args)


func _deal_damage(args: Array[String]) -> void:
	var target: Entity = encounter.find_closest_label(args[0])
	var dmg: int = args[0].to_int()
	var type_str: String = Text.closest_match(
		Damage.TYPE_TEXT.values(), 
		args[1]
		)
	var type: Damage.Type = Damage.TYPE_TEXT.find_key(type_str)
	if not type: type = Damage.Type.NONE
	
	encounter.entities[target].damage(dmg, type)
	#TODO: Damage Types!!
