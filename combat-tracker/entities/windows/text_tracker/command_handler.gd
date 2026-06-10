extends Resource
class_name CommandHandler

const DEFAULT_MAX_HP: int = 10
const DEFAULT_AC: int = 10

@export_storage var encounter: CombatEncounter


func _init(encounter_in: CombatEncounter) -> void:
	assert(encounter_in != null, "CommandHandler needs a CombatEncounter.")
	encounter = encounter_in


## Parses and runs a text tracker command against the assigned combat encounter.
func handle_command(command: TextTracker.Command, args: Array[String]) -> void:
	match command:
		TextTracker.Command.NONE:
			push_warning("Unknown command.")
		TextTracker.Command.DAMAGE:
			_damage_closest_entity(args)
		TextTracker.Command.HEAL:
			_heal_closest_entity(args)
		TextTracker.Command.ADD_ENEMY:
			_add_enemy(args)
		TextTracker.Command.CLEAR:
			encounter.clear_entities()
		TextTracker.Command.SET_TURNS_LIST, \
		TextTracker.Command.ADD_PLAYER_AT_INITIATIVE, \
		TextTracker.Command.SKIP_TO_INITIATIVE:
			push_warning("Turn commands are not implemented yet.")


func _damage_closest_entity(args: Array[String]) -> void:
	if not _has_target_and_amount(args, "Damage"):
		return
	
	if not encounter.damage_closest_label(
		args[0],
		_parse_amount(args[1]),
		_parse_damage_type(args[2]) if args.size() > 2 else Damage.Type.NONE
		):
		push_warning("No entity found to damage.")

func _heal_closest_entity(args: Array[String]) -> void:
	if not _has_target_and_amount(args, "Heal"):
		return
	
	if not encounter.heal_closest_label(args[0], _parse_amount(args[1])):
		push_warning("No entity found to heal.")

func _add_enemy(args: Array[String]) -> void:
	if args.is_empty():
		push_warning("Enemy command needs a name.")
		return
	
	var max_hp: int = DEFAULT_MAX_HP
	var ac: int = DEFAULT_AC
	var quantity: int = 1
	var parse_mode: Damage.Vulnerability = Damage.Vulnerability.NONE
	var vulnerabilities: Dictionary[Damage.Type, Damage.Vulnerability] = {}
	
	for index in range(1, args.size()):
		match args[index].to_lower():
			"res", "resistant", "resistance":
				parse_mode = Damage.Vulnerability.RESISTANT
			"vuln", "vulnerable", "vulnerability":
				parse_mode = Damage.Vulnerability.VULNERABLE
			_:
				if _is_integer_argument_with_suffix(args[index], "hp"):
					max_hp = _parse_integer_argument_with_suffix(args[index], "hp")
				elif _is_integer_argument_with_suffix(args[index], "ac"):
					ac = _parse_integer_argument_with_suffix(args[index], "ac")
				elif _is_integer_argument_with_prefix(args[index], "x"):
					quantity = _parse_integer_argument_with_prefix(args[index], "x")
				elif parse_mode != Damage.Vulnerability.NONE:
					_add_vulnerability(vulnerabilities, args[index], parse_mode)
	
	encounter.add_enemy(args[0], max_hp, ac, vulnerabilities, quantity)


func _has_target_and_amount(args: Array[String], command_name: String) -> bool:
	if args.size() >= 2:
		return true
	
	push_warning("%s command needs a target and an amount." % command_name)
	return false

func _parse_amount(text: String) -> int:
	if text.is_valid_int():
		return text.to_int()
	
	var rolled_amount: int = Dice.roll_notation(text)
	if rolled_amount != -1:
		return rolled_amount
	
	push_warning("Could not parse amount: %s" % text)
	return 0

func _parse_damage_type(text: String) -> Damage.Type:
	var type_names: Array[String] = []
	type_names.assign(Damage.TYPE_TEXT.values())
	
	var matched_type: Variant = Damage.TYPE_TEXT.find_key(
		Text.closest_match(type_names, text)
		)
	if matched_type == null:
		return Damage.Type.NONE
	
	return matched_type

func _add_vulnerability(
	vulnerabilities: Dictionary[Damage.Type, Damage.Vulnerability],
	type_text: String,
	parse_mode: Damage.Vulnerability
	) -> void:
	var type: Damage.Type = _parse_damage_type(type_text)
	if type == Damage.Type.NONE:
		return
	
	vulnerabilities[type] = parse_mode

func _is_integer_argument_with_suffix(text: String, suffix: String) -> bool:
	return text.to_lower().ends_with(suffix) \
		and text.substr(0, text.length() - suffix.length()).is_valid_int()

func _parse_integer_argument_with_suffix(text: String, suffix: String) -> int:
	return text.substr(0, text.length() - suffix.length()).to_int()

func _is_integer_argument_with_prefix(text: String, prefix: String) -> bool:
	return text.to_lower().begins_with(prefix) \
		and text.substr(prefix.length()).is_valid_int()

func _parse_integer_argument_with_prefix(text: String, prefix: String) -> int:
	return text.substr(prefix.length()).to_int()
